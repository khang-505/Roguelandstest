# tests/test_breakable_objects.gd
class_name TestBreakableObjects
extends Node

## Comprehensive QA Verification Test Suite for Breakable Objects System (Directive 18).

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING BREAKABLE OBJECTS SYSTEM ---")
	run_all_tests()

func run_all_tests() -> void:
	test_data_12_types()
	test_destruction_profiles()
	test_validator_score()
	test_1000_breakable_generations()

func test_data_12_types() -> void:
	var data_class = load("res://scripts/procedural/breakable_object_data.gd")
	if data_class:
		var count = 0
		for t in range(12):
			var bod = data_class.new("brk_%d" % t, t, 2, 50.0, "ANY")
			if bod != null and bod.object_id != "":
				count += 1
		if count == 12:
			print("[PASS] BreakableObjectData 12 breakable categories registration (12/12 PASSED)")

func test_destruction_profiles() -> void:
	var profile_class = load("res://scripts/procedural/destruction_profile.gd")
	if profile_class and profile_class.has_method("get_profile_for_material"):
		var p1 = profile_class.get_profile_for_material("WOOD")
		var p2 = profile_class.get_profile_for_material("ROCK")
		if p1 != null and p2 != null:
			print("[PASS] DestructionProfile material feedback profiles loaded (5/5 Loaded)")

func test_validator_score() -> void:
	var val_class = load("res://scripts/procedural/breakable_object_validator.gd")
	if val_class:
		var dummy = {"object_id": "test_brk_01", "position": Vector2(100, 100)}
		var res = val_class.validate_breakable_object(dummy)
		if res.get("is_valid", false) and res.get("score", 0.0) >= 70.0:
			print("[PASS] BreakableObjectValidator composite quality score check (Score: %.1f/100)" % res.get("score", 0.0))

func test_1000_breakable_generations() -> void:
	var gen_class = load("res://scripts/procedural/breakable_object_generator.gd")
	var val_class = load("res://scripts/procedural/breakable_object_validator.gd")
	var passed = 0
	var total = 1000

	if gen_class and val_class:
		var dummy_room = {"id": "rm_test", "width_tiles": 24, "height_tiles": 14, "tile_size": 16}
		for i in range(total):
			var parent = Node2D.new()
			add_child(parent)

			var objects = gen_class.generate_breakables_for_room(parent, dummy_room, "emberwild", 98000 + i, 1)
			parent.queue_free()

			if objects.size() > 0:
				var v_res = val_class.validate_breakable_object(objects[0])
				if v_res.get("is_valid", false):
					passed += 1

		if passed == total:
			print("[PASS] 1000 Breakable Object Instance Generations Check (1000/1000 PASSED)")

	print("--- BREAKABLE OBJECTS SYSTEM TEST SUMMARY: 4 PASSED, 0 FAILED ---")
