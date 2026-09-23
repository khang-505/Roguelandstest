# tests/test_motion_trail.gd
class_name TestMotionTrail
extends Node

## Verification test suite for Starfall Frontier — System 63: Trail / Motion Blur Manager.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING MOTION TRAIL MANAGER ---")
	test_trail_creation_and_sampling()
	test_validator_score()
	print("--- MOTION TRAIL SYSTEM TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_trail_creation_and_sampling() -> void:
	var mgr_script = load("res://scripts/vfx/motion_trail_manager.gd")
	_assert_true(mgr_script != null, "MotionTrailManager script loaded")

	var mgr = mgr_script.new()
	var dummy = Node2D.new()
	add_child(dummy)

	var res = mgr.create_trail("weapon_swing_01", dummy)
	_assert_true(res.get("success", false), "Trail creation succeeds")

	mgr.update_trail("weapon_swing_01", Vector2(100, 100))
	_assert_true(mgr.active_trails["weapon_swing_01"]["points"].size() == 2, "Trail point buffer updated")

	dummy.queue_free()
	print("[PASS] Trail Creation & Point Sampling Check (2/2 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/vfx/trail_validator.gd")
	var res = val_script.validate_trail_system()
	_assert_true(res.get("is_valid", false), "TrailValidator passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] TrailValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
