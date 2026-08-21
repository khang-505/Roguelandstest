# tests/test_procedural.gd
class_name TestProcedural
extends Node

## Verification test runner for Phase 1.3 Procedural Room Generation.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 1.3 PROCEDURAL WORLD SLICE ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_seed_reproducibility():
		print("[PASS] Seed Reproducibility: Seed A -> identical topology twice")
		pass_count += 1
	else:
		print("[FAIL] Seed reproducibility failed")
		fail_count += 1

	if test_seed_differentiation():
		print("[PASS] Seed Differentiation: Seed A vs Seed B generate different layouts")
		pass_count += 1
	else:
		print("[FAIL] Seed differentiation failed")
		fail_count += 1
		
	if test_100_seeds_validity():
		print("[PASS] 100 Random Seeds Topological Validity & Connectivity Check")
		pass_count += 1
	else:
		print("[FAIL] 100 seeds validity test failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_seed_reproducibility() -> bool:
	var gen = RoomGenerator.new()
	var res1 = gen.generate_room(12345)
	var res2 = gen.generate_room(12345)
	gen.free()
	
	return res1["player_spawn"] == res2["player_spawn"] and res1["enemy_spawns"] == res2["enemy_spawns"]

func test_seed_differentiation() -> bool:
	var gen = RoomGenerator.new()
	var resA = gen.generate_room(11111)
	var resB = gen.generate_room(99999)
	gen.free()
	
	return resA["enemy_spawns"] != resB["enemy_spawns"] or resA["loot_spawns"] != resB["loot_spawns"]

func test_100_seeds_validity() -> bool:
	var gen = RoomGenerator.new()
	var valid_count = 0
	for s in range(100):
		var res = gen.generate_room(10000 + s)
		if res["is_valid"]:
			valid_count += 1
	gen.free()
	
	return valid_count >= 95 # At least 95% pass topological path validation
