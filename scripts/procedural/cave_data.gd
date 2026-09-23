# scripts/procedural/cave_data.gd
class_name CaveData
extends Resource

## Data structure defining cave archetypes, size categories, depth levels, and feature flags.

enum CaveType {
	CAVE_ENTRANCE,
	CAVE_TUNNEL,
	CAVE_CHAMBER,
	CAVE_BRANCH,
	CAVE_VERTICAL_SHAFT,
	CAVE_CROSSROAD,
	CAVE_ARENA,
	CAVE_TREASURE,
	CAVE_SECRET,
	DEEP_CAVE,
	CAVE_EXIT
}

enum CaveSize {
	SMALL,
	MEDIUM,
	LARGE,
	DEEP,
	VERTICAL,
	MULTI_CHAMBER
}

enum DepthLevel {
	DEPTH_0_ENTRANCE,
	DEPTH_1_SHALLOW,
	DEPTH_2_UNDERGROUND,
	DEPTH_3_DEEP,
	DEPTH_4_EXTREME
}

@export var cave_id: String = "cave_room_01"
@export var archetype: int = CaveType.CAVE_TUNNEL
@export var size_category: int = CaveSize.MEDIUM
@export var depth_level: int = DepthLevel.DEPTH_1_SHALLOW

@export var width_tiles: int = 32
@export var height_tiles: int = 18

@export var has_breakable_wall: bool = false
@export var has_treasure: bool = false
@export var has_shortcut: bool = false
@export var has_vertical_shaft: bool = false
@export var has_elite: bool = false

@export var allowed_biomes: Array = ["emberwild", "verdant_abyss", "frostgrave", "industrial_core", "alien_void"]

func init_cave_data(arch: int, c_id: String = "", depth: int = 1) -> void:
	archetype = arch
	cave_id = c_id if c_id != "" else "cave_arch_%d" % arch
	depth_level = clamp(depth, 0, 4)

	match arch:
		CaveType.CAVE_ENTRANCE:
			size_category = CaveSize.SMALL
			width_tiles = 24
			height_tiles = 14
			depth_level = DepthLevel.DEPTH_0_ENTRANCE
		CaveType.CAVE_TUNNEL:
			size_category = CaveSize.MEDIUM
			width_tiles = 32
			height_tiles = 16
		CaveType.CAVE_CHAMBER, CaveType.CAVE_ARENA:
			size_category = CaveSize.LARGE
			width_tiles = 48
			height_tiles = 24
			has_elite = (depth >= 3)
		CaveType.CAVE_VERTICAL_SHAFT:
			size_category = CaveSize.VERTICAL
			width_tiles = 24
			height_tiles = 36
			has_vertical_shaft = true
		CaveType.CAVE_TREASURE, CaveType.CAVE_SECRET:
			size_category = CaveSize.SMALL
			width_tiles = 20
			height_tiles = 14
			has_treasure = true
			has_breakable_wall = (arch == CaveType.CAVE_SECRET)
		CaveType.DEEP_CAVE:
			size_category = CaveSize.DEEP
			width_tiles = 40
			height_tiles = 24
			depth_level = DepthLevel.DEPTH_3_DEEP
			has_elite = true
		CaveType.CAVE_EXIT:
			size_category = CaveSize.SMALL
			width_tiles = 24
			height_tiles = 14
			has_shortcut = true
