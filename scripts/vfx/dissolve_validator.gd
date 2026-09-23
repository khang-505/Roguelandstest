# scripts/vfx/dissolve_validator.gd
class_name DissolveValidator
extends Resource

## Quality Score Engine evaluating Dissolve Progress Calculations, Reverse Materialization, and Completion Signals.

static func validate_dissolve_system() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var ctrl_script = load("res://scripts/vfx/dissolve_effect_controller.gd")
	if not ctrl_script:
		warnings.append("DissolveEffectController script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	var ctrl = ctrl_script.new()
	var dummy = Node2D.new()

	# 1. Start Dissolve (30 Points)
	var start_res = ctrl.start_dissolve(dummy, 1.0, false)
	if start_res.get("success", false) and ctrl.active_dissolves.size() == 1:
		total_score += 30.0
		details["start_score"] = 30.0
	else:
		warnings.append("Start dissolve check failed")

	# 2. Process Dissolve Progress (25 Points)
	ctrl.process_dissolves(0.5) # 0.5s / 1.0s -> 0.5 progress
	var info = ctrl.active_dissolves[0] if ctrl.active_dissolves.size() > 0 else {}

	if is_equal_approx(info.get("progress", 0.0), 0.5):
		total_score += 25.0
		details["progress_score"] = 25.0
	else:
		warnings.append("Dissolve progress calculation failed")

	# 3. Completion & Signal Emission (25 Points)
	var completed = false
	ctrl.dissolve_completed.connect(func(_target): completed = true)
	ctrl.process_dissolves(0.6) # Total 1.1s > 1.0s -> Completed

	if completed and ctrl.active_dissolves.size() == 0:
		total_score += 25.0
		details["completion_score"] = 25.0
	else:
		warnings.append("Dissolve completion signal check failed")

	# 4. Null Target Guard (20 Points)
	var null_res = ctrl.start_dissolve(null, 1.0)
	if not null_res.get("success", true) and null_res.get("reason") == "invalid_target":
		total_score += 20.0
		details["null_guard_score"] = 20.0
	else:
		warnings.append("Null target guard failed")

	dummy.free()
	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
