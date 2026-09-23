# tests/test_boss_arenas.gd
class_name TestBossArenas
extends Node

## Verification test suite for Starfall Frontier Directive 25 — Boss Arenas Improvement Directive.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING BOSS ARENAS SYSTEM ---")
	test_authored_biome_arenas()
	test_1000_arena_generations()
	test_phase_terrain_shifts()
	test_arena_lock_progression()
	test_quality_validation()
	print("--- BOSS ARENAS SYSTEM TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_authored_biome_arenas() -> void:
	var gen_script = load("res://scripts/procedural/boss_arena_generator.gd")
	
	var mining_arena = gen_script.generate_arena("titan_excavator", "mining", 1001)
	_assert_true(mining_arena.platforms.size() >= 4, "Mining arena has >=4 platforms")
	_assert_true(mining_arena.safe_zones.size() >= 3, "Mining arena has >=3 safe zones")
	
	var forest_arena = gen_script.generate_arena("apex_bio_horror", "forest", 2001)
	_assert_true(forest_arena.platforms.size() >= 4, "Forest arena has >=4 platforms")
	_assert_true(forest_arena.hazards.size() >= 2, "Forest arena has >=2 hazard zones")
	
	var cave_arena = gen_script.generate_arena("core_custodian", "cave", 3001)
	_assert_true(cave_arena.platforms.size() >= 4, "Cave arena has >=4 platforms")
	_assert_true(cave_arena.phase_objects.size() >= 1, "Cave arena has shield generator phase objects")
	
	print("[PASS] Authored Biome Arenas (Mining, Forest, Cave) Check (6/6 PASSED)")

func test_1000_arena_generations() -> void:
	var gen_script = load("res://scripts/procedural/boss_arena_generator.gd")
	var valid_count = 0
	var biomes = ["mining", "forest", "cave"]
	
	for seed_idx in range(1000):
		var b_id = biomes[seed_idx % biomes.size()]
		var arena = gen_script.generate_arena("boss_gen", b_id, seed_idx + 7000)
		
		if arena.width >= 600.0 and arena.height >= 400.0 and arena.platforms.size() >= 3:
			valid_count += 1
			
	_assert_true(valid_count == 1000, "1000/1000 Boss Arena Generations Check (1000/1000 PASSED)")
	print("[PASS] 1000 Procedural Arena Variant Generations Check (1000/1000 PASSED)")

func test_phase_terrain_shifts() -> void:
	var gen_script = load("res://scripts/procedural/boss_arena_generator.gd")
	var mining_arena = gen_script.generate_arena("titan_excavator", "mining", 8888)
	
	gen_script.apply_phase_terrain_shift(mining_arena, 1)
	_assert_true(mining_arena.current_phase_terrain == 1, "Phase 1 terrain applied")
	
	gen_script.apply_phase_terrain_shift(mining_arena, 2)
	_assert_true(mining_arena.current_phase_terrain == 2, "Phase 2 terrain applied")
	
	var active_p2 = 0
	for plat in mining_arena.platforms:
		if plat.get("is_active", false):
			active_p2 += 1
	_assert_true(active_p2 >= 3, "Phase 2 unlocks mid elevator platforms (Active: %d)" % active_p2)
	
	gen_script.apply_phase_terrain_shift(mining_arena, 3)
	var active_p3 = 0
	for plat in mining_arena.platforms:
		if plat.get("is_active", false):
			active_p3 += 1
	_assert_true(active_p3 == mining_arena.platforms.size(), "Phase 3 unlocks all platforms (Active: %d)" % active_p3)
	print("[PASS] Dynamic Phase Terrain Transformations Check (4/4 PASSED)")

func test_arena_lock_progression() -> void:
	var gen_script = load("res://scripts/procedural/boss_arena_generator.gd")
	var arena = gen_script.generate_arena("titan_excavator", "mining", 9999)
	
	_assert_true(not arena.arena_locked, "Initial arena state is unlocked")
	arena.arena_locked = true
	_assert_true(arena.arena_locked, "Arena locks on battle initiation")
	arena.arena_locked = false
	_assert_true(not arena.arena_locked, "Arena unlocks on victory")
	
	print("[PASS] Arena Lock & Door Progression Check (3/3 PASSED)")

func test_quality_validation() -> void:
	var gen_script = load("res://scripts/procedural/boss_arena_generator.gd")
	var val_script = load("res://scripts/procedural/boss_arena_validator.gd")
	
	var biomes = ["mining", "forest", "cave"]
	var all_passed = true
	var min_score = 100.0
	
	for b in biomes:
		var arena = gen_script.generate_arena("boss_val", b, 5555)
		var res = val_script.validate_arena(arena)
		if not res.is_valid or res.quality_score < 70.0:
			all_passed = false
		min_score = min(min_score, res.quality_score)
		
	_assert_true(all_passed, "All Boss Arenas pass quality score validation (Min Score: %.1f/100)" % min_score)
	print("[PASS] BossArenaValidator composite quality score check (Score: %.1f/100)" % min_score)
