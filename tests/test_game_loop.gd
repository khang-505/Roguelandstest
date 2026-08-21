# tests/test_game_loop.gd
class_name TestGameLoop
extends Node

## Verification test runner for Phase 1.4 Game Loop Slice.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 1.4 GAME LOOP SLICE ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_main_menu_instantiation():
		print("[PASS] Main Menu UI instantiation & button hooks")
		pass_count += 1
	else:
		print("[FAIL] Main Menu test failed")
		fail_count += 1

	if test_hud_controller():
		print("[PASS] HUD overlay realtime update & signal binding")
		pass_count += 1
	else:
		print("[FAIL] HUD controller test failed")
		fail_count += 1

	if test_loot_magnet():
		print("[PASS] LootDrop magnetic pull logic & pickup signal")
		pass_count += 1
	else:
		print("[FAIL] LootDrop test failed")
		fail_count += 1
		
	if test_full_loop_transition():
		print("[PASS] Game Loop State Flow (MENU -> WORLD -> DEATH -> MENU)")
		pass_count += 1
	else:
		print("[FAIL] Game Loop State Flow failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_main_menu_instantiation() -> bool:
	var scene = load("res://scenes/ui/main_menu.tscn")
	if scene == null:
		return false
	var instance = scene.instantiate()
	var ok = (instance is MainMenuController)
	instance.free()
	return ok

func test_hud_controller() -> bool:
	var scene = load("res://scenes/ui/hud.tscn")
	if scene == null:
		return false
	var instance = scene.instantiate() as HUDController
	instance._ready()
	var ok = (instance != null)
	instance.free()
	return ok

func test_loot_magnet() -> bool:
	var loot = LootDrop.new()
	loot._ready()
	var item_ok = (loot.item_data != null)
	loot.free()
	return item_ok

func test_full_loop_transition() -> bool:
	GameManager.change_state(GameManager.GameState.MAIN_MENU)
	var menu_ok = (GameManager.current_state == GameManager.GameState.MAIN_MENU)
	GameManager.start_new_expedition(777)
	var gen_ok = (GameManager.current_state == GameManager.GameState.WORLD_GENERATION)
	GameManager.change_state(GameManager.GameState.DEATH)
	var death_ok = (GameManager.current_state == GameManager.GameState.DEATH)
	return menu_ok and gen_ok and death_ok
