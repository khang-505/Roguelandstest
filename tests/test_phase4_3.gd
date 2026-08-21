# tests/test_phase4_3.gd
class_name TestPhase43
extends Node

## Verification test runner for Phase 4.3 Expedition Contracts System.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 4.3 EXPEDITION CONTRACTS ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_contract_registration():
		print("[PASS] Contract Data Registration (No Healing, Speed Run, Melee Only)")
		pass_count += 1
	else:
		print("[FAIL] Contract registration test failed")
		fail_count += 1

	if test_reward_multiplier_math():
		print("[PASS] Reward Multiplier Math: 100 Base Credits * 1.8x = 180 Final Credits")
		pass_count += 1
	else:
		print("[FAIL] Multiplier math test failed")
		fail_count += 1

	if test_multiplier_idempotency():
		print("[PASS] Multiplier Idempotency: Prevents double-multiplication bugs")
		pass_count += 1
	else:
		print("[FAIL] Multiplier idempotency test failed")
		fail_count += 1

	if test_contract_reset():
		print("[PASS] Contract Reset: Returns active contract to 'none' on run completion")
		pass_count += 1
	else:
		print("[FAIL] Contract reset test failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_contract_registration() -> bool:
	var contracts = ["no_healing", "speed_run", "melee_only"]
	for c_id in contracts:
		var c = ContractData.get_contract(c_id)
		if c == null or c.contract_id != c_id:
			return false
	return true

func test_reward_multiplier_math() -> bool:
	RewardManager.reset_contract()
	RewardManager.select_contract("no_healing")
	
	var res = RewardManager.calculate_final_rewards(100, 10)
	var cred_ok = (res["final_credits"] == 180) # 100 * 1.8 = 180
	var shard_ok = (res["final_shards"] == 10)   # 10 * 1.0 = 10
	
	return cred_ok and shard_ok

func test_multiplier_idempotency() -> bool:
	RewardManager.reset_contract()
	RewardManager.select_contract("no_healing")
	
	var res1 = RewardManager.calculate_final_rewards(100, 10)
	var res2 = RewardManager.calculate_final_rewards(100, 10) # Should NOT become 324 (180 * 1.8)
	
	return res1["final_credits"] == 180 and res2["final_credits"] == 180

func test_contract_reset() -> bool:
	RewardManager.select_contract("speed_run")
	RewardManager.reset_contract()
	return RewardManager.active_contract_id == "none"
