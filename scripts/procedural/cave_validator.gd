# scripts/procedural/cave_validator.gd
class_name CaveValidator
extends Resource

## Quality Score and Graph Reachability Validator for Procedural Cave Networks.

static func validate_cave_network(cave_result: Dictionary) -> Dictionary:
	var result = {
		"is_valid": true,
		"score": 100.0,
		"graph_reachable": true,
		"stalactite_count": 0,
		"resource_count": 0,
		"shortcut_count": 0
	}

	if cave_result == null or not cave_result.has("graph"):
		result.is_valid = false
		result.score = 0.0
		return result

	var graph = cave_result.get("graph") as Object
	if graph and graph.has_method("is_path_reachable"):
		var reachable = graph.is_path_reachable("c_entrance", "c_exit")
		result.graph_reachable = reachable
		if not reachable:
			result.is_valid = false
			result.score -= 50.0

	var stalactites = cave_result.get("stalactites", []) as Array
	result.stalactite_count = stalactites.size()
	if stalactites.size() == 0:
		result.score -= 20.0

	var resources = cave_result.get("resources", []) as Array
	result.resource_count = resources.size()

	var shortcuts = cave_result.get("shortcuts", []) as Array
	result.shortcut_count = shortcuts.size()

	result.score = clamp(result.score, 0.0, 100.0)
	if result.score < 70.0:
		result.is_valid = false

	return result
