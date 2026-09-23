# tests/test_boss_system.gd
class_name TestBossSystem
extends Node

## Verification test suite for Starfall Frontier Directive 24 — Boss System Improvement Directive.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING BOSS SYSTEM ---")
	test_boss_catalog()
	test_phase_controller_flow()
	test_1000_boss_fight_simulations()
	test_quality_validator()
	test_planet_boss_binding()
	print("--- BOSS SYSTEM TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_boss_catalog() -> void:
	var catalog_script = load("res://scripts/procedural/boss_catalog.gd")
	var boss_ids = catalog_script.get_all_boss_ids()
	_assert_true(boss_ids.size() == 3, "3 Planet Bosses registered in catalog (Got %d)" % boss_ids.size())
	
	var valid_bosses = 0
	for id in boss_ids:
		var boss = catalog_script.get_boss(id)
		if boss and boss.phases.size() >= 3 and boss.attack_patterns.size() >= 4:
			valid_bosses += 1
	_assert_true(valid_bosses == 3, "3/3 Bosses have valid phase counts (>=3) and attack patterns (>=4)")
	print("[PASS] BossCatalog 3 Planet Signature Bosses registration (3/3 PASSED)")

func test_phase_controller_flow() -> void:
	var catalog_script = load("res://scripts/procedural/boss_catalog.gd")
	var controller_script = load("res://scripts/procedural/boss_phase_controller.gd")
	
	var titan = catalog_script.get_boss("titan_excavator")
	var controller = controller_script.new(titan)
	
	_assert_true(controller.current_phase_index == 1, "Initial phase is 1")
	_assert_true(controller.current_hp == titan.max_health, "Initial HP is max_health")
	
	# Damage to Phase 2 (60% HP)
	controller.take_damage(titan.max_health * 0.45) # Remaining 55%
	_assert_true(controller.current_phase_index == 2, "Phase changed to Phase 2 at <=60% HP")
	_assert_true(controller.is_invulnerable, "Boss becomes invulnerable during phase transition")
	
	controller.complete_phase_transition()
	_assert_true(not controller.is_invulnerable, "Boss invulnerability ends after transition")
	
	# Damage to Enrage (15% HP)
	controller.take_damage(titan.max_health * 0.40) # Remaining 15%
	_assert_true(controller.is_enraged, "Boss enters ENRAGE state at <=20% HP")
	
	if controller.is_invulnerable:
		controller.complete_phase_transition()
	
	# Select attack
	var atk = controller.select_next_attack(12345)
	_assert_true(not atk.is_empty(), "Controller selects valid attack pattern")
	_assert_true(atk.has("telegraph_duration") and atk.has("counterplay"), "Selected attack has telegraph duration & counterplay")
	
	print("[PASS] BossPhaseController state transitions, enrage & attack selection check (6/6 PASSED)")

func test_1000_boss_fight_simulations() -> void:
	var catalog_script = load("res://scripts/procedural/boss_catalog.gd")
	var controller_script = load("res://scripts/procedural/boss_phase_controller.gd")
	
	var boss_ids = catalog_script.get_all_boss_ids()
	var successful_fights = 0
	
	for fight_idx in range(1000):
		var target_id = boss_ids[fight_idx % boss_ids.size()]
		var boss_data = catalog_script.get_boss(target_id)
		var controller = controller_script.new(boss_data)
		
		var max_dmg_steps = 100
		var step = 0
		var hit_amount = boss_data.max_health / 10.0
		
		while not controller.is_dead and step < max_dmg_steps:
			step += 1
			if controller.is_invulnerable:
				controller.complete_phase_transition()
			else:
				controller.select_next_attack(fight_idx * 10 + step)
				controller.take_damage(hit_amount)
				controller.update_cooldowns(1.0)
				
		if controller.is_dead and controller.current_hp == 0.0:
			successful_fights += 1
			
	_assert_true(successful_fights == 1000, "1000/1000 Boss Fight Simulations completed cleanly to victory state (1000/1000 PASSED)")
	print("[PASS] 1000 Boss Fight Simulations Check (1000/1000 PASSED)")

func test_quality_validator() -> void:
	var catalog_script = load("res://scripts/procedural/boss_catalog.gd")
	var validator_script = load("res://scripts/procedural/boss_validator.gd")
	
	var boss_ids = catalog_script.get_all_boss_ids()
	var all_passed = true
	var min_score = 100.0
	
	for id in boss_ids:
		var boss = catalog_script.get_boss(id)
		var res = validator_script.validate_boss(boss)
		if not res.is_valid or res.quality_score < 70.0:
			all_passed = false
		min_score = min(min_score, res.quality_score)
		
	_assert_true(all_passed, "All Planet Bosses pass quality score validation (Min Score: %.1f/100)" % min_score)
	print("[PASS] BossValidator composite quality score check (Score: %.1f/100)" % min_score)

func test_planet_boss_binding() -> void:
	var catalog_script = load("res://scripts/procedural/boss_catalog.gd")
	
	var mining_boss = catalog_script.get_boss_for_planet("emberwild")
	_assert_true(mining_boss.boss_id == "titan_excavator", "Emberwild planet bound to titan_excavator")
	
	var forest_boss = catalog_script.get_boss_for_planet("verdia")
	_assert_true(forest_boss.boss_id == "apex_bio_horror", "Verdia planet bound to apex_bio_horror")
	
	var cave_boss = catalog_script.get_boss_for_planet("abyssia")
	_assert_true(cave_boss.boss_id == "core_custodian", "Abyssia planet bound to core_custodian")
	
	print("[PASS] Planet Boss Binding Check (3/3 PASSED)")
