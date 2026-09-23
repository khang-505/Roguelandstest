# tests/test_post_processing.gd
class_name TestPostProcessing
extends Node

## Verification test suite for Starfall Frontier — System 67: Post-Processing Pipeline.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING POST-PROCESSING PIPELINE ---")
	test_post_processing_profiles()
	test_profile_switching()
	test_validator_score()
	print("--- POST-PROCESSING TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_post_processing_profiles() -> void:
	var ctrl_script = load("res://scripts/vfx/post_processing_controller.gd")
	_assert_true(ctrl_script != null, "PostProcessingController script loaded")

	var profiles = ctrl_script.PROFILES
	_assert_true(profiles.size() == 4, "Post-processing defines 4 environment profiles")
	print("[PASS] Post-Processing Profiles Check (2/2 PASSED)")

func test_profile_switching() -> void:
	var ctrl_script = load("res://scripts/vfx/post_processing_controller.gd")
	var ctrl = ctrl_script.new()

	ctrl.apply_profile("volcanic_warm")
	var s = ctrl.get_active_settings()
	_assert_true(s.get("bloom_intensity") == 0.45, "Volcanic warm bloom intensity is 0.45")
	print("[PASS] Profile Switching & Settings Check (1/1 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/vfx/post_processing_validator.gd")
	var res = val_script.validate_post_processing()
	_assert_true(res.get("is_valid", false), "PostProcessingValidator passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] PostProcessingValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
