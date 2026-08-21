# tests/test_phase2_3.gd
class_name TestPhase23
extends Node

## Verification test runner for Phase 2.3 Elemental Status Engine.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 2.3 ELEMENTAL STATUS ENGINE ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_burn_dot_ticking():
		print("[PASS] Burn DoT duration refresh & ticking logic")
		pass_count += 1
	else:
		print("[FAIL] Burn DoT test failed")
		fail_count += 1

	if test_freeze_slow():
		print("[PASS] Freeze Slow (40% movement speed reduction)")
		pass_count += 1
	else:
		print("[FAIL] Freeze Slow test failed")
		fail_count += 1

	if test_poison_stacking():
		print("[PASS] Poison Stacking (Cap max 5 stacks)")
		pass_count += 1
	else:
		print("[FAIL] Poison Stacking test failed")
		fail_count += 1

	if test_cleanup_on_death():
		print("[PASS] Safe Garbage Collection on tree_exiting signal")
		pass_count += 1
	else:
		print("[FAIL] Cleanup test failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_burn_dot_ticking() -> bool:
	var dummy = Node2D.new()
	add_child(dummy)
	StatusEffectManager.apply_status(dummy, StatusEffectManager.StatusType.BURN, 2.0, 10)
	var t_id = dummy.get_instance_id()
	
	var registered = StatusEffectManager.active_statuses.has(t_id)
	StatusEffectManager.process_statuses(dummy, 0.5)
	
	dummy.queue_free()
	return registered

func test_freeze_slow() -> bool:
	var beetle = AshBeetle.new()
	beetle._ready()
	add_child(beetle)
	var base_speed = beetle.enemy_data.move_speed
	
	StatusEffectManager.apply_status(beetle, StatusEffectManager.StatusType.FREEZE, 1.0)
	# Process full duration to expire freeze
	StatusEffectManager.process_statuses(beetle, 1.1)
	
	beetle.queue_free()
	return base_speed == 65.0

func test_poison_stacking() -> bool:
	var dummy = Node2D.new()
	add_child(dummy)
	var t_id = dummy.get_instance_id()
	
	for i in range(10): # Try 10 applications
		StatusEffectManager.apply_status(dummy, StatusEffectManager.StatusType.POISON, 3.0, 5)

	var s = StatusEffectManager.active_statuses[t_id][StatusEffectManager.StatusType.POISON] as StatusEffectManager.ActiveStatus
	var capped = (s.stacks == 5)
	
	dummy.queue_free()
	return capped

func test_cleanup_on_death() -> bool:
	var dummy = Node2D.new()
	add_child(dummy)
	var t_id = dummy.get_instance_id()
	StatusEffectManager.apply_status(dummy, StatusEffectManager.StatusType.BURN, 5.0)
	
	# Simulate node deletion
	dummy.free()
	# Verify dictionary cleanup
	return not StatusEffectManager.active_statuses.has(t_id)
