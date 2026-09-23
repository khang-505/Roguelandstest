# scripts/procedural/cave_generator.gd
class_name CaveGenerator
extends Node

## Master Procedural Subterranean Cave System Generator implementing the Main-Route-First pipeline with depth progression.

const GENERATOR_VERSION: int = 1

static func generate_cave_network(
	parent_node: Node2D,
	biome_id: String,
	seed_val: int,
	depth_level: int = 1
) -> Dictionary:
	var result = {
		"version": GENERATOR_VERSION,
		"seed": seed_val,
		"biome": biome_id,
		"depth": depth_level,
		"graph": null,
		"cave_spots": [],
		"stalactites": [],
		"hazards": [],
		"resources": [],
		"secrets": [],
		"shortcuts": []
	}

	if parent_node == null:
		return result

	var rng = RandomNumberGenerator.new()
	rng.seed = seed_val

	var graph_class = load("res://scripts/procedural/cave_graph.gd")
	var data_class = load("res://scripts/procedural/cave_data.gd")

	var graph = graph_class.new() if graph_class else null
	result.graph = graph

	# 1. Construct Topological Cave Graph (Main Route: Entrance -> Main Tunnel -> Deep Cave -> Exit)
	var n_ent = graph.add_cave_node("c_entrance", 0, 0, Vector2(64, 64), true) if graph else null
	var n_tun = graph.add_cave_node("c_main_tunnel", 1, 1, Vector2(256, 128), true) if graph else null
	var n_deep = graph.add_cave_node("c_deep_cave", 9, 3, Vector2(512, 256), true) if graph else null
	var n_exit = graph.add_cave_node("c_exit", 10, 0, Vector2(768, 64), true) if graph else null

	if graph:
		graph.connect_cave_nodes("c_entrance", "c_main_tunnel", "TUNNEL", false)
		graph.connect_cave_nodes("c_main_tunnel", "c_deep_cave", "SHAFT", false)
		graph.connect_cave_nodes("c_deep_cave", "c_exit", "TUNNEL", false)

		# Add Optional Branches (Treasure Chamber & Secret Breakable Wall)
		var n_treas = graph.add_cave_node("c_treasure", 7, 2, Vector2(384, 64), false)
		graph.connect_cave_nodes("c_main_tunnel", "c_treasure", "SECRET", false)

		# Add Surface Shortcut Loop (Deep Cave -> Exit Shortcut)
		graph.connect_cave_nodes("c_deep_cave", "c_exit", "SHORTCUT", true)
		result.shortcuts.append(Vector2(640, 128))

	# 2. Build Physical Cave Tunnel Collision & Formations
	var tunnel_y = 14
	var num_stalactites = rng.randi_range(4, 8)

	for i in range(num_stalactites):
		var cx = rng.randi_range(4, 28)
		var pos = Vector2(cx * 16.0, (tunnel_y - 2) * 16.0)

		var cave_node = StaticBody2D.new()
		cave_node.collision_layer = 1
		cave_node.collision_mask = 6

		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.size = Vector2(16, 24)
		shape.shape = rect
		cave_node.add_child(shape)

		var visual = ColorRect.new()
		visual.color = Color(0.12, 0.15, 0.20, 1.0)
		visual.offset_left = -8.0
		visual.offset_top = -12.0
		visual.offset_right = 8.0
		visual.offset_bottom = 12.0
		cave_node.add_child(visual)

		cave_node.position = pos
		parent_node.add_child(cave_node)

		result.stalactites.append(pos)
		result.cave_spots.append(pos + Vector2(0, 32))

	# 3. Add Cave Resources & Hazard Pools based on depth
	var resource_count = 2 + depth_level
	for r in range(resource_count):
		var res_pos = Vector2(128.0 + r * 96.0, (tunnel_y + 1) * 16.0)
		result.resources.append(res_pos)

	if depth_level >= 2:
		result.hazards.append(Vector2(400.0, (tunnel_y + 1) * 16.0))

	return result

static func generate_cave_section(
	parent_node: Node2D,
	width_tiles: int,
	height_tiles: int,
	tile_size: int,
	rng: RandomNumberGenerator
) -> Array[Vector2]:
	var res = generate_cave_network(parent_node, "emberwild", rng.seed if rng else 1234, 1)
	var spots: Array[Vector2] = []
	for s in res.get("cave_spots", []):
		spots.append(s as Vector2)
	return spots
