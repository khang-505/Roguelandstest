# scripts/core/world_manager.gd
class_name WorldManagerSingleton
extends Node

## Handles world instance lifecycle, seed generation, biome data, and level loading.

var current_world_seed: int = 1337
var current_biome_id: String = "emberwild"
var is_world_active: bool = false
var extraction_unlocked: bool = false
var instability_level: float = 0.0

func _ready() -> void:
	EventBus.world_generated.connect(_on_world_generated)

func prepare_world(seed_val: int, biome_id: String = "emberwild") -> void:
	current_world_seed = seed_val
	current_biome_id = biome_id
	instability_level = 0.0
	extraction_unlocked = false
	is_world_active = true
	EventBus.world_generated.emit(current_world_seed, current_biome_id)

func set_extraction_ready(p_ready: bool) -> void:
	extraction_unlocked = p_ready

func increase_instability(amount: float) -> void:
	instability_level = clamp(instability_level + amount, 0.0, 100.0)

func _on_world_generated(_seed_val: int, _world_name: String) -> void:
	is_world_active = true
