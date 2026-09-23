# scripts/procedural/biome_data.gd
class_name BiomeData
extends Resource

## Data-Driven Biome Definition for Starfall Frontier planets.

@export var id: String = "emberwild"
@export var display_name: String = "Emberwild Frontier (Mining/Volcanic)"
@export var description: String = "Volcanic mining sector dense with ore veins, lava pools, and automated mining drones."
@export var theme_color: Color = Color(0.95, 0.35, 0.15, 1.0)
@export var background_color: Color = Color(0.14, 0.06, 0.04, 1.0)
@export var hazard_type: String = "LAVA"
@export var instability_rate: float = 1.0 # Multiplier per minute

@export var enemy_pool: Array = ["ash_beetle", "iron_golem", "exploder_bug"]
@export var elite_pool: Array = ["molten_elite"]
@export var resource_pool: Array = ["ember_ore", "star_shard", "iron_scrap"]
@export var loot_pool: Array = ["armor_module", "plasma_blade", "heavy_blaster"]

@export var verticality: float = 0.85 # 0.0 = flat, 1.0 = highly vertical
@export var cave_probability: float = 0.70
@export var treasure_probability: float = 0.20
@export var elite_probability: float = 0.25
@export var secret_probability: float = 0.35
@export var hazard_density: float = 0.40
@export var enemy_density: float = 1.0
@export var compatibility_tags: Array = ["mining", "industrial", "caves", "vertical"]

static var biome_registry: Dictionary = {}

static func _static_init() -> void:
	_setup_registry()

static func _setup_registry() -> void:
	if biome_registry.size() > 0:
		return

	# Biome 1: Emberwild (Mining / Volcanic)
	var ember = BiomeData.new()
	ember.id = "emberwild"
	ember.display_name = "Emberwild Frontier (Mining/Volcanic)"
	ember.description = "Volcanic mining sector dense with ore veins, lava pools, and automated mining drones."
	ember.theme_color = Color(0.95, 0.35, 0.15, 1.0)
	ember.background_color = Color(0.14, 0.06, 0.04, 1.0)
	ember.hazard_type = "LAVA"
	ember.verticality = 0.85
	ember.cave_probability = 0.70
	ember.enemy_pool = ["ash_beetle", "iron_golem", "exploder_bug"]
	ember.resource_pool = ["ember_ore", "star_shard", "iron_scrap"]
	ember.loot_pool = ["armor_module", "plasma_blade", "heavy_blaster"]
	ember.compatibility_tags = ["mining", "industrial", "caves", "vertical"]
	biome_registry["emberwild"] = ember

	# Biome 2: Frostgrave (Ice Wasteland)
	var frost = BiomeData.new()
	frost.id = "frostgrave"
	frost.display_name = "Frostgrave Glacial Wasteland"
	frost.description = "Frozen sub-zero tundra with slippery glacial platforms, cryo crystals, and stalking predators."
	frost.theme_color = Color(0.25, 0.75, 0.95, 1.0)
	frost.background_color = Color(0.04, 0.08, 0.14, 1.0)
	frost.hazard_type = "ICE_SPIKES"
	frost.verticality = 0.70
	frost.cave_probability = 0.50
	frost.enemy_pool = ["frost_stalker", "flying_drone", "crystal_construct"]
	frost.resource_pool = ["cryo_crystal", "star_shard"]
	frost.loot_pool = ["frost_artifact", "cryo_blaster"]
	frost.compatibility_tags = ["frozen", "glacial", "slippery"]
	biome_registry["frostgrave"] = frost

	# Biome 3: Verdant Abyss (Forest Jungle)
	var verdant = BiomeData.new()
	verdant.id = "verdant_abyss"
	verdant.display_name = "Verdant Canopy & Root Caverns"
	verdant.description = "Overgrown jungle canopy featuring vine pathways, toxic spore clouds, and organic flora."
	verdant.theme_color = Color(0.20, 0.85, 0.40, 1.0)
	verdant.background_color = Color(0.04, 0.12, 0.06, 1.0)
	verdant.hazard_type = "TOXIC_SPORES"
	verdant.verticality = 0.75
	verdant.cave_probability = 0.80
	verdant.enemy_pool = ["flying_drone", "ash_beetle", "exploder_bug"]
	verdant.resource_pool = ["bio_sample", "star_shard", "rare_plant"]
	verdant.loot_pool = ["poison_artifact", "bio_sword"]
	verdant.compatibility_tags = ["jungle", "organic", "canopy"]
	biome_registry["verdant_abyss"] = verdant

	# Biome 4: Alien Void (Deep Void / Corrupted)
	var alien = BiomeData.new()
	alien.id = "alien_void"
	alien.display_name = "Alien Void Core"
	alien.description = "Corrupted cosmic realm with anti-gravity anomalies, rare void artifacts, and aggressive entities."
	alien.theme_color = Color(0.75, 0.20, 0.95, 1.0)
	alien.background_color = Color(0.08, 0.03, 0.14, 1.0)
	alien.hazard_type = "VOID_RIFT"
	alien.verticality = 0.90
	alien.cave_probability = 0.60
	alien.enemy_pool = ["void_lurker", "flying_drone", "frost_stalker"]
	alien.resource_pool = ["star_shard", "bio_sample", "void_core"]
	alien.loot_pool = ["void_artifact", "energy_weapon"]
	alien.compatibility_tags = ["corrupted", "alien", "void"]
	biome_registry["alien_void"] = alien

	# Biome 5: Industrial Core (Machine World)
	var machine = BiomeData.new()
	machine.id = "industrial_core"
	machine.display_name = "Industrial Machine Complex"
	machine.description = "High-tech automated facility with mechanical lifts, laser grids, and security turrets."
	machine.theme_color = Color(0.40, 0.60, 0.90, 1.0)
	machine.background_color = Color(0.06, 0.08, 0.12, 1.0)
	machine.hazard_type = "LASER_GRID"
	machine.verticality = 0.80
	machine.cave_probability = 0.30
	machine.enemy_pool = ["security_bot", "flying_drone", "iron_golem"]
	machine.resource_pool = ["iron_scrap", "energy_core", "star_shard"]
	machine.loot_pool = ["energy_weapon", "shield_module"]
	machine.compatibility_tags = ["industrial", "machine", "mechanical"]
	biome_registry["industrial_core"] = machine

static func get_biome(b_id: String) -> Resource:
	_setup_registry()
	if biome_registry.has(b_id):
		return biome_registry[b_id] as Resource
	return biome_registry["emberwild"] as Resource

static func get_all_biome_ids() -> Array[String]:
	_setup_registry()
	var keys: Array[String] = []
	for k in biome_registry.keys():
		keys.append(str(k))
	return keys
