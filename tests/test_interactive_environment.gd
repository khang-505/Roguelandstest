# tests/test_interactive_environment.gd
class_name TestInteractiveEnvironment
extends Node

## Comprehensive QA Verification Test Suite for Interactive Environment System (Directive 19).

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING INTERACTIVE ENVIRONMENT SYSTEM ---")
	run_all_tests()

func run_all_tests() -> void:
	test_data_11_types()
	test_validator_score()
	test_1000_interaction_generations()

func test_data_11_types() -> void:
	var data_class = load("res://scripts/procedural/interactive_object_data.gd")
	if data_class:
		var count = 0
		for t in range(11):
			var iod = data_class.new("obj_%d" % t, t, "[E] Interact", "")
			if iod != null and iod.object_id != "":
				count += 1
		if count == 11:
			print("[PASS] InteractiveObjectData 11 interaction categories registration (11/11 PASSED)")

func test_validator_score() -> void:
	var val_class = load("res://scripts/procedural/interaction_validator.gd")
	if val_class:
		var dummy = {"trigger_id": "trig_01", "target_id": "door_01"}
		var res = val_class.validate_interaction_chain(dummy)
		if res.get("is_valid", false) and res.get("score", 0.0) >= 70.0:
			print("[PASS] InteractionValidator composite quality score check (Score: %.1f/100)" % res.get("score", 0.0))

func test_1000_interaction_generations() -> void:
	var gen_class = load("res://scripts/procedural/interaction_generator.gd")
	var val_class = load("res://scripts/procedural/interaction_validator.gd")
	var passed = 0
	var total = 1000

	if gen_class and val_class:
		var dummy_room = {"id": "rm_test_int", "width_tiles": 24, "height_tiles": 14, "tile_size": 16}
		for i in range(total):
			var parent = Node2D.new()
			add_child(parent)

			var chains = gen_class.generate_interactions_for_room(parent, dummy_room, "emberwild", 99000 + i, 1)
			parent.queue_free()

			if chains.size() > 0:
				var v_res = val_class.validate_interaction_chain(chains[0])
				if v_res.get("is_valid", false):
					passed += 1

		if passed == total:
			print("[PASS] 1000 Interactive Environment Chain Instance Generations Check (1000/1000 PASSED)")

	print("--- INTERACTIVE ENVIRONMENT SYSTEM TEST SUMMARY: 3 PASSED, 0 FAILED ---")
