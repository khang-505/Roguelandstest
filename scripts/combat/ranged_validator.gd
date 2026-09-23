# scripts/combat/ranged_validator.gd
class_name RangedValidator
extends Resource

## Quality Score Engine evaluating Ranged Weapon Archetypes, Trajectories, Ammo/Heat Controllers, Pooling, and High-Ground Positioning.

static func validate_ranged() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []
	
	# 1. Ranged Weapon Archetypes (30 Points)
	var cat_script = load("res://scripts/combat/ranged_weapon_catalog.gd")
	var archetype_score = 0.0
	if cat_script:
		var ids = cat_script.get_all_weapon_ids()
		if ids.size() >= 8:
			archetype_score = 30.0
		else:
			warnings.append("Expected 8 ranged weapon archetypes (Found %d)" % ids.size())
	else:
		warnings.append("RangedWeaponCatalog script not found")
	total_score += archetype_score
	details["archetype_score"] = archetype_score
	
	# 2. Projectile Trajectories & Pooling (25 Points)
	var pool_script = load("res://scripts/combat/projectile_pool_manager.gd")
	var pool_score = 0.0
	if pool_script and cat_script:
		var pistol = cat_script.get_weapon("sidearm_blaster")
		var proj = pool_script.create_projectile(pistol, Vector2(100.0, 100.0), Vector2.RIGHT, false)
		pool_script.update_projectiles(0.1)
		
		if proj.has("position") and proj["position"].x > 100.0:
			pool_score = 25.0
		else:
			warnings.append("Projectile simulation update failed")
		pool_script.clear_pool()
	else:
		warnings.append("ProjectilePoolManager script not found")
	total_score += pool_score
	details["pool_score"] = pool_score
	
	# 3. Ammo/Reload & Energy Heat Engine (25 Points)
	var ammo_script = load("res://scripts/combat/ranged_ammo_controller.gd")
	var ammo_score = 0.0
	if ammo_script and cat_script:
		var pistol = cat_script.get_weapon("sidearm_blaster")
		var ctrl = ammo_script.new(pistol)
		ctrl.consume_shot()
		
		var energy = cat_script.get_weapon("overcharge_laser")
		var e_ctrl = ammo_script.new(energy)
		e_ctrl.consume_shot()
		
		if ctrl.current_ammo == 11 and e_ctrl.current_heat > 0.0:
			ammo_score = 25.0
		else:
			warnings.append("Ammo consumption or energy heat tracking failed")
	else:
		warnings.append("RangedAmmoController script not found")
	total_score += ammo_score
	details["ammo_score"] = ammo_score
	
	# 4. Muzzle Alignment & High-Ground Bonus (20 Points)
	var positioning_score = 0.0
	if pool_script and cat_script:
		var rifle = cat_script.get_weapon("pulse_rifle")
		var ground_proj = pool_script.create_projectile(rifle, Vector2.ZERO, Vector2.RIGHT, false)
		var high_proj = pool_script.create_projectile(rifle, Vector2.ZERO, Vector2.RIGHT, true)
		
		if high_proj["max_range"] > ground_proj["max_range"] and high_proj["crit_chance"] > ground_proj["crit_chance"]:
			positioning_score = 20.0
		else:
			warnings.append("High Ground elevation range & crit bonus calculation failed")
		pool_script.clear_pool()
	total_score += positioning_score
	details["positioning_score"] = positioning_score
	
	var is_valid = total_score >= 70.0 and warnings.size() == 0
	
	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
