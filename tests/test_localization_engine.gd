# tests/test_localization_engine.gd
class_name TestLocalizationEngine
extends Node

## Verification test suite for Starfall Frontier — System 90: Localization Engine.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING LOCALIZATION ENGINE ---")
	test_locales_and_translations()
	test_string_interpolation()
	test_validator_score()
	print("--- LOCALIZATION ENGINE TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_locales_and_translations() -> void:
	var eng_script = load("res://scripts/core/localization_engine.gd")
	_assert_true(eng_script != null, "LocalizationEngine script loaded")

	var eng = eng_script.new()
	_assert_true(eng.set_locale("ja"), "Switching to Japanese (ja) locale succeeds")
	_assert_true(eng.translate("HUD_HEALTH") == "体力", "Japanese translation for HUD_HEALTH is 体力")
	print("[PASS] Locales & Translations Check (3/3 PASSED)")

func test_string_interpolation() -> void:
	var eng_script = load("res://scripts/core/localization_engine.gd")
	var eng = eng_script.new()
	eng.set_locale("en")

	var msg = eng.translate("MSG_CREDITS", {"amount": 2500})
	_assert_true(msg == "Credits: 2500", "String parameter interpolation formats 'Credits: 2500'")
	print("[PASS] String Parameter Interpolation Check (1/1 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/core/localization_validator.gd")
	var res = val_script.validate_localization()
	_assert_true(res.get("is_valid", false), "LocalizationValidator passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] LocalizationValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
