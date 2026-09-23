# scripts/procedural/interaction_generator.gd
class_name InteractionGenerator
extends Node

## 12-Step Procedural Generator for interactive environment objects and linked logical chains.

const GENERATOR_VERSION: int = 1

static func generate_interactions_for_room(
	parent_node: Node2D,
	room_data: Dictionary,
	biome_id: String = "emberwild",
	seed_val: int = 1337,
	chain_budget: int = 2
) -> Array:
	var results: Array = []
	var room_seed = int(abs(hash(str(seed_val) + "_interaction_" + room_data.get("id", "rm"))))
	var rng = RandomNumberGenerator.new()
	rng.seed = room_seed

	var w_tiles = room_data.get("width_tiles", 24)
	var h_tiles = room_data.get("height_tiles", 14)
	var t_size = room_data.get("tile_size", 16)

	var door_script = load("res://scripts/world/interactive_door.gd")
	var lever_script = load("res://scripts/world/interactive_lever.gd")
	var chest_script = load("res://scripts/world/interactive_chest.gd")
	var term_script = load("res://scripts/world/interactive_terminal.gd")
	var trap_script = load("res://scripts/world/environmental_trap.gd")

	for i in range(chain_budget):
		var target_id = "target_%s_%d_%d" % [biome_id, room_seed, i]
		var trigger_id = "trig_%s_%d_%d" % [biome_id, room_seed, i]

		var target_pos = Vector2((w_tiles - 4) * t_size, (h_tiles - 3) * t_size)
		var trigger_pos = Vector2(4 * t_size, (h_tiles - 3) * t_size)

		var door_node: Node2D = null
		var lever_node: Node2D = null

		if parent_node != null:
			# Spawn Target (Door)
			if door_script:
				var d_inst = door_script.new() as StaticBody2D
				d_inst.set("door_id", target_id)
				d_inst.position = target_pos
				parent_node.add_child(d_inst)
				door_node = d_inst

			# Spawn Trigger (Lever linked to Door)
			if lever_script:
				var l_inst = lever_script.new() as Area2D
				l_inst.set("lever_id", trigger_id)
				l_inst.set("linked_target_ids", [target_id])
				l_inst.position = trigger_pos
				parent_node.add_child(l_inst)
				lever_node = l_inst

		results.append({
			"trigger_id": trigger_id,
			"target_id": target_id,
			"trigger_pos": trigger_pos,
			"target_pos": target_pos,
			"trigger_node": lever_node,
			"target_node": door_node,
			"version": GENERATOR_VERSION
		})

	return results
