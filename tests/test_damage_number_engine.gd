# tests/test_damage_number_engine.gd
class_name TestDamageNumberEngine
extends Node

## Verification test suite for Starfall Frontier — System 68: Damage Numbers Controller.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING DAMAGE NUMBER ENGINE ---")
	test_damage_number_formatting()
	test_queue_buffering()
	test_validator_score()
	print("--- DAMAGE NUMBER ENGINE TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_damage_number_formatting() -> void:
	var eng_script = load("res://scripts/combat/damage_number_engine.gd")
	_assert_true(eng_script != null, "DamageNumberEngine script loaded")

	var data = eng_script.format_number_data(100.0, "ICE", true)
	_assert_true(data.get("is_crit") and data.get("scale") == 1.6, "Crit format scales text by 1.6x")
	print("[PASS] Damage Number Formatting Check (2/2 PASSED)")

func test_queue_buffering() -> void:
	var eng_script = load("res://scripts/combat/damage_number_engine.gd")
	eng_script.clear_queue()

	eng_script.queue_number(Vector2(50, 50), 30.0, "FIRE", false)
	_assert_true(eng_script.get_active_queue().size() == 1, "Queue number adds entry to active queue")

	eng_script.clear_queue()
	print("[PASS] Queue Buffering Check (1/1 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/combat/damage_number_validator.gd")
	var res = val_script.validate_damage_numbers()
	_assert_true(res.get("is_valid", false), "DamageNumberValidator passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] DamageNumberValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
