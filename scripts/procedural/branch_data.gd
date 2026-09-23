# scripts/procedural/branch_data.gd
class_name BranchData
extends Resource

## Data-Driven Branch Definition for Starfall Frontier procedural maps.

@export var branch_id: String = "reward_treasure"
@export var branch_type: String = "REWARD_TREASURE" # REWARD_TREASURE, RISK_ELITE, RESOURCE_SHOP, EXPLORATION_CAVE, SECRET_HIDDEN, SHORTCUT

@export var risk_rating: float = 0.3
@export var reward_rating: float = 0.8
@export var min_depth: int = 1
@export var max_depth: int = 8

@export var reconnect_to_main: bool = true
@export var is_secret: bool = false

static var branch_registry: Dictionary = {}

static func _setup_registry() -> void:
	if branch_registry.size() > 0:
		return

	var self_script = load("res://scripts/procedural/branch_data.gd") as GDScript

	# Type 1: Reward Treasure
	var b1 = self_script.new() as Resource
	b1.set("branch_id", "reward_treasure")
	b1.set("branch_type", "REWARD_TREASURE")
	b1.set("risk_rating", 0.3)
	b1.set("reward_rating", 0.8)
	b1.set("reconnect_to_main", true)
	b1.set("is_secret", false)
	branch_registry["reward_treasure"] = b1

	# Type 2: Risk Elite
	var b2 = self_script.new() as Resource
	b2.set("branch_id", "risk_elite")
	b2.set("branch_type", "RISK_ELITE")
	b2.set("risk_rating", 0.9)
	b2.set("reward_rating", 0.95)
	b2.set("reconnect_to_main", true)
	b2.set("is_secret", false)
	branch_registry["risk_elite"] = b2

	# Type 3: Resource Shop
	var b3 = self_script.new() as Resource
	b3.set("branch_id", "resource_shop")
	b3.set("branch_type", "RESOURCE_SHOP")
	b3.set("risk_rating", 0.1)
	b3.set("reward_rating", 0.7)
	b3.set("reconnect_to_main", true)
	b3.set("is_secret", false)
	branch_registry["resource_shop"] = b3

	# Type 4: Exploration Cave
	var b4 = self_script.new() as Resource
	b4.set("branch_id", "exploration_cave")
	b4.set("branch_type", "EXPLORATION_CAVE")
	b4.set("risk_rating", 0.5)
	b4.set("reward_rating", 0.6)
	b4.set("reconnect_to_main", true)
	b4.set("is_secret", false)
	branch_registry["exploration_cave"] = b4

	# Type 5: Secret Hidden
	var b5 = self_script.new() as Resource
	b5.set("branch_id", "secret_hidden")
	b5.set("branch_type", "SECRET_HIDDEN")
	b5.set("risk_rating", 0.2)
	b5.set("reward_rating", 1.0)
	b5.set("reconnect_to_main", false)
	b5.set("is_secret", true)
	branch_registry["secret_hidden"] = b5

	# Type 6: Shortcut
	var b6 = self_script.new() as Resource
	b6.set("branch_id", "shortcut")
	b6.set("branch_type", "SHORTCUT")
	b6.set("risk_rating", 0.4)
	b6.set("reward_rating", 0.5)
	b6.set("reconnect_to_main", true)
	b6.set("is_secret", false)
	branch_registry["shortcut"] = b6

static func get_registry() -> Dictionary:
	_setup_registry()
	return branch_registry

static func get_branch(b_id: String) -> Object:
	_setup_registry()
	if branch_registry.has(b_id):
		return branch_registry[b_id]
	return branch_registry.values()[0] if branch_registry.size() > 0 else null
