# tests/test_phase4_1.gd
class_name TestPhase41
extends Node

## Verification test runner for Phase 4.1 Extraction Defense Challenge & Channel Timer.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 4.1 EXTRACTION DEFENSE CHALLENGE ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_extraction_timer_update():
		print("[PASS] Channeling Delta Timer: Accumulates accurately during extraction")
		pass_count += 1
	else:
		print("[FAIL] Channeling timer test failed")
		fail_count += 1

	if test_extraction_interruption():
		print("[PASS] Extraction Interruption: Exiting beacon transitions to INTERRUPTED state")
		pass_count += 1
	else:
		print("[FAIL] Interruption test failed")
		fail_count += 1

	if test_10s_completion():
		print("[PASS] 10-Second Completion: Reaching duration transitions to COMPLETED")
		pass_count += 1
	else:
		print("[FAIL] 10s completion test failed")
		fail_count += 1

	if test_idempotent_reward_security():
		print("[PASS] Idempotent Reward Transfer: Rewards transferred to profile EXACTLY ONCE")
		pass_count += 1
	else:
		print("[FAIL] Idempotent reward test failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_extraction_timer_update() -> bool:
	var beacon = ExtractionBeacon.new()
	var dummy_player = CharacterBody2D.new()
	beacon.target_player = dummy_player
	
	beacon.start_extraction()
	beacon._physics_process(2.5) # Simulate 2.5s
	
	var active = (beacon.current_state == ExtractionBeacon.ExtractionState.CHANNELING)
	var timer_ok = (beacon.channel_timer == 2.5)
	
	dummy_player.free()
	beacon.free()
	return active and timer_ok

func test_extraction_interruption() -> bool:
	var beacon = ExtractionBeacon.new()
	var dummy_player = CharacterBody2D.new()
	beacon.target_player = dummy_player
	
	beacon.start_extraction()
	beacon._physics_process(2.0)
	beacon.interrupt_extraction()
	
	var interrupted = (beacon.current_state == ExtractionBeacon.ExtractionState.INTERRUPTED)
	var timer_reset = (beacon.channel_timer == 0.0)
	
	dummy_player.free()
	beacon.free()
	return interrupted and timer_reset

func test_10s_completion() -> bool:
	var beacon = ExtractionBeacon.new()
	var dummy_player = CharacterBody2D.new()
	beacon.target_player = dummy_player
	
	beacon.start_extraction()
	beacon._physics_process(10.0)
	
	var completed = (beacon.current_state == ExtractionBeacon.ExtractionState.COMPLETED)
	
	dummy_player.free()
	beacon.free()
	return completed

func test_idempotent_reward_security() -> bool:
	SaveManager.profile_data["total_credits"] = 100
	GameManager.run_credits = 50
	
	var beacon = ExtractionBeacon.new()
	beacon._secure_run_rewards()
	
	var first_transfer = (SaveManager.profile_data["total_credits"] == 150)
	
	# Call again to test idempotency
	beacon._secure_run_rewards()
	var second_transfer = (SaveManager.profile_data["total_credits"] == 150) # Still 150, not 200
	
	beacon.free()
	return first_transfer and second_transfer
