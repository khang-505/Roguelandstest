# scripts/ui/input_remapping_manager.gd
class_name InputRemappingManager
extends Resource

## Dynamic Keybinding and Gamepad Controller Remapping Engine with conflict detection.

signal keybinding_changed(action_name: String, event_type: String, input_code: int)

static var DEFAULT_BINDINGS: Dictionary = {
	"move_left": {"type": "key", "code": KEY_A},
	"move_right": {"type": "key", "code": KEY_D},
	"jump": {"type": "key", "code": KEY_SPACE},
	"dash": {"type": "key", "code": KEY_SHIFT},
	"attack_melee": {"type": "mouse", "code": MOUSE_BUTTON_LEFT},
	"attack_ranged": {"type": "mouse", "code": MOUSE_BUTTON_RIGHT},
	"ability_1": {"type": "key", "code": KEY_Q},
	"ability_2": {"type": "key", "code": KEY_E},
	"interact": {"type": "key", "code": KEY_F},
	"open_inventory": {"type": "key", "code": KEY_I}
}

var current_bindings: Dictionary = {}

func _init() -> void:
	reset_to_defaults()

func reset_to_defaults() -> void:
	current_bindings = DEFAULT_BINDINGS.duplicate(true)

func remap_action(action_name: String, event_type: String, input_code: int) -> Dictionary:
	if not DEFAULT_BINDINGS.has(action_name):
		return {"success": false, "reason": "action_not_found"}

	# Conflict detection: check if code is already bound to another action
	for other_action in current_bindings.keys():
		if other_action == action_name:
			continue
		var b = current_bindings[other_action]
		if b["type"] == event_type and b["code"] == input_code:
			return {"success": false, "reason": "conflict_detected", "conflicting_action": other_action}

	current_bindings[action_name] = {"type": event_type, "code": input_code}
	keybinding_changed.emit(action_name, event_type, input_code)
	return {"success": true, "action": action_name, "type": event_type, "code": input_code}

func get_binding(action_name: String) -> Dictionary:
	if current_bindings.has(action_name):
		return current_bindings[action_name].duplicate()
	return {}
