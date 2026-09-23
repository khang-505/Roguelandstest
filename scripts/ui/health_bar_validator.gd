# scripts/ui/health_bar_validator.gd
class_name HealthBarValidator
extends Resource

## Quality Score Engine evaluating Health Bar Percentages, Shield Overlays, Stagger Calculations, and Death State Guards.

static func validate_health_bars() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var ctrl_script = load("res://scripts/ui/health_bar_controller.gd")
	if not ctrl_script:
		warnings.append("HealthBarController script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	var ctrl = ctrl_script.new()
	ctrl.max_hp = 200.0

	# 1. Health Percentage Calculation (30 Points)
	var hp_res = ctrl.update_health(150.0, 50.0) # 150/200 = 0.75 hp_pct, 50/200 = 0.25 shield_pct
	if is_equal_approx(hp_res.get("hp_pct", 0.0), 0.75) and is_equal_approx(hp_res.get("shield_pct", 0.0), 0.25):
		total_score += 30.0
		details["hp_pct_score"] = 30.0
	else:
		warnings.append("Health percentage calculation failed")

	# 2. Stagger Bar Progress & Trigger (25 Points)
	ctrl.max_stagger = 100.0
	var stagger_res = ctrl.update_stagger(100.0)

	if is_equal_approx(stagger_res.get("stagger_pct", 0.0), 1.0) and stagger_res.get("is_staggered", false):
		total_score += 25.0
		details["stagger_score"] = 25.0
	else:
		warnings.append("Stagger bar progress check failed")

	# 3. Death State Detection (25 Points)
	var dead_res = ctrl.update_health(0.0)
	if dead_res.get("is_dead", false) and dead_res.get("hp_pct") == 0.0:
		total_score += 25.0
		details["death_state_score"] = 25.0
	else:
		warnings.append("Death state detection failed")

	# 4. Over-damage Clamping Guard (20 Points)
	var over_res = ctrl.update_health(-50.0)
	if over_res.get("current_hp") == 0.0:
		total_score += 20.0
		details["clamp_guard_score"] = 20.0
	else:
		warnings.append("Over-damage clamping guard failed")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
