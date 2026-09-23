# scripts/procedural/breakable_object_generator.gd
class_name BreakableObjectGenerator
extends Node

## 12-Step Procedural Generator for breakable crates, ore rocks, explosive barrels, and weak walls.

const GENERATOR_VERSION: int = 1

static func generate_breakables_for_room(
	parent_node: Node2D,
	room_data: Dictionary,
	biome_id: String = "emberwild",
	seed_val: int = 1337,
	density_budget: int = 3
) -> Array:
	var results: Array = []
	var room_seed = int(abs(hash(str(seed_val) + "_breakables_" + room_data.get("id", "rm"))))
	var rng = RandomNumberGenerator.new()
	rng.seed = room_seed

	var w_tiles = room_data.get("width_tiles", 24)
	var h_tiles = room_data.get("height_tiles", 14)
	var t_size = room_data.get("tile_size", 16)

	var obj_script = load("res://scripts/world/breakable_object.gd")
	var barrel_script = load("res://scripts/world/explosive_barrel.gd")

	for i in range(density_budget):
		var obj_id = "brk_%s_%d_%d" % [biome_id, room_seed, i]
		var obj_type = rng.randi_range(0, 11) # 0-11 ObjectType

		var gx = rng.randi_range(2, w_tiles - 3) * t_size
		var gy = rng.randi_range(2, h_tiles - 3) * t_size
		var pos = Vector2(gx, gy)

		var spawned_node: Node2D = null

		if parent_node != null:
			if obj_type == 1: # BARREL
				if barrel_script:
					var b_inst = barrel_script.new() as StaticBody2D
					b_inst.set("object_id", obj_id)
					b_inst.position = pos
					parent_node.add_child(b_inst)
					spawned_node = b_inst
			else:
				if obj_script:
					var o_inst = obj_script.new() as StaticBody2D
					o_inst.set("object_id", obj_id)
					o_inst.position = pos
					parent_node.add_child(o_inst)
					spawned_node = o_inst

		results.append({
			"object_id": obj_id,
			"object_type": obj_type,
			"position": pos,
			"biome": biome_id,
			"node": spawned_node,
			"version": GENERATOR_VERSION
		})

	return results
