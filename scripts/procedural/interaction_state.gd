# scripts/procedural/interaction_state.gd
class_name InteractionState
extends Node

## Persistence manager tracking interactive object states across run revisits.

static var object_states: Dictionary = {} # object_id -> Dictionary

static func reset_all_states() -> void:
	object_states.clear()

static func register_object(object_id: String) -> void:
	if not object_states.has(object_id):
		object_states[object_id] = {
			"object_id": object_id,
			"state": "AVAILABLE", # INACTIVE, AVAILABLE, ACTIVATED, LOCKED, DISABLED, COMPLETED
			"activated_count": 0,
			"power_online": true
		}

static func set_state(object_id: String, new_state: String) -> void:
	register_object(object_id)
	object_states[object_id]["state"] = new_state
	if new_state == "ACTIVATED":
		object_states[object_id]["activated_count"] += 1

static func get_state(object_id: String) -> String:
	return object_states.get(object_id, {}).get("state", "AVAILABLE")

static func is_activated(object_id: String) -> bool:
	return get_state(object_id) == "ACTIVATED" or get_state(object_id) == "COMPLETED"
