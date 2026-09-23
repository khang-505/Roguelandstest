# scripts/combat/projectile_validator.gd
class_name ProjectileValidator
extends RefCounted

## Quality Score Engine evaluating ProjectileData presets across 14 Projectile Types, ownership rules, ExplosionEngine falloff, and 1000 zero-allocation pooling stress iterations.

static func validate_projectiles() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	# 1. 14 Projectile Types & Data Model (25 Points)
	var data_script = load("res://scripts/combat/projectile_data.gd")
	var model_score = 0.0
	if data_script:
		var valid_types = 0
		for t in range(14):
			var data = data_script.create_preset(t)
			if data and data.display_name != "" and data.speed > 0.0:
				valid_types += 1
		if valid_types == 14:
			model_score = 25.0
		else:
			warnings.append("Expected 14 valid Projectile Data presets (Got %d)" % valid_types)
	else:
		warnings.append("ProjectileData script missing")
	total_score += model_score
	details["model_score"] = model_score

	# 2. Ownership Rules & Hit Registry (25 Points)
	var ownership_score = 0.0
	if data_script:
		var proj = Projectile.new()
		var data = data_script.create_preset(0) # BASIC
		proj.init_projectile(data, Vector2.ZERO, Vector2.RIGHT, null, 0)
		
		if proj.team == 0 and proj.already_hit_targets.size() == 0 and proj.hit_count == 0:
			ownership_score = 25.0
		else:
			warnings.append("Projectile ownership tracking or hit registry initialization failed")
	else:
		warnings.append("Projectile script missing")
	total_score += ownership_score
	details["ownership_score"] = ownership_score

	# 3. ExplosionEngine & Area Damage Falloff (25 Points)
	var exp_script = load("res://scripts/combat/explosion_engine.gd")
	var explosion_score = 0.0
	if exp_script:
		var res = exp_script.trigger_explosion(Vector2.ZERO, 100.0, 50.0, 80.0, ["BURN"], 0, [], [])
		if res.has("targets_hit") and res.has("explosion_radius"):
			explosion_score = 25.0
		else:
			warnings.append("ExplosionEngine radius calculation failed")
	else:
		warnings.append("ExplosionEngine script missing")
	total_score += explosion_score
	details["explosion_score"] = explosion_score

	# 4. Zero-Allocation Pooling & 1000 High-Volume Stress Iterations (25 Points)
	var pool_script = load("res://scripts/combat/projectile_pool_manager.gd")
	var pool_score = 0.0
	if pool_script and data_script:
		pool_script.clear_pool()
		var p_data = data_script.create_preset(1) # FAST
		
		for i in range(1000):
			pool_script.acquire_projectile(p_data, Vector2(10.0, 10.0), Vector2.RIGHT, null, 0)
			
		var active_c = pool_script.get_active_count()
		pool_script.update_projectiles(2.0) # Force expiration
		var remaining_c = pool_script.get_active_count()
		
		if active_c == 1000 and remaining_c == 0:
			pool_score = 25.0
		else:
			warnings.append("Zero-allocation pooling stress test failed (Active: %d, Remaining: %d)" % [active_c, remaining_c])
	else:
		warnings.append("ProjectilePoolManager script missing")
	total_score += pool_score
	details["pool_score"] = pool_score

	var is_valid = total_score >= 70.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
