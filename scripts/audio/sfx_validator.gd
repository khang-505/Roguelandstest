# scripts/audio/sfx_validator.gd
class_name SFXValidator
extends Resource

## Quality Score Engine evaluating Spatial Audio Attenuation, Pitch Randomization, Out-of-Range Cutoffs, and Surface Footstep Mapping.

static func validate_sfx_system() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var engine_script = load("res://scripts/audio/positional_sfx_engine.gd")
	if not engine_script:
		warnings.append("PositionalSFXEngine script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	var engine = engine_script.new()
	engine.max_audible_distance = 500.0

	# 1. Distance Attenuation Calculation (30 Points)
	var listener = Vector2(0, 0)
	var emitter_mid = Vector2(250, 0) # Half distance (250/500) -> atten -15db
	var audio_mid = engine.calculate_spatial_audio(listener, emitter_mid, 0.0, 0.0)

	if audio_mid.get("is_audible", false) and is_equal_approx(audio_mid.get("volume_db", 0.0), -15.0):
		total_score += 30.0
		details["attenuation_score"] = 30.0
	else:
		warnings.append("Spatial audio distance attenuation calculation failed")

	# 2. Out-of-Range Cutoff (25 Points)
	var emitter_far = Vector2(600, 0) # > 500 max distance
	var audio_far = engine.calculate_spatial_audio(listener, emitter_far)

	if not audio_far.get("is_audible", true) and audio_far.get("volume_db") == -80.0:
		total_score += 25.0
		details["cutoff_score"] = 25.0
	else:
		warnings.append("Out-of-range spatial audio cutoff check failed")

	# 3. Surface Footstep Mapping (25 Points)
	var f_metal = engine.get_footstep_sfx_name(engine_script.SurfaceType.METAL)
	var f_magma = engine.get_footstep_sfx_name(engine_script.SurfaceType.MAGMA)

	if f_metal == "footstep_metal" and f_magma == "footstep_magma":
		total_score += 25.0
		details["footstep_mapping_score"] = 25.0
	else:
		warnings.append("Surface footstep mapping check failed")

	# 4. Pitch Randomization Range (20 Points)
	var audio_pitch = engine.calculate_spatial_audio(listener, listener, 0.0, 0.10) # +/- 10%
	var pitch = audio_pitch.get("pitch", 1.0)

	if pitch >= 0.90 and pitch <= 1.10:
		total_score += 20.0
		details["pitch_rand_score"] = 20.0
	else:
		warnings.append("Pitch randomization range check failed")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
