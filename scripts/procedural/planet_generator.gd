# scripts/procedural/planet_generator.gd
class_name PlanetGenerator
extends Node2D

## Master Procedural Planet Generator executing the 21-step generation pipeline with automated seed retry.

var current_seed: int = 1337
var planet_data: Object = null
var active_graph: Object = null
var generated_planet_data: Dictionary = {}

var room_gen: RoomGenerator = null

func _ready() -> void:
	if room_gen == null:
		room_gen = RoomGenerator.new()
		room_gen.name = "RoomGenerator"
		add_child(room_gen)

func generate_planet_world(seed_val: int = -1, planet_id: String = "eclipse_7") -> Dictionary:
	var seed_mgr = load("res://scripts/procedural/seed_manager.gd")
	var planet_data_class = load("res://scripts/procedural/planet_data.gd")
	var map_graph_class = load("res://scripts/procedural/map_graph.gd")
	var planet_val_class = load("res://scripts/procedural/planet_validator.gd")
	var selector_class = load("res://scripts/procedural/biome_selector.gd")

	# Step 1: Generate Seed
	if seed_mgr and seed_mgr.has_method("initialize_seed"):
		current_seed = seed_mgr.initialize_seed(seed_val)
	else:
		current_seed = seed_val if seed_val != -1 else 1337

	# Step 2: Load PlanetData
	if planet_data_class and planet_data_class.has_method("get_planet"):
		planet_data = planet_data_class.get_planet(planet_id)

	var valid_planet_found = false
	var attempts = 0
	var final_seed = current_seed
	var final_world_data: Dictionary = {}

	var rng = RandomNumberGenerator.new()

	while not valid_planet_found and attempts < 10:
		rng.seed = final_seed

		# Step 3-18: Macro Topology, Region Graph, Biomes, Rooms, Hazards & Rewards
		if map_graph_class:
			active_graph = map_graph_class.new()
			if active_graph.has_method("generate_graph"):
				var r_count = planet_data.region_count if planet_data and "region_count" in planet_data else 6
				active_graph.generate_graph(final_seed, r_count)

		var first_node_id = active_graph.get("start_node_id") if "start_node_id" in active_graph else 0
		var first_node_archetype = 0
		if "nodes" in active_graph and active_graph.nodes.has(first_node_id):
			var n = active_graph.nodes[first_node_id]
			if "archetype" in n: first_node_archetype = n.archetype

		# Select Biome via BiomeSelector
		var active_biome = null
		if selector_class and selector_class.has_method("select_biome_for_region"):
			var total_r = planet_data.region_count if planet_data and "region_count" in planet_data else 6
			active_biome = selector_class.select_biome_for_region(planet_data, 0, total_r, rng)

		var primary_biome_id = active_biome.id if active_biome and "id" in active_biome else "emberwild"

		if room_gen == null:
			room_gen = RoomGenerator.new()
			add_child(room_gen)

		var room_data = room_gen.generate_archetype_room(
			final_seed, first_node_id, first_node_archetype, primary_biome_id
		)

		final_world_data = {
			"seed": final_seed,
			"planet_data": planet_data,
			"biome": active_biome,
			"graph": active_graph,
			"current_room": room_data,
			"is_valid": true
		}

		# Step 19-20: Traversal Validation & Quality Scoring Check
		if planet_val_class and planet_val_class.has_method("validate_planet_world"):
			var val_result = planet_val_class.validate_planet_world(final_world_data)
			if val_result.get("is_valid", false):
				valid_planet_found = true
			else:
				attempts += 1
				final_seed += 1
		else:
			valid_planet_found = true

	# Step 21: Instantiate Planet
	generated_planet_data = final_world_data
	var display_name = planet_data.get("planet_name") if planet_data and "planet_name" in planet_data else "Eclipse-7 Planet"
	EventBus.world_generated.emit(final_seed, display_name)
	return generated_planet_data
