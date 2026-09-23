# scripts/procedural/map_graph.gd
class_name MapGraph
extends Node

## Macro-graph generator creating connected room node structures before physical instantiation.

enum RoomArchetype {
	START,
	COMBAT,
	EXPLORATION,
	TREASURE,
	EVENT,
	SHOP,
	REST,
	ELITE,
	SECRET,
	CHALLENGE,
	MINI_BOSS,
	BOSS,
	EXIT
}

class MapGraphNode:
	var id: int
	var depth: int
	var archetype: int
	var is_main_path: bool = true
	var is_visited: bool = false
	var grid_pos: Vector2i = Vector2i.ZERO
	var connected_node_ids: Array[int] = []
	var secret_connected_ids: Array[int] = []

	func _init(p_id: int, p_depth: int, p_type: int, p_pos: Vector2i = Vector2i.ZERO):
		id = p_id
		depth = p_depth
		archetype = p_type
		grid_pos = p_pos

var nodes: Dictionary = {} # int id -> MapGraphNode
var start_node_id: int = 0
var boss_node_id: int = 0
var max_depth: int = 6

func generate_graph(seed_val: int, depth_count: int = 6) -> void:
	max_depth = depth_count
	nodes.clear()
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_val

	var node_counter = 0

	# Depth 0: Start Node
	var start_node = MapGraphNode.new(node_counter, 0, RoomArchetype.START, Vector2i(0, 0))
	nodes[node_counter] = start_node
	start_node_id = node_counter
	node_counter += 1

	var current_main_id = start_node_id

	# Build Main Progression Path (65% of world structure)
	for d in range(1, max_depth - 1):
		var archetype = _roll_main_archetype(rng, d, max_depth)
		var next_node = MapGraphNode.new(node_counter, d, archetype, Vector2i(d, 0))
		nodes[node_counter] = next_node
		
		(nodes[current_main_id] as MapGraphNode).connected_node_ids.append(next_node.id)
		current_main_id = next_node.id
		node_counter += 1

	# Pre-Boss Prep Node (Rest / Shop)
	var prep_node = MapGraphNode.new(node_counter, max_depth - 1, RoomArchetype.REST, Vector2i(max_depth - 1, 0))
	nodes[node_counter] = prep_node
	(nodes[current_main_id] as MapGraphNode).connected_node_ids.append(prep_node.id)
	current_main_id = prep_node.id
	node_counter += 1

	# Final Boss Node
	var boss_node = MapGraphNode.new(node_counter, max_depth, RoomArchetype.BOSS, Vector2i(max_depth, 0))
	nodes[node_counter] = boss_node
	boss_node_id = boss_node.id
	(nodes[current_main_id] as MapGraphNode).connected_node_ids.append(boss_node.id)

	# Attach Optional & Secret Branches
	var branch_gen = load("res://scripts/procedural/branch_generator.gd")
	if branch_gen and branch_gen.has_method("attach_branches_to_graph"):
		branch_gen.attach_branches_to_graph(self, rng)

func _roll_main_archetype(rng: RandomNumberGenerator, depth: int, total_d: int) -> int:
	if depth == 1:
		return RoomArchetype.COMBAT
	elif depth == total_d - 2:
		return RoomArchetype.MINI_BOSS if rng.randf() < 0.5 else RoomArchetype.ELITE

	var roll = rng.randf()
	if roll < 0.40: return RoomArchetype.COMBAT
	elif roll < 0.60: return RoomArchetype.EXPLORATION
	elif roll < 0.75: return RoomArchetype.EVENT
	elif roll < 0.88: return RoomArchetype.TREASURE
	else: return RoomArchetype.ELITE

func _roll_branch_archetype(rng: RandomNumberGenerator) -> int:
	var roll = rng.randf()
	if roll < 0.35: return RoomArchetype.TREASURE
	elif roll < 0.60: return RoomArchetype.SHOP
	elif roll < 0.80: return RoomArchetype.CHALLENGE
	else: return RoomArchetype.EVENT
