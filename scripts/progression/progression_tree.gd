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

	# Root Node 1: Basic Combat (+15% HP)
	var n1 = ResearchNodeData.new()
	n1.node_id = "basic_combat"
	n1.display_name = "Basic Combat (Tăng HP)"
	n1.description = "+15% Maximum Health"
	n1.cost_shards = 2
	var p1: Array[String] = []
	n1.prerequisites = p1
	n1.required_hub_level = 1
	n1.stat_target = "max_hp"
	n1.operation = "MULTIPLY"
	n1.value = 0.15
	node_registry[n1.node_id] = n1

	# Node 2: Advanced Combat (Requires Basic Combat)
	var n2 = ResearchNodeData.new()
	n2.node_id = "advanced_combat"
	n2.display_name = "Advanced Combat (Tăng Sức Mạnh)"
	n2.description = "+20% Base Weapon Damage"
	n2.cost_shards = 5
	var p2: Array[String] = ["basic_combat"]
	n2.prerequisites = p2
	n2.required_hub_level = 1
	n2.stat_target = "weapon_damage"
	n2.operation = "MULTIPLY"
	n2.value = 0.20
	node_registry[n2.node_id] = n2

	# Node 3: Magnet Array
	var n3 = ResearchNodeData.new()
	n3.node_id = "magnet_array"
	n3.display_name = "Magnet Array (Tăng Tầm Nhặt Đồ)"
	n3.description = "+24px Loot Pickup Radius"
	n3.cost_shards = 3
	var p3: Array[String] = []
	n3.prerequisites = p3
	n3.required_hub_level = 1
	n3.stat_target = "magnet_radius"
	n3.operation = "ADD"
	n3.value = 24.0
	node_registry[n3.node_id] = n3

	# Node 4: Titan Physique (Requires Basic Combat)
	var n4 = ResearchNodeData.new()
	n4.node_id = "titan_physique"
	n4.display_name = "Titan Physique (Thân Thể Thần Thánh)"
	n4.description = "+25% Maximum Health Tier 2"
	n4.cost_shards = 6
	var p4: Array[String] = ["basic_combat"]
	n4.prerequisites = p4
	n4.required_hub_level = 1
	n4.stat_target = "max_hp"
	n4.operation = "MULTIPLY"
	n4.value = 0.25
	node_registry[n4.node_id] = n4

	# Node 5: Master Smith (Requires Advanced Combat)
	var n5 = ResearchNodeData.new()
	n5.node_id = "master_smith"
	n5.display_name = "Master Smith (Hỏa Lực Tối Thượng)"
	n5.description = "+30% Base Damage Tier 2"
	n5.cost_shards = 10
	var p5: Array[String] = ["advanced_combat"]
	n5.prerequisites = p5
	n5.required_hub_level = 1
	n5.stat_target = "weapon_damage"
	n5.operation = "MULTIPLY"
	n5.value = 0.30
	node_registry[n5.node_id] = n5

	# Node 6: Swift Boots (Requires Magnet Array)
	var n6 = ResearchNodeData.new()
	n6.node_id = "swift_boots"
	n6.display_name = "Swift Boots (Giày Giáp Siêu Tốc)"
	n6.description = "+48px Loot Pickup Radius Tier 2"
	n6.cost_shards = 5
	var p6: Array[String] = ["magnet_array"]
	n6.prerequisites = p6
	n6.required_hub_level = 1
	n6.stat_target = "magnet_radius"
	n6.operation = "ADD"
	n6.value = 48.0
	node_registry[n6.node_id] = n6

static func get_node_data(node_id: String) -> ResearchNodeData:
	_setup_registry()
	if node_registry.has(node_id):
		return node_registry[node_id]
	return null

static func can_unlock(node: ResearchNodeData, profile: Dictionary) -> Dictionary:
	if node == null:
		return {"can_unlock": false, "reason": "Nghiên cứu không hợp lệ"}

	var unlocked_nodes: Array = profile.get("unlocked_research", [])
	if node.node_id in unlocked_nodes:
		return {"can_unlock": false, "reason": "Đã mở khóa rồi!"}

	# Check Prerequisites
	for prereq in node.prerequisites:
		if not (prereq in unlocked_nodes):
			return {"can_unlock": false, "reason": "Cần mở khóa điều kiện trước: %s" % prereq}

	# Check Shards Currency
	var shards = profile.get("total_shards", 0)
	if shards < node.cost_shards:
		return {"can_unlock": false, "reason": "Thiếu Star-Shards (%d/%d)" % [shards, node.cost_shards]}

	return {"can_unlock": true, "reason": "Sẵn sàng mở khóa!"}

static func unlock_research(node_id: String) -> Dictionary:
	_setup_registry()
	var node = get_node_data(node_id)
	if node == null:
		return {"success": false, "message": "Nghiên cứu không hợp lệ!"}

	var profile = SaveManager.profile_data
	var validation = can_unlock(node, profile)
	if not validation["can_unlock"]:
		return {"success": false, "message": validation["reason"]}

	# Atomic Shards Deduction
	profile["total_shards"] = profile.get("total_shards", 0) - node.cost_shards

	# Mark Unlocked
	var unlocked: Array = profile.get("unlocked_research", [])
	unlocked.append(node.node_id)
	profile["unlocked_research"] = unlocked

	# Apply Permanent Stat Modification
	_apply_node_stat_effect(node)

	SaveManager.save_game()
	return {"success": true, "message": "Đã mở khóa nâng cấp %s!" % node.display_name}

static func _apply_node_stat_effect(node: ResearchNodeData) -> void:
	if node.stat_target == "max_hp":
		if node.operation == "MULTIPLY":
			GameManager.player_max_hp = int(GameManager.player_max_hp * (1.0 + node.value))
		elif node.operation == "ADD":
			GameManager.player_max_hp += int(node.value)
	elif node.stat_target == "weapon_damage":
		# Store as a profile modifier that gets applied in start_new_expedition
		# The actual effect is applied via the profile's "research_weapon_damage_bonus" field
		var profile = SaveManager.profile_data
		if node.operation == "MULTIPLY":
			var existing = profile.get("research_weapon_damage_mult", 1.0)
			profile["research_weapon_damage_mult"] = existing * (1.0 + node.value)
		elif node.operation == "ADD":
			var existing = profile.get("research_weapon_damage_add", 0)
			profile["research_weapon_damage_add"] = existing + int(node.value)
	elif node.stat_target == "magnet_radius":
		# Store pickup radius bonus in profile for LootDrop objects to read
		var profile = SaveManager.profile_data
		if node.operation == "ADD":
			var existing = profile.get("research_magnet_bonus", 0.0)
			profile["research_magnet_bonus"] = existing + node.value

static func apply_saved_research_stats() -> void:
	## Re-applies all unlocked research nodes' stat effects on game load or run start.
	_setup_registry()
	var profile = SaveManager.profile_data
	var unlocked: Array = profile.get("unlocked_research", [])
	for node_id in unlocked:
		var node = get_node_data(node_id)
		if node and node.stat_target == "max_hp":
			# Only re-apply HP bonuses to GameManager on expedition start
			if node.operation == "MULTIPLY":
				GameManager.player_max_hp = int(GameManager.player_max_hp * (1.0 + node.value))
			elif node.operation == "ADD":
				GameManager.player_max_hp += int(node.value)
