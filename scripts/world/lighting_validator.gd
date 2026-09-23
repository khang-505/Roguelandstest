# scripts/world/lighting_validator.gd
class_name LightingValidator
extends Resource

## Quality Score Engine evaluating Planetary Ambient Lighting Profiles, Light Registration, and Shadow Parameters.

static func validate_lighting_system() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var ctrl_script = load("res://scripts/world/dynamic_lighting_controller.gd")
	if not ctrl_script:
		warnings.append("DynamicLightingController script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	var ctrl = ctrl_script.new()

	# 1. 4 Ambient Lighting Profiles (30 Points)
	var profiles = ctrl_script.AMBIENT_PROFILES
	if profiles.size() == 4:
		total_score += 30.0
		details["profiles_score"] = 30.0
	else:
		warnings.append("Expected 4 ambient lighting profiles in catalog")

	# 2. Ambient Profile Switching (25 Points)
	var switched = ctrl.set_ambient_profile("cryo_blue")
	var data = ctrl.get_active_profile_data()

	if switched and data.get("energy") == 0.5 and ctrl.active_profile == "cryo_blue":
		total_score += 25.0
		details["switching_score"] = 25.0
	else:
		warnings.append("Ambient profile switching failed")

	# 3. Light Source Registration (25 Points)
	var light = ctrl.register_light_source("torch_01", Vector2(100, 200), Color.YELLOW, 1.5)
	if ctrl.registered_lights.size() == 1 and light.get("light_id") == "torch_01":
		total_score += 25.0
		details["registration_score"] = 25.0
	else:
		warnings.append("Light source registration check failed")

	# 4. Unknown Profile Guard (20 Points)
	var bad_switch = ctrl.set_ambient_profile("non_existent_profile")
	if not bad_switch and ctrl.active_profile == "cryo_blue":
		total_score += 20.0
		details["unknown_guard_score"] = 20.0
	else:
		warnings.append("Unknown profile guard failed")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
