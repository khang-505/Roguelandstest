# scripts/procedural/vertical_validator.gd
class_name VerticalValidator
extends Node

## Traversal physics & reachability validator for vertical platform chains and multi-layer rooms.

static func validate_traversal_graph(graph: Object, params: Object) -> Dictionary:
	var result = {
		"is_valid": true,
		"errors": [],
		"reachability_score": 100.0,
		"recovery_coverage": 1.0
	}

	if graph == null or not "nodes" in graph or not "edges" in graph:
		result.is_valid = false
		result.errors.append("Invalid graph structure")
		return result

	var nodes = graph.nodes as Dictionary
	var edges = graph.edges as Array

	if nodes.size() == 0:
		result.is_valid = false
		result.errors.append("Empty graph nodes")
		return result

	var max_v_gap = params.max_vertical_gap if params and "max_vertical_gap" in params else 140.0
	var max_h_gap = params.max_jump_distance if params and "max_jump_distance" in params else 160.0
	var max_fall = params.max_fall_distance if params and "max_fall_distance" in params else 350.0

	var unrecoverable_nodes = 0

	# 1. Edge Physics Validation
	for edge in edges:
		var from_id = edge.get("from_node_id") if "from_node_id" in edge else edge.from_node_id
		var to_id = edge.get("to_node_id") if "to_node_id" in edge else edge.to_node_id
		var edge_type = edge.get("type") if "type" in edge else edge.type

		if nodes.has(from_id) and nodes.has(to_id):
			var n_from = nodes[from_id]
			var n_to = nodes[to_id]

			var p_from = n_from.position if "position" in n_from else Vector2.ZERO
			var p_to = n_to.position if "position" in n_to else Vector2.ZERO

			var delta_y = p_from.y - p_to.y # Positive = Jumping UP
			var delta_x = abs(p_from.x - p_to.x)

			# Validate Jump UP heights
			if delta_y > 0 and edge_type in [0, 1]: # JUMP or DOUBLE_JUMP
				if delta_y > max_v_gap + 20.0:
					result.is_valid = false
					result.errors.append("Jump height gap exceeded: %.1fpx > %.1fpx" % [delta_y, max_v_gap])

			# Validate Horizontal Jump gaps
			if delta_x > max_h_gap + 30.0 and edge_type in [0, 1, 2]: # JUMP, DOUBLE_JUMP, DASH
				result.is_valid = false
				result.errors.append("Horizontal jump gap exceeded: %.1fpx > %.1fpx" % [delta_x, max_h_gap])

			# Validate Drop / Fall safety
			if delta_y < -max_fall:
				result.errors.append("Warning: Drop height %.1fpx exceeds safe fall %.1fpx" % [-delta_y, max_fall])

	# 2. Check Recovery Platforms for Upper Nodes
	for node_id in nodes.keys():
		var n = nodes[node_id]
		var is_ground = n.is_ground if "is_ground" in n else false
		if not is_ground:
			var recovery = []
			if graph.has_method("get_recovery_nodes_for_node"):
				recovery = graph.get_recovery_nodes_for_node(node_id)
			if recovery.size() == 0:
				unrecoverable_nodes += 1

	if nodes.size() > 0:
		result.recovery_coverage = 1.0 - (float(unrecoverable_nodes) / float(nodes.size()))

	return result
