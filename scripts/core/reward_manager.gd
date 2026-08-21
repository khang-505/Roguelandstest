# scripts/core/reward_manager.gd
class_name RewardManager
extends Node

## Centralized Reward Manager for run finalization and contract multiplier calculations.

static var active_contract_id: String = "none"
static var has_calculated_final_rewards: bool = false

static func select_contract(contract_id: String) -> bool:
	if contract_id == "none" or ContractData.get_contract(contract_id) != null:
		active_contract_id = contract_id
		has_calculated_final_rewards = false
		return true
	return false

static func reset_contract() -> void:
	active_contract_id = "none"
	has_calculated_final_rewards = false

static func calculate_final_rewards(base_credits: int, base_shards: int) -> Dictionary:
	if has_calculated_final_rewards:
		# Return previous calculation to prevent double multiplication
		return {
			"final_credits": GameManager.run_credits,
			"final_shards": GameManager.run_shards
		}

	has_calculated_final_rewards = true
	var cred_mult = 1.0
	var shard_mult = 1.0
	
	var contract = ContractData.get_contract(active_contract_id)
	if contract != null:
		cred_mult = contract.credits_multiplier
		shard_mult = contract.shards_multiplier

	var final_credits = int(floor(float(base_credits) * cred_mult))
	var final_shards = int(floor(float(base_shards) * shard_mult))

	GameManager.run_credits = final_credits
	GameManager.run_shards = final_shards

	return {
		"final_credits": final_credits,
		"final_shards": final_shards
	}
