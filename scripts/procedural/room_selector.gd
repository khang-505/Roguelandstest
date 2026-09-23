# scripts/procedural/room_selector.gd
class_name RoomSelector
extends Node

## Handles weighted room template selection with repetition filtering history buffers.

static var recent_room_ids: Array[String] = []
const MAX_HISTORY: int = 5

static func select_room_template(
	archetype_idx: int,
	biome_id: String,
	_difficulty: float,
	rng: RandomNumberGenerator
) -> Object:
	var room_data_class = load("res://scripts/procedural/room_data.gd")
	if room_data_class == null or not room_data_class.has_method("get_registry"):
		return null

	var registry: Dictionary = room_data_class.get_registry()
	if registry.size() == 0:
		return null

	var type_name = _archetype_index_to_name(archetype_idx)
	var candidates: Array = []

	for r_id in registry.keys():
		var r = registry[r_id]
		if r.get("room_type") == type_name:
			if not recent_room_ids.has(r_id):
				candidates.append(r)

	# Fallback if all candidates were in recent history
	if candidates.size() == 0:
		for r_id in registry.keys():
			var r = registry[r_id]
			if r.get("room_type") == type_name:
				candidates.append(r)

	if candidates.size() == 0:
		return registry.values()[0]

	var selected = candidates[rng.randi() % candidates.size()]
	var sel_id = selected.get("room_id") as String

	recent_room_ids.append(sel_id)
	if recent_room_ids.size() > MAX_HISTORY:
		recent_room_ids.pop_front()

	return selected

static func _archetype_index_to_name(idx: int) -> String:
	match idx:
		0: return "START"
		1: return "COMBAT"
		2: return "EXPLORATION"
		3: return "TREASURE"
		4: return "EVENT"
		5: return "SHOP"
		6: return "REST"
		7: return "ELITE"
		8: return "SECRET"
		9: return "CHALLENGE"
		10: return "MINI_BOSS"
		11: return "BOSS"
		12: return "EXIT"
		_: return "COMBAT"
