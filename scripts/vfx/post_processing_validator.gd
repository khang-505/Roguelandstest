# scripts/vfx/post_processing_validator.gd
class_name PostProcessingValidator
extends Resource

## Quality Score Engine evaluating Post-Processing Profiles, Bloom, Vignette, Chromatic Aberration, and Profile Transitions.

static func validate_post_processing() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var ctrl_script = load("res://scripts/vfx/post_processing_controller.gd")
	if not ctrl_script:
		warnings.append("PostProcessingController script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	var ctrl = ctrl_script.new()

	# 1. 4 Post-Processing Profiles (30 Points)
	var profiles = ctrl_script.PROFILES
	if profiles.size() == 4:
		total_score += 30.0
		details["profiles_score"] = 30.0
	else:
		warnings.append("Expected 4 post-processing profiles in catalog")

	# 2. Profile Application & Settings Fetching (25 Points)
	var applied = ctrl.apply_profile("void_shadow")
	var settings = ctrl.get_active_settings()

	if applied and settings.get("bloom_intensity") == 0.60 and settings.get("vignette_intensity") == 0.50:
		total_score += 25.0
		details["application_score"] = 25.0
	else:
		warnings.append("Profile application & settings check failed")

	# 3. Chromatic Aberration & Saturation Specs (25 Points)
	if settings.get("chromatic_aberration") == 0.12 and settings.get("color_saturation") == 0.85:
		total_score += 25.0
		details["spec_score"] = 25.0
	else:
		warnings.append("Chromatic aberration & saturation specs mismatch")

	# 4. Unknown Profile Guard (20 Points)
	var bad_apply = ctrl.apply_profile("non_existent_profile")
	if not bad_apply and ctrl.active_profile_id == "void_shadow":
		total_score += 20.0
		details["unknown_guard_score"] = 20.0
	else:
		warnings.append("Unknown profile application guard failed")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
