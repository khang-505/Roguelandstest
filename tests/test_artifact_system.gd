# tests/test_artifact_system.gd
class_name TestArtifactSystem
extends Node

## Verification test suite for Starfall Frontier Directive — System 34: Artifacts / Accessories.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING ARTIFACT SYSTEM ---")
	test_catalog_15_artifacts()
	test_artifact_passive_stats()
	test_proc_triggers_and_cooldowns()
	test_proc_engine_triggers()
	test_quality_validation()
	print("--- ARTIFACT SYSTEM TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_catalog_15_artifacts() -> void:
	var catalog_script = load("res://scripts/combat/artifact_catalog.gd")
	_assert_true(catalog_script != null, "ArtifactCatalog script loaded")
	
	var ids = catalog_script.get_all_artifact_ids()
	_assert_true(ids.size() == 15, "ArtifactCatalog registers exactly 15 unique artifacts (Found %d)" % ids.size())
	
	var v_fang = catalog_script.get_artifact("vampiric_fang")
	_assert_true(v_fang != null and v_fang.artifact_id == "vampiric_fang", "Artifact get_artifact('vampiric_fang') returns valid instance")
	print("[PASS] Artifact Catalog 15 Artifacts Check (3/3 PASSED)")

func test_artifact_passive_stats() -> void:
	var catalog_script = load("res://scripts/combat/artifact_catalog.gd")
	var engine_script = load("res://scripts/combat/artifact_proc_engine.gd")
	
	var a1 = catalog_script.get_artifact("vampiric_fang") # attack +5
	var a5 = catalog_script.get_artifact("aegis_talisman") # hp +30, def +8
	var a6 = catalog_script.get_artifact("shadow_ring")   # crit +0.06
	
	var aggregated = engine_script.calculate_artifact_passive_stats([a1, a5, a6])
	_assert_true(aggregated.get("bonus_attack", 0) == 5, "Bonus attack calculated correctly (5)")
	_assert_true(aggregated.get("bonus_hp", 0) == 30, "Bonus HP calculated correctly (30)")
	_assert_true(aggregated.get("bonus_defense", 0) == 8, "Bonus defense calculated correctly (8)")
	_assert_true(is_equal_approx(aggregated.get("crit_chance", 0.0), 0.06), "Crit chance calculated correctly (0.06)")
	print("[PASS] Artifact Passive Stats Aggregation Check (4/4 PASSED)")

func test_proc_triggers_and_cooldowns() -> void:
	var data_script = load("res://scripts/data/artifact_data.gd")
	var art = data_script.new()
	art.artifact_id = "test_art"
	art.proc_cooldown = 2.0
	
	_assert_true(not art.is_on_cooldown(0.0), "Initial artifact not on cooldown")
	_assert_true(art.trigger_proc(0.0), "First trigger succeeds at t=0s")
	_assert_true(art.is_on_cooldown(1.0), "Artifact on cooldown at t=1s (< 2s)")
	_assert_true(not art.trigger_proc(1.0), "Trigger fails while on cooldown")
	_assert_true(not art.is_on_cooldown(2.5), "Artifact cooldown expired at t=2.5s")
	_assert_true(art.trigger_proc(2.5), "Second trigger succeeds at t=2.5s")
	print("[PASS] Artifact Internal Cooldown Mechanics Check (6/6 PASSED)")

func test_proc_engine_triggers() -> void:
	var catalog_script = load("res://scripts/combat/artifact_catalog.gd")
	var engine_script = load("res://scripts/combat/artifact_proc_engine.gd")
	var data_script = load("res://scripts/data/artifact_data.gd")
	
	var storm = catalog_script.get_artifact("storm_pendant") # ON_HIT, 20%
	var pyro = catalog_script.get_artifact("pyro_core")     # ON_CRIT, 30%
	var equipped = [storm, pyro]
	
	# Trigger ON_HIT event with forced rng 0.05
	var hit_results = engine_script.process_trigger(equipped, data_script.ProcTrigger.ON_HIT, {}, 10.0, 0.05)
	_assert_true(hit_results.size() == 1, "ON_HIT event triggers storm pendant")
	_assert_true(hit_results[0].get("proc_effect_id") == "chain_lightning", "Proc effect is chain_lightning")
	
	# Trigger ON_CRIT event with forced rng 0.10
	var crit_results = engine_script.process_trigger(equipped, data_script.ProcTrigger.ON_CRIT, {}, 10.0, 0.10)
	_assert_true(crit_results.size() == 1, "ON_CRIT event triggers pyro core")
	_assert_true(crit_results[0].get("proc_effect_id") == "burn_nova", "Proc effect is burn_nova")
	print("[PASS] Artifact Proc Engine Triggers Check (4/4 PASSED)")

func test_quality_validation() -> void:
	var val_script = load("res://scripts/combat/artifact_validator.gd")
	var res = val_script.validate_artifact_system()
	_assert_true(res.get("is_valid", false), "Artifact System passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality Score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] Artifact Validator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
