# scripts/procedural/spawn_point_data.gd
class_name SpawnPointData
extends Resource

## Data model for spawn point markers defining marker types, preferred roles, and difficulty bounds.

enum MarkerType {
	GROUND,
	UPPER,
	LOWER,
	AIR,
	EDGE,
	AMBUSH,
	RANGED,
	CENTER,
	BOSS,
	ELITE,
	REINFORCEMENT
}

@export var marker_id: String = ""
@export var marker_type: MarkerType = MarkerType.GROUND
@export var relative_position: Vector2 = Vector2.ZERO
@export var preferred_role: int = 0 # EncounterData.EnemyRole.MELEE
@export var min_difficulty: float = 0.0
@export var max_difficulty: float = 10.0
@export var requires_line_of_sight: bool = false
@export var telegraph_duration: float = 0.8

func _init(
	p_id: String = "",
	p_type: MarkerType = MarkerType.GROUND,
	p_pos: Vector2 = Vector2.ZERO,
	p_role: int = 0
) -> void:
	marker_id = p_id
	marker_type = p_type
	relative_position = p_pos
	preferred_role = p_role

static func get_marker_name(m: MarkerType) -> String:
	match m:
		MarkerType.GROUND: return "Ground Spawn"
		MarkerType.UPPER: return "Upper Ledge Spawn"
		MarkerType.LOWER: return "Lower Pit Spawn"
		MarkerType.AIR: return "Aerial Airborne Spawn"
		MarkerType.EDGE: return "Room Edge Flank"
		MarkerType.AMBUSH: return "Hidden Wall Ambush"
		MarkerType.RANGED: return "Ranged Sniper Perch"
		MarkerType.CENTER: return "Center Arena Spawn"
		MarkerType.BOSS: return "Boss Core Altar"
		MarkerType.ELITE: return "Elite Champion Spawn"
		MarkerType.REINFORCEMENT: return "Warp Portal Portal"
	return "Spawn Marker"
