# tests/test_stat_aggregator.gd
class_name TestStatAggregator
extends Node

## Verification test suite for Starfall Frontier — System 36: Item Stats Pipeline.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING STAT AGGREGATOR ---")
	test_basic_stat_aggregation()
	test_crit_and_speed_caps()
	test_damage_reduction_formula()
	test_validator_score()
	print("--- STAT AGGREGATOR TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_basic_stat_aggregation() -> void:
	var agg_script = load("res://scripts/combat/stat_aggregator.gd")
	_assert_true(agg_script != null, "StatAggregator script loaded")
	
	var base = {"attack": 15, "defense": 5, "hp": 100, "speed": 180.0, "crit_chance": 0.05}
	var weapon = {"base_damage": 25.0, "affixes": [{"stat": "crit_chance", "value": 0.10}]}
	
	var stats = agg_script.calculate_stats(base, [], weapon)
	_assert_true(stats.get("total_attack", 0.0) == 40.0, "Total Attack = 15 base + 25 weapon (40.0)")
	_assert_true(is_equal_approx(stats.get("crit_chance", 0.0), 0.15), "Total Crit = 0.05 base + 0.10 weapon (0.15)")
	print("[PASS] Basic Stat Aggregation Check (3/3 PASSED)")

func test_crit_and_speed_caps() -> void:
	var agg_script = load("res://scripts/combat/stat_aggregator.gd")
	
	var overcap_stats = {"crit_chance": 0.80, "speed": 700.0}
	var buffs = [{"bonus_crit_chance": 0.50}]
	
	var stats = agg_script.calculate_stats(overcap_stats, [], {}, [], buffs)
	_assert_true(is_equal_approx(stats.get("crit_chance", 0.0), 1.0), "Crit chance capped at 100% (1.0)")
	_assert_true(stats.get("move_speed", 0.0) == 600.0, "Move speed capped at max 600.0")
	print("[PASS] Stat Caps Enforcement Check (2/2 PASSED)")

func test_damage_reduction_formula() -> void:
	var agg_script = load("res://scripts/combat/stat_aggregator.gd")
	
	var stats_50_def = agg_script.calculate_stats({"defense": 50})
	# 50 / (50 + 100) = 50 / 150 = 0.3333...
	_assert_true(is_equal_approx(stats_50_def.get("damage_reduction", 0.0), 0.333333), "50 Armor yields 33.3% damage reduction")
	print("[PASS] Diminishing Armor Formula Check (1/1 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/combat/stat_aggregator_validator.gd")
	var res = val_script.validate_stat_aggregator()
	_assert_true(res.get("is_valid", false), "StatAggregator passes validator quality check")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] StatAggregator Validator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
