# scripts/procedural/boss_data.gd
class_name BossData
extends Resource

## Data Resource defining Boss Identity, Phase Architecture, Attack Sets, Movement Modalities, Weaknesses, Arena Integration, and Rewards.

enum AttackCategory {
	BASIC,
	PROJECTILE,
	AREA,
	CHARGE,
	DASH,
	SUMMON,
	BEAM,
	HAZARD,
	TRAP,
	DEFENSIVE,
	ULTIMATE
}

@export var boss_id: String = ""
@export var boss_name: String = "Planet Guardian"
@export var planet_id: String = "emberwild"
@export var biome_id: String = "mining"
@export var lore_text: String = "An ancient warmachine powering the core."

@export var max_health: float = 1000.0
@export var base_damage: float = 25.0
@export var move_speed: float = 140.0
@export var enrage_hp_threshold: float = 0.20 # Enrages at 20% HP

@export var phase_count: int = 3
@export var phases: Array = []
@export var attack_patterns: Array = []

@export var primary_weakness: String = "PHYSICAL"
@export var resistances: Array[String] = []

@export var arena_type: String = "BOSS_ARENA"
@export var arena_scene_path: String = "res://scenes/arenas/boss_arena_mining.tscn"
@export var arena_hazards: Array[String] = ["laser_grid", "falling_debris"]

@export var loot_table: Dictionary = {}

func _init(
	p_id: String = "",
	p_name: String = "Planet Guardian",
	p_planet: String = "emberwild",
	p_biome: String = "mining",
	p_hp: float = 1000.0
) -> void:
	boss_id = p_id
	boss_name = p_name
	planet_id = p_planet
	biome_id = p_biome
	max_health = p_hp
	phases = [
		{"phase_index": 1, "hp_threshold": 1.0, "unlocked_attacks": ["basic_slam", "drill_charge"]},
		{"phase_index": 2, "hp_threshold": 0.6, "unlocked_attacks": ["basic_slam", "drill_charge", "hazard_grid"]},
		{"phase_index": 3, "hp_threshold": 0.25, "unlocked_attacks": ["basic_slam", "drill_charge", "hazard_grid", "overcharge_beam"]}
	]
	attack_patterns = [
		{
			"id": "drill_charge",
			"name": "Drill Charge",
			"category": AttackCategory.CHARGE,
			"telegraph_duration": 1.2,
			"execution_duration": 1.5,
			"recovery_duration": 1.8,
			"damage": 35.0,
			"counterplay": "Dodge or jump onto high platform"
		},
		{
			"id": "hazard_grid",
			"name": "Laser Grid Lockdown",
			"category": AttackCategory.HAZARD,
			"telegraph_duration": 1.5,
			"execution_duration": 3.0,
			"recovery_duration": 1.0,
			"damage": 20.0,
			"counterplay": "Stand in designated safe zone"
		},
		{
			"id": "overcharge_beam",
			"name": "Orbital Core Beam",
			"category": AttackCategory.BEAM,
			"telegraph_duration": 2.0,
			"execution_duration": 2.5,
			"recovery_duration": 2.0,
			"damage": 50.0,
			"counterplay": "Hide behind reinforced barrier pillar"
		}
	]
	loot_table = {
		"guaranteed_drops": ["legendary_boss_weapon", "planet_unlock_core"],
		"currency_multiplier": 5.0,
		"choice_rewards": [
			{"type": "WEAPON", "name": "Titan Buster Cannon", "tier": "LEGENDARY"},
			{"type": "ARTIFACT", "name": "Core Catalyst", "tier": "LEGENDARY"},
			{"type": "UPGRADE", "name": "Permanent HP Capsule", "tier": "EPIC"}
		]
	}
