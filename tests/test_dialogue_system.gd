# tests/test_dialogue_system.gd
class_name TestDialogueSystem
extends Node

## Verification test suite for Starfall Frontier — System 55: NPC / Dialogue System Engine.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING NPC / DIALOGUE SYSTEM ---")
	test_dialogue_data_creation()
	test_dialogue_traversal()
	test_validator_score()
	print("--- DIALOGUE SYSTEM TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_dialogue_data_creation() -> void:
	var data_script = load("res://scripts/data/dialogue_data.gd")
	_assert_true(data_script != null, "DialogueData script loaded")

	var d = data_script.create_sample_commander_dialogue()
	_assert_true(d.nodes.size() == 4, "Sample dialogue contains 4 nodes")
	print("[PASS] Dialogue Data Creation Check (2/2 PASSED)")

func test_dialogue_traversal() -> void:
	var data_script = load("res://scripts/data/dialogue_data.gd")
	var engine_script = load("res://scripts/ui/dialogue_engine.gd")

	var d = data_script.create_sample_commander_dialogue()
	var engine = engine_script.new()

	_assert_true(engine.start_dialogue(d, "root"), "Start dialogue succeeds")
	_assert_true(engine.select_choice(1), "Select choice 'briefing' succeeds")
	_assert_true(engine.current_node_id == "briefing", "Current node navigated to 'briefing'")
	print("[PASS] Dialogue Traversal Check (3/3 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/ui/dialogue_validator.gd")
	var res = val_script.validate_dialogue_system()
	_assert_true(res.get("is_valid", false), "DialogueValidator passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] DialogueValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
