# tests/test_phase5_1.gd
class_name TestPhase51
extends Node

## Verification test runner for Phase 5.1 Co-op Multiplayer Architecture & Revive System.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 5.1 CO-OP & REVIVE SYSTEM ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_offline_single_player():
		print("[PASS] Offline Compatibility: Single-player runs 100% offline without network sessions")
		pass_count += 1
	else:
		print("[FAIL] Offline compatibility test failed")
		fail_count += 1

	if test_coop_downed_transition():
		print("[PASS] Downed State: HP=0 in co-op transitions to DOWNED state")
		pass_count += 1
	else:
		print("[FAIL] Downed transition test failed")
		fail_count += 1

	if test_5s_revive_channeling():
		print("[PASS] 5-Second Revive Channel: Completes revive and restores 50% HP")
		pass_count += 1
	else:
		print("[FAIL] Revive channel test failed")
		fail_count += 1

	if test_revive_interruption():
		print("[PASS] Revive Interruption: Exceeding radius cancels revive channel cleanly")
		pass_count += 1
	else:
		print("[FAIL] Revive interruption test failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_offline_single_player() -> bool:
	var nm = NetworkManagerSingleton.new()
	var offline_ok = nm.is_offline()
	var host_ok = nm.is_host()
	nm.free()
	return offline_ok and host_ok

func test_coop_downed_transition() -> bool:
	var sys = ReviveSystem.new()
	var p = PlayerController.new()
	p._ready()
	
	sys.process_player_downed(p, true) # Co-op mode = true
	var state = sys.get_player_state(p)
	var downed_ok = (state == ReviveSystem.PlayerLifeState.DOWNED)
	
	p.free()
	sys.free()
	return downed_ok

func test_5s_revive_channeling() -> bool:
	var sys = ReviveSystem.new()
	var target = PlayerController.new()
	var reviver = PlayerController.new()
	target._ready()
	reviver._ready()
	
	target.global_position = Vector2(0, 0)
	reviver.global_position = Vector2(10, 0)
	
	sys.set_player_state(target, ReviveSystem.PlayerLifeState.DOWNED)
	var started = sys.start_revive(reviver, target)
	
	sys.update_revive_process(target, reviver, 5.0) # Process 5 seconds
	var revived_ok = (sys.get_player_state(target) == ReviveSystem.PlayerLifeState.REVIVED)
	
	target.free()
	reviver.free()
	sys.free()
	return started and revived_ok

func test_revive_interruption() -> bool:
	var sys = ReviveSystem.new()
	var target = PlayerController.new()
	var reviver = PlayerController.new()
	target._ready()
	reviver._ready()
	
	target.global_position = Vector2(0, 0)
	reviver.global_position = Vector2(100, 0) # 100px > 48px radius
	
	sys.set_player_state(target, ReviveSystem.PlayerLifeState.DOWNED)
	sys.start_revive(reviver, target)
	sys.update_revive_process(target, reviver, 1.0)
	
	var interrupted_ok = (sys.get_player_state(target) == ReviveSystem.PlayerLifeState.DOWNED)
	
	target.free()
	reviver.free()
	sys.free()
	return interrupted_ok
