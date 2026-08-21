# tests/test_phase3_2.gd
class_name TestPhase32
extends Node

## Verification test runner for Phase 3.2 Research Lab & Meta-Progression Tree.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 3.2 RESEARCH LAB ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_valid_research_unlock():
		print("[PASS] Atomic Research Unlock: Shards deducted, node unlocked & saved")
		pass_count += 1
	else:
		print("[FAIL] Valid research unlock test failed")
		fail_count += 1

	if test_prerequisite_lock():
		print("[PASS] Dependency Chain Validation: Prerequisites enforced (Advanced Combat locked without Basic Combat)")
		pass_count += 1
	else:
		print("[FAIL] Prerequisite lock test failed")
		fail_count += 1

	if test_insufficient_shards_failure():
		print("[PASS] Transaction Safety: Insufficient shards reject unlock & preserve funds")
		pass_count += 1
	else:
		print("[FAIL] Insufficient shards test failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_valid_research_unlock() -> bool:
	SaveManager.profile_data["hub_level"] = 2
	SaveManager.profile_data["total_shards"] = 50
	SaveManager.profile_data["unlocked_research"] = []
	
	var success = ProgressionTree.unlock_research("basic_combat")
	
	var shards_ok = (SaveManager.profile_data["total_shards"] == 40) # 50 - 10 = 40
	var unlocked_ok = ("basic_combat" in SaveManager.profile_data["unlocked_research"])
	
	return success and shards_ok and unlocked_ok

func test_prerequisite_lock() -> bool:
	SaveManager.profile_data["hub_level"] = 2
	SaveManager.profile_data["total_shards"] = 100
	SaveManager.profile_data["unlocked_research"] = [] # Missing "basic_combat"
	
	var success = ProgressionTree.unlock_research("advanced_combat") # Requires "basic_combat"
	
	var rejected = (not success)
	var shards_same = (SaveManager.profile_data["total_shards"] == 100)
	
	return rejected and shards_same

func test_insufficient_shards_failure() -> bool:
	SaveManager.profile_data["hub_level"] = 2
	SaveManager.profile_data["total_shards"] = 5 # Need 10
	SaveManager.profile_data["unlocked_research"] = []
	
	var success = ProgressionTree.unlock_research("basic_combat")
	
	var rejected = (not success)
	var shards_same = (SaveManager.profile_data["total_shards"] == 5)
	
	return rejected and shards_same
