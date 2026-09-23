# scripts/procedural/hidden_path_state.gd
class_name HiddenPathState
extends Node

## Persistence manager tracking hidden path discovery, completion, and shortcut unlock states.

static var path_states: Dictionary = {} # path_id -> Dictionary

static func reset_all_states() -> void:
	path_states.clear()

static func register_path(path_id: String, required_ability: String = "NONE") -> void:
	if not path_states.has(path_id):
		path_states[path_id] = {
			"path_id": path_id,
			"discovered": false,
			"opened": false,
			"completed": false,
			"reward_collected": false,
			"shortcut_unlocked": false,
			"required_ability": required_ability
		}

static func mark_discovered(path_id: String) -> void:
	register_path(path_id)
	path_states[path_id]["discovered"] = true

static func mark_opened(path_id: String) -> void:
	register_path(path_id)
	path_states[path_id]["opened"] = true
	path_states[path_id]["discovered"] = true

static func mark_completed(path_id: String) -> void:
	register_path(path_id)
	path_states[path_id]["completed"] = true
	path_states[path_id]["reward_collected"] = true

static func unlock_shortcut(path_id: String) -> void:
	register_path(path_id)
	path_states[path_id]["shortcut_unlocked"] = true
	path_states[path_id]["opened"] = true
	path_states[path_id]["discovered"] = true

static func is_discovered(path_id: String) -> bool:
	return path_states.get(path_id, {}).get("discovered", false)

static func is_opened(path_id: String) -> bool:
	return path_states.get(path_id, {}).get("opened", false)

static func is_completed(path_id: String) -> bool:
	return path_states.get(path_id, {}).get("completed", false)

static func is_shortcut_unlocked(path_id: String) -> bool:
	return path_states.get(path_id, {}).get("shortcut_unlocked", false)

static func get_path_state(path_id: String) -> Dictionary:
	return path_states.get(path_id, {}).duplicate()
