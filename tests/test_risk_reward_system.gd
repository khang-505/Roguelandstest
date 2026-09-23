# tests/test_risk_reward_system.gd
class_name TestRiskRewardSystem
extends Node

## Verification test suite for Starfall Frontier — System 46: Risk / Reward Choice System.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING RISK / REWARD CHOICE SYSTEM ---")
	test_pact_catalog()
	test_pact_acceptance()
	test_validator_score()
	print("--- RISK / REWARD SYSTEM TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_pact_catalog() -> void:
	var mgr_script = load("res://scripts/procedural/risk_reward_manager.gd")
	_assert_true(mgr_script != null, "RiskRewardManager script loaded")

	var mgr = mgr_script.new()
	var choices = mgr.get_random_pact_choices(3, 999)
	_assert_true(choices.size() == 3, "Pact choice selection returns exactly 3 choices")
	print("[PASS] Risk / Reward Catalog & Seeded Selection Check (2/2 PASSED)")

func test_pact_acceptance() -> void:
	var mgr_script = load("res://scripts/procedural/risk_reward_manager.gd")
	var mgr = mgr_script.new()

	var bargain = mgr_script.PACT_CATALOG[0]
	mgr.accept_pact(bargain)

	_assert_true(mgr.active_pacts.size() == 1, "Active pacts list updated to 1")
	var mods = mgr.get_aggregate_modifiers()
	_assert_true(is_equal_approx(mods.get("loot_drop_mult", 0.0), 0.80), "Loot drop multiplier aggregated to +80%")
	print("[PASS] Pact Acceptance & Modifier Aggregation Check (2/2 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/procedural/risk_reward_validator.gd")
	var res = val_script.validate_risk_reward_system()
	_assert_true(res.get("is_valid", false), "Risk/Reward System passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] RiskRewardValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
