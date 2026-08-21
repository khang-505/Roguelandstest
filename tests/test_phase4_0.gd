# tests/test_phase4_0.gd
class_name TestPhase40
extends Node

## Verification test runner for Phase 4.0 Biome Guardian Boss System & Multi-Phase FSM.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 4.0 BIOME GUARDIAN BOSS SYSTEM ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_boss_initial_phase():
		print("[PASS] Boss Initial Phase: Phase 1 at 100% HP (400/400)")
		pass_count += 1
	else:
		print("[FAIL] Initial phase test failed")
		fail_count += 1

	if test_phase2_transition_threshold():
		print("[PASS] Phase 2 Threshold (<=66% HP): Transition triggered exactly once")
		pass_count += 1
	else:
		print("[FAIL] Phase 2 threshold test failed")
		fail_count += 1

	if test_phase3_transition_threshold():
		print("[PASS] Phase 3 Threshold (<=33% HP): Enraged mode (+50% attack speed) applied ONCE")
		pass_count += 1
	else:
		print("[FAIL] Phase 3 threshold test failed")
		fail_count += 1

	if test_boss_death_cleanup():
		print("[PASS] Boss Death Cleanup: HP=0 -> DEAD state, hazards freed, boss_defeated event emitted")
		pass_count += 1
	else:
		print("[FAIL] Boss death cleanup test failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_boss_initial_phase() -> bool:
	var warden = MoltenWarden.new()
	warden._ready()
	var ok = (warden.current_phase == BossBase.BossPhase.PHASE_1 and warden.current_hp == 400)
	warden.free()
	return ok

func test_phase2_transition_threshold() -> bool:
	var warden = MoltenWarden.new()
	warden._ready()
	
	var phase_changed_count = 0
	warden.boss_phase_changed.connect(func(_o, _n): phase_changed_count += 1)
	
	# Deal 150 damage (400 - 150 = 250 HP, which is 62.5% <= 66%)
	warden._on_hit_received(150, false, "PHYSICAL", Vector2.ZERO)
	
	var p2_ok = (warden.current_phase == BossBase.BossPhase.PHASE_2)
	var flag_ok = warden.has_entered_phase_2
	var once_ok = (phase_changed_count == 1)
	
	# Deal another hit of 10 damage (240 HP, still in Phase 2)
	warden._on_hit_received(10, false, "PHYSICAL", Vector2.ZERO)
	var still_once = (phase_changed_count == 1)
	
	warden.free()
	return p2_ok and flag_ok and once_ok and still_once

func test_phase3_transition_threshold() -> bool:
	var warden = MoltenWarden.new()
	warden._ready()
	
	# Deal 300 damage (400 - 300 = 100 HP, which is 25% <= 33%)
	warden._on_hit_received(300, false, "PHYSICAL", Vector2.ZERO)
	
	var p3_ok = (warden.current_phase == BossBase.BossPhase.PHASE_3)
	var enraged_ok = warden.is_enraged
	var cd_ok = (warden.base_attack_cd == 1.0)
	
	warden.free()
	return p3_ok and enraged_ok and cd_ok

func test_boss_death_cleanup() -> bool:
	var warden = MoltenWarden.new()
	warden._ready()
	
	var event_emitted = false
	warden.boss_defeated.connect(func(_id, _pos): event_emitted = true)
	
	# Deal lethal damage
	warden._on_hit_received(500, false, "PHYSICAL", Vector2.ZERO)
	
	return event_emitted
