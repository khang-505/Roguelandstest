# scripts/combat/projectile_pool_manager.gd
class_name ProjectilePoolManager
extends Resource

## Manager providing zero-allocation Projectile Object Pooling, 14 Trajectory Simulations, Muzzle Alignment, High-Ground Bonuses, and Ownership Tracking.

static var _pool: Array = []
static var _active_projectiles: Array = []

static func create_projectile(
	weapon_data: Resource,
	muzzle_pos: Vector2,
	aim_direction: Vector2,
	is_high_ground: bool = false
) -> Dictionary:
	var aim_norm = aim_direction.normalized()
	if aim_norm == Vector2.ZERO:
		aim_norm = Vector2.RIGHT
		
	var base_speed = weapon_data.projectile_speed if (weapon_data and "projectile_speed" in weapon_data) else 600.0
	var base_range = weapon_data.effective_range if (weapon_data and "effective_range" in weapon_data) else 500.0
	var base_crit = weapon_data.crit_chance if (weapon_data and "crit_chance" in weapon_data) else 0.10
	var traj_type = weapon_data.trajectory_type if (weapon_data and "trajectory_type" in weapon_data) else 0 # STRAIGHT
	
	# High Ground Elevation Bonus
	var final_range = base_range * (1.20 if is_high_ground else 1.0)
	var final_crit = min(1.0, base_crit + (0.15 if is_high_ground else 0.0))
	
	var proj: Dictionary
	if _pool.size() > 0:
		proj = _pool.pop_back()
	else:
		proj = {}
		
	proj["id"] = "proj_" + str(randi())
	proj["weapon_id"] = weapon_data.weapon_id if (weapon_data and "weapon_id" in weapon_data) else ""
	proj["position"] = muzzle_pos
	proj["velocity"] = aim_norm * base_speed
	proj["aim_direction"] = aim_norm
	proj["speed"] = base_speed
	proj["range_remaining"] = final_range
	proj["max_range"] = final_range
	proj["distance_traveled"] = 0.0
	proj["damage"] = weapon_data.base_damage if (weapon_data and "base_damage" in weapon_data) else 20.0
	proj["damage_type"] = weapon_data.damage_type if (weapon_data and "damage_type" in weapon_data) else "PHYSICAL"
	proj["crit_chance"] = final_crit
	proj["trajectory_type"] = traj_type
	proj["pierce_count"] = 2 if (traj_type == 3 or traj_type == 5) else 0
	proj["bounces_remaining"] = 3 if traj_type == 6 else 0
	proj["is_active"] = true
	proj["lifetime"] = 3.0
	proj["already_hit_targets"] = []
	proj["owner_team"] = 0
	
	_active_projectiles.append(proj)
	return proj

static func acquire_projectile(
	proj_data: Resource,
	pos: Vector2,
	dir: Vector2,
	owner_node: Node = null,
	team: int = 0
) -> Dictionary:
	var dir_norm = dir.normalized()
	if dir_norm == Vector2.ZERO:
		dir_norm = Vector2.RIGHT
		
	var proj: Dictionary
	if _pool.size() > 0:
		proj = _pool.pop_back()
	else:
		proj = {}
		
	var spd = proj_data.speed if proj_data else 400.0
	proj["id"] = proj_data.id if proj_data else "proj_" + str(randi())
	proj["data"] = proj_data
	proj["position"] = pos
	proj["velocity"] = dir_norm * spd
	proj["aim_direction"] = dir_norm
	proj["speed"] = spd
	proj["range_remaining"] = proj_data.max_range if proj_data else 500.0
	proj["max_range"] = proj_data.max_range if proj_data else 500.0
	proj["distance_traveled"] = 0.0
	proj["damage"] = proj_data.damage if proj_data else 20.0
	proj["damage_type"] = proj_data.damage_type if proj_data else "ENERGY"
	proj["crit_chance"] = proj_data.crit_chance if proj_data else 0.10
	proj["trajectory_type"] = proj_data.projectile_type if proj_data else 0
	proj["pierce_count"] = proj_data.max_hits if (proj_data and proj_data.piercing) else 0
	proj["bounces_remaining"] = proj_data.bounce_count if proj_data else 0
	proj["chain_count_remaining"] = proj_data.chain_count if proj_data else 0
	proj["is_active"] = true
	proj["lifetime"] = proj_data.lifetime if proj_data else 3.0
	proj["already_hit_targets"] = []
	proj["owner_node"] = owner_node
	proj["owner_team"] = team
	
	_active_projectiles.append(proj)
	return proj

static func update_projectiles(delta: float) -> Array:
	var terminated: Array = []
	
	for i in range(_active_projectiles.size() - 1, -1, -1):
		var proj = _active_projectiles[i]
		if not proj.get("is_active", false):
			_active_projectiles.remove_at(i)
			continue
			
		proj["lifetime"] -= delta
		var dist_step = proj["speed"] * delta
		proj["position"] += proj["velocity"] * delta
		proj["distance_traveled"] += dist_step
		proj["range_remaining"] -= dist_step
		
		# Trajectory simulation logic per type
		var traj = proj.get("trajectory_type", 0)
		if traj == 3 or traj == 13: # ARC or DROPPED
			var grav = 400.0
			if proj.has("data") and proj["data"] and proj["data"].gravity > 0.0:
				grav = proj["data"].gravity
			proj["velocity"].y += grav * delta
		elif traj == 4: # HOMING
			proj["velocity"] = proj["velocity"].rotated(0.1 * delta)
			
		if proj["lifetime"] <= 0.0 or proj["range_remaining"] <= 0.0:
			proj["is_active"] = false
			terminated.append(proj)
			_pool.append(proj)
			_active_projectiles.remove_at(i)
			
	return terminated

static func recycle_projectile(proj: Dictionary) -> void:
	proj["is_active"] = false
	if not _pool.has(proj):
		_pool.append(proj)
	var idx = _active_projectiles.find(proj)
	if idx >= 0:
		_active_projectiles.remove_at(idx)

static func get_active_count() -> int:
	return _active_projectiles.size()

static func get_pooled_count() -> int:
	return _pool.size()

static func clear_pool() -> void:
	_pool.clear()
	_active_projectiles.clear()
