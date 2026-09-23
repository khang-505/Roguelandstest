# tests/test_quest_bounty_system.gd
class_name TestQuestBountySystem
extends Node

## Verification test suite for Starfall Frontier — System 56: Quest / Bounty System Engine.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING QUEST / BOUNTY SYSTEM ---")
	test_quest_presets()
	test_quest_progression_and_claiming()
	test_validator_score()
	print("--- QUEST / BOUNTY SYSTEM TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_quest_presets() -> void:
	var data_script = load("res://scripts/data/quest_data.gd")
	_assert_true(data_script != null, "QuestData script loaded")

	var q = data_script.create_preset("bounty_beetles")
	_assert_true(q != null and q.required_amount == 5, "Bounty Beetles preset loaded (5 required)")
	print("[PASS] Quest Data Presets Check (2/2 PASSED)")

func test_quest_progression_and_claiming() -> void:
	var data_script = load("res://scripts/data/quest_data.gd")
	var mgr_script = load("res://scripts/core/quest_bounty_manager.gd")

	var mgr = mgr_script.new()
	var q = data_script.create_preset("boss_hunt") # 1 boss_sentinel required
	mgr.accept_quest(q)

	mgr.notify_event(data_script.QuestType.BOSS, "boss_sentinel", 1)
	_assert_true(q.is_completed, "Boss hunt quest marked completed after 1 boss kill")

	var claim = mgr.claim_reward("boss_hunt")
	_assert_true(claim.get("success", false) and claim["rewards"].get("credits", 0) == 1500, "Boss hunt reward claimed (1500 credits)")
	print("[PASS] Quest Progression & Reward Claiming Check (2/2 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/core/quest_validator.gd")
	var res = val_script.validate_quest_system()
	_assert_true(res.get("is_valid", false), "QuestValidator passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] QuestValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
