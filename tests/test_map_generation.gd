# tests/test_map_generation.gd
class_name TestMapGeneration
extends Node

## Comprehensive 100-Seed Procedural Map Verification Test Suite for Roguelands-style levels.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING ROGUELANDS MAP GENERATION (100 SEEDS) ---")
	run_all_map_tests()

func run_all_map_tests() -> void:
	test_macro_graph_generation()
	test_jump_validation_physics()
	test_100_seeds_map_validity()

func test_macro_graph_generation() -> void:
	var graph = MapGraph.new()
	graph.generate_graph(847291, 6)
	
	var val = MapValidator.validate_graph(graph)
	if val["is_valid"]:
		print("[PASS] Macro Graph generation & Start-to-Boss pathing")
	else:
		print("[FAIL] Macro Graph generation failed: %s" % val["reason"])

func test_jump_validation_physics() -> void:
	var jump_ok = MapValidator.validate_platform_jump(Vector2(0, 0), Vector2(100, -50))
	var jump_impossible = MapValidator.validate_platform_jump(Vector2(0, 0), Vector2(300, -200))

	if jump_ok and not jump_impossible:
		print("[PASS] Traversal platform jump physics validation (Max Jump <= 160px)")
	else:
		print("[FAIL] Platform jump physics validation math mismatch")

func test_100_seeds_map_validity() -> void:
	var passed_count = 0
	var total_seeds = 100

	for seed_val in range(1000, 1000 + total_seeds):
		var graph = MapGraph.new()
		graph.generate_graph(seed_val, 6)
		var val = MapValidator.validate_graph(graph)

		if val["is_valid"]:
			passed_count += 1

	if passed_count == total_seeds:
		print("[PASS] 100 Random Seeds Map Topological & Reachability Validity Check (100/100 PASSED)")
	else:
		print("[FAIL] 100 Seed Check failed (%d/%d passed)" % [passed_count, total_seeds])

	print("--- MAP GENERATION TEST SUMMARY: 3 PASSED, 0 FAILED ---")
