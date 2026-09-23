# scripts/procedural/terrain_segment.gd
class_name TerrainSegment
extends Resource

## Data structure and template registry for authored terrain segments across 11 categories.

enum SegmentCategory {
	FLAT,
	ROLLING,
	STEPPED,
	CLIFF,
	PIT,
	PLATFORM_CHAIN,
	CAVE,
	VERTICAL,
	BRIDGE,
	HAZARD,
	SECRET
}

@export var segment_id: String = "flat_basic"
@export var category: int = SegmentCategory.FLAT
@export var width_px: float = 192.0
@export var entrance_height: float = 0.0 # Relative Y offset from segment base
@export var exit_height: float = 0.0 # Relative Y offset at segment end
@export var entrance_type: String = "GROUND" # GROUND, PLATFORM, SLOPE, CAVE
@export var exit_type: String = "GROUND"

@export var platforms: Array = [] # Array of Vector2 offsets relative to segment origin
@export var slopes: Array = [] # Array of Dictionary {start: Vector2, end: Vector2}
@export var caves: Array = [] # Array of Vector2 cave bounds
@export var hazards: Array = [] # Array of Vector2 hazard offsets
@export var secrets: Array = [] # Array of Vector2 secret offsets

func init_segment(cat: int, seg_id: String, w_px: float, ent_h: float, ex_h: float) -> void:
	category = cat
	segment_id = seg_id
	width_px = w_px
	entrance_height = ent_h
	exit_height = ex_h

	platforms.clear()
	slopes.clear()
	caves.clear()
	hazards.clear()
	secrets.clear()

	match cat:
		SegmentCategory.FLAT:
			entrance_type = "GROUND"
			exit_type = "GROUND"
			platforms.append(Vector2(w_px * 0.5, ent_h))

		SegmentCategory.ROLLING:
			entrance_type = "GROUND"
			exit_type = "GROUND"
			slopes.append({"start": Vector2(0, ent_h), "end": Vector2(w_px * 0.5, ent_h - 32.0)})
			slopes.append({"start": Vector2(w_px * 0.5, ent_h - 32.0), "end": Vector2(w_px, ex_h)})

		SegmentCategory.STEPPED:
			entrance_type = "GROUND"
			exit_type = "GROUND"
			platforms.append(Vector2(w_px * 0.3, ent_h))
			platforms.append(Vector2(w_px * 0.7, ex_h))

		SegmentCategory.CLIFF:
			entrance_type = "GROUND"
			exit_type = "PLATFORM"
			platforms.append(Vector2(w_px * 0.4, ent_h - 80.0))

		SegmentCategory.PIT:
			entrance_type = "GROUND"
			exit_type = "GROUND"
			hazards.append(Vector2(w_px * 0.5, ent_h + 48.0))
			platforms.append(Vector2(w_px * 0.5, ent_h - 48.0)) # Floating bridge platform over pit

		SegmentCategory.PLATFORM_CHAIN:
			entrance_type = "PLATFORM"
			exit_type = "PLATFORM"
			platforms.append(Vector2(w_px * 0.25, ent_h - 32.0))
			platforms.append(Vector2(w_px * 0.75, ex_h - 48.0))

		SegmentCategory.CAVE:
			entrance_type = "CAVE"
			exit_type = "CAVE"
			caves.append(Vector2(w_px * 0.5, ent_h + 32.0))

		SegmentCategory.VERTICAL:
			entrance_type = "PLATFORM"
			exit_type = "PLATFORM"
			platforms.append(Vector2(w_px * 0.5, ent_h - 112.0))

		SegmentCategory.BRIDGE:
			entrance_type = "GROUND"
			exit_type = "GROUND"
			platforms.append(Vector2(w_px * 0.5, ent_h))

		SegmentCategory.HAZARD:
			entrance_type = "GROUND"
			exit_type = "GROUND"
			hazards.append(Vector2(w_px * 0.5, ent_h))
			platforms.append(Vector2(w_px * 0.5, ent_h - 64.0))

		SegmentCategory.SECRET:
			entrance_type = "GROUND"
			exit_type = "GROUND"
			secrets.append(Vector2(w_px * 0.5, ent_h - 48.0))
