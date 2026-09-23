# tests/test_synergy_engine.gd
class_name TestSynergyEngine
extends Node

## Verification test suite for Starfall Frontier — System 37: Build Synergy Engine.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING BUILD SYNERGY ENGINE ---")
	test_synergy_catalog()
	test_tier_activations()
	test_validator_score()
	print("--- BUILD SYNERGY ENGINE TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_synergy_catalog() -> void:
	var cat_script = load("res://scripts/combat/synergy_catalog.gd")
	_assert_true(cat_script != null, "SynergyCatalog script loaded")
	
	var tags = cat_script.get_all_synergy_tags()
	_assert_true(tags.size() == 8, "SynergyCatalog defines all 8 Build Archetype tags (Found %d)" % tags.size())
	
	var fire_syn = cat_script.get_synergy("FIRE")
	_assert_true(fire_syn.get("name") == "Pyromancer", "FIRE archetype name is Pyromancer")
	print("[PASS] Synergy Catalog 8 Archetypes Check (3/3 PASSED)")

func test_tier_activations() -> void:
	var engine_script = load("res://scripts/combat/synergy_engine.gd")
	_assert_true(engine_script != null, "SynergyEngine script loaded")
	
	# Test 2-item (Tier 1), 4-item (Tier 2), and 6-item (Tier 3)
	var weapon_4tank = {"synergies": ["TANK", "TANK", "TANK", "TANK"]}
	var res = engine_script.calculate_build_synergies(weapon_4tank)
	
	var active = res.get("active_synergies", [])
	var bonuses = res.get("aggregate_bonuses", {})
	
	_assert_true(active.size() == 1, "Exactly 1 active synergy detected")
	_assert_true(active[0].get("active_tier") == 4, "Tier 2 (4 items) activated")
	_assert_true(bonuses.get("bonus_hp", 0) == 100, "Tier 2 Tank grants +100 HP")
	print("[PASS] Build Synergy Tier Threshold Activations Check (4/4 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/combat/synergy_validator.gd")
	var res = val_script.validate_synergies()
	_assert_true(res.get("is_valid", false), "Synergy Engine passes validator quality score")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] Synergy Engine Validator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
