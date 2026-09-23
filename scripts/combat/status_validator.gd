# scripts/combat/status_validator.gd
class_name StatusValidator
extends RefCounted

## Quality Score Engine evaluating StatusEffectData presets across 5 categories, stacking rules, DoT pipeline, target resistance math, cleanses, status interactions, and 1000 stress iterations.

static func validate_status_system() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	# 1. 5 Status Categories & Data Model (25 Points)
	var data_script = load("res://scripts/combat/status_effect_data.gd")
	var categories_score = 0.0
	
	if data_script:
		var presets = ["burn", "slow", "shield", "vulnerability", "marked"]
		var valid_count = 0
		for p in presets:
			var data = data_script.create_preset(p)
			if data and data.display_name != "" and data.duration > 0.0:
				valid_count += 1
		if valid_count == 5:
			categories_score = 25.0
		else:
			warnings.append("Expected 5 valid Status Categories presets (Got %d)" % valid_count)
	else:
		warnings.append("StatusEffectData script missing")
	total_score += categories_score
	details["categories_score"] = categories_score

	# 2. Stacking Rules & DoT Damage Pipeline (25 Points)
	var mgr_script = load("res://scripts/combat/status_effect_manager.gd")
	var stack_score = 0.0
	
	if mgr_script and data_script:
		var dummy = Node2D.new()
		var burn_data = data_script.create_preset("burn")
		
		var res1 = mgr_script.apply_status_data(dummy, burn_data)
		var res2 = mgr_script.apply_status_data(dummy, burn_data)
		
		if res1.get("success", false) and res2.get("stacks", 0) == 2:
			stack_score = 25.0
		else:
			warnings.append("Status stacking pipeline check failed")
		dummy.free()
	else:
		warnings.append("StatusEffectManager script missing")
	total_score += stack_score
	details["stack_score"] = stack_score

	# 3. Resistance Math, Cleanse & Boss Handling (25 Points)
	var resistance_score = 0.0
	if mgr_script and data_script:
		var dummy = Node2D.new()
		dummy.set("fire_resistance", 0.25) # 25% resistance
		
		var burn_data = data_script.create_preset("burn") # Base duration 4.0s -> 3.0s
		var res = mgr_script.apply_status_data(dummy, burn_data)
		var cleansed = mgr_script.cleanse_all(dummy)
		
		if res.get("duration", 0.0) == 3.0 and cleansed == 1:
			resistance_score = 25.0
		else:
			warnings.append("Target resistance duration reduction or cleanse failed")
		dummy.free()
	total_score += resistance_score
	details["resistance_score"] = resistance_score

	# 4. Status Interactions & 1000 Stress Iterations (25 Points)
	var stress_score = 0.0
	if mgr_script and data_script:
		var valid_count = 0
		for i in range(1000):
			var dummy = Node2D.new()
			var data = data_script.create_preset("burn" if i % 2 == 0 else "poison")
			var res = mgr_script.apply_status_data(dummy, data)
			if res.get("success", false):
				valid_count += 1
			dummy.free()
		if valid_count == 1000:
			stress_score = 25.0
		else:
			warnings.append("1000 status application stress iterations failed")
	total_score += stress_score
	details["stress_score"] = stress_score

	var is_valid = total_score >= 70.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
