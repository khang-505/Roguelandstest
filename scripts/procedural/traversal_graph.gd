# scripts/procedural/traversal_graph.gd
class_name TraversalGraph
extends Node

## Directed navigation graph modeling vertical traversal connections between multi-tier platforms and layers.

enum TraversalType {
	JUMP,
	DOUBLE_JUMP,
	DASH,
	LADDER,
	ELEVATOR,
	MOVING_PLATFORM,
	DROP,
	CAVE_DESCENT
}

enum TraversalDirection {
	UP,
	DOWN,
	LATERAL
}

class TraversalNode:
	var id: int
	var layer: int # VerticalExplorationParams.VerticalLayer
	var position: Vector2 # Global or room-relative pixel coordinates
	var width_px: float = 64.0
	var is_ground: bool = false
	var is_recovery: bool = false # Safe fallback landing area if player fails upper jump

	func _init(p_id: int, p_layer: int, p_pos: Vector2, p_width: float = 64.0, p_ground: bool = false):
		id = p_id
		layer = p_layer
		position = p_pos
		width_px = p_width
		is_ground = p_ground

class TraversalEdge:
	var from_node_id: int
	var to_node_id: int
	var type: int # TraversalType
	var direction: int # TraversalDirection
	var distance_px: float = 0.0
	var is_optional: bool = false
	var required_ability: String = ""

	func _init(p_from: int, p_to: int, p_type: int, p_dir: int, p_dist: float, p_optional: bool = false, p_ability: String = ""):
		from_node_id = p_from
		to_node_id = p_to
		type = p_type
		direction = p_dir
		distance_px = p_dist
		is_optional = p_optional
		required_ability = p_ability

var nodes: Dictionary = {} # int id -> TraversalNode
var edges: Array[TraversalEdge] = []
var node_counter: int = 0

func clear() -> void:
	nodes.clear()
	edges.clear()
	node_counter = 0

func add_platform_node(layer: int, pos: Vector2, width_px: float = 64.0, is_ground: bool = false) -> TraversalNode:
	var n = TraversalNode.new(node_counter, layer, pos, width_px, is_ground)
	nodes[node_counter] = n
	node_counter += 1
	return n

func connect_nodes(from_id: int, to_id: int, type: int, is_optional: bool = false, ability: String = "") -> void:
	if not nodes.has(from_id) or not nodes.has(to_id):
		return
	var n_from = nodes[from_id] as TraversalNode
	var n_to = nodes[to_id] as TraversalNode
	var dist = n_from.position.distance_to(n_to.position)

	var dir = TraversalDirection.LATERAL
	if n_to.position.y < n_from.position.y - 10.0:
		dir = TraversalDirection.UP
	elif n_to.position.y > n_from.position.y + 10.0:
		dir = TraversalDirection.DOWN

	var edge = TraversalEdge.new(from_id, to_id, type, dir, dist, is_optional, ability)
	edges.append(edge)

# BFS Reachability Check from start node to target node
func is_reachable(start_id: int, target_id: int) -> bool:
	if not nodes.has(start_id) or not nodes.has(target_id):
		return false
	if start_id == target_id:
		return true

	var visited = {}
	var queue = [start_id]
	visited[start_id] = true

	while queue.size() > 0:
		var curr = queue.pop_front() as int
		if curr == target_id:
			return true

		for edge in edges:
			if edge.from_node_id == curr and not visited.has(edge.to_node_id):
				visited[edge.to_node_id] = true
				queue.append(edge.to_node_id)
	return false

# Find all nodes connected to a recovery ground/platform if player drops
func get_recovery_nodes_for_node(node_id: int) -> Array[int]:
	var recovery: Array[int] = []
	if not nodes.has(node_id):
		return recovery
	var target_node = nodes[node_id] as TraversalNode

	for n_id in nodes.keys():
		var n = nodes[n_id] as TraversalNode
		# Recovery node is lower Y (downwards in 2D physics) and within horizontal jump range
		if n.position.y > target_node.position.y and abs(n.position.x - target_node.position.x) <= 220.0:
			if n.is_ground or n.is_recovery:
				recovery.append(n.id)
	return recovery
