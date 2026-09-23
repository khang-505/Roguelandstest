# scripts/procedural/platform_pattern.gd
class_name PlatformPattern
extends Resource

## Authored pattern definitions for platform chains across 15 pattern categories.

enum PatternType {
	FLAT,
	STAIRS,
	ASCENDING,
	DESCENDING,
	ZIGZAG,
	DIAGONAL,
	VERTICAL,
	ALTERNATING,
	SPIRAL,
	BRIDGE,
	GAP,
	CAVE,
	TOWER,
	CLIFF,
	ARENA
}

@export var pattern_type: int = PatternType.FLAT
@export var pattern_name: String = "Flat Baseline"
@export var platform_offsets: Array = [] # Array of Dictionary {offset: Vector2, width: float, type: int}

func init_pattern(p_type: int) -> void:
	pattern_type = p_type
	platform_offsets.clear()

	match p_type:
		PatternType.FLAT:
			pattern_name = "Flat Baseline"
			platform_offsets.append({"offset": Vector2(0, 0), "width": 128.0, "type": 0})
			platform_offsets.append({"offset": Vector2(160, 0), "width": 128.0, "type": 0})

		PatternType.STAIRS:
			pattern_name = "Elevation Stairs"
			for i in range(4):
				platform_offsets.append({"offset": Vector2(i * 80.0, -i * 32.0), "width": 64.0, "type": 2})

		PatternType.ASCENDING:
			pattern_name = "Ascending Ledges"
			for i in range(4):
				platform_offsets.append({"offset": Vector2(i * 96.0, -i * 48.0), "width": 56.0, "type": 2})

		PatternType.DESCENDING:
			pattern_name = "Descending Ledges"
			for i in range(4):
				platform_offsets.append({"offset": Vector2(i * 96.0, i * 48.0), "width": 56.0, "type": 2})

		PatternType.ZIGZAG:
			pattern_name = "Vertical ZigZag"
			for i in range(4):
				var x_off = 0.0 if i % 2 == 0 else 112.0
				platform_offsets.append({"offset": Vector2(x_off, -i * 64.0), "width": 64.0, "type": 2})

		PatternType.DIAGONAL:
			pattern_name = "Diagonal Flow"
			for i in range(3):
				platform_offsets.append({"offset": Vector2(i * 112.0, -i * 40.0), "width": 64.0, "type": 2})

		PatternType.VERTICAL:
			pattern_name = "Vertical Shaft"
			for i in range(4):
				platform_offsets.append({"offset": Vector2(0, -i * 80.0), "width": 48.0, "type": 2})

		PatternType.ALTERNATING:
			pattern_name = "Alternating Heights"
			for i in range(4):
				var y_off = -32.0 if i % 2 == 1 else 0.0
				platform_offsets.append({"offset": Vector2(i * 80.0, y_off), "width": 56.0, "type": 2})

		PatternType.SPIRAL:
			pattern_name = "Spiral Ascent"
			for i in range(4):
				var x_off = sin(i * 1.5) * 64.0 + 64.0
				platform_offsets.append({"offset": Vector2(x_off, -i * 48.0), "width": 48.0, "type": 2})

		PatternType.BRIDGE:
			pattern_name = "Suspended Bridge"
			platform_offsets.append({"offset": Vector2(0, 0), "width": 192.0, "type": 0})

		PatternType.GAP:
			pattern_name = "Pit Gap Crossing"
			platform_offsets.append({"offset": Vector2(0, 0), "width": 64.0, "type": 0})
			platform_offsets.append({"offset": Vector2(144.0, -16.0), "width": 48.0, "type": 1})
			platform_offsets.append({"offset": Vector2(288.0, 0), "width": 64.0, "type": 0})

		PatternType.CAVE:
			pattern_name = "Subterranean Cavern"
			for i in range(3):
				platform_offsets.append({"offset": Vector2(i * 96.0, 32.0 + (i % 2) * 16.0), "width": 64.0, "type": 2})

		PatternType.TOWER:
			pattern_name = "High Tower Platforms"
			for i in range(5):
				platform_offsets.append({"offset": Vector2((i % 2) * 80.0, -i * 72.0), "width": 48.0, "type": 2})

		PatternType.CLIFF:
			pattern_name = "Cliffside Ledges"
			platform_offsets.append({"offset": Vector2(0, 0), "width": 80.0, "type": 0})
			platform_offsets.append({"offset": Vector2(96.0, -64.0), "width": 56.0, "type": 2})
			platform_offsets.append({"offset": Vector2(192.0, -128.0), "width": 64.0, "type": 2})

		PatternType.ARENA:
			pattern_name = "Combat Arena Platforms"
			platform_offsets.append({"offset": Vector2(0, 0), "width": 256.0, "type": 0})
			platform_offsets.append({"offset": Vector2(48.0, -64.0), "width": 64.0, "type": 2})
			platform_offsets.append({"offset": Vector2(144.0, -64.0), "width": 64.0, "type": 2})
