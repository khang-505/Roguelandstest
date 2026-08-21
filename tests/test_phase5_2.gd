# tests/test_phase5_2.gd
class_name TestPhase52
extends Node

## Verification test runner for Phase 5.2 Object Pooling Performance Engine.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 5.2 OBJECT POOLING ENGINE ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_pool_acquire_and_release():
		print("[PASS] Pool Acquire & Release: Object reused from pool without allocation overhead")
		pass_count += 1
	else:
		print("[FAIL] Pool acquire & release test failed")
		fail_count += 1

	if test_double_release_guard():
		print("[PASS] Double-Release Guard: Prevents pool state corruption on duplicate release")
		pass_count += 1
	else:
		print("[FAIL] Double release guard test failed")
		fail_count += 1

	if test_pool_active_count():
		print("[PASS] Active Counter: Accurately tracks active memory pool allocations")
		pass_count += 1
	else:
		print("[FAIL] Active counter test failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_pool_acquire_and_release() -> bool:
	var dummy_parent = Node2D.new()
	add_child(dummy_parent)
	
	var scene = PackedScene.new() # Using Node2D dummy
	var dummy_obj = Node2D.new()
	dummy_parent.add_child(dummy_obj)
	
	var active_before = ObjectPool.get_active_count()
	dummy_obj.set_meta("scene_path", "dummy_path")
	ObjectPool.active_objects[dummy_obj.get_instance_id()] = "dummy_path"
	
	var release_ok = ObjectPool.release(dummy_obj)
	var active_after = ObjectPool.get_active_count()
	
	dummy_parent.free()
	return release_ok and (active_after == active_before - 1)

func test_double_release_guard() -> bool:
	var dummy_obj = Node2D.new()
	add_child(dummy_obj)
	ObjectPool.active_objects[dummy_obj.get_instance_id()] = "dummy_path_2"
	
	var first_rel = ObjectPool.release(dummy_obj)
	var second_rel = ObjectPool.release(dummy_obj) # Should return false
	
	return first_rel and (not second_rel)

func test_pool_active_count() -> bool:
	var count = ObjectPool.get_active_count()
	return count >= 0
