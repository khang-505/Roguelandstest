# scripts/procedural/map_generator.gd
class_name MapGenerator
extends Node2D

## Master Procedural Map Generator executing the 15-step Roguelands generation pipeline.

var current_seed: int = 1337
var current_biome: Object = null
var active_graph: Object = null
var active_room_id: int = 0
var generated_world_data: Dictionary = {}

var room_gen: RoomGenerator = null

func _ready() -> void:
	if room_gen == null:
		room_gen = RoomGenerator.new()
		room_gen.name = "RoomGenerator"
		add_child(room_gen)

func generate_planet_world(seed_val: int = -1, biome_id: String = "emberwild") -> Dictionary:
	var seed_mgr = load("res://scripts/procedural/seed_manager.gd")
	var map_graph_class = load("res://scripts/procedural/map_graph.gd")
	var map_val_class = load("res://scripts/procedural/map_validator.gd")

	# Step 1: Generate Seed
	if seed_mgr and seed_mgr.has_method("initialize_seed"):
		current_seed = seed_mgr.initialize_seed(seed_val)
	else:
		current_seed = seed_val if seed_val != -1 else 1337

	# Step 2: Select Biome
	current_biome = BiomeData.get_biome(biome_id)

	var valid_map_found = false
	var attempts = 0
	var final_seed = current_seed

	while not valid_map_found and attempts < 10:
		# Step 3: Generate Macro Map Graph
		if map_graph_class:
			active_graph = map_graph_class.new()
			if active_graph.has_method("generate_graph"):
				active_graph.generate_graph(final_seed, 6)

		# Step 4: Validate Graph
		if map_val_class and map_val_class.has_method("validate_graph"):
			var val_result = map_val_class.validate_graph(active_graph)
			if val_result.get("is_valid", false):
				valid_map_found = true
			else:
				attempts += 1
				final_seed += 1
		else:
			valid_map_found = true

	if room_gen == null:
		room_gen = RoomGenerator.new()
		add_child(room_gen)

	# Step 5 to 15: Select Room Archetypes, Platforms, Spawns, Secrets & Instantiate
	var first_node_id = active_graph.get("start_node_id") if "start_node_id" in active_graph else 0
	var first_node_archetype = 0
	if "nodes" in active_graph and active_graph.nodes.has(first_node_id):
		var n = active_graph.nodes[first_node_id]
		if "archetype" in n: first_node_archetype = n.archetype

	var room_data = room_gen.generate_archetype_room(
		final_seed, first_node_id, first_node_archetype, current_biome.id
	)

	generated_world_data = {
		"seed": final_seed,
		"biome": current_biome,
		"graph": active_graph,
		"current_room": room_data,
		"is_valid": true
	}

	var display_name = current_biome.get("display_name") if "display_name" in current_biome else "Emberwild"
	EventBus.world_generated.emit(final_seed, display_name)
	return generated_world_data
