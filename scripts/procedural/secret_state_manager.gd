# scripts/procedural/secret_state_manager.gd
class_name SecretStateManager
extends Node

## Tracks secret state persistence per node across scene transitions and save states.

static var secret_states: Dictionary = {} # secret_id -> Dictionary

static func reset_all_states() -> void:
	secret_states.clear()

static func register_secret(secret_id: String, required_ability: String = "NONE") -> void:
	if not secret_states.has(secret_id):
		secret_states[secret_id] = {
			"secret_id": secret_id,
			"discovered": false,
			"visited": false,
			"completed": false,
			"reward_collected": false,
			"entrance_opened": false,
			"required_ability": required_ability
		}

static func mark_discovered(secret_id: String) -> void:
	register_secret(secret_id)
	secret_states[secret_id]["discovered"] = true

static func mark_opened(secret_id: String) -> void:
	register_secret(secret_id)
	secret_states[secret_id]["entrance_opened"] = true
	secret_states[secret_id]["discovered"] = true

static func mark_completed(secret_id: String) -> void:
	register_secret(secret_id)
	secret_states[secret_id]["completed"] = true
	secret_states[secret_id]["reward_collected"] = true

static func is_discovered(secret_id: String) -> bool:
	return secret_states.get(secret_id, {}).get("discovered", false)

static func is_opened(secret_id: String) -> bool:
	return secret_states.get(secret_id, {}).get("entrance_opened", false)

static func is_completed(secret_id: String) -> bool:
	return secret_states.get(secret_id, {}).get("completed", false)

static func get_state(secret_id: String) -> Dictionary:
	return secret_states.get(secret_id, {}).duplicate()
