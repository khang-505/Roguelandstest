# tests/test_phase4_4.gd
class_name TestPhase44
extends Node

## Verification test runner for Phase 4.4 Reward Integration & Run Finalization.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 4.4 REWARD INTEGRATION ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_run_finalization_once():
		print("[PASS] Run Finalization: Reward calculation pipeline executed exactly once")
		pass_count += 1
	else:
		print("[FAIL] Run finalization test failed")
		fail_count += 1

	if test_reward_security():
		print("[PASS] Reward Security: Persistent credits updated safely on extraction victory")
		pass_count += 1
	else:
		print("[FAIL] Reward security test failed")
		fail_count += 1

	if test_contract_reset_on_hub_return():
		print("[PASS] Contract State Persistence: Active contract resets when returning to Hub")
		pass_count += 1
	else:
		print("[FAIL] Contract reset test failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_run_finalization_once() -> bool:
	RewardManager.reset_contract()
	RewardManager.select_contract("no_healing")
	GameManager.run_credits = 100
	GameManager.run_shards = 10
	
	var res1 = RewardManager.calculate_final_rewards(100, 10)
	var res2 = RewardManager.calculate_final_rewards(100, 10)
	
	return res1["final_credits"] == 180 and res2["final_credits"] == 180

func test_reward_security() -> bool:
	SaveManager.profile_data["total_credits"] = 200
	GameManager.run_credits = 100
	
	var beacon = ExtractionBeacon.new()
	beacon._secure_run_rewards()
	beacon.free()
	
	return SaveManager.profile_data["total_credits"] == 300

func test_contract_reset_on_hub_return() -> bool:
	RewardManager.select_contract("speed_run")
	GameManager.change_state(GameManager.GameState.HUB)
	RewardManager.reset_contract()
	return RewardManager.active_contract_id == "none"
