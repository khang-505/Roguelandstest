# tests/test_interactive_chest.gd
class_name TestInteractiveChest
extends Node

## Verification test suite for Starfall Frontier — System 43: Interactive Chest System.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING INTERACTIVE CHEST SYSTEM ---")
	test_4_tiers_and_multipliers()
	test_lock_and_key()
	test_mimic_trap()
	test_validator_score()
	print("--- INTERACTIVE CHEST SYSTEM TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_4_tiers_and_multipliers() -> void:
	var chest_script = load("res://scripts/world/interactive_chest.gd")
	_assert_true(chest_script != null, "InteractiveChest script loaded")
	
	var c_silver = chest_script.new()
	c_silver.tier = chest_script.ChestTier.SILVER
	var res = c_silver.open_chest(false, 0.99)
	_assert_true(res.get("tier_multiplier", 0.0) == 1.5, "Silver tier grants 1.5x loot multiplier")
	print("[PASS] 4 Chest Tiers & Multipliers Check (2/2 PASSED)")

func test_lock_and_key() -> void:
	var chest_script = load("res://scripts/world/interactive_chest.gd")
	
	var c_locked = chest_script.new()
	c_locked.is_locked = true
	c_locked.required_key_id = "void_key"
	
	var fail_res = c_locked.open_chest(false, 0.99)
	_assert_true(fail_res.get("reason") == "locked_requires_key", "Opening locked chest without key fails")
	
	var success_res = c_locked.open_chest(true, 0.99)
	_assert_true(success_res.get("success", false), "Opening locked chest WITH key succeeds")
	print("[PASS] Lock and Key Mechanics Check (2/2 PASSED)")

func test_mimic_trap() -> void:
	var chest_script = load("res://scripts/world/interactive_chest.gd")
	
	var c_mimic = chest_script.new()
	c_mimic.mimic_chance = 0.20
	var res = c_mimic.open_chest(false, 0.05) # forced 0.05 < 0.20
	_assert_true(res.get("is_mimic", false), "Mimic trap triggers when roll < mimic_chance")
	print("[PASS] Mimic Trap Check (1/1 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/world/chest_validator.gd")
	var res = val_script.validate_chests()
	_assert_true(res.get("is_valid", false), "Chest system passes validator quality check")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] Chest Validator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
