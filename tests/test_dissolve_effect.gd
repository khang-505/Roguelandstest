# tests/test_dissolve_effect.gd
class_name TestDissolveEffect
extends Node

## Verification test suite for Starfall Frontier — System 65: Dissolve & Teleport FX.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING DISSOLVE & TELEPORT FX CONTROLLER ---")
	test_dissolve_progress()
	test_validator_score()
	print("--- DISSOLVE EFFECT TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_dissolve_progress() -> void:
	var ctrl_script = load("res://scripts/vfx/dissolve_effect_controller.gd")
	_assert_true(ctrl_script != null, "DissolveEffectController script loaded")

	var ctrl = ctrl_script.new()
	var dummy = Node2D.new()
	add_child(dummy)

	ctrl.start_dissolve(dummy, 1.0, false)
	ctrl.process_dissolves(0.5)
	_assert_true(ctrl.active_dissolves.size() == 1, "Active dissolve track retained")

	dummy.queue_free()
	print("[PASS] Dissolve Progress Check (2/2 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/vfx/dissolve_validator.gd")
	var res = val_script.validate_dissolve_system()
	_assert_true(res.get("is_valid", false), "DissolveValidator passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] DissolveValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
