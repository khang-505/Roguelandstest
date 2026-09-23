# scripts/procedural/enemy_archetype_data.gd
class_name EnemyArchetypeData
extends Resource

## Data Resource defining 13 Enemy Roles, 10 Movement Modalities, Weakness/Resistance matrices, and Counterplay Telegraphs.

enum Role {
	MELEE,
	RANGED,
	TANK,
	FLYING,
	ASSASSIN,
	SUPPORT,
	SUMMONER,
	EXPLODER,
	CONTROL,
	BURROWER,
	SNIPER,
	ELITE,
	BOSS
}

enum MovementType {
	WALK,
	RUN,
	JUMP,
	FLY,
	TELEPORT,
	BURROW,
	DASH,
	HOVER,
	CLIMB,
	LEAP
}

@export var archetype_id: String = ""
@export var archetype_name: String = "Enemy Archetype"
@export var role: Role = Role.MELEE
@export var family_id: String = "drone"
@export var biome_id: String = "emberwild"

@export var max_health: float = 100.0
@export var base_damage: float = 15.0
@export var move_speed: float = 120.0
@export var attack_range: float = 40.0
@export var attack_cooldown: float = 1.5

@export var movement_type: MovementType = MovementType.WALK
@export var primary_weakness: String = "PHYSICAL" # PHYSICAL, FIRE, ICE, ELECTRIC, POISON, EXPLOSIVE
@export var primary_resistance: String = "NONE"
@export var telegraph_duration: float = 0.8
@export var threat_description: String = "Approaches player in melee combat"
@export var counterplay_tip: String = "Dodge or spacing"

func _init(
	p_id: String = "",
	p_name: String = "Enemy Archetype",
	p_role: Role = Role.MELEE,
	p_family: String = "drone",
	p_biome: String = "emberwild"
) -> void:
	archetype_id = p_id
	archetype_name = p_name
	role = p_role
	family_id = p_family
	biome_id = p_biome

static func get_role_name(r: Role) -> String:
	match r:
		Role.MELEE: return "Melee Attacker"
		Role.RANGED: return "Ranged Shooter"
		Role.TANK: return "Heavy Tank"
		Role.FLYING: return "Airborne Flier"
		Role.ASSASSIN: return "Burst Assassin"
		Role.SUPPORT: return "Support Buffer"
		Role.SUMMONER: return "Minion Summoner"
		Role.EXPLODER: return "Suicide Exploder"
		Role.CONTROL: return "Crowd Controller"
		Role.BURROWER: return "Subterranean Burrower"
		Role.SNIPER: return "Long-Range Sniper"
		Role.ELITE: return "Elite Champion"
		Role.BOSS: return "Boss Guardian"
	return "Enemy Role"

static func get_movement_name(m: MovementType) -> String:
	match m:
		MovementType.WALK: return "Ground Walk"
		MovementType.RUN: return "Fast Sprint Run"
		MovementType.JUMP: return "Vertical Jump"
		MovementType.FLY: return "Continuous Flight"
		MovementType.TELEPORT: return "Phase Teleport"
		MovementType.BURROW: return "Subterranean Burrow"
		MovementType.DASH: return "Burst Dash"
		MovementType.HOVER: return "Floating Hover"
		MovementType.CLIMB: return "Wall Climb"
		MovementType.LEAP: return "Pounce Leap"
	return "Standard Movement"
