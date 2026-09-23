# scripts/ui/input_remapping_validator.gd
class_name InputRemappingValidator
extends Resource

## Quality Score Engine evaluating Input Action Catalog, Key Remapping, Conflict Detection, and Default Reset.

static func validate_input_remapping() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var mgr_script = load("res://scripts/ui/input_remapping_manager.gd")
	if not mgr_script:
		warnings.append("InputRemappingManager script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	var mgr = mgr_script.new()

	# 1. 10 Default Action Mappings (30 Points)
	var defaults = mgr_script.DEFAULT_BINDINGS
	if defaults.size() == 10:
		total_score += 30.0
		details["defaults_score"] = 30.0
	else:
		warnings.append("Expected 10 default action keybindings in catalog")

	# 2. Action Remapping (25 Points)
	var remap_res = mgr.remap_action("dash", "key", KEY_C) # Remap DASH to C
	var binding = mgr.get_binding("dash")

	if remap_res.get("success", false) and binding.get("code") == KEY_C:
		total_score += 25.0
		details["remap_score"] = 25.0
	else:
		warnings.append("Action remapping check failed")

	# 3. Conflict Detection Guard (25 Points)
	# Try to remap "jump" to KEY_C which is already bound to "dash"
	var conflict_res = mgr.remap_action("jump", "key", KEY_C)
	if not conflict_res.get("success", true) and conflict_res.get("reason") == "conflict_detected" and conflict_res.get("conflicting_action") == "dash":
		total_score += 25.0
		details["conflict_guard_score"] = 25.0
	else:
		warnings.append("Conflict detection guard failed")

	# 4. Reset to Defaults (20 Points)
	mgr.reset_to_defaults()
	var reset_dash = mgr.get_binding("dash")
	if reset_dash.get("code") == KEY_SHIFT:
		total_score += 20.0
		details["reset_score"] = 20.0
	else:
		warnings.append("Reset to defaults failed")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
