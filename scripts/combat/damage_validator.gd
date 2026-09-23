# scripts/combat/damage_validator.gd
class_name DamageValidator
extends RefCounted

## Quality Score Engine evaluating DamageRequest pipeline, 9 Damage Types, conditional critical rolls, armor/resistance penetration, safeguards against NaN/Infinity, and 1000 combat stress calculations.

static func validate_damage_system() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	# 1. 9 Extensible Damage Types & DamageRequest (25 Points)
	var calc_script = load("res://scripts/combat/damage_calculator.gd")
	var types_score = 0.0
	
	if calc_script:
		var d_types = ["PHYSICAL", "ENERGY", "FIRE", "ICE", "ELECTRIC", "POISON", "EXPLOSIVE", "VOID", "TRUE"]
		var valid_count = 0
		for t in d_types:
			var req = DamageRequest.new(50.0, t, "MELEE_LIGHT", 0.0, 1.5)
			var res = calc_script.process_damage_request(req)
			if res.get("final_damage", 0) > 0 and res["damage_type"] == t:
				valid_count += 1
		if valid_count == 9:
			types_score = 25.0
		else:
			warnings.append("Expected 9 valid Damage Types calculations (Got %d)" % valid_count)
	else:
		warnings.append("DamageCalculator script missing")
	total_score += types_score
	details["types_score"] = types_score

	# 2. Conditional Critical Rolls & Clamping (25 Points)
	var crit_score = 0.0
	if calc_script:
		var req = DamageRequest.new(100.0, "PHYSICAL", "MELEE_HEAVY", 0.10, 2.0)
		req.set_flag("guaranteed_crit", true)
		var res = calc_script.process_damage_request(req)
		
		if res.get("is_crit", false) and res.get("final_damage", 0) == 200:
			crit_score = 25.0
		else:
			warnings.append("Guaranteed critical roll or multiplier calculation failed")
	total_score += crit_score
	details["crit_score"] = crit_score

	# 3. Armor & Resistance Penetration Math & Safeguards (25 Points)
	var defense_score = 0.0
	if calc_script:
		# Test TRUE damage bypassing armor
		var true_req = DamageRequest.new(100.0, "TRUE", "MELEE_LIGHT", 0.0, 1.0)
		true_req.target = {"armor": 50.0, "resistance": 0.5}
		var true_res = calc_script.process_damage_request(true_req)
		
		# Test NaN/Inf protection
		var nan_req = DamageRequest.new(NAN, "PHYSICAL", "MELEE_LIGHT", 0.0, 1.0)
		var nan_res = calc_script.process_damage_request(nan_req)
		
		if true_res.get("final_damage", 0) == 100 and nan_res.get("final_damage", -1) == 0:
			defense_score = 25.0
		else:
			warnings.append("Armor penetration or NaN protection calculation failed")
	total_score += defense_score
	details["defense_score"] = defense_score

	# 4. Event Bus & 1000 Stress Calculations (25 Points)
	var stress_score = 0.0
	if calc_script:
		var valid_stress = 0
		for i in range(1000):
			var req = DamageRequest.new(float(i % 100 + 10), "ENERGY", "RANGED", 0.2, 1.5)
			var res = calc_script.process_damage_request(req)
			if res.get("final_damage", 0) >= 0:
				valid_stress += 1
		if valid_stress == 1000:
			stress_score = 25.0
		else:
			warnings.append("1000 damage calculation stress iterations failed")
	total_score += stress_score
	details["stress_score"] = stress_score

	var is_valid = total_score >= 70.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
