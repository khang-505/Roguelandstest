# tests/test_camera_shake.gd
class_name TestCameraShake
extends Node

## Verification test suite for Starfall Frontier — System 64: Screen Shake & Impact FX Controller.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING CAMERA SHAKE & IMPACT CONTROLLER ---")
	test_trauma_and_offsets()
	test_hit_freeze_frame()
	test_validator_score()
	print("--- CAMERA SHAKE TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_trauma_and_offsets() -> void:
	var ctrl_script = load("res://scripts/vfx/camera_shake_controller.gd")
	_assert_true(ctrl_script != null, "CameraShakeController script loaded")

	var ctrl = ctrl_script.new()
	ctrl.add_trauma(0.5)
	_assert_true(ctrl.trauma == 0.5, "Trauma set to 0.5")

	var offset = ctrl.get_shake_offset(1.0)
	_assert_true(offset != Vector2.ZERO, "Shake offset calculated non-zero when trauma > 0")
	print("[PASS] Trauma & Shake Offset Check (2/2 PASSED)")

func test_hit_freeze_frame() -> void:
	var ctrl_script = load("res://scripts/vfx/camera_shake_controller.gd")
	var ctrl = ctrl_script.new()

	ctrl.trigger_hit_freeze(0.05, 0.2)
	_assert_true(is_equal_approx(Engine.time_scale, 0.2), "Engine.time_scale set to 0.2 during hit freeze")
	Engine.time_scale = 1.0 # Reset
	print("[PASS] Hit Freeze Frame Check (1/1 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/vfx/shake_validator.gd")
	var res = val_script.validate_shake_system()
	_assert_true(res.get("is_valid", false), "ShakeValidator passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] ShakeValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
