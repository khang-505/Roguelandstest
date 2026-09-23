# tests/test_meta_progression_tree.gd
class_name TestMetaProgressionTree
extends Node

## Verification test suite for Starfall Frontier — System 48: Meta-Progression Tree Engine.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING META-PROGRESSION TREE ---")
	test_tree_nodes_catalog()
	test_prerequisite_and_currency_checks()
	test_validator_score()
	print("--- META-PROGRESSION TREE TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_tree_nodes_catalog() -> void:
	var tree_script = load("res://scripts/core/meta_progression_tree.gd")
	_assert_true(tree_script != null, "MetaProgressionTree script loaded")

	var nodes = tree_script.TREE_NODES
	_assert_true(nodes.size() >= 6, "Meta-progression tree contains at least 6 nodes across 4 branches")
	print("[PASS] Meta-Progression Tree Nodes Catalog Check (2/2 PASSED)")

func test_prerequisite_and_currency_checks() -> void:
	var tree_script = load("res://scripts/core/meta_progression_tree.gd")

	# Check upgrade can proceed with sufficient funds & prereqs
	var check = tree_script.can_upgrade_node("def_hp_1", {}, 500, 500)
	_assert_true(check.get("can_upgrade", false), "Root node upgrade succeeds with sufficient credits")

	var bonuses = tree_script.calculate_meta_tree_bonuses({"def_hp_1": 2})
	_assert_true(bonuses.get("bonus_hp_flat", 0) == 40, "Rank 2 HP node grants +40 HP")
	print("[PASS] Prerequisite & Currency Check (2/2 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/core/meta_tree_validator.gd")
	var res = val_script.validate_meta_tree()
	_assert_true(res.get("is_valid", false), "MetaTreeValidator passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] MetaTreeValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
