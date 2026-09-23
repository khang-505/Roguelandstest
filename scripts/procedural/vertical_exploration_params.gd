# scripts/procedural/vertical_exploration_params.gd
class_name VerticalExplorationParams
extends Resource

## Centralized configuration resource for vertical world layers, platform gap bounds, and player traversal physics constraints.

# Vertical World Layers
enum VerticalLayer {
	DEEP_UNDERGROUND = 0,
	UNDERGROUND_CAVE = 1,
	LOWER_GAMEPLAY = 2,
	MAIN_GAMEPLAY = 3,
	UPPER_EXPLORATION = 4,
	UPPER_SECRET = 5
}

@export var verticality: float = 0.65 # 0.0 (mostly flat) to 1.0 (extreme verticality)
@export var max_layers: int = 6
@export var min_vertical_gap: float = 48.0 # Minimum Y gap between platform tiers (px)
@export var max_vertical_gap: float = 140.0 # Maximum Y jump height gap (px) (Player Max Jump <= 160px)
@export var max_jump_distance: float = 160.0 # Maximum X jump distance gap (px)
@export var max_fall_distance: float = 350.0 # Maximum safe drop distance (px)

@export var platform_density: float = 0.50
@export var upper_route_probability: float = 0.45
@export var lower_route_probability: float = 0.40
@export var underground_probability: float = 0.35
@export var secret_vertical_probability: float = 0.20

func init_for_biome(biome_id: String) -> void:
	match biome_id:
		"jungle", "verdant_4":
			verticality = 0.75
			upper_route_probability = 0.60
			lower_route_probability = 0.45
			underground_probability = 0.40
		"mine", "iron_core":
			verticality = 0.85
			upper_route_probability = 0.40
			lower_route_probability = 0.70
			underground_probability = 0.60
		"frozen", "frostgrave_9":
			verticality = 0.70
			upper_route_probability = 0.50
			lower_route_probability = 0.50
			underground_probability = 0.30
		"machine", "eclipse_7":
			verticality = 0.80
			upper_route_probability = 0.65
			lower_route_probability = 0.40
			underground_probability = 0.35
		_:
			verticality = 0.65
