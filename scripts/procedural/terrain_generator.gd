# scripts/procedural/terrain_generator.gd
class_name TerrainGenerator
extends Node

## Master Procedural Terrain Generator implementing the Main-Route-First pipeline with deterministic seeding and engine versioning.

const GENERATOR_VERSION: int = 1

static func generate_terrain_for_room(
	parent_node: Node2D,
	width_tiles: int,
	height_tiles: int,
	tile_size: int,
	biome_id: String,
	seed_val: int
) -> Dictionary:
	var result = {
		"version": GENERATOR_VERSION,
		"seed": seed_val,
		"segments": [],
		"main_path": [],
		"platforms": [],
		"slopes": [],
		"caves": [],
		"hazards": [],
		"secrets": [],
		"traversal_graph": null
	}

	if parent_node == null:
		return result

	var rng = RandomNumberGenerator.new()
	rng.seed = seed_val

	var profile_class = load("res://scripts/procedural/terrain_profile.gd")
	var profile = profile_class.new() if profile_class else null
	if profile and profile.has_method("init_for_biome"):
		profile.init_for_biome(biome_id)

	var seg_class = load("res://scripts/procedural/terrain_segment.gd")
	var conn_class = load("res://scripts/procedural/terrain_connector.gd")
	var graph_class = load("res://scripts/procedural/traversal_graph.gd")

	var graph = graph_class.new() if graph_class else null
	result.traversal_graph = graph

	var room_width_px = width_tiles * tile_size
	var room_height_px = height_tiles * tile_size

	# 1. Main Base Floor (Base Level)
	var main_floor_y = room_height_px - 32.0
	_build_ground_collision(parent_node, room_width_px, main_floor_y)

	var start_pos = Vector2(32.0, main_floor_y - 16.0)
	var exit_pos = Vector2(room_width_px - 32.0, main_floor_y - 16.0)

	var start_n = null
	var exit_n = null
	if graph:
		start_n = graph.add_platform_node(3, start_pos, 64.0, true)
		exit_n = graph.add_platform_node(3, exit_pos, 64.0, true)

	# 2. Main Traversal Route (Segment Chain)
	var segment_width = 192.0
	var num_segments = int(ceil(room_width_px / segment_width))
	var prev_seg = null

	var current_x = 0.0
	var current_y = main_floor_y

	for s_idx in range(num_segments):
		var cat = rng.randi() % 11 # 11 Categories
		var seg = seg_class.new() if seg_class else null
		if seg and seg.has_method("init_segment"):
			seg.init_segment(cat, "seg_%d" % s_idx, segment_width, 0.0, 0.0)

		if prev_seg and seg and conn_class:
			var conn_val = conn_class.validate_connector(prev_seg, seg)
			if not conn_val.get("is_compatible", true):
				# Fall back to FLAT segment if incompatible
				seg.init_segment(0, "seg_%d_flat" % s_idx, segment_width, 0.0, 0.0)

		result.segments.append(seg)
		prev_seg = seg

		# Spawn segment platforms
		if seg and "platforms" in seg:
			for p_off in seg.platforms:
				var p_pos = Vector2(current_x + p_off.x, current_y + p_off.y - 48.0)
				_spawn_platform(parent_node, p_pos, 64.0)
				result.platforms.append(p_pos)

				if graph and start_n:
					var p_node = graph.add_platform_node(4, p_pos, 64.0, false)
					graph.connect_nodes(start_n.id, p_node.id, 0, false) # JUMP
					start_n = p_node

		current_x += segment_width

	# Connect final platform to Exit
	if graph and start_n and exit_n:
		graph.connect_nodes(start_n.id, exit_n.id, 0, false)

	# 3. Add Subterranean Cave Descents & Hazards
	if profile and profile.cave_probability > 0.4:
		var cave_class = load("res://scripts/procedural/cave_generator.gd")
		if cave_class:
			var cave_spots = cave_class.generate_cave_section(parent_node, width_tiles, height_tiles, tile_size, rng)
			result.caves.append_array(cave_spots)

	return result

static func _build_ground_collision(parent_node: Node2D, w_px: float, y_pos: float) -> void:
	var body = StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 6

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(w_px, 16)
	shape.shape = rect
	body.add_child(shape)

	var visual = ColorRect.new()
	visual.color = Color(0.16, 0.20, 0.26, 1.0)
	visual.offset_left = -(w_px * 0.5)
	visual.offset_top = -8.0
	visual.offset_right = (w_px * 0.5)
	visual.offset_bottom = 8.0
	body.add_child(visual)

	body.position = Vector2(w_px * 0.5, y_pos)
	parent_node.add_child(body)

static func _spawn_platform(parent_node: Node2D, pos: Vector2, p_width: float) -> void:
	var body = StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 6

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(p_width, 8)
	shape.shape = rect
	shape.one_way_collision = true
	body.add_child(shape)

	var visual = ColorRect.new()
	visual.color = Color(0.30, 0.36, 0.44, 0.95)
	visual.offset_left = -(p_width * 0.5)
	visual.offset_top = -4.0
	visual.offset_right = (p_width * 0.5)
	visual.offset_bottom = 4.0
	body.add_child(visual)

	body.position = pos
	parent_node.add_child(body)
