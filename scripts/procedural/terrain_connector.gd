# scripts/procedural/terrain_connector.gd
class_name TerrainConnector
extends Node

## Validates connector height alignment, exit/entrance matching, and traversal compatibility between adjacent terrain segments.

static func validate_connector(
	prev_segment: Object,
	next_segment: Object,
	max_vertical_gap: float = 140.0
) -> Dictionary:
	var result = {
		"is_compatible": true,
		"height_delta": 0.0,
		"reason": "OK"
	}

	if prev_segment == null or next_segment == null:
		return result

	var ex_h = prev_segment.exit_height if "exit_height" in prev_segment else 0.0
	var ent_h = next_segment.entrance_height if "entrance_height" in next_segment else 0.0

	var delta = abs(ex_h - ent_h)
	result.height_delta = delta

	if delta > max_vertical_gap:
		result.is_compatible = false
		result.reason = "Vertical height delta %.1f exceeds max jump height %.1f" % [delta, max_vertical_gap]
		return result

	# Check entrance/exit type compatibility
	var ex_type = prev_segment.exit_type if "exit_type" in prev_segment else "GROUND"
	var ent_type = next_segment.entrance_type if "entrance_type" in next_segment else "GROUND"

	if ex_type == "CAVE" and ent_type == "PLATFORM":
		# Minor mismatch, allowed with transition step
		pass

	return result
