# scripts/procedural/room_generator.gd
class_name RoomGenerator
extends Node2D

## Deterministic seeded room & platform generator consuming BiomeData.

@export var room_width: int = 30 # tiles (16px per tile = 480px)
@export var room_height: int = 17 # tiles (16px per tile = 272px)
@export var tile_size: int = 16

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var grid: Array = [] # 2D array: 0 = AIR, 1 = SOLID_PLATFORM, 2 = HAZARD, 3 = PORTAL, 4 = SPAWN

var player_spawn_pos: Vector2 = Vector2.ZERO
var extraction_pos: Vector2 = Vector2.ZERO
var enemy_spawn_positions: Array[Vector2] = []
var loot_spawn_positions: Array[Vector2] = []
var hazard_positions: Array[Vector2] = []

var generated_nodes: Array[Node] = []

func _clear_generated_nodes() -> void:
	for n in generated_nodes:
		if is_instance_valid(n):
			n.queue_free()
	generated_nodes.clear()

func generate_room(seed_value: int, depth_level: int = 1, biome_id: String = "emberwild") -> Dictionary:
	_clear_generated_nodes()
	var biome = BiomeData.get_biome(biome_id)
	rng.seed = seed_value

	# Dynamically scale width and height based on depth_level!
	room_width = 30 + (depth_level - 1) * 15 # Stage 1: 30, Stage 2: 45, Stage 3: 60 tiles
	room_height = 17 + (depth_level - 1) * 4 # Stage 1: 17, Stage 2: 21, Stage 3: 25 tiles

	_update_stage_boundaries()

	grid.clear()
	enemy_spawn_positions.clear()
	loot_spawn_positions.clear()
	hazard_positions.clear()

	# 1. Initialize grid with empty air
	for y in range(room_height):
		var row: Array = []
		for x in range(room_width):
			row.append(0)
		grid.append(row)

	# 2. Build outer boundary walls & floor
	for x in range(room_width):
		grid[0][x] = 1 # Ceiling
		grid[room_height - 1][x] = 1 # Floor
	for y in range(room_height):
		grid[y][0] = 1 # Left wall
		grid[y][room_width - 1] = 1 # Right wall

	# 3. Deterministic spawn platform (Left side)
	player_spawn_pos = Vector2(3 * tile_size, (room_height - 3) * tile_size)
	grid[room_height - 2][2] = 1
	grid[room_height - 2][3] = 1
	grid[room_height - 2][4] = 1

	# 4. Deterministic extraction portal platform (Right side)
	var ext_x = room_width - 5
	var ext_y = min(6, room_height - 5)
	extraction_pos = Vector2(ext_x * tile_size, ext_y * tile_size)
	grid[ext_y][ext_x] = 1
	grid[ext_y][ext_x + 1] = 1
	grid[ext_y][ext_x + 2] = 1
	_spawn_platform_node(ext_x, ext_y, 3)

	# 5. Generate stepping stone platforms using seeded RNG
	var num_platforms = 5 + depth_level * 3
	for i in range(num_platforms):
		var px = rng.randi_range(5, room_width - 7)
		var py = rng.randi_range(4, room_height - 4)
		var p_width = rng.randi_range(3, 6)

		for w in range(p_width):
			if px + w < room_width - 1:
				grid[py][px + w] = 1

		_spawn_platform_node(px, py, p_width)

		# 6. Seeded enemy & loot placement on platform top
		if rng.randf() < 0.7:
			enemy_spawn_positions.append(Vector2((px + 1) * tile_size, (py - 1) * tile_size))
		if rng.randf() < 0.4:
			loot_spawn_positions.append(Vector2((px + 2) * tile_size, (py - 1) * tile_size))

	# 7. Seeded environmental hazards placement along floor
	for hx in range(6, room_width - 6, 4):
		if rng.randf() < 0.4:
			grid[room_height - 2][hx] = 2 # HAZARD
			var h_pos = Vector2(hx * tile_size, (room_height - 2) * tile_size)
			hazard_positions.append(h_pos)
			_spawn_hazard_visual(hx, room_height - 2)

	# 8. Validate connectivity
	var valid = validate_topology()

	return {
		"seed": seed_value,
		"biome": biome,
		"grid": grid,
		"player_spawn": player_spawn_pos,
		"extraction_pos": extraction_pos,
		"enemy_spawns": enemy_spawn_positions,
		"loot_spawns": loot_spawn_positions,
		"hazard_spawns": hazard_positions,
		"room_width_px": room_width * tile_size,
		"room_height_px": room_height * tile_size,
		"is_valid": valid
	}

func _update_stage_boundaries() -> void:
	var total_w = room_width * tile_size
	var total_h = room_height * tile_size

	# Update BG color rect
	var bg = get_node_or_null("../BG") as ColorRect
	if bg:
		bg.offset_right = total_w
		bg.offset_bottom = total_h

	# Update Ground platform
	var ground = get_node_or_null("../StaticPlatforms/GroundPlatform") as StaticBody2D
	if ground:
		ground.position = Vector2(total_w * 0.5, total_h - 4)
		var shape = ground.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape and shape.shape is RectangleShape2D:
			(shape.shape as RectangleShape2D).size = Vector2(total_w * 2, 16)
		var visual = ground.get_node_or_null("GroundVisual") as ColorRect
		if visual:
			visual.offset_left = -total_w
			visual.offset_right = total_w

	# Update Right Wall
	var right_wall = get_node_or_null("../StaticPlatforms/RightWall") as StaticBody2D
	if right_wall:
		right_wall.position = Vector2(total_w + 4, total_h * 0.5)
		var shape = right_wall.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape and shape.shape is RectangleShape2D:
			(shape.shape as RectangleShape2D).size = Vector2(total_h * 2, 16)

	# Update Left Wall
	var left_wall = get_node_or_null("../StaticPlatforms/LeftWall") as StaticBody2D
	if left_wall:
		left_wall.position = Vector2(-4, total_h * 0.5)
		var shape = left_wall.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape and shape.shape is RectangleShape2D:
			(shape.shape as RectangleShape2D).size = Vector2(total_h * 2, 16)

	# Update Extraction Beacon position
	var beacon = get_node_or_null("../ExtractionBeacon") as Node2D
	if beacon:
		beacon.position = Vector2(total_w - 48, min(96, total_h - 60))

func _spawn_platform_node(px: int, py: int, p_width: int) -> void:
	var target_container = get_node_or_null("../StaticPlatforms")
	if target_container == null:
		target_container = self

	var body = StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 6

	var shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(p_width * tile_size, 8)
	shape.shape = rect_shape
	body.add_child(shape)

	var visual = ColorRect.new()
	visual.offset_left = -(p_width * tile_size * 0.5)
	visual.offset_top = -4.0
	visual.offset_right = (p_width * tile_size * 0.5)
	visual.offset_bottom = 4.0
	visual.color = Color(0.3, 0.35, 0.4, 1.0)
	body.add_child(visual)

	body.position = Vector2((px + float(p_width) * 0.5) * tile_size, (py + 0.5) * tile_size)
	target_container.add_child(body)
	generated_nodes.append(body)

func _spawn_hazard_visual(hx: int, hy: int) -> void:
	var target_container = get_node_or_null("../StaticPlatforms")
	if target_container == null:
		target_container = self

	var hazard_rect = ColorRect.new()
	hazard_rect.size = Vector2(tile_size * 2, 6)
	hazard_rect.position = Vector2(hx * tile_size, (hy + 0.5) * tile_size)
	hazard_rect.color = Color(1.0, 0.2, 0.1, 0.95)
	target_container.add_child(hazard_rect)
	generated_nodes.append(hazard_rect)

func validate_topology() -> bool:
	var start_tile = Vector2i(int(player_spawn_pos.x / tile_size), int(player_spawn_pos.y / tile_size))
	var end_tile = Vector2i(int(extraction_pos.x / tile_size), int(extraction_pos.y / tile_size))

	var visited: Dictionary = {}
	var queue: Array[Vector2i] = [start_tile]
	visited[start_tile] = true

	var directions = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, -1)]

	while queue.size() > 0:
		var curr = queue.pop_front()
		if curr.distance_to(end_tile) <= 3.0: # Reachable range
			return true

		for dir in directions:
			var nxt = curr + dir
			if nxt.x >= 0 and nxt.x < room_width and nxt.y >= 0 and nxt.y < room_height:
				if not visited.has(nxt) and grid[nxt.y][nxt.x] != 1: # Air space pathing
					visited[nxt] = true
					queue.append(nxt)

	return false
