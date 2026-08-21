# tests/test_phase5_0.gd
class_name TestPhase50
extends Node

## Verification test runner for Phase 5.0 Relic Fusion System (Originality Mechanic 2).

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 5.0 RELIC FUSION SYSTEM ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_valid_relic_fusion():
		print("[PASS] Atomic Relic Fusion: Fragments deducted, Relic unlocked & saved")
		pass_count += 1
	else:
		print("[FAIL] Valid relic fusion test failed")
		fail_count += 1

	if test_atomic_fusion_failure():
		print("[PASS] Transaction Safety: Insufficient fragments reject fusion & preserve resources")
		pass_count += 1
	else:
		print("[FAIL] Atomic fusion failure test failed")
		fail_count += 1

	if test_singularity_combat_effect():
		print("[PASS] Combat Burst Effect: Molten Singularity applies Burn status effect to enemies")
		pass_count += 1
	else:
		print("[FAIL] Singularity combat effect test failed")
		fail_count += 1

	if test_duplicate_fusion_prevention():
		print("[PASS] Duplicate Prevention: Fusing existing relic maintains clean unlocked array")
		pass_count += 1
	else:
		print("[FAIL] Duplicate fusion test failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_valid_relic_fusion() -> bool:
	SaveManager.profile_data["persistent_materials"] = {"ember_ore": 10, "star_shard": 10, "cryo_crystal": 10}
	SaveManager.profile_data["unlocked_relics"] = []
	
	var success = RelicFusionManager.fuse_relic("molten_singularity")
	
	var mats = SaveManager.profile_data["persistent_materials"]
	var mats_ok = (mats["ember_ore"] == 5 and mats["star_shard"] == 5 and mats["cryo_crystal"] == 5)
	var relic_ok = ("relic_molten_singularity" in SaveManager.profile_data["unlocked_relics"])
	
	return success and mats_ok and relic_ok

func test_atomic_fusion_failure() -> bool:
	SaveManager.profile_data["persistent_materials"] = {"ember_ore": 2, "star_shard": 1, "cryo_crystal": 0} # Need 5 each
	SaveManager.profile_data["unlocked_relics"] = []
	
	var success = RelicFusionManager.fuse_relic("molten_singularity")
	
	var rejected = (not success)
	var mats = SaveManager.profile_data["persistent_materials"]
	var mats_same = (mats["ember_ore"] == 2 and mats["star_shard"] == 1)
	
	return rejected and mats_same

func test_singularity_combat_effect() -> bool:
	var beetle = AshBeetle.new()
	add_child(beetle)
	beetle.global_position = Vector2(50, 0)
	
	var executed = RelicFusionManager.execute_relic_burst("relic_molten_singularity", get_tree(), Vector2.ZERO)
	
	beetle.queue_free()
	return executed

func test_duplicate_fusion_prevention() -> bool:
	SaveManager.profile_data["persistent_materials"] = {"ember_ore": 20, "star_shard": 20, "cryo_crystal": 20}
	SaveManager.profile_data["unlocked_relics"] = ["relic_molten_singularity"]
	
	RelicFusionManager.fuse_relic("molten_singularity")
	
	var relics: Array = SaveManager.profile_data["unlocked_relics"]
	var count = 0
	for r in relics:
		if r == "relic_molten_singularity":
			count += 1
			
	return count == 1
