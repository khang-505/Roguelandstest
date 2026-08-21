# scripts/data/contract_data.gd
class_name ContractData
extends Resource

## Data-Driven Expedition Contract for high-risk, high-reward deployment challenges.

@export var contract_id: String = "no_healing"
@export var display_name: String = "Contract: No Healing"
@export var description: String = "Health restoration items are disabled during expedition."
@export var credits_multiplier: float = 1.8
@export var shards_multiplier: float = 1.0
@export var loot_quality_multiplier: float = 1.0
@export var is_no_healing: bool = true
@export var is_speed_run: bool = false
@export var is_melee_only: bool = false
@export var speed_run_deadline: float = 600.0 # 10 minutes

static var contract_registry: Dictionary = {}

static func _static_init() -> void:
	_setup_registry()

static func _setup_registry() -> void:
	if contract_registry.size() > 0:
		return

	# Contract 1: No Healing
	var c1 = ContractData.new()
	c1.contract_id = "no_healing"
	c1.display_name = "Contract: No Healing"
	c1.description = "All HP restoration items are disabled. Reward: 1.8x Credits."
	c1.credits_multiplier = 1.8
	c1.is_no_healing = true
	contract_registry[c1.contract_id] = c1

	# Contract 2: Speed Run
	var c2 = ContractData.new()
	c2.contract_id = "speed_run"
	c2.display_name = "Contract: Speed Run"
	c2.description = "Extract within 10 minutes (600s). Reward: 2.0x Star-Shards."
	c2.shards_multiplier = 2.0
	c2.is_speed_run = true
	c2.speed_run_deadline = 600.0
	contract_registry[c2.contract_id] = c2

	# Contract 3: Melee Only
	var c3 = ContractData.new()
	c3.contract_id = "melee_only"
	c3.display_name = "Contract: Melee Only"
	c3.description = "Ranged and Energy ammo attacks are disabled. Reward: 2.5x Loot Quality."
	c3.loot_quality_multiplier = 2.5
	c3.is_melee_only = true
	contract_registry[c3.contract_id] = c3

static func get_contract(c_id: String) -> ContractData:
	_setup_registry()
	if contract_registry.has(c_id):
		return contract_registry[c_id]
	return null
