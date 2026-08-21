# tests/test_foundation.gd
class_name TestFoundation
extends Node

## Verification test runner for Phase 1.0 Foundation.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 1.0 FOUNDATION ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_event_bus():
		print("[PASS] EventBus signals registered")
		pass_count += 1
	else:
		print("[FAIL] EventBus signals failure")
		fail_count += 1
		
	if test_game_manager():
		print("[PASS] GameManager state machine & telemetry")
		pass_count += 1
	else:
		print("[FAIL] GameManager failure")
		fail_count += 1
		
	if test_world_manager():
		print("[PASS] WorldManager seed & biome initialization")
		pass_count += 1
	else:
		print("[FAIL] WorldManager failure")
		fail_count += 1
		
	if test_save_manager():
		print("[PASS] SaveManager data structure & profile serialization")
		pass_count += 1
	else:
		print("[FAIL] SaveManager failure")
		fail_count += 1
		
	if test_data_resources():
		print("[PASS] Data Resource instantiations (WeaponData, ItemData, EnemyData)")
		pass_count += 1
	else:
		print("[FAIL] Data Resource failure")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_event_bus() -> bool:
	return EventBus != null and EventBus.has_signal("game_state_changed") and EventBus.has_signal("player_hp_changed")

func test_game_manager() -> bool:
	if GameManager == null:
		return false
	GameManager.change_state(GameManager.GameState.HUB)
	var state_ok = (GameManager.current_state == GameManager.GameState.HUB)
	GameManager.start_new_expedition(9999)
	var seed_ok = (GameManager.current_seed == 9999)
	return state_ok and seed_ok

func test_world_manager() -> bool:
	if WorldManager == null:
		return false
	WorldManager.prepare_world(8888, "frostgrave")
	return WorldManager.current_world_seed == 8888 and WorldManager.current_biome_id == "frostgrave"

func test_save_manager() -> bool:
	if SaveManager == null:
		return false
	SaveManager.profile_data["total_credits"] = 500
	var save_ok = SaveManager.save_game()
	return save_ok and SaveManager.profile_data.has("save_version")

func test_data_resources() -> bool:
	var weapon = WeaponData.new()
	weapon.display_name = "Plasma Spear"
	var item = ItemData.new()
	item.display_name = "Ember Ore"
	var enemy = EnemyData.new()
	enemy.display_name = "Ash Beetle"
	return weapon.display_name == "Plasma Spear" and item.display_name == "Ember Ore" and enemy.display_name == "Ash Beetle"
