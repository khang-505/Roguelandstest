# scripts/procedural/platform_data.gd
class_name PlatformData
extends Resource

## Data-Driven Platform Definition for Starfall Frontier interactive platform types.

enum PlatformType {
	STATIC,
	MOVING,
	ONE_WAY,
	BREAKABLE,
	FALLING,
	FLOATING,
	HAZARD,
	SECRET,
	COMBAT,
	TREASURE,
	BOUNCE,
	DROP_THROUGH
}

@export var platform_id: String = "static_default"
@export var type: int = PlatformType.ONE_WAY
@export var width_min: float = 32.0
@export var width_max: float = 128.0
@export var height: float = 8.0

@export var supports_combat: bool = true
@export var supports_loot: bool = true
@export var supports_secret: bool = false
@export var is_one_way: bool = true

@export var compatibility_tags: Array = ["mining", "jungle", "frozen", "industrial", "alien"]

func init_platform_type(p_type: int, p_id: String = "") -> void:
	type = p_type
	platform_id = p_id if p_id != "" else "plat_%d" % p_type

	match p_type:
		PlatformType.STATIC:
			is_one_way = false
			width_min = 64.0
			width_max = 256.0
		PlatformType.ONE_WAY, PlatformType.FLOATING:
			is_one_way = true
			width_min = 48.0
			width_max = 128.0
		PlatformType.MOVING:
			is_one_way = true
			width_min = 64.0
			width_max = 96.0
		PlatformType.BREAKABLE, PlatformType.FALLING:
			is_one_way = true
			width_min = 32.0
			width_max = 64.0
		PlatformType.HAZARD:
			is_one_way = false
			width_min = 48.0
			width_max = 96.0
		PlatformType.SECRET, PlatformType.TREASURE:
			supports_secret = true
			width_min = 32.0
			width_max = 64.0
		PlatformType.BOUNCE, PlatformType.DROP_THROUGH:
			is_one_way = true
			width_min = 32.0
			width_max = 64.0
