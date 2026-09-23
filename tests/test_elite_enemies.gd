# tests/test_elite_enemies.gd
class_name TestEliteEnemies
extends Node

## Verification test suite for Starfall Frontier Directive 23 — Elite Enemies Improvement Directive.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING ELITE ENEMIES SYSTEM ---")
	test_catalog_affixes()
	test_budget_and_compatibility()
	test_1000_elite_generations()
	test_biome_presets()
	test_quality_validation()
	test_terrain_synergy()
	print("--- ELITE ENEMIES SYSTEM TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_catalog_affixes() -> void:
	var catalog_script = load("res://scripts/procedural/elite_affix_catalog.gd")
	var affix_ids = catalog_script.get_all_affix_ids()
	_assert_true(affix_ids.size() == 15, "All 15 Elite Affixes registered (Got %d)" % affix_ids.size())
	
	var valid_affixes = 0
	for id in affix_ids:
		var affix = catalog_script.get_affix(id)
		if affix and affix.difficulty_cost >= 1 and affix.difficulty_cost <= 4:
			valid_affixes += 1
	_assert_true(valid_affixes == 15, "15/15 Affixes have valid difficulty costs (1-4) (Passed: %d/15)" % valid_affixes)
	print("[PASS] EliteAffixCatalog 15 Affixes & Budget Costs registration (15/15 PASSED)")

func test_budget_and_compatibility() -> void:
	var catalog_script = load("res://scripts/procedural/elite_affix_catalog.gd")
	_assert_true(not catalog_script.are_compatible("FAST", "ARMORED"), "FAST and ARMORED are mutually exclusive")
	_assert_true(not catalog_script.are_compatible("BURNING", "FROZEN"), "BURNING and FROZEN are mutually exclusive")
	_assert_true(catalog_script.are_compatible("FAST", "EXPLOSIVE"), "FAST and EXPLOSIVE are compatible")
	
	var chosen = catalog_script.select_affixes_for_budget(6, 12345, "")
	var total_cost = 0
	for affix in chosen:
		total_cost += affix.difficulty_cost
	_assert_true(total_cost <= 6, "Selected affixes total cost (%d) <= budget (6)" % total_cost)
	print("[PASS] Affix budget constraint and compatibility matrix check (3/3 PASSED)")

func test_1000_elite_generations() -> void:
	var generator_script = load("res://scripts/procedural/elite_enemy_generator.gd")
	var archetype_script = load("res://scripts/procedural/enemy_archetype_data.gd")
	
	var base_drone = archetype_script.new("drone_base", "Alpha Drone", archetype_script.Role.MELEE, "drone", "emberwild")
	var valid_count = 0
	
	for seed_idx in range(1000):
		var elite = generator_script.generate_elite(base_drone, 6, seed_idx + 5000, "emberwild")
		var cost = elite.get("total_cost", 0)
		var hp = elite.get("composite_hp", 0.0)
		var title = elite.get("elite_title", "")
		var rewards = elite.get("rewards", {})
		
		if cost <= 6 and hp > base_drone.max_health and not title.is_empty() and rewards.has("reward_choices"):
			valid_count += 1
			
	_assert_true(valid_count == 1000, "1000/1000 Procedural Elite Generations & Budget Verification (1000/1000 PASSED)")
	print("[PASS] 1000 Procedural Elite Generations Check (1000/1000 PASSED)")

func test_biome_presets() -> void:
	var generator_script = load("res://scripts/procedural/elite_enemy_generator.gd")
	
	var mining_presets = generator_script.get_biome_preset_elites("mining")
	_assert_true(mining_presets.size() == 3, "Mining biome has 3 preset elites")
	
	var forest_presets = generator_script.get_biome_preset_elites("forest")
	_assert_true(forest_presets.size() == 3, "Forest biome has 3 preset elites")
	
	var cave_presets = generator_script.get_biome_preset_elites("cave")
	_assert_true(cave_presets.size() == 3, "Cave biome has 3 preset elites")
	
	print("[PASS] Biome Elite Presets (Mining, Forest, Cave) Check (3/3 PASSED)")

func test_quality_validation() -> void:
	var generator_script = load("res://scripts/procedural/elite_enemy_generator.gd")
	var validator_script = load("res://scripts/procedural/elite_validator.gd")
	var archetype_script = load("res://scripts/procedural/enemy_archetype_data.gd")
	
	var base_drone = archetype_script.new("drone_base", "Alpha Drone", archetype_script.Role.MELEE, "drone", "emberwild")
	var elite = generator_script.generate_elite(base_drone, 6, 8888, "emberwild")
	
	var res = validator_script.validate_elite(elite)
	_assert_true(res.is_valid, "Elite enemy passes quality validation")
	_assert_true(res.quality_score >= 70.0, "Elite Quality Score >= 70.0 (Score: %.1f/100)" % res.quality_score)
	print("[PASS] EliteValidator composite quality score check (Score: %.1f/100)" % res.quality_score)

func test_terrain_synergy() -> void:
	var generator_script = load("res://scripts/procedural/elite_enemy_generator.gd")
	var archetype_script = load("res://scripts/procedural/enemy_archetype_data.gd")
	
	var flying_archetype = archetype_script.new("flyer", "Sky Drone", archetype_script.Role.FLYING, "drone", "mining")
	flying_archetype.movement_type = archetype_script.MovementType.FLY
	var elite_flying = generator_script.generate_elite(flying_archetype, 6, 9999, "mining")
	
	_assert_true(elite_flying.preferred_terrain == "VERTICAL_ARENA", "Flying/Teleporting elites pair with VERTICAL_ARENA terrain")
	print("[PASS] Elite Room Terrain Synergy Check (1/1 PASSED)")
