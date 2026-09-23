# scripts/audio/music_validator.gd
class_name MusicValidator
extends Resource

## Quality Score Engine evaluating Music Intensity States, Stem Profiles, Crossfade Durations, and Transition Signals.

static func validate_music_system() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var ctrl_script = load("res://scripts/audio/dynamic_music_controller.gd")
	if not ctrl_script:
		warnings.append("DynamicMusicController script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	var ctrl = ctrl_script.new()

	# 1. 4 Intensity States Catalog Check (30 Points)
	var profiles = ctrl_script.STATE_PROFILES
	if profiles.size() == 4:
		total_score += 30.0
		details["profiles_score"] = 30.0
	else:
		warnings.append("Expected 4 music intensity state profiles")

	# 2. Music State Transition (25 Points)
	var switched = ctrl.set_music_state(ctrl_script.MusicState.COMBAT_INTENSE)
	var profile = ctrl.get_active_profile()

	if switched and profile.get("id") == "combat_intense" and profile.get("stem_percussion") == 1.0:
		total_score += 25.0
		details["transition_score"] = 25.0
	else:
		warnings.append("Music state transition check failed")

	# 3. Crossfade Signal Emission (25 Points)
	var crossfade_emitted = false
	ctrl.crossfade_started.connect(func(_from, _to, _dur): crossfade_emitted = true)
	ctrl.set_music_state(ctrl_script.MusicState.BOSS_PHASE)

	if crossfade_emitted and ctrl.current_state == ctrl_script.MusicState.BOSS_PHASE:
		total_score += 25.0
		details["crossfade_signal_score"] = 25.0
	else:
		warnings.append("Crossfade signal emission failed")

	# 4. Same State No-Op Guard (20 Points)
	var noop = ctrl.set_music_state(ctrl_script.MusicState.BOSS_PHASE)
	if not noop:
		total_score += 20.0
		details["noop_guard_score"] = 20.0
	else:
		warnings.append("Same state no-op guard failed")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
