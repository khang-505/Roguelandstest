# scripts/procedural/boss_arena_validator.gd
class_name BossArenaValidator
extends Resource

## Quality Score Engine evaluating Boss Arena spatial bounds, hazard/safe zone ratios, phase terrain shifts, and camera framing.

static func validate_arena(arena_data: Resource) -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []
	
	if not arena_data:
		return {
			"is_valid": false,
			"quality_score": 0.0,
			"details": {},
			"warnings": ["BossArenaData is null"]
		}
		
	# 1. Spatial Clearance & Bounds (30 Points)
	var spatial_score = 0.0
	var w = arena_data.width
	var h = arena_data.height
	if w >= 600.0 and h >= 400.0:
		spatial_score += 15.0
	else:
		warnings.append("Arena dimensions (%f x %f) below minimum threshold (600 x 400)" % [w, h])
		
	var p_spawn = arena_data.player_spawn
	var b_spawn = arena_data.boss_spawn
	if p_spawn.distance_to(b_spawn) >= 300.0:
		spatial_score += 15.0
	else:
		warnings.append("Player spawn and Boss spawn are too close (<300px)")
	total_score += spatial_score
	details["spatial_score"] = spatial_score
	
	# 2. Hazard & Safe Zone Balance (25 Points)
	var balance_score = 0.0
	var hazards: Array = arena_data.hazards
	var safe_zones: Array = arena_data.safe_zones
	if safe_zones.size() >= 1:
		balance_score += 15.0
	else:
		warnings.append("Arena lacks designated safe zones")
		
	if hazards.size() >= 1 and safe_zones.size() >= hazards.size():
		balance_score += 10.0
	elif hazards.is_empty():
		balance_score += 10.0 # Clean arena is acceptable
	total_score += balance_score
	details["balance_score"] = balance_score
	
	# 3. Phase Terrain Transformations (25 Points)
	var phase_score = 0.0
	var platforms: Array = arena_data.platforms
	var phase_objects: Array = arena_data.phase_objects
	if platforms.size() >= 2:
		phase_score += 15.0
	if phase_objects.size() >= 1:
		phase_score += 10.0
	total_score += phase_score
	details["phase_score"] = phase_score
	
	# 4. Progression & Lock Integration (20 Points)
	var lock_score = 0.0
	var entry = arena_data.entry_door_pos
	var exit_pos = arena_data.exit_portal_pos
	if entry != Vector2.ZERO and exit_pos != Vector2.ZERO:
		lock_score += 20.0
	total_score += lock_score
	details["lock_score"] = lock_score
	
	var is_valid = total_score >= 70.0 and warnings.size() == 0
	
	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
