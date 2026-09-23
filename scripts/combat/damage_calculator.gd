# scripts/combat/damage_calculator.gd
class_name DamageCalculator
extends Resource

## Centralized Source of Truth Damage Engine computing base damage, conditional critical rolls, elemental affinity matrices, armor/resistance penetration, safeguards, and hit reactions.

enum DamageType {
	PHYSICAL,
	ENERGY,
	FIRE,
	ICE,
	ELECTRIC,
	POISON,
	EXPLOSIVE,
	VOID,
	TRUE
}

# Elemental Advantage Matrix (Attacker Element -> Target Element -> Multiplier)
static var ELEMENT_MATRIX: Dictionary = {
	"FIRE": {"ICE": 1.5, "FIRE": 0.5, "POISON": 1.2},
	"ICE": {"FIRE": 1.2, "ELECTRIC": 1.4, "ICE": 0.5},
	"ELECTRIC": {"ENERGY": 1.5, "PHYSICAL": 1.2, "ELECTRIC": 0.5},
	"POISON": {"PHYSICAL": 1.4, "POISON": 0.5},
	"EXPLOSIVE": {"PHYSICAL": 1.5, "ENERGY": 1.2},
	"ENERGY": {"ELECTRIC": 1.4, "ENERGY": 0.5},
	"VOID": {"PHYSICAL": 1.3, "ENERGY": 1.3, "FIRE": 1.3, "ICE": 1.3, "ELECTRIC": 1.3, "POISON": 1.3, "EXPLOSIVE": 1.3},
	"TRUE": {},
	"PHYSICAL": {}
}

## Core Damage Pipeline processing a DamageRequest object
static func process_damage_request(req: Resource) -> Dictionary:
	if not req:
		return _empty_result()

	# 1. Base Damage Safeguards (Prevent NaN, Infinity, negative values)
	var raw_base = req.base_damage
	if is_nan(raw_base) or is_inf(raw_base) or raw_base < 0.0:
		raw_base = 0.0
		
	# 2. Conditional Critical Roll & Multiplier
	var eff_crit = req.critical_chance + req.critical_bonus
	
	if req.get_flag("is_full_health_target"): eff_crit += 0.15
	if req.get_flag("is_marked_target"): eff_crit += 0.25
	if req.get_flag("is_frozen_target"): eff_crit += 0.30
	if req.get_flag("is_rear_attack"): eff_crit += 0.20
	if req.get_flag("is_after_dash"): eff_crit += 0.15
	
	eff_crit = clamp(eff_crit, 0.0, 1.0)
	var is_crit = req.get_flag("guaranteed_crit") or (randf() < eff_crit)
	var crit_mult = req.critical_multiplier if is_crit else 1.0

	# 3. Target Properties & Elemental Matrix
	var target_element = "NONE"
	var target_armor = 0.0
	var target_resistance = 0.0
	var target_vulnerability = 1.0
	var target_weight = 1.0
	
	if is_instance_valid(req.target):
		if "target_element" in req.target: target_element = str(req.target.target_element)
		if "armor" in req.target: target_armor = float(req.target.armor)
		if "resistance" in req.target: target_resistance = float(req.target.resistance)
		if "vulnerability" in req.target: target_vulnerability = float(req.target.vulnerability)
		if "weight" in req.target: target_weight = float(req.target.weight)

	var element_mult = 1.0
	var elem_upper = req.damage_type.to_upper()
	var target_elem_upper = target_element.to_upper()
	if ELEMENT_MATRIX.has(elem_upper) and ELEMENT_MATRIX[elem_upper].has(target_elem_upper):
		element_mult = ELEMENT_MATRIX[elem_upper][target_elem_upper]

	var raw_damage = raw_base * crit_mult * element_mult * target_vulnerability

	# 4. Defense, Armor & Resistance Mitigation
	var final_damage = raw_damage
	var armor_mitigated = 0.0
	var res_mitigated = 0.0

	if req.damage_type.to_upper() == "TRUE":
		# TRUE damage bypasses all armor and resistance
		final_damage = raw_damage
	else:
		var eff_armor = max(0.0, target_armor - req.armor_penetration)
		armor_mitigated = min(raw_damage, eff_armor)
		var post_armor_damage = max(0.0, raw_damage - eff_armor)
		
		var eff_res = clamp(target_resistance - req.resistance_penetration, -0.5, 0.90)
		res_mitigated = post_armor_damage * eff_res
		final_damage = max(1.0, post_armor_damage * (1.0 - eff_res))

	# 5. Final Safeguards & Overflow Clamping
	if is_nan(final_damage) or is_inf(final_damage):
		final_damage = 0.0
	final_damage = clamp(final_damage, 0.0, 999999.0)

	# 6. Hit Stop & Knockback Math
	var hit_stop_duration = 0.03
	var knockback_base = req.knockback if req.knockback > 0.0 else 120.0

	match req.attack_type:
		"MELEE_HEAVY":
			hit_stop_duration = 0.06
			knockback_base = max(knockback_base, 220.0)
		"ABILITY", "EXPLOSION":
			hit_stop_duration = 0.08
			knockback_base = max(knockback_base, 280.0)
		"ULTIMATE", "BOSS":
			hit_stop_duration = 0.10
			knockback_base = max(knockback_base, 350.0)

	if is_crit:
		hit_stop_duration += 0.02
		knockback_base *= 1.2

	var final_knockback = max(20.0, knockback_base / max(0.2, target_weight))

	# Notify Event Bus if present
	var bus_script = load("res://scripts/combat/damage_event_bus.gd")
	if bus_script:
		bus_script.dispatch_damage_resolved(req, int(final_damage), is_crit)

	return {
		"final_damage": int(final_damage),
		"damage": int(final_damage),
		"raw_damage": raw_damage,
		"is_crit": is_crit,
		"damage_type": req.damage_type,
		"element_multiplier": element_mult,
		"armor_mitigated": armor_mitigated,
		"resistance_mitigated": res_mitigated,
		"hit_stop_duration": hit_stop_duration,
		"knockback_force": final_knockback,
		"status_effects": req.status_effects
	}

## Legacy method signature for backwards compatibility
static func calculate_damage(
	base_damage: float,
	attack_type: String = "LIGHT",
	damage_type: String = "PHYSICAL",
	crit_chance: float = 0.10,
	crit_multiplier: float = 1.5,
	weapon_multiplier: float = 1.0,
	ability_multiplier: float = 1.0,
	target_armor: float = 0.0,
	target_element: String = "NONE",
	target_weight: float = 1.0,
	rng_seed: int = 0
) -> Dictionary:
	var req = DamageRequest.new(base_damage * weapon_multiplier * ability_multiplier, damage_type, attack_type, crit_chance, crit_multiplier)
	req.armor_penetration = 0.0
	var dummy_target = {"target_element": target_element, "armor": target_armor, "weight": target_weight}
	req.target = dummy_target
	return process_damage_request(req)

	var is_crit = (randf() < crit_chance)
	var crit_mult = crit_multiplier if is_crit else 1.0
	var raw = base_damage * weapon_multiplier * ability_multiplier * crit_mult
	var final_d = max(1.0, raw - target_armor)
	return {
		"damage": int(final_d),
		"final_damage": int(final_d),
		"raw_damage": raw,
		"is_crit": is_crit,
		"damage_type": damage_type,
		"element_multiplier": 1.0,
		"hit_stop_duration": 0.03,
		"knockback_force": 120.0
	}

static func _empty_result() -> Dictionary:
	return {
		"final_damage": 0,
		"damage": 0,
		"raw_damage": 0.0,
		"is_crit": false,
		"damage_type": "PHYSICAL",
		"element_multiplier": 1.0,
		"armor_mitigated": 0.0,
		"resistance_mitigated": 0.0,
		"hit_stop_duration": 0.0,
		"knockback_force": 0.0,
		"status_effects": []
	}
