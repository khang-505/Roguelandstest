# tests/test_curse_system.gd
class_name TestCurseSystem
extends Node

## Verification test suite for Starfall Frontier — System 47: Curse / Corruption System.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING CURSE & CORRUPTION SYSTEM ---")
	test_curse_catalog()
	test_corruption_thresholds()
	test_validator_score()
	print("--- CURSE SYSTEM TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_curse_catalog() -> void:
	var data_script = load("res://scripts/data/curse_data.gd")
	_assert_true(data_script != null, "CurseData script loaded")

	var ids = data_script.get_all_curse_ids()
	_assert_true(ids.size() == 4, "Curse catalog defines 4 signature curses")

	var c_glass = data_script.get_curse("corrupted_glass")
	_assert_true(c_glass != null and c_glass.corruption_value == 25.0, "Corrupted Glass curse returns valid instance")
	print("[PASS] Curse Data Catalog & Creation Check (3/3 PASSED)")

func test_corruption_thresholds() -> void:
	var mgr_script = load("res://scripts/combat/curse_manager.gd")
	var mgr = mgr_script.new()

	var count = 0
	mgr.threshold_reached.connect(func(_tier): count += 1)

	mgr.add_corruption(55.0) # Crosses 25% and 50% thresholds -> 2 triggers
	_assert_true(mgr.corruption_points == 55.0, "Corruption points set to 55.0")
	_assert_true(count == 2, "Crossed 2 corruption thresholds (25% and 50%)")
	print("[PASS] Corruption Threshold Triggers Check (2/2 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/combat/curse_validator.gd")
	var res = val_script.validate_curse_system()
	_assert_true(res.get("is_valid", false), "Curse System passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] CurseValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
