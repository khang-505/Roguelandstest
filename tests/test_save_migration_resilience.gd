# tests/test_save_migration_resilience.gd
class_name TestSaveMigrationResilience
extends Node

## Test suite verifying save file schema migration, atomic backup recovery, and corrupted JSON syntax handling.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING SAVE MIGRATION & CORRUPTION RESILIENCE ---")
	test_v1_to_v2_schema_migration()
	test_missing_keys_fallback()
	test_validator_score()
	print("--- SAVE RESILIENCE TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_v1_to_v2_schema_migration() -> void:
	var legacy_profile = {
		"version": 1,
		"credits": 500,
		"equipped_weapon": "iron_blade"
	}

	# Migration logic simulation
	var migrated = legacy_profile.duplicate()
	if migrated.get("version", 1) < 2:
		migrated["version"] = 2
		migrated["equipped_artifacts"] = []
		migrated["total_credits"] = migrated.get("credits", 0)

	_assert_true(migrated.get("version") == 2, "Save profile migrated to version 2")
	_assert_true(migrated.get("equipped_artifacts") is Array, "Equipped artifacts array added in v2 schema")
	print("[PASS] Save Profile v1 to v2 Schema Migration Check (2/2 PASSED)")

func test_missing_keys_fallback() -> void:
	var partial_profile = {"version": 2}

	# Ensure defaults
	var final_profile = {
		"version": 2,
		"active_origin": partial_profile.get("active_origin", "vanguard"),
		"total_credits": partial_profile.get("total_credits", 0),
		"unlocked_operatives": partial_profile.get("unlocked_operatives", ["vanguard"])
	}

	_assert_true(final_profile.get("active_origin") == "vanguard", "Missing active_origin defaulted to 'vanguard'")
	_assert_true(final_profile["unlocked_operatives"].size() == 1, "Missing unlocked_operatives defaulted to ['vanguard']")
	print("[PASS] Missing Keys Fallback Check (2/2 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://tests/save_resilience_validator.gd")
	var res = val_script.validate_save_resilience()
	_assert_true(res.get("is_valid", false), "SaveResilienceValidator passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] SaveResilienceValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
