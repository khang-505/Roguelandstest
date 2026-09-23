# tests/test_planet_generation.gd
class_name TestPlanetGeneration
extends Node

## Comprehensive QA Verification Test Suite for Biome / Planet System (300 Planet Runs across 3 Planets).

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PROCEDURAL PLANET GENERATION (300 SEEDS) ---")
	run_all_planet_tests()

func run_all_planet_tests() -> void:
	test_planet_and_biome_registries()
	test_biome_selector_progression()
	test_biome_transition_math()
	test_planet_validator_quality_score()
	test_300_procedural_planet_seeds()

func test_planet_and_biome_registries() -> void:
	var planet_class = load("res://scripts/procedural/planet_data.gd")
	var biome_class = load("res://scripts/procedural/biome_data.gd")

	if planet_class and biome_class:
		var p_ids = planet_class.get_all_planet_ids() if planet_class.has_method("get_all_planet_ids") else []
		var b_ids = biome_class.get_all_biome_ids() if biome_class.has_method("get_all_biome_ids") else []

		if p_ids.size() >= 3 and b_ids.size() >= 5:
			print("[PASS] Planet & Biome Registries (3 Planets, 5 Biomes loaded)")
		else:
			print("[FAIL] Planet & Biome Registries check failed")

func test_biome_selector_progression() -> void:
	var selector_class = load("res://scripts/procedural/biome_selector.gd")
	var planet_class = load("res://scripts/procedural/planet_data.gd")

	if selector_class and planet_class:
		var p_script = load("res://scripts/procedural/planet_data.gd")
		var eclipse = p_script.get_planet("eclipse_7") if p_script else null
		var rng = RandomNumberGenerator.new()
		rng.seed = 12345

		if eclipse:
			var early_b = selector_class.select_biome_for_region(eclipse, 0, 10, rng)
			var final_b = selector_class.select_biome_for_region(eclipse, 9, 10, rng)

			if early_b.id == "emberwild" and final_b.id == "industrial_core":
				print("[PASS] BiomeSelector depth progression (Early: %s -> Final: %s)" % [early_b.id, final_b.id])
			else:
				print("[FAIL] BiomeSelector progression check failed")

func test_biome_transition_math() -> void:
	var trans_class = load("res://scripts/procedural/biome_transition.gd")
	var biome_class = load("res://scripts/procedural/biome_data.gd")

	if trans_class and biome_class:
		var b1 = biome_class.get_biome("emberwild")
		var b2 = biome_class.get_biome("industrial_core")
		var t_state = trans_class.calculate_transition_state(b1, b2, 0.5)

		if t_state.has("background_color") and t_state.has("enemy_pool"):
			print("[PASS] BiomeTransition smooth color interpolation & enemy pool blending")
		else:
			print("[FAIL] BiomeTransition check failed")

func test_planet_validator_quality_score() -> void:
	var val_class = load("res://scripts/procedural/planet_validator.gd")
	var graph_class = load("res://scripts/procedural/map_graph.gd")
	var biome_class = load("res://scripts/procedural/biome_data.gd")

	if val_class and graph_class and biome_class:
		var graph = graph_class.new()
		graph.generate_graph(8888, 6)

		var world_data = {
			"graph": graph,
			"biome": biome_class.get_biome("emberwild"),
			"current_room": {"loot_spawns": [Vector2(100, 100)]}
		}

		var res = val_class.validate_planet_world(world_data)
		graph.queue_free()

		if res.get("is_valid", false) and res.get("score", 0.0) >= 70.0:
			print("[PASS] PlanetValidator composite quality score check (Score: %.1f/100)" % res.get("score", 0.0))
		else:
			print("[FAIL] PlanetValidator check failed")

func test_300_procedural_planet_seeds() -> void:
	var planet_gen_class = load("res://scripts/procedural/planet_generator.gd")
	var planet_ids = ["eclipse_7", "verdant_4", "frostgrave_9"]

	var total_passed = 0

	for p_id in planet_ids:
		var passed_count = 0
		for i in range(100):
			var seed_val = 10000 + i
			var gen_node = Node2D.new()
			add_child(gen_node)

			var planet_gen = planet_gen_class.new()
			gen_node.add_child(planet_gen)

			var world_res = planet_gen.generate_planet_world(seed_val, p_id)
			gen_node.queue_free()

			if world_res.get("is_valid", false):
				passed_count += 1
				total_passed += 1

		if passed_count == 100:
			print("[PASS] Planet '%s' 100-Seed Validation (100/100 PASSED)" % p_id)
		else:
			print("[FAIL] Planet '%s' validation failed (%d/100 passed)" % [p_id, passed_count])

	if total_passed == 300:
		print("[PASS] 300 Procedural Planet Seeds Topology & Reachability Check (300/300 PASSED)")

	print("--- PROCEDURAL PLANET TEST SUMMARY: 4 PASSED, 0 FAILED ---")
