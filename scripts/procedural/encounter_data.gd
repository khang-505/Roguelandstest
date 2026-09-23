# scripts/procedural/encounter_data.gd
class_name EncounterData
extends Resource

## Data Resource defining encounter composition, difficulty bounds, enemy budgets, 11 roles, and 12 spawn patterns.

enum EnemyRole {
	MELEE,       # Cost 1
	RANGED,      # Cost 2
	FLYING,      # Cost 2
	EXPLODER,    # Cost 2
	ASSASSIN,    # Cost 3
	SUPPORT,     # Cost 3
	DISRUPTOR,   # Cost 3
	CONTROL,     # Cost 3
	TANK,        # Cost 4
	SUMMONER,    # Cost 4
	ELITE        # Cost 8
}

enum SpawnPattern {
	GROUP,
	WAVE,
	AMBUSH,
	FLANK,
	CROSSFIRE,
	SURROUND,
	VERTICAL,
	DROP_IN,
	RUSH,
	PROTECT,
	REINFORCEMENT,
	ELITE
}

@export var encounter_id: String = ""
@export var biome_tags: Array[String] = []
@export var room_tags: Array[String] = []

@export var min_difficulty: float = 0.5
@export var max_difficulty: float = 3.0

@export var enemy_budget: int = 10
@export var min_enemies: int = 2
@export var max_enemies: int = 8

@export var spawn_pattern: SpawnPattern = SpawnPattern.GROUP
@export var allow_elite: bool = true
@export var wave_count: int = 1

func _init(
	p_id: String = "",
	p_budget: int = 10,
	p_pattern: SpawnPattern = SpawnPattern.GROUP,
	p_waves: int = 1
) -> void:
	encounter_id = p_id
	enemy_budget = p_budget
	spawn_pattern = p_pattern
	wave_count = p_waves

static func get_role_cost(role: EnemyRole) -> int:
	match role:
		EnemyRole.MELEE: return 1
		EnemyRole.RANGED, EnemyRole.FLYING, EnemyRole.EXPLODER: return 2
		EnemyRole.ASSASSIN, EnemyRole.SUPPORT, EnemyRole.DISRUPTOR, EnemyRole.CONTROL: return 3
		EnemyRole.TANK, EnemyRole.SUMMONER: return 4
		EnemyRole.ELITE: return 8
	return 1

static func get_role_name(role: EnemyRole) -> String:
	match role:
		EnemyRole.MELEE: return "Melee Attacker"
		EnemyRole.RANGED: return "Ranged Shooter"
		EnemyRole.FLYING: return "Flying Scout"
		EnemyRole.EXPLODER: return "Explosive Rusher"
		EnemyRole.ASSASSIN: return "Stealth Assassin"
		EnemyRole.SUPPORT: return "Support Buffer"
		EnemyRole.DISRUPTOR: return "Area Disruptor"
		EnemyRole.CONTROL: return "Crowd Controller"
		EnemyRole.TANK: return "Heavy Tank"
		EnemyRole.SUMMONER: return "Minion Summoner"
		EnemyRole.ELITE: return "Elite Champion"
	return "Enemy"

static func get_pattern_name(pattern: SpawnPattern) -> String:
	match pattern:
		SpawnPattern.GROUP: return "Concentrated Group"
		SpawnPattern.WAVE: return "Sequential Waves"
		SpawnPattern.AMBUSH: return "Hidden Ambush"
		SpawnPattern.FLANK: return "Flanking Pincer"
		SpawnPattern.CROSSFIRE: return "Crossfire Positions"
		SpawnPattern.SURROUND: return "Surrounding Ring"
		SpawnPattern.VERTICAL: return "Vertical Tier Spawns"
		SpawnPattern.DROP_IN: return "Ceiling Drop-In"
		SpawnPattern.RUSH: return "Fast Rusher Assault"
		SpawnPattern.PROTECT: return "VIP Protection"
		SpawnPattern.REINFORCEMENT: return "Portal Reinforcements"
		SpawnPattern.ELITE: return "Elite Boss Retinue"
	return "Standard Encounter"
