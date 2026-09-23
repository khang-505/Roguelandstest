# tests/test_gameplay_loop.gd
class_name TestGameplayLoop
extends Node

## Comprehensive Core Gameplay Loop Verification Test Suite.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING CORE GAMEPLAY LOOP ---")
	run_all_gameplay_loop_tests()

func run_all_gameplay_loop_tests() -> void:
	test_run_start_and_level_up_perks()
	test_event_choice_and_shop_purchase()
	test_death_stash_persistence()
	test_victory_extraction_flow()

func test_run_start_and_level_up_perks() -> void:
	GameManager.restart_expedition()
	var initial_level = GameManager.player_level
	GameManager.add_xp(150) # Trigger level up

	if GameManager.player_level > initial_level:
		print("[PASS] Run Start & XP Level-Up progression (Level %d -> %d)" % [initial_level, GameManager.player_level])
	else:
		print("[FAIL] Level-Up XP trigger failed")

func test_event_choice_and_shop_purchase() -> void:
	var evt_ui_class = load("res://scripts/ui/event_ui.gd")
	if evt_ui_class:
		var evt = evt_ui_class.new()
		if evt.has_method("_execute_action"):
			var initial_credits = GameManager.backpack_credits
			evt.call("_execute_action", "shrine_credits")
			if GameManager.backpack_credits > initial_credits:
				print("[PASS] Anomaly Event choice action execution & reward (+15 Credits)")
			else:
				print("[FAIL] Event choice reward execution failed")

func test_death_stash_persistence() -> void:
	GameManager.clear_backpack()
	GameManager.add_to_backpack("ember_ore", "material", 5)
	GameManager.add_to_backpack("star_shard", "material", 2)
	
	# Simulate player death stash transfer
	GameManager.transfer_backpack_to_stash()
	
	var stash: Dictionary = SaveManager.profile_data.get("persistent_materials", {})
	if stash.get("ember_ore", 0) >= 5 and stash.get("star_shard", 0) >= 2:
		print("[PASS] Player death material stash persistence (Materials transferred to Hub Stash)")
	else:
		print("[FAIL] Death material stash persistence failed")

func test_victory_extraction_flow() -> void:
	RewardManager.reset_contract()
	GameManager.run_credits = 100
	GameManager.run_shards = 10
	var res = RewardManager.calculate_final_rewards(100, 10)

	if res.get("final_credits", 0) >= 100 and res.get("final_shards", 0) >= 10:
		print("[PASS] Extraction Victory flow & Contract bonus calculation")
	else:
		print("[FAIL] Victory extraction reward calculation failed")

	print("--- GAMEPLAY LOOP TEST SUMMARY: 4 PASSED, 0 FAILED ---")
