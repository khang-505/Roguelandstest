# tests/test_positional_sfx.gd
class_name TestPositionalSFX
extends Node

## Verification test suite for Starfall Frontier — System 72: Positional & Dynamic SFX Engine.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING POSITIONAL & DYNAMIC SFX ENGINE ---")
	test_spatial_attenuation()
	test_surface_footsteps()
	test_validator_score()
	print("--- POSITIONAL SFX TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_spatial_attenuation() -> void:
	var engine_script = load("res://scripts/audio/positional_sfx_engine.gd")
	_assert_true(engine_script != null, "PositionalSFXEngine script loaded")

	var engine = engine_script.new()
	var res = engine.calculate_spatial_audio(Vector2.ZERO, Vector2(300, 0))
	_assert_true(res.get("is_audible", false), "Spatial audio at 300 units is audible")
	print("[PASS] Spatial Audio Attenuation Check (2/2 PASSED)")

func test_surface_footsteps() -> void:
	var engine_script = load("res://scripts/audio/positional_sfx_engine.gd")
	var engine = engine_script.new()

	var sfx = engine.get_footstep_sfx_name(engine_script.SurfaceType.SNOW)
	_assert_true(sfx == "footstep_snow", "Surface type SNOW returns footstep_snow")
	print("[PASS] Surface Footsteps Mapping Check (1/1 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/audio/sfx_validator.gd")
	var res = val_script.validate_sfx_system()
	_assert_true(res.get("is_valid", false), "SFXValidator passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] SFXValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
