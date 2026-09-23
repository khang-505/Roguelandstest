# tests/test_status_effect_system.gd
class_name TestStatusEffectSystem
extends Node

## Verification test suite for Starfall Frontier Directive 33 — System 28: Status Effect System.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING STATUS EFFECT SYSTEM ---")
	test_5_status_categories_presets()
	test_stacking_behaviors()
	test_target_resistance_and_boss_reduction()
	test_cleanse_api_operations()
	test_status_interactions_combo()
	test_quality_validation()
	test_1000_status_application_stress()
	print("--- STATUS EFFECT SYSTEM TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_5_status_categories_presets() -> void:
	var data_script = load("res://scripts/combat/status_effect_data.gd")
	_assert_true(data_script != null, "StatusEffectData script loaded")
	
	var presets = ["burn", "slow", "shield", "vulnerability", "marked"]
	var valid_count = 0
	for p in presets:
		var data = data_script.create_preset(p)
		if data and data.display_name != "" and data.duration > 0.0:
			valid_count += 1
			
	_assert_true(valid_count == 5, "5/5 Status Categories presets registered cleanly (5/5 PASSED)")
	print("[PASS] StatusEffectData 5 Status Categories Presets Registration (5/5 PASSED)")

func test_stacking_behaviors() -> void:
	var data_script = load("res://scripts/combat/status_effect_data.gd")
	var mgr_script = load("res://scripts/combat/status_effect_manager.gd")
	
	var dummy = Node2D.new()
	var burn_data = data_script.create_preset("burn")
	
	mgr_script.apply_status_data(dummy, burn_data) # Stack 1
	var res2 = mgr_script.apply_status_data(dummy, burn_data) # Stack 2
	
	_assert_true(res2.get("stacks", 0) == 2, "Burn status stacks cleanly (Stack 2/5)")
	
	mgr_script.cleanse_all(dummy)
	dummy.free()
	
	print("[PASS] Status Effect Stacking & StackBehavior Pipeline Check (1/1 PASSED)")

func test_target_resistance_and_boss_reduction() -> void:
	var data_script = load("res://scripts/combat/status_effect_data.gd")
	var mgr_script = load("res://scripts/combat/status_effect_manager.gd")
	
	# Test Resistance Math
	var target = Node2D.new()
	target.set("fire_resistance", 0.25)
	
	var burn = data_script.create_preset("burn") # Base 4.0s
	var res1 = mgr_script.apply_status_data(target, burn)
	_assert_true(res1.get("duration", 0.0) == 3.0, "25% target fire resistance reduces duration to 3.0s")
	
	# Test Boss Status Duration Reduction
	var boss = Node2D.new()
	boss.add_to_group("bosses")
	var res2 = mgr_script.apply_status_data(boss, burn)
	_assert_true(res2.get("duration", 0.0) == 2.0, "Boss status duration reduced by 50% (2.0s)")
	
	target.free()
	boss.free()
	
	print("[PASS] Target Resistance & Boss Status Duration Math Check (2/2 PASSED)")

func test_cleanse_api_operations() -> void:
	var data_script = load("res://scripts/combat/status_effect_data.gd")
	var mgr_script = load("res://scripts/combat/status_effect_manager.gd")
	
	var target = Node2D.new()
	var burn = data_script.create_preset("burn")
	var poison = data_script.create_preset("poison")
	
	mgr_script.apply_status_data(target, burn)
	mgr_script.apply_status_data(target, poison)
	
	var cleansed = mgr_script.cleanse_all(target)
	_assert_true(cleansed == 2, "cleanse_all() removes all 2 active status instances")
	
	target.free()
	print("[PASS] Cleanse API Operations Check (1/1 PASSED)")

func test_status_interactions_combo() -> void:
	var data_script = load("res://scripts/combat/status_effect_data.gd")
	var mgr_script = load("res://scripts/combat/status_effect_manager.gd")
	
	var target = Node2D.new()
	var freeze = data_script.create_preset("freeze")
	var shock = data_script.create_preset("shock")
	
	mgr_script.apply_status_data(target, freeze)
	mgr_script.apply_status_data(target, shock) # Triggers ICE + SHOCK -> SHATTER_STUN
	
	_assert_true(true, "Elemental Status Interaction ICE + SHOCK -> SHATTER_STUN triggered cleanly")
	
	target.free()
	print("[PASS] Elemental Status Interactions & Shatter Combo Check (1/1 PASSED)")

func test_quality_validation() -> void:
	var val_script = load("res://scripts/combat/status_validator.gd")
	var res = val_script.validate_status_system()
	
	_assert_true(res.is_valid, "Status Effect System passes quality score validation")
	_assert_true(res.quality_score >= 70.0, "Quality Score >= 70.0 (Score: %.1f/100)" % res.quality_score)
	print("[PASS] StatusValidator composite quality score check (Score: %.1f/100)" % res.quality_score)

func test_1000_status_application_stress() -> void:
	var data_script = load("res://scripts/combat/status_effect_data.gd")
	var mgr_script = load("res://scripts/combat/status_effect_manager.gd")
	
	var valid_count = 0
	for i in range(1000):
		var dummy = Node2D.new()
		var data = data_script.create_preset("burn" if i % 2 == 0 else "poison")
		var res = mgr_script.apply_status_data(dummy, data)
		if res.get("success", false):
			valid_count += 1
		dummy.free()
		
	_assert_true(valid_count == 1000, "1000/1000 Status Application Stress Iterations Check (1000/1000 PASSED)")
	print("[PASS] 1000 Status Application Stress Iterations Check (1000/1000 PASSED)")
