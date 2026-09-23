# scripts/procedural/room_generator.gd
class_name RoomGenerator
extends Node2D

## Modular Room Generator creating archetype rooms (Combat, Exploration, Secret, Boss) with connectors.

@export var room_width: int = 32 # tiles (16px per tile = 512px)
@export var room_height: int = 18 # tiles (16px per tile = 288px)
@export var tile_size: int = 16

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var grid: Array = []
var generated_nodes: Array[Node] = []
var current_biome_id: String = ""

func _clear_generated_nodes() -> void:
	for n in generated_nodes:
		if is_instance_valid(n):
			n.queue_free()
	generated_nodes.clear()

func generate_room(seed_value: int, _depth_level: int = 1, biome_id: String = "emberwild") -> Dictionary:
	return generate_archetype_room(seed_value, 0, 1, biome_id)

func generate_archetype_room(
	seed_value: int,
	room_id: int,
	archetype: int,
	biome_id: String = "emberwild"
) -> Dictionary:
	_clear_generated_nodes()
	current_biome_id = biome_id
	var biome = BiomeData.get_biome(biome_id)
	rng.seed = seed_value + room_id

	_update_room_bounds(biome)

	# Dynamic helper script resolution
	var room_sel = load("res://scripts/procedural/room_selector.gd")
	var variant_mgr = load("res://scripts/procedural/room_variant_manager.gd")
	var platform_gen = load("res://scripts/procedural/platform_generator.gd")
	var spawn_gen = load("res://scripts/procedural/spawn_generator.gd")
	var loot_gen = load("res://scripts/procedural/loot_generator.gd")
	var cave_gen = load("res://scripts/procedural/cave_generator.gd")
	var secret_gen = load("res://scripts/procedural/secret_generator.gd")
	var landmark_mgr = load("res://scripts/procedural/landmark_manager.gd")

	# Select RoomData template & variant
	var template: Object = null
	if room_sel and room_sel.has_method("select_room_template"):
		template = room_sel.select_room_template(archetype, biome_id, 1.0, rng)

	# 1. Platform Traversal Generation
	var platform_spots: Array[Vector2] = []
	if platform_gen and platform_gen.has_method("generate_platforms_for_room"):
		platform_spots = platform_gen.generate_platforms_for_room(
			self, room_width, room_height, tile_size, biome.verticality, rng
		)

	# 2. Content Variant Assembly
	var variant_data: Dictionary = {}
	if variant_mgr and variant_mgr.has_method("assemble_room_variant"):
		variant_data = variant_mgr.assemble_room_variant(template, platform_spots, biome, rng)

	# 3. Cave Section Generation
	if cave_gen and cave_gen.has_method("generate_cave_section"):
		cave_gen.generate_cave_section(self, room_width, room_height, tile_size, rng)

	# 4. Secret Breakable Walls
	if secret_gen and secret_gen.has_method("spawn_secret_walls_for_room"):
		secret_gen.spawn_secret_walls_for_room(self, room_width, room_height, tile_size, archetype, rng)

	# 5. Landmark Visual Anchor
	if landmark_mgr and landmark_mgr.has_method("spawn_landmark_for_room"):
		landmark_mgr.spawn_landmark_for_room(self, room_width, room_height, tile_size, archetype, biome, rng)

	# 6. Door Connectors
	_spawn_connectors(archetype)

	# 7. Enemy Spawns
	var enemies: Array[Node2D] = []
	var e_spots: Array[Vector2] = []
	var raw_spots = variant_data.get("enemy_spots", platform_spots) as Array
	for s in raw_spots:
		if s is Vector2: e_spots.append(s)

	if spawn_gen and spawn_gen.has_method("spawn_enemies_for_room"):
		enemies = spawn_gen.spawn_enemies_for_room(
			self, e_spots, archetype, biome, rng
		)

	# 8. Loot & Resource Spawns
	if loot_gen and loot_gen.has_method("spawn_loot_for_room"):
		loot_gen.spawn_loot_for_room(
			self, platform_spots, archetype, biome, rng
		)

	# 9. Determine Player & Exit positions
	var player_spawn = Vector2(3 * tile_size, (room_height - 3) * tile_size)
	var exit_pos = Vector2((room_width - 4) * tile_size, (room_height - 3) * tile_size)

	var enemy_spawns: Array[Vector2] = []
	for e in enemies:
		if is_instance_valid(e): enemy_spawns.append(e.global_position)

	return {
		"room_id": room_id,
		"archetype": archetype,
		"seed": seed_value,
		"biome": biome,
		"template": template,
		"player_spawn": player_spawn,
		"exit_pos": exit_pos,
		"enemy_spawns": enemy_spawns,
		"loot_spawns": platform_spots,
		"hazard_spawns": [],
		"resource_spawns": platform_spots,
		"enemy_count": enemies.size(),
		"room_width_px": room_width * tile_size,
		"room_height_px": room_height * tile_size,
		"is_valid": true
	}

func _spawn_connectors(archetype: int) -> void:
	var connector_script = load("res://scripts/procedural/room_connector.gd")
	if connector_script:
		var east_door = connector_script.new() as Area2D
		east_door.set("direction", 2) # EAST
		east_door.position = Vector2((room_width - 1) * tile_size, (room_height - 3) * tile_size)
		add_child(east_door)
		generated_nodes.append(east_door)

		if (archetype == 1 or archetype == 7) and east_door.has_method("set_locked"):
			east_door.call("set_locked", false)

func _update_room_bounds(biome: Object) -> void:
	var total_w = room_width * tile_size
	var total_h = room_height * tile_size

	var bg = get_node_or_null("../BG") as ColorRect
	if bg:
		bg.offset_right = total_w
		bg.offset_bottom = total_h + 32
		if biome and "background_color" in biome:
			bg.color = biome.background_color
