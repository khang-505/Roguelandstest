# scripts/procedural/platform_generator.gd
class_name PlatformGenerator
extends Node

## Multi-tier traversal builder generating authored platform chains, moving platforms, and recovery ledges.

const GENERATOR_VERSION: int = 1

static func generate_platforms_for_room(
	parent_node: Node2D,
	width_tiles: int,
	height_tiles: int,
	tile_size: int,
	verticality: float,
	rng: RandomNumberGenerator
) -> Array[Vector2]:
	var platform_tops: Array[Vector2] = []
	if parent_node == null:
		return platform_tops

	var profile_class = load("res://scripts/procedural/traversal_profile.gd")
	var profile = profile_class.new() if profile_class else null
	if profile and profile.has_method("init_default_profile"):
		profile.init_default_profile()

	var pattern_class = load("res://scripts/procedural/platform_pattern.gd")
	var plat_data_class = load("res://scripts/procedural/platform_data.gd")

	# 1. Main Horizontal Base Ground Floor
	var room_width_px = width_tiles * tile_size
	var room_height_px = height_tiles * tile_size
	var main_floor_y = room_height_px - 16.0
	_create_ground_floor(parent_node, width_tiles, height_tiles, tile_size)
	platform_tops.append(Vector2(room_width_px * 0.5, main_floor_y - 12.0))

	# 2. Main Traversal Platform Route (Authored Pattern Chains)
	var pat_idx = rng.randi() % 15 # 15 Pattern Categories
	var pattern = pattern_class.new() if pattern_class else null
	if pattern and pattern.has_method("init_pattern"):
		pattern.init_pattern(pat_idx)

	var origin_x = 64.0
	var origin_y = main_floor_y - 64.0

	if pattern and "platform_offsets" in pattern:
		for p_info in pattern.platform_offsets:
			var off = p_info.get("offset", Vector2.ZERO) as Vector2
			var p_w = p_info.get("width", 64.0) as float
			var p_type = p_info.get("type", 2) as int

			var p_pos = Vector2(origin_x + off.x, origin_y + off.y)

			# Ensure platform is within room bounds
			if p_pos.x >= 32.0 and p_pos.x <= room_width_px - 32.0 and p_pos.y >= 32.0 and p_pos.y <= main_floor_y - 16.0:
				if p_type == 1: # MOVING PLATFORM
					_spawn_moving_platform(parent_node, p_pos, p_w, 96.0)
				elif p_type == 3: # BREAKABLE PLATFORM
					_spawn_breakable_platform(parent_node, p_pos, p_w)
				else: # ONE_WAY / STATIC
					_spawn_one_way_platform(parent_node, p_pos, p_w, tile_size)

				platform_tops.append(p_pos + Vector2(0, -12))

	# 3. Secondary Tier Platform Chains (Upper Ledges & Recovery)
	var tier_count = int(2 + verticality * 2)
	var tier_spacing_tiles = int(clamp(height_tiles / (tier_count + 1), 3, 5))

	for t in range(1, tier_count + 1):
		var tier_y = height_tiles - (t * tier_spacing_tiles)
		if tier_y <= 2: break

		var current_x = rng.randi_range(3, 6)
		while current_x < width_tiles - 6:
			var p_width = rng.randi_range(3, 6)
			var pos = Vector2((current_x + float(p_width) * 0.5) * tile_size, tier_y * tile_size)

			_spawn_one_way_platform(parent_node, pos, p_width * tile_size, tile_size)
			platform_tops.append(pos + Vector2(0, -12))

			var gap = rng.randi_range(3, 5) # 48px to 80px gap (Safe <= 160px)
			current_x += p_width + gap

	return platform_tops

static func _create_ground_floor(parent_node: Node2D, width_tiles: int, height_tiles: int, tile_size: int) -> void:
	var body = StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 6

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(width_tiles * tile_size, 16)
	shape.shape = rect
	body.add_child(shape)

	var visual = ColorRect.new()
	visual.color = Color(0.18, 0.22, 0.28, 1.0)
	visual.offset_left = -(width_tiles * tile_size * 0.5)
	visual.offset_top = -8.0
	visual.offset_right = (width_tiles * tile_size * 0.5)
	visual.offset_bottom = 8.0
	body.add_child(visual)

	body.position = Vector2((width_tiles * 0.5) * tile_size, (height_tiles - 1) * tile_size)
	parent_node.add_child(body)

static func _spawn_one_way_platform(parent_node: Node2D, pos: Vector2, p_width_px: float, _tile_size: int) -> void:
	var body = StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 6

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(p_width_px, 8)
	shape.shape = rect
	shape.one_way_collision = true
	body.add_child(shape)

	var visual = ColorRect.new()
	visual.color = Color(0.32, 0.38, 0.46, 0.95)
	visual.offset_left = -(p_width_px * 0.5)
	visual.offset_top = -4.0
	visual.offset_right = (p_width_px * 0.5)
	visual.offset_bottom = 4.0
	body.add_child(visual)

	body.position = pos
	parent_node.add_child(body)

static func _spawn_moving_platform(parent_node: Node2D, pos: Vector2, p_width_px: float, travel_dist: float) -> void:
	var body = AnimatableBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 6

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(p_width_px, 8)
	shape.shape = rect
	shape.one_way_collision = true
	body.add_child(shape)

	var visual = ColorRect.new()
	visual.color = Color(0.40, 0.70, 0.90, 0.95)
	visual.offset_left = -(p_width_px * 0.5)
	visual.offset_top = -4.0
	visual.offset_right = (p_width_px * 0.5)
	visual.offset_bottom = 4.0
	body.add_child(visual)

	body.position = pos
	parent_node.add_child(body)

static func _spawn_breakable_platform(parent_node: Node2D, pos: Vector2, p_width_px: float) -> void:
	var body = StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 6

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(p_width_px, 8)
	shape.shape = rect
	shape.one_way_collision = true
	body.add_child(shape)

	var visual = ColorRect.new()
	visual.color = Color(0.85, 0.45, 0.20, 0.90)
	visual.offset_left = -(p_width_px * 0.5)
	visual.offset_top = -4.0
	visual.offset_right = (p_width_px * 0.5)
	visual.offset_bottom = 4.0
	body.add_child(visual)

	body.position = pos
	parent_node.add_child(body)
