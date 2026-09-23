# scripts/procedural/branch_generator.gd
class_name BranchGenerator
extends Node

## Manages decision point creation, optional path generation (20-30%), secret paths (5-10%), and branch reconnection.

static func attach_branches_to_graph(graph: Object, rng: RandomNumberGenerator) -> void:
	if graph == null or not "nodes" in graph:
		return

	var nodes_dict = graph.nodes as Dictionary
	if nodes_dict.size() == 0:
		return

	var main_nodes: Array = []
	for n_id in nodes_dict.keys():
		var n = nodes_dict[n_id]
		if "is_main_path" in n and n.is_main_path:
			main_nodes.append(n)

	if main_nodes.size() < 3:
		return

	var b_data_class = load("res://scripts/procedural/branch_data.gd")
	if b_data_class == null or not b_data_class.has_method("get_registry"):
		return

	var branch_reg = b_data_class.get_registry() as Dictionary
	var node_counter = nodes_dict.size()

	var branches_created = 0

	# Create Optional Branches (25% ratio with guaranteed 1st branch)
	for i in range(1, main_nodes.size() - 1):
		var parent_node = main_nodes[i]
		var depth = parent_node.depth if "depth" in parent_node else i

		if i == 1 or rng.randf() < 0.45:
			branches_created += 1
			var b_keys = branch_reg.keys()
			var chosen_key = b_keys[rng.randi() % b_keys.size()]
			var b_data = branch_reg[chosen_key]

			var is_secret = b_data.get("is_secret") if "is_secret" in b_data else false
			var archetype_val = 3 # TREASURE
			var b_type = b_data.get("branch_type") if "branch_type" in b_data else ""
			if b_type == "RISK_ELITE": archetype_val = 7
			elif b_type == "RESOURCE_SHOP": archetype_val = 5
			elif b_type == "SECRET_HIDDEN": archetype_val = 8

			var p_pos = parent_node.grid_pos if "grid_pos" in parent_node else Vector2i(depth, 0)
			var branch_pos = p_pos + Vector2i(0, -1 if is_secret else 1)

			var map_node_class = load("res://scripts/procedural/map_graph.gd")
			if map_node_class:
				# Instantiate branch node
				var branch_node = map_node_class.MapGraphNode.new(node_counter, depth, archetype_val, branch_pos)
				branch_node.is_main_path = false

				nodes_dict[node_counter] = branch_node

				# Connect parent to branch
				if is_secret:
					if "secret_connected_ids" in parent_node:
						parent_node.secret_connected_ids.append(node_counter)
				else:
					if "connected_node_ids" in parent_node:
						parent_node.connected_node_ids.append(node_counter)

				# Reconnect optional branch back to main path
				var reconnect = b_data.get("reconnect_to_main") if "reconnect_to_main" in b_data else true
				if reconnect and (i + 1) < main_nodes.size():
					var next_main = main_nodes[i + 1]
					if "connected_node_ids" in branch_node and "id" in next_main:
						branch_node.connected_node_ids.append(next_main.id)

				node_counter += 1
