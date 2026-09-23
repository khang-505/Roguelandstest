# scripts/ui/ui_transition_validator.gd
class_name UITransitionValidator
extends Resource

## Quality Score Engine evaluating UI Transitions, Fade, Slide, Scale-Bounce, and Completion Signals.

static func validate_ui_transitions() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var mgr_script = load("res://scripts/ui/ui_transition_manager.gd")
	if not mgr_script:
		warnings.append("UITransitionManager script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	var mgr = mgr_script.new()
	var dummy_control = Control.new()

	# 1. Transition In Initialization (30 Points)
	var in_res = mgr.transition_in(dummy_control, mgr_script.TransitionType.FADE, 0.5)
	if in_res.get("success", false) and mgr.active_transitions.size() == 1:
		total_score += 30.0
		details["in_init_score"] = 30.0
	else:
		warnings.append("Transition in initialization check failed")

	# 2. Progress Processing & Property Update (25 Points)
	mgr.process_transitions(0.25) # 0.25 / 0.5 = 0.5 progress
	if is_equal_approx(dummy_control.modulate.a, 0.5):
		total_score += 25.0
		details["progress_update_score"] = 25.0
	else:
		warnings.append("Transition progress property update failed")

	# 3. Completion Signal Emission (25 Points)
	var completed = false
	mgr.transition_completed.connect(func(_target): completed = true)
	mgr.process_transitions(0.3) # Total 0.55s > 0.5s -> Completed

	if completed and mgr.active_transitions.size() == 0:
		total_score += 25.0
		details["completion_signal_score"] = 25.0
	else:
		warnings.append("Transition completion signal emission failed")

	# 4. Null Control Guard (20 Points)
	var null_res = mgr.transition_in(null)
	if not null_res.get("success", true) and null_res.get("reason") == "invalid_target":
		total_score += 20.0
		details["null_guard_score"] = 20.0
	else:
		warnings.append("Null control guard failed")

	dummy_control.free()
	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
