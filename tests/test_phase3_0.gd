# tests/test_phase3_0.gd
class_name TestPhase30
extends Node

## Verification test runner for Phase 3.0 Persistent Hub World & Base Level Evolution.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 3.0 HUB WORLD & BASE EVOLUTION ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_hub_initial_level():
		print("[PASS] Hub initial level initializes at Level 1")
		pass_count += 1
	else:
		print("[FAIL] Initial level test failed")
		fail_count += 1

	if test_hub_upgrade_success():
		print("[PASS] Hub Upgrade Transaction: Level 1 -> Level 2 with exact currency deduction & save")
		pass_count += 1
	else:
		print("[FAIL] Hub upgrade success test failed")
		fail_count += 1

	if test_hub_upgrade_insufficient_funds():
		print("[PASS] Transaction Safety: Insufficient currency rejects upgrade & preserves funds")
		pass_count += 1
	else:
		print("[FAIL] Transaction safety test failed")
		fail_count += 1
		
	if test_hub_upgrade_max_level_cap():
		print("[PASS] Level Cap Bounds: Max Level 4 cap prevents invalid upgrades")
		pass_count += 1
	else:
		print("[FAIL] Level cap test failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_hub_initial_level() -> bool:
	SaveManager.profile_data["hub_level"] = 1
	var hub = HubController.new()
	hub._ready()
	var ok = (hub.current_hub_level == 1)
	hub.free()
	return ok

func test_hub_upgrade_success() -> bool:
	SaveManager.profile_data["hub_level"] = 1
	SaveManager.profile_data["total_credits"] = 200
	SaveManager.profile_data["total_shards"] = 20
	
	var hub = HubController.new()
	hub._ready()
	var success = hub.upgrade_hub()
	
	var level_ok = (hub.current_hub_level == 2)
	var credits_ok = (SaveManager.profile_data["total_credits"] == 100) # 200 - 100 = 100
	var shards_ok = (SaveManager.profile_data["total_shards"] == 10) # 20 - 10 = 10
	
	hub.free()
	return success and level_ok and credits_ok and shards_ok

func test_hub_upgrade_insufficient_funds() -> bool:
	SaveManager.profile_data["hub_level"] = 1
	SaveManager.profile_data["total_credits"] = 50 # Need 100
	SaveManager.profile_data["total_shards"] = 5  # Need 10
	
	var hub = HubController.new()
	hub._ready()
	var success = hub.upgrade_hub()
	
	var rejected = (not success)
	var level_same = (hub.current_hub_level == 1)
	var credits_same = (SaveManager.profile_data["total_credits"] == 50)
	
	hub.free()
	return rejected and level_same and credits_same

func test_hub_upgrade_max_level_cap() -> bool:
	SaveManager.profile_data["hub_level"] = 4
	SaveManager.profile_data["total_credits"] = 5000
	SaveManager.profile_data["total_shards"] = 500
	
	var hub = HubController.new()
	hub._ready()
	var success = hub.upgrade_hub()
	
	var rejected = (not success)
	var level_max = (hub.current_hub_level == 4)
	
	hub.free()
	return rejected and level_max
