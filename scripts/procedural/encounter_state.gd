# scripts/procedural/encounter_state.gd
class_name EncounterState
extends Node

## Persistence manager tracking cleared room encounters, wave progress, and defeated elites.

static var encounter_states: Dictionary = {} # encounter_id -> Dictionary

static func reset_all_states() -> void:
	encounter_states.clear()

static func register_encounter(encounter_id: String, wave_count: int = 1) -> void:
	if not encounter_states.has(encounter_id):
		encounter_states[encounter_id] = {
			"encounter_id": encounter_id,
			"cleared": false,
			"current_wave": 1,
			"total_waves": wave_count,
			"enemies_remaining": 0,
			"elite_defeated": false
		}

static func mark_cleared(encounter_id: String) -> void:
	register_encounter(encounter_id)
	encounter_states[encounter_id]["cleared"] = true
	encounter_states[encounter_id]["enemies_remaining"] = 0

static func advance_wave(encounter_id: String) -> void:
	register_encounter(encounter_id)
	var curr = encounter_states[encounter_id]["current_wave"]
	var total = encounter_states[encounter_id]["total_waves"]
	if curr < total:
		encounter_states[encounter_id]["current_wave"] = curr + 1

static func is_cleared(encounter_id: String) -> bool:
	return encounter_states.get(encounter_id, {}).get("cleared", false)

static func get_current_wave(encounter_id: String) -> int:
	return encounter_states.get(encounter_id, {}).get("current_wave", 1)

static func get_encounter_state(encounter_id: String) -> Dictionary:
	return encounter_states.get(encounter_id, {}).duplicate()
