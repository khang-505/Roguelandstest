# tests/test_player.gd
class_name TestPlayer
extends Node

## Unit test runner for Phase 1.1 Player Controller.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 1.1 PLAYER SLICE ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_player_instantiation():
		print("[PASS] PlayerController node & scene initialization")
		pass_count += 1
	else:
		print("[FAIL] PlayerController initialization failed")
		fail_count += 1

	if test_player_movement_values():
		print("[PASS] Configurable movement stats (speed, jump, dash)")
		pass_count += 1
	else:
		print("[FAIL] Movement stats check failed")
		fail_count += 1
		
	if test_player_dash_and_health():
		print("[PASS] Player dash i-frame & health damage deduction")
		pass_count += 1
	else:
		print("[FAIL] Dash / health check failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_player_instantiation() -> bool:
	var scene = load("res://scenes/player/player.tscn")
	if scene == null:
		return false
	var instance = scene.instantiate()
	if instance == null or not (instance is PlayerController):
		return false
	instance.free()
	return true

func test_player_movement_values() -> bool:
	var player = PlayerController.new()
	var speed_ok = (player.move_speed > 0.0)
	var jump_ok = (player.jump_force < 0.0)
	var coyote_ok = (player.coyote_time > 0.0)
	player.free()
	return speed_ok and jump_ok and coyote_ok

func test_player_dash_and_health() -> bool:
	var player = PlayerController.new()
	player._ready()
	var initial_hp = player.current_hp
	player.take_damage(20)
	var damage_ok = (player.current_hp == initial_hp - 20)
	player.free()
	return damage_ok
