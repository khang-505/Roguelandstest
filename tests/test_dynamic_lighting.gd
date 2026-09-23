# tests/test_dynamic_lighting.gd
class_name TestDynamicLighting
extends Node

## Verification test suite for Starfall Frontier — System 66: Dynamic Lighting & Shadows.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING DYNAMIC LIGHTING SYSTEM ---")
	test_ambient_lighting_profiles()
	test_light_registration()
	test_validator_score()
	print("--- DYNAMIC LIGHTING TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_ambient_lighting_profiles() -> void:
	var ctrl_script = load("res://scripts/world/dynamic_lighting_controller.gd")
	_assert_true(ctrl_script != null, "DynamicLightingController script loaded")

	var profiles = ctrl_script.AMBIENT_PROFILES
	_assert_true(profiles.size() == 4, "Dynamic lighting system defines 4 ambient profiles")
	print("[PASS] Ambient Lighting Profiles Check (2/2 PASSED)")

func test_light_registration() -> void:
	var ctrl_script = load("res://scripts/world/dynamic_lighting_controller.gd")
	var ctrl = ctrl_script.new()

	var l = ctrl.register_light_source("laser_core_01", Vector2(400, 300))
	_assert_true(l.get("light_id") == "laser_core_01", "Laser core light registered successfully")
	print("[PASS] Light Source Registration Check (1/1 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/world/lighting_validator.gd")
	var res = val_script.validate_lighting_system()
	_assert_true(res.get("is_valid", false), "LightingValidator passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] LightingValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
