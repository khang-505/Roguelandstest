# scripts/procedural/boss_arena_data.gd
class_name BossArenaData
extends Resource

## Data Resource defining Boss Arena Layouts, Spatial Boundaries, Hazards, Safe Zones, Phase Terrain Objects, and Door Locks.

enum ArenaType {
	FLAT,
	MULTI_LEVEL,
	VERTICAL,
	PLATFORM,
	CAVE,
	MACHINE,
	OPEN,
	HAZARD,
	MOVING_PLATFORM
}

@export var arena_id: String = ""
@export var boss_id: String = ""
@export var biome_id: String = "mining"
@export var arena_type: ArenaType = ArenaType.MULTI_LEVEL

@export var width: float = 1200.0
@export var height: float = 750.0

@export var player_spawn: Vector2 = Vector2(150.0, 600.0)
@export var boss_spawn: Vector2 = Vector2(950.0, 450.0)
@export var camera_bounds: Rect2 = Rect2(0.0, 0.0, 1200.0, 750.0)

@export var platforms: Array = []
@export var hazards: Array = []
@export var safe_zones: Array = []
@export var phase_objects: Array = []

@export var entry_door_pos: Vector2 = Vector2(50.0, 600.0)
@export var exit_portal_pos: Vector2 = Vector2(1150.0, 600.0)
@export var reward_chest_pos: Vector2 = Vector2(600.0, 600.0)

@export var arena_locked: bool = false
@export var current_phase_terrain: int = 1

func _init(
	p_id: String = "",
	p_boss: String = "",
	p_biome: String = "mining",
	p_type: ArenaType = ArenaType.MULTI_LEVEL,
	p_w: float = 1200.0,
	p_h: float = 750.0
) -> void:
	arena_id = p_id
	boss_id = p_boss
	biome_id = p_biome
	arena_type = p_type
	width = p_w
	height = p_h
	camera_bounds = Rect2(0.0, 0.0, p_w, p_h)
