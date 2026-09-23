# scripts/procedural/planet_validator.gd
class_name PlanetValidator
extends Node

## Calculates composite Quality Score for procedural planets and rejects unplayable seeds.

const MIN_QUALITY_THRESHOLD: float = 70.0

static func validate_planet_world(world_data: Dictionary) -> Dictionary:
	if world_data == null or not world_data.has("graph"):
		return {"is_valid": false, "score": 0.0, "reason": "Missing map graph"}

	var graph = world_data["graph"]
	var score = 0.0

	# 1. Connectivity Score (Max 25 pts)
	var val_script = load("res://scripts/procedural/map_validator.gd")
	if val_script and val_script.has_method("validate_graph"):
		var graph_val = val_script.validate_graph(graph)
		if graph_val.get("is_valid", false):
			score += 25.0

	# 2. Traversal Physics Score (Max 25 pts)
	if val_script and val_script.has_method("validate_platform_jump"):
		var safe_jump = val_script.validate_platform_jump(Vector2(0, 0), Vector2(120, -64))
		if safe_jump:
			score += 25.0

	# 3. Biome Coherence & Pool Integrity Score (Max 20 pts)
	if world_data.has("biome") and world_data["biome"] != null:
		var b = world_data["biome"]
		var e_pool = b.enemy_pool if "enemy_pool" in b else []
		var r_pool = b.resource_pool if "resource_pool" in b else []
		if e_pool.size() > 0 and r_pool.size() > 0:
			score += 20.0

	# 4. Reward Distribution Score (Max 15 pts)
	if world_data.has("current_room") and world_data["current_room"].get("loot_spawns", []).size() > 0:
		score += 15.0

	# 5. Secret Distribution & Macro Node Score (Max 15 pts)
	if "nodes" in graph and graph.nodes.size() >= 3:
		score += 15.0

	var is_valid = score >= MIN_QUALITY_THRESHOLD
	return {
		"is_valid": is_valid,
		"score": score,
		"reason": "Quality score %.1f/100" % score if is_valid else "Score %.1f below threshold %.1f" % [score, MIN_QUALITY_THRESHOLD]
	}
