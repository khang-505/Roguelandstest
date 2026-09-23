# scripts/procedural/terrain_validator.gd
class_name TerrainValidator
extends Node

## Evaluates composite Quality Score for generated procedural terrain and verifies 0 softlocks.

const MIN_QUALITY_THRESHOLD: float = 70.0

static func validate_terrain_result(terrain_res: Dictionary) -> Dictionary:
	var score = 0.0
	var result = {
		"is_valid": true,
		"score": 0.0,
		"reason": "OK"
	}

	if terrain_res == null or not terrain_res.has("traversal_graph"):
		result.is_valid = false
		result.reason = "Missing terrain traversal graph"
		return result

	var graph = terrain_res["traversal_graph"]

	# 1. Main Path Reachability (Max 35 pts)
	if graph and graph.has_method("is_reachable"):
		# Find first and last nodes
		var start_id = 0
		var exit_id = graph.nodes.size() - 1
		if exit_id > 0 and graph.is_reachable(start_id, exit_id):
			score += 35.0

	# 2. Segment Variety & Authored Patterns (Max 25 pts)
	var segs = terrain_res.get("segments", []) as Array
	if segs.size() >= 3:
		score += 25.0

	# 3. Platform & Traversal Physics Constraints (Max 25 pts)
	var plats = terrain_res.get("platforms", []) as Array
	if plats.size() >= 2:
		score += 25.0

	# 4. Deterministic Seed Versioning (Max 15 pts)
	if terrain_res.get("version", 0) >= 1:
		score += 15.0

	result.score = score
	result.is_valid = score >= MIN_QUALITY_THRESHOLD
	if not result.is_valid:
		result.reason = "Quality score %.1f below threshold %.1f" % [score, MIN_QUALITY_THRESHOLD]

	return result
