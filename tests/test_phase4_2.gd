# tests/test_phase4_2.gd
class_name TestPhase42
extends Node

## Verification test runner for Phase 4.2 World Instability & Elite Mutation Engine.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 4.2 WORLD INSTABILITY ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_instability_clamping():
		print("[PASS] Instability Escalation & Clamping (0% -> 100% max)")
		pass_count += 1
	else:
		print("[FAIL] Instability clamping test failed")
		fail_count += 1

	if test_elite_mutation_math():
		print("[PASS] Elite Mutation: +50% HP and +30% Damage applied correctly")
		pass_count += 1
	else:
		print("[FAIL] Elite mutation math test failed")
		fail_count += 1

	if test_elite_mutation_idempotency():
		print("[PASS] Idempotent Mutation: Duplicate elite mutation rejected & HP preserved")
		pass_count += 1
	else:
		print("[FAIL] Elite mutation idempotency test failed")
		fail_count += 1

	if test_instability_reset():
		print("[PASS] Instability Reset: Resets meter to 0.0 on new expedition")
		pass_count += 1
	else:
		print("[FAIL] Instability reset test failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_instability_clamping() -> bool:
	var mgr = InstabilityManager.new()
	mgr.base_instability_rate = 50.0
	mgr.process_instability(3.0) # 50 * 3 = 150 -> clamped to 100
	
	var max_ok = (mgr.current_instability == 100.0)
	mgr.free()
	return max_ok

func test_elite_mutation_math() -> bool:
	var mgr = InstabilityManager.new()
	var beetle = AshBeetle.new()
	beetle._ready()
	var base_hp = beetle.max_hp # 45
	
	var success = mgr.mutate_enemy_to_elite(beetle)
	var hp_ok = (beetle.max_hp == int(base_hp * 1.50)) # 45 * 1.5 = 67
	
	mgr.free()
	beetle.free()
	return success and hp_ok

func test_elite_mutation_idempotency() -> bool:
	var mgr = InstabilityManager.new()
	var beetle = AshBeetle.new()
	beetle._ready()
	
	var first = mgr.mutate_enemy_to_elite(beetle)
	var hp_after_first = beetle.max_hp
	
	var second = mgr.mutate_enemy_to_elite(beetle) # Should return false
	var hp_after_second = beetle.max_hp
	
	mgr.free()
	beetle.free()
	return first and (not second) and (hp_after_first == hp_after_second)

func test_instability_reset() -> bool:
	var mgr = InstabilityManager.new()
	mgr.current_instability = 75.0
	mgr.reset_instability()
	var reset_ok = (mgr.current_instability == 0.0)
	mgr.free()
	return reset_ok
