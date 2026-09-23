# scripts/procedural/terrain_profile.gd
class_name TerrainProfile
extends Resource

## Centralized configuration resource for biome terrain parameters, density, and slope/cave probabilities.

@export var terrain_id: String = "emberwild_mining"
@export var biome_id: String = "emberwild"
@export var platform_density: float = 0.60
@export var slope_probability: float = 0.35
@export var cliff_probability: float = 0.45
@export var cave_probability: float = 0.70
@export var verticality: float = 0.85
@export var hazard_density: float = 0.40
@export var compatibility_tags: Array = ["mining", "rock", "industrial"]

func init_for_biome(b_id: String) -> void:
	biome_id = b_id
	match b_id:
		"emberwild":
			terrain_id = "emberwild_mining"
			platform_density = 0.65
			slope_probability = 0.30
			cliff_probability = 0.50
			cave_probability = 0.70
			verticality = 0.85
			hazard_density = 0.40
			compatibility_tags = ["mining", "rock", "industrial"]

		"verdant_abyss":
			terrain_id = "verdant_canopy"
			platform_density = 0.75
			slope_probability = 0.60
			cliff_probability = 0.35
			cave_probability = 0.80
			verticality = 0.75
			hazard_density = 0.30
			compatibility_tags = ["jungle", "organic", "vines"]

		"frostgrave":
			terrain_id = "frostgrave_ice"
			platform_density = 0.50
			slope_probability = 0.70
			cliff_probability = 0.60
			cave_probability = 0.50
			verticality = 0.70
			hazard_density = 0.35
			compatibility_tags = ["frozen", "glacial", "slippery"]

		"industrial_core":
			terrain_id = "industrial_complex"
			platform_density = 0.80
			slope_probability = 0.20
			cliff_probability = 0.70
			cave_probability = 0.30
			verticality = 0.80
			hazard_density = 0.50
			compatibility_tags = ["industrial", "metal", "mechanical"]

		"alien_void", _:
			terrain_id = "alien_void_realm"
			platform_density = 0.70
			slope_probability = 0.25
			cliff_probability = 0.65
			cave_probability = 0.60
			verticality = 0.90
			hazard_density = 0.45
			compatibility_tags = ["corrupted", "alien", "void"]
