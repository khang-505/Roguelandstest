# scripts/procedural/breakable_object_state.gd
class_name BreakableObjectState
extends Node

## Persistence manager tracking destroyed breakable objects and loot collection across revisits.

static var object_states: Dictionary = {} # object_id -> Dictionary

static func reset_all_states() -> void:
	object_states.clear()

static func register_object(object_id: String) -> void:
	if not object_states.has(object_id):
		object_states[object_id] = {
			"object_id": object_id,
			"is_destroyed": false,
			"loot_collected": false,
			"path_revealed": false
		}

static func mark_destroyed(object_id: String) -> void:
	register_object(object_id)
	object_states[object_id]["is_destroyed"] = true

static func mark_loot_collected(object_id: String) -> void:
	register_object(object_id)
	object_states[object_id]["loot_collected"] = true

static func is_destroyed(object_id: String) -> bool:
	return object_states.get(object_id, {}).get("is_destroyed", false)

static func is_loot_collected(object_id: String) -> bool:
	return object_states.get(object_id, {}).get("loot_collected", false)
