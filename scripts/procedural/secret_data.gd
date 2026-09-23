# scripts/procedural/secret_data.gd
class_name SecretData
extends Resource

## Data Resource defining 14 Secret Categories, discovery rules, and reward scaling.

enum SecretType {
	HIDDEN_ROOM,
	HIDDEN_CAVE,
	HIDDEN_PLATFORM,
	HIDDEN_TUNNEL,
	HIDDEN_WALL,
	HIDDEN_FLOOR,
	HIDDEN_CEILING,
	VERTICAL_SECRET,
	BREAKABLE_SECRET,
	MOVEMENT_SECRET,
	PUZZLE_SECRET,
	COMBAT_SECRET,
	RISK_REWARD_SECRET,
	SECRET_SHORTCUT
}

@export var secret_id: String = ""
@export var secret_type: SecretType = SecretType.HIDDEN_WALL
@export var biome_tags: Array[String] = []
@export var room_tags: Array[String] = []

@export var discovery_difficulty: float = 0.5 # 0.0 = Common/Obvious, 1.0 = Rare/Hidden
@export var reward_value: float = 1.0 # Multiplier for secret loot tables
@export var required_ability: String = "NONE" # NONE, DOUBLE_JUMP, DASH, WALL_JUMP, EXPLOSIVE
@export var is_optional: bool = true
@export var generator_version: int = 1

func _init(
	p_id: String = "",
	p_type: SecretType = SecretType.HIDDEN_WALL,
	p_diff: float = 0.5,
	p_reward: float = 1.0,
	p_ability: String = "NONE"
) -> void:
	secret_id = p_id
	secret_type = p_type
	discovery_difficulty = p_diff
	reward_value = p_reward
	required_ability = p_ability

static func get_type_name(t: SecretType) -> String:
	match t:
		SecretType.HIDDEN_ROOM: return "Hidden Room"
		SecretType.HIDDEN_CAVE: return "Hidden Cave"
		SecretType.HIDDEN_PLATFORM: return "Hidden Platform"
		SecretType.HIDDEN_TUNNEL: return "Hidden Tunnel"
		SecretType.HIDDEN_WALL: return "Hidden Wall"
		SecretType.HIDDEN_FLOOR: return "Hidden Floor Drop"
		SecretType.HIDDEN_CEILING: return "Hidden Ceiling Shaft"
		SecretType.VERTICAL_SECRET: return "Vertical Secret"
		SecretType.BREAKABLE_SECRET: return "Breakable Secret"
		SecretType.MOVEMENT_SECRET: return "Movement Challenge Secret"
		SecretType.PUZZLE_SECRET: return "Puzzle Secret"
		SecretType.COMBAT_SECRET: return "Secret Combat Arena"
		SecretType.RISK_REWARD_SECRET: return "Risk/Reward Shrine"
		SecretType.SECRET_SHORTCUT: return "Secret Shortcut"
	return "Unknown Secret"
