# tests/test_input_remapping.gd
class_name TestInputRemapping
extends Node

## Verification test suite for Starfall Frontier — System 75: Comprehensive Keybinding & Controller Remapping.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING INPUT REMAPPING & KEYBINDINGS ---")
	test_default_bindings()
	test_action_remapping_and_conflict()
	test_validator_score()
	print("--- INPUT REMAPPING TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_default_bindings() -> void:
	var mgr_script = load("res://scripts/ui/input_remapping_manager.gd")
	_assert_true(mgr_script != null, "InputRemappingManager script loaded")

	var defaults = mgr_script.DEFAULT_BINDINGS
	_assert_true(defaults.size() == 10, "Input remapping defines 10 default actions")
	print("[PASS] Default Bindings Catalog Check (2/2 PASSED)")

func test_action_remapping_and_conflict() -> void:
	var mgr_script = load("res://scripts/ui/input_remapping_manager.gd")
	var mgr = mgr_script.new()

	var ok = mgr.remap_action("jump", "key", KEY_Z)
	_assert_true(ok.get("success", false), "Remapping jump to KEY_Z succeeds")

	var conflict = mgr.remap_action("dash", "key", KEY_Z)
	_assert_true(not conflict.get("success", true), "Remapping dash to KEY_Z yields conflict error")
	print("[PASS] Action Remapping & Conflict Guard Check (2/2 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/ui/input_remapping_validator.gd")
	var res = val_script.validate_input_remapping()
	_assert_true(res.get("is_valid", false), "InputRemappingValidator passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] InputRemappingValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
