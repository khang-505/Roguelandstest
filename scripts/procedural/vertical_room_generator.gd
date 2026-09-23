# scripts/procedural/vertical_room_generator.gd
class_name VerticalRoomGenerator
extends Node

## Assembles multi-layer vertical room modules with upper secret routes, lower cave descents, elevators, and ladders.

enum VerticalRoomArchetype {
	VERTICAL_SMALL,
	VERTICAL_TALL,
	VERTICAL_SHAFT,
	VERTICAL_CAVE,
	VERTICAL_ARENA,
	VERTICAL_TOWER,
	VERTICAL_CLIFF,
	VERTICAL_RUINS
}

static func generate_vertical_room(
	parent_node: Node2D,
	archetype: int,
	biome_id: String,
	seed_val: int
) -> Dictionary:
	var result = {
		"room_node": parent_node,
		"layer_platforms": {}, # Layer ID -> Array[Vector2]
		"traversal_graph": null,
		"ladders": [],
		"elevators": [],
		"secrets": []
	}

	if parent_node == null:
		return result

	var rng = RandomNumberGenerator.new()
	rng.seed = seed_val

	var params_class = load("res://scripts/procedural/vertical_exploration_params.gd")
	var params = params_class.new() if params_class else null
	if params and params.has_method("init_for_biome"):
		params.init_for_biome(biome_id)

	var graph_class = load("res://scripts/procedural/traversal_graph.gd")
	var graph = graph_class.new() if graph_class else null
	result.traversal_graph = graph

	var width_tiles = 24
	var height_tiles = 20
	if archetype == VerticalRoomArchetype.VERTICAL_TALL or archetype == VerticalRoomArchetype.VERTICAL_SHAFT:
		height_tiles = 32
	elif archetype == VerticalRoomArchetype.VERTICAL_SMALL:
		height_tiles = 16

	var tile_size = 16

	# 1. Main Base Floor (LAYER 3 - MAIN GAMEPLAY)
	var main_floor_y = (height_tiles - 4) * tile_size
	var ground_n = null
	if graph:
		ground_n = graph.add_platform_node(3, Vector2((width_tiles * 0.5) * tile_size, main_floor_y), width_tiles * tile_size, true)

	result.layer_platforms[3] = [Vector2((width_tiles * 0.5) * tile_size, main_floor_y)]

	# 2. Upper Layer Platform Chains (LAYER 4 - UPPER EXPLORATION & LAYER 5 - UPPER SECRET)
	var upper_platforms: Array[Vector2] = []
	var tier_count = 3
	for t in range(1, tier_count + 1):
		var layer_y = main_floor_y - (t * 96.0) # 96px tier spacing <= 140px max vertical gap
		if layer_y < 32.0: break

		var p_x = rng.randf_range(48.0, (width_tiles - 6) * tile_size)
		var pos = Vector2(p_x, layer_y)
		upper_platforms.append(pos)

		var layer_id = 4 if t < tier_count else 5
		if not result.layer_platforms.has(layer_id):
			result.layer_platforms[layer_id] = []
		(result.layer_platforms[layer_id] as Array).append(pos)

		if graph:
			var p_node = graph.add_platform_node(layer_id, pos, 64.0, false)
			# Connect previous ground/lower platform to upper platform
			if ground_n:
				graph.connect_nodes(ground_n.id, p_node.id, 0, false) # JUMP
				ground_n = p_node

	# 3. Lower Layer Cave Descent (LAYER 1 - LOWER GAMEPLAY & LAYER 0 - DEEP CAVE)
	var lower_y = main_floor_y + 112.0
	var cave_pos = Vector2((width_tiles * 0.5) * tile_size, lower_y)
	result.layer_platforms[1] = [cave_pos]
	if graph and ground_n:
		var cave_node = graph.add_platform_node(1, cave_pos, 96.0, true)
		graph.connect_nodes(ground_n.id, cave_node.id, 7, true) # CAVE_DESCENT

	# 4. Spawn Ladder for Vertical Shafts/Towers
	if archetype in [VerticalRoomArchetype.VERTICAL_SHAFT, VerticalRoomArchetype.VERTICAL_TOWER, VerticalRoomArchetype.VERTICAL_TALL]:
		var ladder_class = load("res://scripts/world/ladder_system.gd")
		if ladder_class:
			var ladder_inst = ladder_class.new()
			ladder_inst.setup_ladder(Vector2(48.0, main_floor_y), Vector2(48.0, main_floor_y - 192.0))
			parent_node.add_child(ladder_inst)
			result.ladders.append(ladder_inst)

	# 5. Spawn Mechanical Elevator for Deep Mines/Towers
	if archetype in [VerticalRoomArchetype.VERTICAL_TOWER, VerticalRoomArchetype.VERTICAL_CLIFF] or biome_id in ["mine", "iron_core", "machine"]:
		var elevator_class = load("res://scripts/world/elevator_system.gd")
		if elevator_class:
			var elevator_inst = elevator_class.new()
			elevator_inst.setup_elevator(Vector2((width_tiles - 4) * tile_size, main_floor_y), Vector2((width_tiles - 4) * tile_size, main_floor_y - 210.0))
			parent_node.add_child(elevator_inst)
			result.elevators.append(elevator_inst)

	# 6. Allocate Tactical Enemy Positioning across Vertical Layers
	var combat_pos_class = load("res://scripts/procedural/vertical_combat_positioning.gd")
	if combat_pos_class:
		combat_pos_class.allocate_enemies_for_vertical_room(parent_node, result.layer_platforms, 4, rng)

	return result
