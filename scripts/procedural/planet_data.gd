# scripts/procedural/planet_data.gd
class_name PlanetData
extends Resource

## Data-Driven Planet Definition for Starfall Frontier procedural worlds.

@export var planet_id: String = "eclipse_7"
@export var planet_name: String = "Eclipse-7 Mining Planet"
@export var description: String = "Abandoned alien mining planet rich in rare minerals, vertical shafts, and industrial hazards."
@export var theme: String = "Abandoned Alien Mining Planet"

@export var starting_biome_id: String = "emberwild"
@export var final_biome_id: String = "industrial_core"
@export var biome_pool: Array = ["emberwild", "industrial_core", "alien_void"]
@export var region_count: int = 10
@export var difficulty: float = 1.0
@export var verticality: float = 0.85
@export var cave_frequency: float = 0.70
@export var secret_frequency: float = 0.40
@export var boss_id: String = "molten_warden"
@export var unique_mechanic: String = "DESTRUCTIBLE_MINING_SHAFTS_AND_ELEVATORS"
@export var compatibility_tags: Array = ["mining", "industrial", "caves", "vertical"]

static var planet_registry: Dictionary = {}

static func _static_init() -> void:
	_setup_registry()

static func _setup_registry() -> void:
	if planet_registry.size() > 0:
		return

	var p_script = load("res://scripts/procedural/planet_data.gd")
	if not p_script:
		return

	# Planet 1: Eclipse-7 (Mining Planet)
	var eclipse = p_script.new()
	eclipse.planet_id = "eclipse_7"
	eclipse.planet_name = "Eclipse-7 Mining Planet"
	eclipse.description = "Abandoned alien mining planet rich in rare minerals, vertical shafts, and industrial hazards."
	eclipse.theme = "Abandoned Alien Mining Planet"
	eclipse.starting_biome_id = "emberwild"
	eclipse.final_biome_id = "industrial_core"
	eclipse.biome_pool = ["emberwild", "industrial_core", "alien_void"]
	eclipse.region_count = 10
	eclipse.difficulty = 1.0
	eclipse.verticality = 0.85
	eclipse.cave_frequency = 0.70
	eclipse.secret_frequency = 0.40
	eclipse.boss_id = "molten_warden"
	eclipse.unique_mechanic = "DESTRUCTIBLE_MINING_SHAFTS_AND_ELEVATORS"
	eclipse.compatibility_tags = ["mining", "industrial", "caves", "vertical"]
	planet_registry["eclipse_7"] = eclipse

	# Planet 2: Verdant-4 (Alien Jungle World)
	var verdant = p_script.new()
	verdant.planet_id = "verdant_4"
	verdant.planet_name = "Verdant-4 Jungle World"
	verdant.description = "Overgrown alien biosphere with dense canopy, subterranean root caverns, and toxic spore pockets."
	verdant.theme = "Overgrown Bio-Sphere"
	verdant.starting_biome_id = "verdant_abyss"
	verdant.final_biome_id = "alien_void"
	verdant.biome_pool = ["verdant_abyss", "alien_void", "emberwild"]
	verdant.region_count = 12
	verdant.difficulty = 1.50
	verdant.verticality = 0.75
	verdant.cave_frequency = 0.80
	verdant.secret_frequency = 0.60
	verdant.boss_id = "ancient_guardian"
	verdant.unique_mechanic = "CANOPY_VINES_AND_POISON_SPORE_POCKETS"
	verdant.compatibility_tags = ["jungle", "organic", "canopy", "poison"]
	planet_registry["verdant_4"] = verdant

	# Planet 3: Frostgrave-9 (Frozen Research World)
	var frost = p_script.new()
	frost.planet_id = "frostgrave_9"
	frost.planet_name = "Frostgrave-9 Ice Wasteland"
	frost.description = "Frozen glacial planet housing abandoned cryo-facilities, slippery ice cliffs, and blizzards."
	frost.theme = "Frozen Glacial Core"
	frost.starting_biome_id = "frostgrave"
	frost.final_biome_id = "alien_void"
	frost.biome_pool = ["frostgrave", "alien_void", "industrial_core"]
	frost.region_count = 8
	frost.difficulty = 1.25
	frost.verticality = 0.70
	frost.cave_frequency = 0.50
	frost.secret_frequency = 0.50
	frost.boss_id = "frost_stalker_alpha"
	frost.unique_mechanic = "SLIPPERY_GLACIAL_CLIFFS_AND_BLIZZARD_HAZARDS"
	frost.compatibility_tags = ["frozen", "glacial", "slippery", "cryo"]
	planet_registry["frostgrave_9"] = frost

static func get_planet(p_id: String) -> Resource:
	_setup_registry()
	if planet_registry.has(p_id):
		return planet_registry[p_id] as Resource
	return planet_registry["eclipse_7"] as Resource

static func get_all_planet_ids() -> Array[String]:
	_setup_registry()
	var keys: Array[String] = []
	for k in planet_registry.keys():
		keys.append(str(k))
	return keys
