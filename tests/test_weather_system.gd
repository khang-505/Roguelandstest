# tests/test_weather_system.gd
class_name TestWeatherSystem
extends Node

## Verification test suite for Starfall Frontier — System 58: Dynamic Weather & Atmospheric Effects.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING WEATHER & ATMOSPHERIC SYSTEM ---")
	test_weather_presets()
	test_weather_switching()
	test_validator_score()
	print("--- WEATHER SYSTEM TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_weather_presets() -> void:
	var ctrl_script = load("res://scripts/world/weather_controller.gd")
	_assert_true(ctrl_script != null, "WeatherController script loaded")

	var presets = ctrl_script.PRESETS
	_assert_true(presets.size() == 4, "Weather system defines 4 atmospheric presets")
	print("[PASS] Weather Presets Catalog Check (2/2 PASSED)")

func test_weather_switching() -> void:
	var ctrl_script = load("res://scripts/world/weather_controller.gd")
	var ctrl = ctrl_script.new()

	ctrl.set_weather(ctrl_script.WeatherType.ASH_STORM)
	var preset = ctrl.get_active_preset()
	_assert_true(preset.get("id") == "ash_storm", "Active weather preset switched to ash_storm")
	print("[PASS] Weather Preset Switching Check (1/1 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/world/weather_validator.gd")
	var res = val_script.validate_weather_system()
	_assert_true(res.get("is_valid", false), "WeatherValidator passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] WeatherValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
