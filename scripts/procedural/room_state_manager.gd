# scripts/procedural/room_state_manager.gd
class_name RoomStateManager
extends Node

## Retains room clearing, loot collection, and secret wall destruction state across backtracking.

static var room_states: Dictionary = {} # int room_id -> Dictionary state

static func clear_all_states() -> void:
	room_states.clear()

static func record_room_cleared(room_id: int) -> void:
	if not room_states.has(room_id):
		room_states[room_id] = {}
	room_states[room_id]["is_cleared"] = true

static func is_room_cleared(room_id: int) -> bool:
	if room_states.has(room_id):
		return room_states[room_id].get("is_cleared", false)
	return false

static func record_loot_collected(room_id: int, loot_index: int) -> void:
	if not room_states.has(room_id):
		room_states[room_id] = {}
	if not room_states[room_id].has("collected_loot"):
		room_states[room_id]["collected_loot"] = []
	(room_states[room_id]["collected_loot"] as Array).append(loot_index)

static func is_loot_collected(room_id: int, loot_index: int) -> bool:
	if room_states.has(room_id) and room_states[room_id].has("collected_loot"):
		return (room_states[room_id]["collected_loot"] as Array).has(loot_index)
	return false
