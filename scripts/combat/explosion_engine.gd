# scripts/combat/explosion_engine.gd
class_name ExplosionEngine
extends RefCounted

## Area Damage Engine managing explosion radius falloff, knockback vectors, status effect application, and breakable object destruction.

static func trigger_explosion(
	center: Vector2,
	radius: float,
	base_damage: float,
	knockback_force: float = 100.0,
	status_effects: Array = [],
	owner_team: int = 0,
	targets: Array = [],
	breakables: Array = []
) -> Dictionary:
	var hits_count: int = 0
	var total_damage: float = 0.0
	var breakables_destroyed: int = 0
	var hit_records: Array = []

	if radius <= 0.0:
		return {"targets_hit": 0, "total_damage": 0.0, "breakables_destroyed": 0}

	# 1. Target Entity Damage & Knockback
	for target in targets:
		if not is_instance_valid(target):
			continue
			
		var target_pos = target.global_position if target.has_method("get_global_position") else target.position
		var dist = center.distance_to(target_pos)
		
		if dist <= radius:
			var falloff = clamp(1.0 - (dist / radius), 0.25, 1.0)
			var final_dmg = base_damage * falloff
			var knock_dir = (target_pos - center).normalized()
			if knock_dir == Vector2.ZERO:
				knock_dir = Vector2.UP
				
			# Calculate final damage through DamageCalculator if available
			var dmg_script = load("res://scripts/combat/damage_calculator.gd")
			if dmg_script:
				var calc_res = dmg_script.calculate_damage(final_dmg, 0.0, "FIRE", 0.0, 0.0)
				final_dmg = calc_res.get("final_damage", final_dmg)
				
			if target.has_method("take_damage"):
				target.take_damage(final_dmg)
				
			if target.has_method("apply_knockback"):
				target.apply_knockback(knock_dir * knockback_force * falloff)
				
			if target.has_method("apply_status_effect"):
				for status in status_effects:
					target.apply_status_effect(status, 3.0)
					
			hits_count += 1
			total_damage += final_dmg
			hit_records.append({"target": target, "damage": final_dmg, "distance": dist})

	# 2. Breakable Object Destruction
	for breakable in breakables:
		if not is_instance_valid(breakable):
			continue
			
		var b_pos = breakable.global_position if breakable.has_method("get_global_position") else breakable.position
		if center.distance_to(b_pos) <= radius:
			if breakable.has_method("destroy"):
				breakable.destroy()
				breakables_destroyed += 1
			elif breakable.has_method("take_damage"):
				breakable.take_damage(base_damage)
				breakables_destroyed += 1

	return {
		"targets_hit": hits_count,
		"total_damage": total_damage,
		"breakables_destroyed": breakables_destroyed,
		"hit_records": hit_records,
		"explosion_center": center,
		"explosion_radius": radius
	}
