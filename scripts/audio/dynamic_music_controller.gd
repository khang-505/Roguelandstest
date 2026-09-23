# scripts/audio/dynamic_music_controller.gd
class_name DynamicMusicController
extends Node

## Interactive music state engine supporting 4 combat/exploration intensity states and stem crossfading.

enum MusicState { EXPLORATION, COMBAT_LIGHT, COMBAT_INTENSE, BOSS_PHASE }

signal music_state_changed(old_state: MusicState, new_state: MusicState, state_data: Dictionary)
signal crossfade_started(from_track: String, to_track: String, duration: float)

static var STATE_PROFILES: Dictionary = {
	MusicState.EXPLORATION: {
		"id": "exploration",
		"name": "Exploration Ambient",
		"track_id": "ambient_hub",
		"stem_percussion": 0.0,
		"stem_bass": 0.5,
		"stem_lead": 0.8,
		"crossfade_duration": 1.5
	},
	MusicState.COMBAT_LIGHT: {
		"id": "combat_light",
		"name": "Skirmish Combat",
		"track_id": "planet_combat",
		"stem_percussion": 0.6,
		"stem_bass": 0.8,
		"stem_lead": 0.8,
		"crossfade_duration": 1.0
	},
	MusicState.COMBAT_INTENSE: {
		"id": "combat_intense",
		"name": "Heavy Assault",
		"track_id": "planet_combat",
		"stem_percussion": 1.0,
		"stem_bass": 1.0,
		"stem_lead": 1.0,
		"crossfade_duration": 0.5
	},
	MusicState.BOSS_PHASE: {
		"id": "boss_phase",
		"name": "Boss Showdown",
		"track_id": "boss_battle_theme",
		"stem_percussion": 1.0,
		"stem_bass": 1.0,
		"stem_lead": 1.0,
		"crossfade_duration": 0.3
	}
}

@export var current_state: MusicState = MusicState.EXPLORATION

func set_music_state(new_state: MusicState) -> bool:
	if current_state == new_state:
		return false

	var old_state = current_state
	current_state = new_state
	var profile = STATE_PROFILES[new_state]

	var old_track = STATE_PROFILES[old_state]["track_id"]
	var new_track = profile["track_id"]
	var dur = float(profile["crossfade_duration"])

	crossfade_started.emit(old_track, new_track, dur)
	music_state_changed.emit(old_state, new_state, profile)
	return true

func get_active_profile() -> Dictionary:
	return STATE_PROFILES.get(current_state, STATE_PROFILES[MusicState.EXPLORATION]).duplicate()
