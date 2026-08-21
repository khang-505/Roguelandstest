# scripts/progression/progression_tree.gd
class_name ProgressionTree
extends Node

## Research Lab Meta-Progression Manager handling dependency chains and atomic unlocks.

static var node_registry: Dictionary = {}

static func _static_init() -> void:
	_setup_registry()

static func _setup_registry() -> void:
	if node_registry.size() > 0:
		return

	# Root Node 1: Basic Combat
	var n1 = ResearchNodeData.new()
	n1.node_id = "basic_combat"
	n1.display_name = "Basic Combat"
	n1.description = "+15% Maximum Health"
	n1.cost_shards = 10
	n1.prerequisites = []
	n1.required_hub_level = 2
	n1.stat_target = "max_hp"
	n1.operation = "MULTIPLY"
	n1.value = 0.15
	node_registry[n1.node_id] = n1

	# Node 2: Advanced Combat (Requires Basic Combat)
	var n2 = ResearchNodeData.new()
	n2.node_id = "advanced_combat"
	n2.display_name = "Advanced Combat"
	n2.description = "+20% Base Weapon Damage"
	n2.cost_shards = 25
	n2.prerequisites = ["basic_combat"]
	n2.required_hub_level = 2
	n2.stat_target = "weapon_damage"
	n2.operation = "MULTIPLY"
	n2.value = 0.20
	node_registry[n2.node_id] = n2

	# Node 3: Magnet Array
	var n3 = ResearchNodeData.new()
	n3.node_id = "magnet_array"
	n3.display_name = "Magnet Array"
	n3.description = "+24px Loot Pickup Radius"
	n3.cost_shards = 15
	n3.prerequisites = []
	n3.required_hub_level = 2
	n3.stat_target = "magnet_radius"
	n3.operation = "ADD"
	n3.value = 24.0
	node_registry[n3.node_id] = n3

static func get_node_data(node_id: String) -> ResearchNodeData:
	_setup_registry()
	if node_registry.has(node_id):
		return node_registry[node_id]
	return null

static func can_unlock(node: ResearchNodeData, profile: Dictionary) -> Dictionary:
	if node == null:
		return {"can_unlock": false, "reason": "Invalid research node"}

	var unlocked_nodes: Array = profile.get("unlocked_research", [])
	if node.node_id in unlocked_nodes:
		return {"can_unlock": false, "reason": "Already unlocked"}

	# Check Hub level
	var current_hub = profile.get("hub_level", 1)
	if current_hub < node.required_hub_level:
		return {"can_unlock": false, "reason": "Requires Hub Level %d" % node.required_hub_level}

	# Check Prerequisites
	for prereq in node.prerequisites:
		if not (prereq in unlocked_nodes):
			return {"can_unlock": false, "reason": "Missing prerequisite: %s" % prereq}

	# Check Shards Currency
	var shards = profile.get("total_shards", 0)
	if shards < node.cost_shards:
		return {"can_unlock": false, "reason": "Insufficient Star-Shards (%d/%d)" % [shards, node.cost_shards]}

	return {"can_unlock": true, "reason": "Ready to unlock"}

static func unlock_research(node_id: String) -> bool:
	_setup_registry()
	var node = get_node_data(node_id)
	if node == null:
		return false

	var profile = SaveManager.profile_data
	var validation = can_unlock(node, profile)
	if not validation["can_unlock"]:
		return false

	# Atomic Shards Deduction
	profile["total_shards"] = profile.get("total_shards", 0) - node.cost_shards
	
	# Mark Unlocked
	var unlocked: Array = profile.get("unlocked_research", [])
	unlocked.append(node.node_id)
	profile["unlocked_research"] = unlocked

	# Apply Permanent Stat Modification to GameManager defaults
	_apply_node_stat_effect(node)

	SaveManager.save_game()
	return true

static func _apply_node_stat_effect(node: ResearchNodeData) -> void:
	if node.stat_target == "max_hp":
		if node.operation == "MULTIPLY":
			GameManager.player_max_hp = int(GameManager.player_max_hp * (1.0 + node.value))
		elif node.operation == "ADD":
			GameManager.player_max_hp += int(node.value)
