# scripts/procedural/platform_validator.gd
class_name PlatformValidator
extends Resource

## Quality Score and Reachability Validator for Procedural Platform Chains.

static func validate_platform_layout(
	platform_tops: Array,
	room_width_px: float,
	room_height_px: float,
	max_jump_h: float = 160.0,
	max_jump_v: float = 140.0
) -> Dictionary:
	var result = {
		"is_valid": true,
		"score": 100.0,
		"total_platforms": platform_tops.size(),
		"untraversable_gaps": 0,
		"permanent_traps": 0,
		"has_main_path": true
	}

	if platform_tops.size() < 2:
		result.is_valid = false
		result.score = 0.0
		return result

	# Check gap distances between consecutive platforms in chain
	for i in range(platform_tops.size() - 1):
		var p1 = platform_tops[i] as Vector2
		var p2 = platform_tops[i + 1] as Vector2

		var dx = abs(p2.x - p1.x)
		var dy = abs(p2.y - p1.y)

		if dx > max_jump_h + 32.0 or dy > max_jump_v + 32.0:
			# Check if there is an intermediate platform supporting traversal
			var bridged = false
			for j in range(platform_tops.size()):
				if j != i and j != i + 1:
					var p_mid = platform_tops[j] as Vector2
					if abs(p_mid.x - p1.x) <= max_jump_h and abs(p_mid.y - p1.y) <= max_jump_v:
						if abs(p2.x - p_mid.x) <= max_jump_h and abs(p2.y - p_mid.y) <= max_jump_v:
							bridged = true
							break

			if not bridged:
				result.untraversable_gaps += 1
				result.score -= 15.0

	if result.untraversable_gaps > 2:
		result.is_valid = false

	result.score = clamp(result.score, 0.0, 100.0)
	return result
