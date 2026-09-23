# scripts/procedural/boss_catalog.gd
class_name BossCatalog
extends Resource

## Catalog registering signature Planet Bosses with multi-phase definitions, attack patterns, biome alignment, and rewards.

static var _bosses: Dictionary = {}
static var _initialized: bool = false

static func _ensure_initialized() -> void:
	if _initialized:
		return
	_initialized = true
	
	var boss_data_script = load("res://scripts/procedural/boss_data.gd")
	if not boss_data_script:
		return
		
	# 1. Mining Boss: Titan Excavator
	var titan = boss_data_script.new("titan_excavator", "Titan Excavator", "emberwild", "mining", 1200.0)
	titan.lore_text = "Heavy industrial digging machine retrofitted into an unstoppable mining war engine."
	titan.phases = [
		{"phase_index": 1, "hp_threshold": 1.0, "unlocked_attacks": ["drill_charge", "falling_rubble"]},
		{"phase_index": 2, "hp_threshold": 0.6, "unlocked_attacks": ["drill_charge", "falling_rubble", "laser_grid"]},
		{"phase_index": 3, "hp_threshold": 0.25, "unlocked_attacks": ["drill_charge", "falling_rubble", "laser_grid", "overcharge_beam"]}
	]
	titan.attack_patterns = [
		{
			"id": "drill_charge",
			"name": "Heavy Drill Charge",
			"category": 3, # CHARGE
			"telegraph_duration": 1.0,
			"execution_duration": 1.4,
			"recovery_duration": 1.5,
			"damage": 30.0,
			"counterplay": "Jump over charge onto elevated platform"
		},
		{
			"id": "falling_rubble",
			"name": "Seismic Ground Slam",
			"category": 2, # AREA
			"telegraph_duration": 1.2,
			"execution_duration": 1.0,
			"recovery_duration": 1.2,
			"damage": 25.0,
			"counterplay": "Evacuate red ground warning circle"
		},
		{
			"id": "laser_grid",
			"name": "Machinery Hazard Grid",
			"category": 7, # HAZARD
			"telegraph_duration": 1.5,
			"execution_duration": 3.0,
			"recovery_duration": 1.0,
			"damage": 20.0,
			"counterplay": "Navigate safe gap between laser bars"
		},
		{
			"id": "overcharge_beam",
			"name": "Excavator Core Meltdown",
			"category": 6, # BEAM
			"telegraph_duration": 2.0,
			"execution_duration": 3.0,
			"recovery_duration": 2.0,
			"damage": 50.0,
			"counterplay": "Take cover behind mining pillar"
		}
	]
	titan.loot_table = {
		"guaranteed_drops": ["excavator_drill_lance", "mining_core_key"],
		"currency_multiplier": 5.0,
		"choice_rewards": [
			{"type": "WEAPON", "name": "Excavator Drill Lance", "tier": "LEGENDARY"},
			{"type": "ARTIFACT", "name": "Overclocked Rotor", "tier": "LEGENDARY"},
			{"type": "MATERIAL", "name": "Titan Alloy Plate x10", "tier": "EPIC"}
		]
	}
	_bosses["titan_excavator"] = titan
	
	# 2. Forest Boss: Apex Bio-Horror
	var bio = boss_data_script.new("apex_bio_horror", "Apex Bio-Horror", "verdia", "forest", 1000.0)
	bio.lore_text = "Mutated apex predator infected with planetary spores."
	bio.primary_weakness = "FIRE"
	bio.phases = [
		{"phase_index": 1, "hp_threshold": 1.0, "unlocked_attacks": ["vine_slam", "toxic_spore_burst"]},
		{"phase_index": 2, "hp_threshold": 0.5, "unlocked_attacks": ["vine_slam", "toxic_spore_burst", "spore_minion_summon"]},
		{"phase_index": 3, "hp_threshold": 0.2, "unlocked_attacks": ["vine_slam", "toxic_spore_burst", "spore_minion_summon", "acid_sweep"]}
	]
	bio.attack_patterns = [
		{
			"id": "vine_slam",
			"name": "Entangling Vine Slam",
			"category": 0, # BASIC
			"telegraph_duration": 0.8,
			"execution_duration": 0.8,
			"recovery_duration": 1.0,
			"damage": 22.0,
			"counterplay": "Side dash"
		},
		{
			"id": "toxic_spore_burst",
			"name": "Toxic Spore Cloud",
			"category": 2, # AREA
			"telegraph_duration": 1.2,
			"execution_duration": 2.0,
			"recovery_duration": 1.2,
			"damage": 18.0,
			"counterplay": "Leave toxic cloud radius"
		},
		{
			"id": "spore_minion_summon",
			"name": "Summon Sporelings",
			"category": 5, # SUMMON
			"telegraph_duration": 1.5,
			"execution_duration": 1.0,
			"recovery_duration": 1.5,
			"damage": 0.0,
			"counterplay": "Destroy spore nests before adds spawn"
		},
		{
			"id": "acid_sweep",
			"name": "Corrosive Acid Beam",
			"category": 6, # BEAM
			"telegraph_duration": 1.8,
			"execution_duration": 2.5,
			"recovery_duration": 1.8,
			"damage": 45.0,
			"counterplay": "Dodge under horizontal beam height"
		}
	]
	bio.loot_table = {
		"guaranteed_drops": ["spore_viper_rifle", "forest_core_key"],
		"currency_multiplier": 5.0,
		"choice_rewards": [
			{"type": "WEAPON", "name": "Spore Viper Rifle", "tier": "LEGENDARY"},
			{"type": "ARTIFACT", "name": "Bio-Gland Catalyst", "tier": "LEGENDARY"},
			{"type": "MATERIAL", "name": "Mutated Flora Core x10", "tier": "EPIC"}
		]
	}
	_bosses["apex_bio_horror"] = bio
	
	# 3. Cave Boss: Core Custodian
	var core = boss_data_script.new("core_custodian", "Core Custodian", "abyssia", "cave", 1500.0)
	core.lore_text = "Subterranean guardian sentinel guarding ancient crystalline secrets."
	core.primary_weakness = "ELECTRIC"
	core.phases = [
		{"phase_index": 1, "hp_threshold": 1.0, "unlocked_attacks": ["crystal_shatter", "defense_barrier"]},
		{"phase_index": 2, "hp_threshold": 0.65, "unlocked_attacks": ["crystal_shatter", "defense_barrier", "drone_swarm"]},
		{"phase_index": 3, "hp_threshold": 0.25, "unlocked_attacks": ["crystal_shatter", "defense_barrier", "drone_swarm", "orbital_meltdown"]}
	]
	core.attack_patterns = [
		{
			"id": "crystal_shatter",
			"name": "Crystalline Projectile Burst",
			"category": 1, # PROJECTILE
			"telegraph_duration": 1.0,
			"execution_duration": 1.2,
			"recovery_duration": 1.0,
			"damage": 28.0,
			"counterplay": "Use terrain cover"
		},
		{
			"id": "defense_barrier",
			"name": "Prismatic Energy Shield",
			"category": 9, # DEFENSIVE
			"telegraph_duration": 0.5,
			"execution_duration": 4.0,
			"recovery_duration": 1.0,
			"damage": 0.0,
			"counterplay": "Destroy 2 barrier energy nodes"
		},
		{
			"id": "drone_swarm",
			"name": "Deploy Guardian Drones",
			"category": 5, # SUMMON
			"telegraph_duration": 1.2,
			"execution_duration": 1.0,
			"recovery_duration": 1.2,
			"damage": 0.0,
			"counterplay": "Focus fire guardian drones"
		},
		{
			"id": "orbital_meltdown",
			"name": "Subterranean Meltdown Nova",
			"category": 10, # ULTIMATE
			"telegraph_duration": 2.5,
			"execution_duration": 3.0,
			"recovery_duration": 2.5,
			"damage": 60.0,
			"counterplay": "Activate emergency shelter portal"
		}
	]
	core.loot_table = {
		"guaranteed_drops": ["prismatic_pulse_blaster", "cave_core_key"],
		"currency_multiplier": 5.0,
		"choice_rewards": [
			{"type": "WEAPON", "name": "Prismatic Pulse Blaster", "tier": "LEGENDARY"},
			{"type": "ARTIFACT", "name": "Custodian Shield Generator", "tier": "LEGENDARY"},
			{"type": "MATERIAL", "name": "Resonant Crystal Matrix x10", "tier": "EPIC"}
		]
	}
	_bosses["core_custodian"] = core

static func get_boss(id: String) -> Resource:
	_ensure_initialized()
	if _bosses.has(id):
		return _bosses[id]
	return null

static func get_boss_for_planet(planet_id: String) -> Resource:
	_ensure_initialized()
	for b_id in _bosses.keys():
		var b = _bosses[b_id]
		if b.planet_id == planet_id:
			return b
	return _bosses.get("titan_excavator", null)

static func get_all_boss_ids() -> Array:
	_ensure_initialized()
	return _bosses.keys()
