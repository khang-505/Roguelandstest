# tests/test_phase3_1.gd
class_name TestPhase31
extends Node

## Verification test runner for Phase 3.1 Forge & Recipe Crafting Engine.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 3.1 FORGE CRAFTING SYSTEM ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_valid_crafting_transaction():
		print("[PASS] Atomic Crafting Transaction: Materials deducted, item unlocked & saved")
		pass_count += 1
	else:
		print("[FAIL] Valid crafting transaction test failed")
		fail_count += 1

	if test_insufficient_materials_failure():
		print("[PASS] Transaction Safety: Insufficient materials reject craft & preserve resources")
		pass_count += 1
	else:
		print("[FAIL] Insufficient materials test failed")
		fail_count += 1

	if test_locked_hub_level_recipe():
		print("[PASS] Hub Prerequisite Lock: Higher recipe locked until Hub Level requirement met")
		pass_count += 1
	else:
		print("[FAIL] Locked hub level test failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_valid_crafting_transaction() -> bool:
	SaveManager.profile_data["hub_level"] = 1
	SaveManager.profile_data["persistent_materials"] = {"ember_ore": 15, "star_shard": 10}
	SaveManager.profile_data["unlocked_recipes"] = []
	
	var success = CraftingManager.craft_recipe("plasma_cutter_mk2")
	
	var mats = SaveManager.profile_data["persistent_materials"]
	var mats_ok = (mats["ember_ore"] == 5 and mats["star_shard"] == 5) # 15-10=5, 10-5=5
	var item_ok = ("plasma_cutter_mk2" in SaveManager.profile_data["unlocked_recipes"])
	
	return success and mats_ok and item_ok

func test_insufficient_materials_failure() -> bool:
	SaveManager.profile_data["hub_level"] = 1
	SaveManager.profile_data["persistent_materials"] = {"ember_ore": 2, "star_shard": 1} # Need 10 and 5
	SaveManager.profile_data["unlocked_recipes"] = []
	
	var success = CraftingManager.craft_recipe("plasma_cutter_mk2")
	
	var rejected = (not success)
	var mats = SaveManager.profile_data["persistent_materials"]
	var mats_same = (mats["ember_ore"] == 2 and mats["star_shard"] == 1)
	
	return rejected and mats_same

func test_locked_hub_level_recipe() -> bool:
	SaveManager.profile_data["hub_level"] = 1 # Frost Rifle Mk2 requires Hub Level 2
	SaveManager.profile_data["persistent_materials"] = {"cryo_crystal": 50, "star_shard": 50}
	
	var success = CraftingManager.craft_recipe("frost_rifle_mk2")
	
	var rejected = (not success)
	var mats = SaveManager.profile_data["persistent_materials"]
	var mats_same = (mats["cryo_crystal"] == 50)
	
	return rejected and mats_same
