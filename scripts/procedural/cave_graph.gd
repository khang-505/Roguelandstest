# scripts/procedural/cave_graph.gd
class_name CaveGraph
extends Resource

## Topological network graph tracking subterranean cave nodes, depth progression, and surface shortcuts.

class CaveNode:
	var node_id: String = ""
	var archetype: int = 1 # CaveType
	var depth_level: int = 0
	var position: Vector2 = Vector2.ZERO
	var is_main_route: bool = true
	var is_explored: bool = false
	var connects_to_surface: bool = false

	func _init(p_id: String, p_arch: int, p_depth: int, p_pos: Vector2, p_main: bool = true) -> void:
		node_id = p_id
		archetype = p_arch
		depth_level = p_depth
		position = p_pos
		is_main_route = p_main

class CaveEdge:
	var from_id: String = ""
	var to_id: String = ""
	var edge_type: String = "TUNNEL" # TUNNEL, SHAFT, SECRET, SHORTCUT
	var is_shortcut: bool = false

	func _init(f: String, t: String, type_str: String = "TUNNEL", shortcut: bool = false) -> void:
		from_id = f
		to_id = t
		edge_type = type_str
		is_shortcut = shortcut

@export var nodes: Array = [] # Array of CaveNode
@export var edges: Array = [] # Array of CaveEdge

func add_cave_node(p_id: String, p_arch: int, p_depth: int, p_pos: Vector2, p_main: bool = true) -> CaveNode:
	var n = CaveNode.new(p_id, p_arch, p_depth, p_pos, p_main)
	nodes.append(n)
	return n

func connect_cave_nodes(from_id: String, to_id: String, type_str: String = "TUNNEL", shortcut: bool = false) -> void:
	var e = CaveEdge.new(from_id, to_id, type_str, shortcut)
	edges.append(e)

func get_node(p_id: String) -> CaveNode:
	for n in nodes:
		if n.node_id == p_id:
			return n
	return null

func is_path_reachable(start_id: String, exit_id: String) -> bool:
	if get_node(start_id) == null or get_node(exit_id) == null:
		return false

	var visited = {}
	var queue = [start_id]
	visited[start_id] = true

	while queue.size() > 0:
		var current = queue.pop_front()
		if current == exit_id:
			return true

		for e in edges:
			var neighbor = ""
			if e.from_id == current:
				neighbor = e.to_id
			elif e.to_id == current:
				neighbor = e.from_id

			if neighbor != "" and not visited.has(neighbor):
				visited[neighbor] = true
				queue.append(neighbor)

	return false
