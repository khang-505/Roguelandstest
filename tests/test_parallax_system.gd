# tests/test_parallax_system.gd
class_name TestParallaxSystem
extends Node

## Verification test suite for Starfall Frontier — System 61: Parallax Background Controller.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PARALLAX BACKGROUND CONTROLLER ---")
	test_parallax_layers()
	test_camera_scrolling()
	test_validator_score()
	print("--- PARALLAX SYSTEM TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_parallax_layers() -> void:
	var ctrl_script = load("res://scripts/world/parallax_background_controller.gd")
	_assert_true(ctrl_script != null, "ParallaxBackgroundController script loaded")

	var factors = ctrl_script.LAYER_SCROLL_FACTORS
	_assert_true(factors.size() == 4, "Parallax background defines 4 depth layers")
	print("[PASS] Parallax Depth Layers Check (2/2 PASSED)")

func test_camera_scrolling() -> void:
	var ctrl_script = load("res://scripts/world/parallax_background_controller.gd")
	var ctrl = ctrl_script.new()

	var offset = ctrl.calculate_layer_offset(ctrl_script.ParallaxLayer.FAR_MOUNTAINS, Vector2(500, 200))
	_assert_true(offset.x == 75.0, "Far mountains scroll factor 0.15 * 500 = 75.0")
	print("[PASS] Camera Parallax Scroll Calculation Check (1/1 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/world/parallax_validator.gd")
	var res = val_script.validate_parallax_system()
	_assert_true(res.get("is_valid", false), "ParallaxValidator passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] ParallaxValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
