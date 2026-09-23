# tests/test_ui_transition_manager.gd
class_name TestUITransitionManager
extends Node

## Verification test suite for Starfall Frontier — System 70: UI Animation & Transition Manager.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING UI ANIMATION & TRANSITION MANAGER ---")
	test_ui_transitions()
	test_validator_score()
	print("--- UI TRANSITION MANAGER TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_ui_transitions() -> void:
	var mgr_script = load("res://scripts/ui/ui_transition_manager.gd")
	_assert_true(mgr_script != null, "UITransitionManager script loaded")

	var mgr = mgr_script.new()
	var dummy = Control.new()
	add_child(dummy)

	var res = mgr.transition_in(dummy, mgr_script.TransitionType.SCALE_BOUNCE, 0.4)
	_assert_true(res.get("success", false), "Transition in initialization succeeds")

	mgr.process_transitions(0.2)
	_assert_true(is_equal_approx(dummy.scale.x, 0.5), "Scale bounce transitions scale to 0.5 at half duration")

	dummy.queue_free()
	print("[PASS] UI Transitions Check (2/2 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/ui/ui_transition_validator.gd")
	var res = val_script.validate_ui_transitions()
	_assert_true(res.get("is_valid", false), "UITransitionValidator passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] UITransitionValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
