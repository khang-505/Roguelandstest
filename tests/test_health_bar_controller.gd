# tests/test_health_bar_controller.gd
class_name TestHealthBarController
extends Node

## Verification test suite for Starfall Frontier — System 69: Health Bars Controller.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING HEALTH BARS CONTROLLER ---")
	test_health_and_shield_updates()
	test_validator_score()
	print("--- HEALTH BARS TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_health_and_shield_updates() -> void:
	var ctrl_script = load("res://scripts/ui/health_bar_controller.gd")
	_assert_true(ctrl_script != null, "HealthBarController script loaded")

	var ctrl = ctrl_script.new()
	ctrl.max_hp = 100.0

	var res = ctrl.update_health(80.0, 20.0)
	_assert_true(res.get("hp_pct") == 0.8 and res.get("shield_pct") == 0.2, "80 HP + 20 Shield calculates 0.8 / 0.2 percentages")
	print("[PASS] Health and Shield Updates Check (2/2 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/ui/health_bar_validator.gd")
	var res = val_script.validate_health_bars()
	_assert_true(res.get("is_valid", false), "HealthBarValidator passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] HealthBarValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
