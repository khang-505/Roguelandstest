# scripts/combat/hit_reaction_engine.gd
class_name HitReactionEngine
extends RefCounted

## Hit Reaction Engine calculating 12 Reaction Types, direction vectors, target weight mass scaling, wall bounce reflections, hitstop feedback, and boss recoil math.

const MASS_MAP: Dictionary = {
	0: 0.5,  # LIGHT
	1: 1.0,  # MEDIUM
	2: 2.0,  # HEAVY
	3: 4.0,  # MASSIVE
	4: 10.0  # BOSS
}

static func calculate_direction(source_pos: Vector2, target_pos: Vector2, attack_dir: Vector2 = Vector2.ZERO) -> Vector2:
	if attack_dir != Vector2.ZERO:
		return attack_dir.normalized()
	var dir = (target_pos - source_pos).normalized()
	if dir == Vector2.ZERO:
		return Vector2.RIGHT
	return dir

static func calculate_knockback_impulse(
	base_force: float,
	vert_force: float,
	direction: Vector2,
	target_weight_type: int = 1,
	is_crit: bool = false,
	target_resistance: float = 0.0
) -> Vector2:
	var mass_factor = MASS_MAP.get(target_weight_type, 1.0)
	
	# BOSS Target Handling (Small recoil impulse only, no physics launch)
	if target_weight_type == 4:
		var recoil_dir = direction if direction != Vector2.ZERO else Vector2.RIGHT
		return recoil_dir * (base_force * 0.10)

	var mass_mult = 1.0 / max(0.2, mass_factor * (1.0 + clamp(target_resistance, 0.0, 0.90)))
	var crit_mult = 1.25 if is_crit else 1.0

	var horiz_impulse = direction.x * base_force * mass_mult * crit_mult
	var vert_impulse = vert_force * mass_mult * crit_mult

	# Clamp to prevent extreme out-of-bounds launching
	horiz_impulse = clamp(horiz_impulse, -800.0, 800.0)
	vert_impulse = clamp(vert_impulse, -800.0, 800.0)

	return Vector2(horiz_impulse, vert_impulse)

static func calculate_wall_bounce(velocity: Vector2, wall_normal: Vector2) -> Dictionary:
	var norm = wall_normal.normalized()
	if norm == Vector2.ZERO:
		norm = Vector2.LEFT
		
	var bounce_vel = velocity.bounce(norm) * 0.50 # 50% velocity retention
	var impact_dmg = velocity.length() * 0.15 # 15% kinetic energy convert to wall bounce damage

	return {
		"is_wall_bounce": true,
		"bounce_velocity": bounce_vel,
		"impact_damage": impact_dmg,
		"wall_normal": norm
	}

static func calculate_hitstop_duration(reaction_type: int, is_crit: bool = false, is_boss: bool = false) -> float:
	var hitstop = 0.03
	
	match reaction_type:
		0: hitstop = 0.03 # LIGHT_HIT
		1, 3: hitstop = 0.06 # HEAVY_HIT, KNOCKBACK
		2, 5, 7: hitstop = 0.08 # STAGGER, LAUNCH, WALL_BOUNCE
		8, 9, 10: hitstop = 0.10 # INTERRUPT, STUN, FREEZE
		11: hitstop = 0.12 # DEATH
		
	if is_crit:
		hitstop += 0.02
	if is_boss:
		hitstop += 0.03

	return clamp(hitstop, 0.01, 0.15)

static func process_hit_reaction(
	source: Node,
	target: Node,
	reaction_data: Resource,
	attack_dir: Vector2 = Vector2.ZERO,
	is_crit: bool = false
) -> Dictionary:
	if not reaction_data:
		return _default_reaction()

	var s_pos = source.global_position if (source and source.has_method("get_global_position")) else Vector2.ZERO
	var t_pos = target.global_position if (target and target.has_method("get_global_position")) else Vector2.ZERO
	var dir = calculate_direction(s_pos, t_pos, attack_dir)

	var weight_type = 1 # MEDIUM default
	if target:
		if target.is_in_group("bosses") or (target.has_method("is_boss") and target.is_boss()):
			weight_type = 4 # BOSS
		elif "weight_type" in target:
			weight_type = int(target.weight_type)
		elif "weight" in target:
			var w = float(target.weight)
			if w >= 10.0: weight_type = 4
			elif w >= 4.0: weight_type = 3
			elif w >= 2.0: weight_type = 2
			elif w <= 0.6: weight_type = 0

	var target_res = float(target.knockback_resistance) if (target and "knockback_resistance" in target) else 0.0
	var impulse = calculate_knockback_impulse(
		reaction_data.force,
		reaction_data.vertical_force,
		dir,
		weight_type,
		is_crit,
		target_res
	)

	var is_boss_target = (weight_type == 4)
	var hitstop = calculate_hitstop_duration(reaction_data.reaction_type, is_crit, is_boss_target)

	return {
		"reaction_type": reaction_data.reaction_type,
		"impulse": impulse,
		"hit_stop_duration": hitstop,
		"stagger_duration": reaction_data.stagger_duration,
		"recovery_duration": reaction_data.recovery_duration,
		"airborne": reaction_data.airborne and not is_boss_target,
		"wall_bounce": reaction_data.wall_bounce and not is_boss_target,
		"target_weight_type": weight_type,
		"is_boss_recoil": is_boss_target,
		"can_interrupt": reaction_data.can_interrupt
	}

static func _default_reaction() -> Dictionary:
	return {
		"reaction_type": 0,
		"impulse": Vector2.ZERO,
		"hit_stop_duration": 0.03,
		"stagger_duration": 0.15,
		"recovery_duration": 0.10,
		"airborne": false,
		"wall_bounce": false,
		"target_weight_type": 1,
		"is_boss_recoil": false,
		"can_interrupt": true
	}
