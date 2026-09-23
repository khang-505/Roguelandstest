# scripts/procedural/hidden_path_data.gd
class_name HiddenPathData
extends Resource

## Data Resource defining 14 Hidden Path Categories, discovery parameters, and destination types.

enum PathType {
	HIDDEN_TUNNEL,
	HIDDEN_CAVE,
	HIDDEN_WALL_PATH,
	HIDDEN_FLOOR_PATH,
	HIDDEN_CEILING_PATH,
	HIDDEN_VERTICAL_PATH,
	HIDDEN_PLATFORM_PATH,
	HIDDEN_SHORTCUT,
	HIDDEN_LOOP,
	HIDDEN_ALTERNATIVE_ROUTE,
	HIDDEN_BYPASS,
	HIDDEN_ABILITY_PATH,
	HIDDEN_BREAKABLE_PATH,
	HIDDEN_INTERACTION_PATH
}

@export var path_id: String = ""
@export var path_type: PathType = PathType.HIDDEN_TUNNEL
@export var clue_type: String = "CRACKED_WALL" # CRACKED_WALL, LIGHT_RAY, PARTICLE_DUST, AUDIO_HUM, UNUSUAL_TILE, GEOMETRY_GAP, SUSPICIOUS_SHADOW
@export var required_ability: String = "NONE" # NONE, DOUBLE_JUMP, DASH, WALL_JUMP, EXPLOSIVE
@export var required_item: String = ""
@export var destination_type: String = "TREASURE" # TREASURE, CAVE, SHORTCUT, ALTERNATIVE_REGION, SHOP, ELITE, EVENT, REJOIN_MAIN
@export var difficulty: float = 0.5
@export var reward_value: float = 1.0
@export var biome_tags: Array[String] = []
@export var room_tags: Array[String] = []
@export var reconnect_to_main: bool = true
@export var generator_version: int = 1

func _init(
	p_id: String = "",
	p_type: PathType = PathType.HIDDEN_TUNNEL,
	p_dest: String = "TREASURE",
	p_ability: String = "NONE",
	p_reconnect: bool = true
) -> void:
	path_id = p_id
	path_type = p_type
	destination_type = p_dest
	required_ability = p_ability
	reconnect_to_main = p_reconnect

static func get_path_type_name(t: PathType) -> String:
	match t:
		PathType.HIDDEN_TUNNEL: return "Hidden Tunnel"
		PathType.HIDDEN_CAVE: return "Hidden Subterranean Cave"
		PathType.HIDDEN_WALL_PATH: return "Hidden Wall Passage"
		PathType.HIDDEN_FLOOR_PATH: return "Hidden Floor Drop"
		PathType.HIDDEN_CEILING_PATH: return "Hidden Ceiling Shaft"
		PathType.HIDDEN_VERTICAL_PATH: return "Hidden Vertical Route"
		PathType.HIDDEN_PLATFORM_PATH: return "Hidden Platform Chain"
		PathType.HIDDEN_SHORTCUT: return "Bi-Directional Shortcut"
		PathType.HIDDEN_LOOP: return "Reconnecting Spatial Loop"
		PathType.HIDDEN_ALTERNATIVE_ROUTE: return "Alternative Route"
		PathType.HIDDEN_BYPASS: return "Encounters Bypass Route"
		PathType.HIDDEN_ABILITY_PATH: return "Ability-Gated Route"
		PathType.HIDDEN_BREAKABLE_PATH: return "Breakable Barrier Path"
		PathType.HIDDEN_INTERACTION_PATH: return "Interactive Switch Path"
	return "Hidden Route"
