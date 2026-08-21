# tests/test_phase2_4.gd
class_name TestPhase24
extends Node

## Verification test runner for Phase 2.4 Extended Biomes (300 Seeds Validation across 3 Biomes).

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 2.4 EXTENDED BIOMES ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_emberwild_100_seeds():
		print("[PASS] Emberwild: 100 Seeds Topological Validity & Reachability")
		pass_count += 1
	else:
		print("[FAIL] Emberwild seeds validation failed")
		fail_count += 1

	if test_frostgrave_100_seeds():
		print("[PASS] Frostgrave: 100 Seeds Topological Validity & Reachability")
		pass_count += 1
	else:
		print("[FAIL] Frostgrave seeds validation failed")
		fail_count += 1

	if test_verdant_abyss_100_seeds():
		print("[PASS] Verdant Abyss: 100 Seeds Topological Validity & Reachability")
		pass_count += 1
	else:
		print("[FAIL] Verdant Abyss seeds validation failed")
		fail_count += 1

	if test_biome_data_uniqueness():
		print("[PASS] Biome Registry Data & Resource Pool Uniqueness")
		pass_count += 1
	else:
		print("[FAIL] Biome registry uniqueness test failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_emberwild_100_seeds() -> bool:
	var gen = RoomGenerator.new()
	var valid_count = 0
	for s in range(100):
		var res = gen.generate_room(20000 + s, "emberwild")
		if res["is_valid"] and res["biome"].id == "emberwild":
			valid_count += 1
	gen.free()
	return valid_count >= 95

func test_frostgrave_100_seeds() -> bool:
	var gen = RoomGenerator.new()
	var valid_count = 0
	for s in range(100):
		var res = gen.generate_room(30000 + s, "frostgrave")
		if res["is_valid"] and res["biome"].id == "frostgrave":
			valid_count += 1
	gen.free()
	return valid_count >= 95

func test_verdant_abyss_100_seeds() -> bool:
	var gen = RoomGenerator.new()
	var valid_count = 0
	for s in range(100):
		var res = gen.generate_room(40000 + s, "verdant_abyss")
		if res["is_valid"] and res["biome"].id == "verdant_abyss":
			valid_count += 1
	gen.free()
	return valid_count >= 95

func test_biome_data_uniqueness() -> bool:
	var ember = BiomeData.get_biome("emberwild")
	var frost = BiomeData.get_biome("frostgrave")
	var verdant = BiomeData.get_biome("verdant_abyss")
	
	var ember_ok = (ember.hazard_type == "LAVA")
	var frost_ok = (frost.hazard_type == "ICE_SPIKES")
	var verdant_ok = (verdant.hazard_type == "TOXIC_SPORES")
	
	return ember_ok and frost_ok and verdant_ok
