# scripts/procedural/run_map_manager.gd
class_name RunMapManager
extends Node

## Manages the node-graph structure for procedural planet exploration runs.

enum NodeType {
	START,
	COMBAT,
	ELITE,
	TREASURE,
	EVENT,
	SHOP,
	REST,
	MINI_BOSS,
	BOSS
}

class MapNode:
	var id: int
	var depth: int
	var type: NodeType
	var title: String
	var is_completed: bool = false
	var is_accessible: bool = false
	var connected_node_ids: Array[int] = []

	func _init(p_id: int, p_depth: int, p_type: NodeType, p_title: String = ""):
		id = p_id
		depth = p_depth
		type = p_type
		title = p_title if p_title != "" else _default_title(p_type)

	static func _default_title(t: NodeType) -> String:
		match t:
			NodeType.START: return "Landing Zone"
			NodeType.COMBAT: return "Hostile Encounter"
			NodeType.ELITE: return "Elite Signal"
			NodeType.TREASURE: return "Cache Room"
			NodeType.EVENT: return "Anomaly Event"
			NodeType.SHOP: return "Black Market"
			NodeType.REST: return "Field Clinic"
			NodeType.MINI_BOSS: return "Command Unit"
			NodeType.BOSS: return "Guardian Citadel"
		return "Unknown Area"

var map_nodes: Dictionary = {} # id -> MapNode
var total_depths: int = 6
var current_node_id: int = 0
var current_seed: int = 1337

func generate_map(seed_val: int) -> void:
	current_seed = seed_val
	map_nodes.clear()
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_val

	var node_counter = 0

	# Depth 0: Start Node
	var start_node = MapNode.new(node_counter, 0, NodeType.START)
	start_node.is_accessible = true
	map_nodes[node_counter] = start_node
	current_node_id = node_counter
	node_counter += 1

	var prev_layer_ids: Array[int] = [0]

	# Depths 1 to total_depths - 2: Intermediate weighted nodes
	for d in range(1, total_depths - 1):
		var num_nodes_in_depth = rng.randi_range(2, 3)
		var current_layer_ids: Array[int] = []

		for n in range(num_nodes_in_depth):
			var n_type = _roll_node_type(rng, d, total_depths)
			var node = MapNode.new(node_counter, d, n_type)
			map_nodes[node_counter] = node
			current_layer_ids.append(node_counter)
			node_counter += 1

		# Connect prev layer to current layer
		for prev_id in prev_layer_ids:
			var prev_n = map_nodes[prev_id] as MapNode
			for curr_id in current_layer_ids:
				prev_n.connected_node_ids.append(curr_id)

		prev_layer_ids = current_layer_ids

	# Final Depth: Boss Node
	var boss_node = MapNode.new(node_counter, total_depths - 1, NodeType.BOSS)
	map_nodes[node_counter] = boss_node
	for prev_id in prev_layer_ids:
		var prev_n = map_nodes[prev_id] as MapNode
		prev_n.connected_node_ids.append(node_counter)

func _roll_node_type(rng: RandomNumberGenerator, depth: int, max_d: int) -> NodeType:
	if depth == max_d - 2: # Pre-boss layer: Rest or Shop
		return NodeType.REST if rng.randf() < 0.5 else NodeType.SHOP

	var roll = rng.randf()
	if roll < 0.40:
		return NodeType.COMBAT
	elif roll < 0.55:
		return NodeType.ELITE
	elif roll < 0.70:
		return NodeType.EVENT
	elif roll < 0.82:
		return NodeType.TREASURE
	elif roll < 0.91:
		return NodeType.SHOP
	else:
		return NodeType.REST

func select_node(node_id: int) -> bool:
	if not map_nodes.has(node_id):
		return false
	var target = map_nodes[node_id] as MapNode
	if not target.is_accessible:
		return false

	target.is_completed = true
	current_node_id = node_id

	# Update accessibility for connected nodes
	for n in map_nodes.values():
		(n as MapNode).is_accessible = false

	for conn_id in target.connected_node_ids:
		if map_nodes.has(conn_id):
			(map_nodes[conn_id] as MapNode).is_accessible = true

	return true
