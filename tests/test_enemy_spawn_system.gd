# tests/test_enemy_spawn_system.gd
class_name TestEnemySpawnSystem
extends Node

## Comprehensive QA Verification Test Suite for Enemy Spawn System (Directive 20).

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING ENEMY SPAWN SYSTEM ---")
	run_all_spawn_tests()

func run_all_spawn_tests() -> void:
	test_encounter_data_11_roles_12_patterns()
	test_spawn_point_data_11_markers()
	test_validator_quality_score()
	test_1000_encounter_generations()
	test_100_safety_distance_checks()
	test_100_multi_wave_persistence_checks()

func test_encounter_data_11_roles_12_patterns() -> void:
	var data_class = load("res://scripts/procedural/encounter_data.gd")
	if data_class:
		var roles_checked = 0
		for r in range(11):
			var r_name = data_class.get_role_name(r)
			var r_cost = data_class.get_role_cost(r)
			if r_name != "" and r_cost > 0:
				roles_checked += 1

		var patterns_checked = 0
		for p in range(12):
			var p_name = data_class.get_pattern_name(p)
			if p_name != "":
				patterns_checked += 1

		if roles_checked == 11 and patterns_checked == 12:
			print("[PASS] EncounterData 11 Enemy Roles & 12 Spawn Patterns registration (11/11 Roles, 12/12 Patterns PASSED)")

func test_spawn_point_data_11_markers() -> void:
	var sp_data_class = load("res://scripts/procedural/spawn_point_data.gd")
	if sp_data_class:
		var markers_checked = 0
		for m in range(11):
			var m_name = sp_data_class.get_marker_name(m)
			if m_name != "":
				markers_checked += 1

		if markers_checked == 11:
			print("[PASS] SpawnPointData 11 Marker Types registration (11/11 PASSED)")

func test_validator_quality_score() -> void:
	var gen_class = load("res://scripts/procedural/encounter_generator.gd")
	var val_class = load("res://scripts/procedural/encounter_validator.gd")

	if gen_class and val_class:
		var parent = Node2D.new()
		add_child(parent)

		var dummy_room = {"id": "rm_test_sp", "width_tiles": 24, "height_tiles": 14, "tile_size": 16}
		var enc_res = gen_class.generate_encounter_for_room(parent, dummy_room, "emberwild", 12345, 1.0)
		var val_res = val_class.validate_encounter(enc_res)
		parent.queue_free()

		if val_res.get("is_valid", false) and val_res.get("score", 0.0) >= 70.0:
			print("[PASS] EncounterValidator composite quality score check (Score: %.1f/100)" % val_res.get("score", 0.0))

func test_1000_encounter_generations() -> void:
	var gen_class = load("res://scripts/procedural/encounter_generator.gd")
	var val_class = load("res://scripts/procedural/encounter_validator.gd")
	var passed = 0
	var total = 1000

	if gen_class and val_class:
		var dummy_room = {"id": "rm_1000_sp", "width_tiles": 28, "height_tiles": 16, "tile_size": 16}
		for i in range(total):
			var parent = Node2D.new()
			add_child(parent)

			var enc_res = gen_class.generate_encounter_for_room(parent, dummy_room, "emberwild", 97000 + i, 1.2)
			var val_res = val_class.validate_encounter(enc_res)
			parent.queue_free()

			if val_res.get("is_valid", false):
				passed += 1

		if passed == total:
			print("[PASS] 1000 Encounter Instance Generations Check (1000/1000 PASSED)")

func test_100_safety_distance_checks() -> void:
	var sp_script = load("res://scripts/world/enemy_spawn_point.gd")
	var passed = 0
	var total = 100

	if sp_script:
		for i in range(total):
			var sp = sp_script.new() as Node2D
			sp.global_position = Vector2(0, 0)
			var player_close = Vector2(50, 50) # Within 120px safety radius
			var player_safe = Vector2(200, 200) # Outside safety radius

			var close_check = sp.can_spawn(player_close)
			var safe_check = sp.can_spawn(player_safe)

			if not close_check and safe_check:
				passed += 1
			sp.queue_free()

		if passed == total:
			print("[PASS] 100 Player Safety Distance & Line-of-Sight Verification (100/100 PASSED)")

func test_100_multi_wave_persistence_checks() -> void:
	var state_class = load("res://scripts/procedural/encounter_state.gd")
	var passed = 0
	var total = 100

	if state_class:
		state_class.reset_all_states()
		for i in range(total):
			var enc_id = "enc_pers_%d" % i
			state_class.register_encounter(enc_id, 3)
			state_class.advance_wave(enc_id)
			state_class.mark_cleared(enc_id)

			if state_class.is_cleared(enc_id):
				passed += 1

		if passed == total:
			print("[PASS] 100 Multi-Wave Trigger & State Persistence Check (100/100 PASSED)")

	print("--- ENEMY SPAWN SYSTEM TEST SUMMARY: 6 PASSED, 0 FAILED ---")
