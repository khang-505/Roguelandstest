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

func generate_room(seed_value: int, biome_id: String = "emberwild") -> Dictionary:
	_clear_generated_nodes()
	var biome = BiomeData.get_biome(biome_id)
	rng.seed = seed_value
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
	extraction_pos = Vector2((room_width - 4) * tile_size, 4 * tile_size)
	grid[5][room_width - 5] = 1
	grid[5][room_width - 4] = 1
	grid[5][room_width - 3] = 1
	_spawn_platform_node(room_width - 5, 5, 3)

	# 5. Generate stepping stone platforms using seeded RNG
	var num_platforms = rng.randi_range(4, 7)
	for i in range(num_platforms):
		var px = rng.randi_range(6, room_width - 8)
		var py = rng.randi_range(5, room_height - 4)
		var p_width = rng.randi_range(3, 5)

		for w in range(p_width):
			if px + w < room_width - 1:
				grid[py][px + w] = 1

		_spawn_platform_node(px, py, p_width)

		# 6. Seeded enemy & loot placement on platform top
		if rng.randf() < 0.6:
			enemy_spawn_positions.append(Vector2((px + 1) * tile_size, (py - 1) * tile_size))
		if rng.randf() < 0.4:
			loot_spawn_positions.append(Vector2((px + 2) * tile_size, (py - 1) * tile_size))

	# 7. Seeded environmental hazards placement along floor
	for hx in range(6, room_width - 6, 3):
		if rng.randf() < 0.35:
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
		"is_valid": valid
	}

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
