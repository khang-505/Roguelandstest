# scripts/procedural/biome_data.gd
class_name BiomeData
extends Resource

## Data-Driven Biome Definition for Starfall Frontier planets.

@export var id: String = "emberwild"
@export var display_name: String = "Emberwild Frontier"
@export var theme_color: Color = Color(0.9, 0.3, 0.2, 1.0)
@export var background_color: Color = Color(0.12, 0.05, 0.05, 1.0)
@export var hazard_type: String = "LAVA"
@export var instability_rate: float = 1.0 # Multiplier per minute
@export var enemy_pool: Array = ["ash_beetle"]
@export var resource_pool: Array = ["ember_ore", "star_shard"]

static var biome_registry: Dictionary = {}

static func _static_init() -> void:
	_setup_registry()

static func _setup_registry() -> void:
	if biome_registry.size() > 0:
		return

	# Biome 1: Emberwild (Volcanic Jungle)
	var ember = BiomeData.new()
	ember.id = "emberwild"
	ember.display_name = "Emberwild Frontier"
	ember.theme_color = Color(0.95, 0.35, 0.15, 1.0)
	ember.background_color = Color(0.14, 0.06, 0.04, 1.0)
	ember.hazard_type = "LAVA"
	ember.enemy_pool = ["ash_beetle"]
	ember.resource_pool = ["ember_ore", "star_shard"]
	biome_registry["emberwild"] = ember

	# Biome 2: Frostgrave (Frozen Wasteland)
	var frost = BiomeData.new()
	frost.id = "frostgrave"
	frost.display_name = "Frostgrave Wasteland"
	frost.theme_color = Color(0.25, 0.75, 0.95, 1.0)
	frost.background_color = Color(0.04, 0.08, 0.14, 1.0)
	frost.hazard_type = "ICE_SPIKES"
	frost.enemy_pool = ["frost_spider", "ash_beetle"]
	frost.resource_pool = ["cryo_crystal", "star_shard"]
	biome_registry["frostgrave"] = frost

	# Biome 3: Verdant Abyss (Overgrown Alien Ecosystem)
	var verdant = BiomeData.new()
	verdant.id = "verdant_abyss"
	verdant.display_name = "Verdant Abyss"
	verdant.theme_color = Color(0.20, 0.85, 0.40, 1.0)
	verdant.background_color = Color(0.04, 0.12, 0.06, 1.0)
	verdant.hazard_type = "TOXIC_SPORES"
	verdant.enemy_pool = ["spore_crawler", "ash_beetle"]
	verdant.resource_pool = ["bio_sample", "star_shard"]
	biome_registry["verdant_abyss"] = verdant

static func get_biome(b_id: String) -> BiomeData:
	_setup_registry()
	if biome_registry.has(b_id):
		return biome_registry[b_id]
	return biome_registry["emberwild"]
