# scripts/core/world_manager.gd
class_name WorldManagerSingleton
extends Node

## Handles world instance lifecycle, seed generation, biome data, and level loading.

var current_world_seed: int = 1337
var current_biome_id: String = "emberwild"
var current_planet_id: String = "eclipse_7"
var is_world_active: bool = false
var extraction_unlocked: bool = false
var instability_level: float = 0.0

var active_map_generator: Node = null
var active_graph: Object = null
var active_planet_data: Object = null

func _ready() -> void:
	EventBus.world_generated.connect(_on_world_generated)

func prepare_world(seed_val: int, biome_id: String = "emberwild") -> void:
	current_world_seed = seed_val
	current_biome_id = biome_id
	instability_level = 0.0
	extraction_unlocked = false
	is_world_active = true

	var planet_gen_class = load("res://scripts/procedural/planet_generator.gd")
	if planet_gen_class:
		active_map_generator = planet_gen_class.new()
		active_map_generator.name = "PlanetGenerator"
		add_child(active_map_generator)

		if active_map_generator.has_method("generate_planet_world"):
			var world_data = active_map_generator.generate_planet_world(current_world_seed, current_planet_id)
			if world_data.has("graph"):
				active_graph = world_data["graph"]
			if world_data.has("planet_data"):
				active_planet_data = world_data["planet_data"]

	EventBus.world_generated.emit(current_world_seed, current_biome_id)

func set_extraction_ready(p_ready: bool) -> void:
	extraction_unlocked = p_ready

func increase_instability(amount: float) -> void:
	instability_level = clamp(instability_level + amount, 0.0, 100.0)

func _on_world_generated(_seed_val: int, _world_name: String) -> void:
	is_world_active = true
