# tests/test_phase5_3.gd
class_name TestPhase53
extends Node

## Verification test runner for Phase 5.3 Accessibility, Camera & UI Polish.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 5.3 ACCESSIBILITY & SETTINGS ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_settings_load_and_save():
		print("[PASS] Settings Persistence: Accessibility options save to user://settings.json")
		pass_count += 1
	else:
		print("[FAIL] Settings save test failed")
		fail_count += 1

	if test_screen_shake_toggle():
		print("[PASS] Screen Shake Toggle: Screen shake option toggles cleanly")
		pass_count += 1
	else:
		print("[FAIL] Screen shake toggle test failed")
		fail_count += 1

	if test_settings_persistence_separation():
		print("[PASS] Settings Isolation: User settings saved separately from gameplay profile")
		pass_count += 1
	else:
		print("[FAIL] Settings isolation test failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_settings_load_and_save() -> bool:
	SettingsMenuController.user_settings["master_volume"] = 0.75
	var save_ok = SettingsMenuController.save_settings()
	var load_ok = SettingsMenuController.load_settings()
	var val_ok = (SettingsMenuController.user_settings["master_volume"] == 0.75)
	return save_ok and load_ok and val_ok

func test_screen_shake_toggle() -> bool:
	SettingsMenuController.user_settings["screen_shake_enabled"] = true
	var ui = SettingsMenuController.new()
	ui._on_toggle_screen_shake_pressed()
	var toggled = (SettingsMenuController.user_settings["screen_shake_enabled"] == false)
	ui.free()
	return toggled

func test_settings_persistence_separation() -> bool:
	# Check user_settings dictionary does not overlap with profile_data keys
	var user_keys = SettingsMenuController.user_settings.keys()
	var profile_keys = SaveManager.profile_data.keys()
	for k in user_keys:
		if k in profile_keys:
			return false
	return true
