# scripts/combat/combat_validator.gd
class_name CombatValidator
extends Resource

## Quality Score Engine evaluating Real-time Combat Systems, Damage Centralization, Cancel Windows, Hit Stop, Combos, and Crowd Control.

static func validate_combat() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []
	
	# 1. Damage Engine Centralization & Type Matrix (30 Points)
	var calc_script = load("res://scripts/combat/damage_calculator.gd")
	var dmg_score = 0.0
	if calc_script:
		var calc_res = calc_script.calculate_damage(20.0, "LIGHT", "FIRE", 0.0, 1.5, 1.0, 1.0, 5.0, "ICE", 1.0, 12345)
		var dmg = calc_res.get("damage", 0)
		var elem_mult = calc_res.get("element_multiplier", 1.0)
		
		if elem_mult == 1.5 and dmg > 0:
			dmg_score = 30.0
		else:
			warnings.append("Elemental calculation mismatch: mult=%f, dmg=%d" % [elem_mult, dmg])
	else:
		warnings.append("DamageCalculator script not found")
	total_score += dmg_score
	details["damage_score"] = dmg_score
	
	# 2. Attack Lifecycles & Cancel Windows (25 Points)
	var fsm_script = load("res://scripts/combat/combat_state_machine.gd")
	var fsm_score = 0.0
	if fsm_script:
		var fsm = fsm_script.new()
		fsm.start_attack(0.1, 0.15, 0.2)
		var can_dash_startup = fsm.can_dash()
		fsm._on_state_timer_expired() # -> ATTACK_ACTIVE
		fsm._on_state_timer_expired() # -> ATTACK_RECOVERY
		var can_dash_recovery = fsm.can_dash()
		
		if not can_dash_startup and can_dash_recovery:
			fsm_score = 25.0
		else:
			warnings.append("Cancel window rule failed: startup_cancel=%s, recovery_cancel=%s" % [can_dash_startup, can_dash_recovery])
	else:
		warnings.append("CombatStateMachine script not found")
	total_score += fsm_score
	details["fsm_score"] = fsm_score
	
	# 3. Hit Stop & Knockback Math (25 Points)
	var feedback_score = 0.0
	if calc_script:
		var light_res = calc_script.calculate_damage(20.0, "LIGHT", "PHYSICAL", 0.0, 1.5, 1.0, 1.0, 0.0, "NONE", 1.0, 12345)
		var heavy_res = calc_script.calculate_damage(20.0, "HEAVY", "PHYSICAL", 0.0, 1.5, 1.0, 1.0, 0.0, "NONE", 1.0, 12345)
		
		var light_stop = light_res.get("hit_stop_duration", 0.0)
		var heavy_stop = heavy_res.get("hit_stop_duration", 0.0)
		
		if heavy_stop > light_stop and light_stop >= 0.03:
			feedback_score = 25.0
		else:
			warnings.append("Hit stop duration scaling failed: light=%f, heavy=%f" % [light_stop, heavy_stop])
	total_score += feedback_score
	details["feedback_score"] = feedback_score
	
	# 4. Combo Input Buffering & Crowd Control (20 Points)
	var combo_script = load("res://scripts/combat/combo_manager.gd")
	var combo_score = 0.0
	if combo_script:
		var combo = combo_script.new()
		var s1 = combo.request_attack(false)
		var s2 = combo.request_attack(false)
		var s3 = combo.request_attack(false)
		
		if s1.get("step") == 1 and s2.get("step") == 2 and s3.get("step") == 3 and s3.get("type") == "HEAVY":
			combo_score = 20.0
		else:
			warnings.append("Combo 3-step sequence failed")
	else:
		warnings.append("ComboManager script not found")
	total_score += combo_score
	details["combo_score"] = combo_score
	
	var is_valid = total_score >= 70.0 and warnings.size() == 0
	
	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
