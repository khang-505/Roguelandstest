# scripts/vfx/shake_validator.gd
class_name ShakeValidator
extends Resource

## Quality Score Engine evaluating Camera Shake Trauma, Decay Processing, Offset Scaling, and Hit Freeze.

static func validate_shake_system() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var ctrl_script = load("res://scripts/vfx/camera_shake_controller.gd")
	if not ctrl_script:
		warnings.append("CameraShakeController script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	var ctrl = ctrl_script.new()

	# 1. Trauma Accumulation & Cap (30 Points)
	ctrl.add_trauma(0.7)
	ctrl.add_trauma(0.5) # Total 1.2 -> capped at 1.0

	if ctrl.trauma == 1.0:
		total_score += 30.0
		details["trauma_cap_score"] = 30.0
	else:
		warnings.append("Trauma accumulation cap check failed")

	# 2. Offset Calculation Curve (25 Points)
	ctrl.trauma = 0.5 # trauma^2 = 0.25
	var offset = ctrl.get_shake_offset(1.0) # max_offset (16, 12) * 0.25 = (4, 3)

	if is_equal_approx(offset.x, 4.0) and is_equal_approx(offset.y, 3.0):
		total_score += 25.0
		details["offset_curve_score"] = 25.0
	else:
		warnings.append("Shake offset exponential curve check failed")

	# 3. Decay Processing (25 Points)
	ctrl.trauma = 0.5
	ctrl.process_decay(0.5) # decay = 0.8 * 0.5 = 0.4 -> trauma becomes 0.1

	if is_equal_approx(ctrl.trauma, 0.1):
		total_score += 25.0
		details["decay_score"] = 25.0
	else:
		warnings.append("Trauma decay processing failed")

	# 4. Hit Freeze Frame Emission (20 Points)
	var freeze_triggered = false
	ctrl.freeze_frame_started.connect(func(_dur, _scale): freeze_triggered = true)
	ctrl.trigger_hit_freeze(0.05, 0.1)

	if freeze_triggered and is_equal_approx(Engine.time_scale, 0.1):
		total_score += 20.0
		details["freeze_frame_score"] = 20.0
		Engine.time_scale = 1.0 # Reset back
	else:
		warnings.append("Hit freeze frame emission check failed")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
