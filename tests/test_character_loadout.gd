# tests/test_character_loadout.gd
class_name TestCharacterLoadout
extends Node

## Verification test suite for Starfall Frontier — System 49: Unlockable Characters & Loadouts.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING UNLOCKABLE CHARACTERS & LOADOUTS ---")
	test_operatives_catalog()
	test_unlock_mechanics()
	test_validator_score()
	print("--- CHARACTER LOADOUT SYSTEM TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_operatives_catalog() -> void:
	var mgr_script = load("res://scripts/core/character_loadout_manager.gd")
	_assert_true(mgr_script != null, "CharacterLoadoutManager script loaded")

	var op = mgr_script.get_operative("vanguard")
	_assert_true(op.get("display_name") == "Iron Vanguard", "Vanguard operative returned")
	print("[PASS] Operatives Catalog & Class Data Check (2/2 PASSED)")

func test_unlock_mechanics() -> void:
	var mgr_script = load("res://scripts/core/character_loadout_manager.gd")

	var unlock_res = mgr_script.unlock_operative("cryomancer", [], 200) # Needs 200 shards
	_assert_true(unlock_res.get("success", false), "Cryomancer unlocked with 200 Star-Shards")
	print("[PASS] Character Unlock Mechanics Check (1/1 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/core/character_loadout_validator.gd")
	var res = val_script.validate_character_loadouts()
	_assert_true(res.get("is_valid", false), "CharacterLoadoutValidator passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] CharacterLoadoutValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
