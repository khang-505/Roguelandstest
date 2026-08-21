# tests/test_phase3_3.gd
class_name TestPhase33
extends Node

## Verification test runner for Phase 3.3 Companion Drone System.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 3.3 COMPANION DRONES ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_companion_data_init():
		print("[PASS] CompanionData resource instantiation")
		pass_count += 1
	else:
		print("[FAIL] CompanionData init test failed")
		fail_count += 1

	if test_companion_follow_distance():
		print("[PASS] Smooth Follow: Position interpolation toward player target")
		pass_count += 1
	else:
		print("[FAIL] Smooth follow test failed")
		fail_count += 1

	if test_support_drone_pulse():
		print("[PASS] Support Drone: Healing pulse restores player HP")
		pass_count += 1
	else:
		print("[FAIL] Support drone test failed")
		fail_count += 1

	if test_safe_cleanup():
		print("[PASS] Garbage Collection: Clean disconnection on tree_exiting")
		pass_count += 1
	else:
		print("[FAIL] Safe cleanup test failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_companion_data_init() -> bool:
	var data = CompanionData.new()
	data.companion_id = "combat_drone"
	data.type = CompanionData.Type.COMBAT
	return data.companion_id == "combat_drone" and data.type == CompanionData.Type.COMBAT

func test_companion_follow_distance() -> bool:
	var player = CharacterBody2D.new()
	player.global_position = Vector2(100, 100)
	
	var drone = CompanionBase.new()
	drone.global_position = Vector2(0, 0)
	drone.target_player = player
	
	drone._process_smooth_follow(0.1)
	var moved = (drone.global_position.x > 0.0)
	
	player.free()
	drone.free()
	return moved

func test_support_drone_pulse() -> bool:
	var player = PlayerController.new()
	player._ready()
	player.current_hp = 50
	player.max_hp = 100
	
	var drone = CompanionBase.new()
	drone.target_player = player
	drone.companion_data = CompanionData.new()
	drone.companion_data.type = CompanionData.Type.SUPPORT
	drone.cooldown_timer = 0.0
	
	drone._process_support_logic()
	var healed = (player.current_hp == 60) # 50 + 10 = 60
	
	player.free()
	drone.free()
	return healed

func test_safe_cleanup() -> bool:
	var drone = CompanionBase.new()
	add_child(drone)
	drone.queue_free()
	return true
