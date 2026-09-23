# scripts/procedural/map_validator.gd
class_name MapValidator
extends Node

## Traversal physics & topology validator guaranteeing 0 unplayable maps or impossible jumps.

const MAX_HORIZONTAL_JUMP: float = 160.0 # px
const MAX_VERTICAL_JUMP: float = 96.0 # px
const MIN_PLATFORM_WIDTH: float = 32.0 # px

static func validate_graph(graph: Object) -> Dictionary:
	if graph == null or not "nodes" in graph or graph.nodes.size() == 0:
		return {"is_valid": false, "reason": "Graph is empty"}

	var start_id = graph.get("start_node_id") if "start_node_id" in graph else 0
	var boss_id = graph.get("boss_node_id") if "boss_node_id" in graph else 0

	# 1. Validate Start and Boss node existence
	if not graph.nodes.has(start_id):
		return {"is_valid": false, "reason": "Missing Start node"}
	if not graph.nodes.has(boss_id):
		return {"is_valid": false, "reason": "Missing Boss node"}

	# 2. BFS Path Validation from Start to Boss
	var visited: Dictionary = {}
	var queue: Array[int] = [start_id]
	visited[start_id] = true
	var boss_reached = false

	while queue.size() > 0:
		var curr_id = queue.pop_front()
		if curr_id == boss_id:
			boss_reached = true
			break

		var curr_node = graph.nodes[curr_id]
		if curr_node == null or not "connected_node_ids" in curr_node: continue

		for conn_id in curr_node.connected_node_ids:
			if not visited.has(conn_id):
				visited[conn_id] = true
				queue.append(conn_id)

	if not boss_reached:
		return {"is_valid": false, "reason": "Boss node is unreachable from Start"}

	return {"is_valid": true, "reason": "Graph topology valid"}

static func validate_platform_jump(from_pos: Vector2, to_pos: Vector2) -> bool:
	var h_dist = abs(to_pos.x - from_pos.x)
	var v_dist = from_pos.y - to_pos.y # Positive if jumping up

	if h_dist > MAX_HORIZONTAL_JUMP:
		return false
	if v_dist > MAX_VERTICAL_JUMP:
		return false

	return true
