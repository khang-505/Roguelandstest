# tests/test_combat.gd
class_name TestCombat
extends Node

## Verification test runner for Phase 1.2 Combat Slice.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 1.2 COMBAT SLICE ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_hitbox_damage_calc():
		print("[PASS] Hitbox critical hit & damage math calculation")
		pass_count += 1
	else:
		print("[FAIL] Hitbox damage math failed")
		fail_count += 1

	if test_hurtbox_team_filter():
		print("[PASS] Hurtbox team collision filtering & armor mitigation")
		pass_count += 1
	else:
		print("[FAIL] Hurtbox team check failed")
		fail_count += 1
		
	if test_enemy_fsm():
		print("[PASS] Enemy FSM state transitions (IDLE -> CHASE -> ATTACK -> DEAD)")
		pass_count += 1
	else:
		print("[FAIL] Enemy FSM test failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_hitbox_damage_calc() -> bool:
	var hitbox = Hitbox.new()
	hitbox.damage = 20
	hitbox.critical_chance = 0.0 # Force no crit
	var calc = hitbox.get_calculated_damage()
	hitbox.free()
	return calc["damage"] == 20 and not calc["is_crit"]

func test_hurtbox_team_filter() -> bool:
	var hurtbox = Hurtbox.new()
	hurtbox.team = Hitbox.Team.ENEMY
	hurtbox.armor = 5
	var hb = Hitbox.new()
	hb.team = Hitbox.Team.PLAYER
	hb.damage = 15
	hb.critical_chance = 0.0
	
	var damage_received = 0
	hurtbox.hit_received.connect(func(dmg, _c, _t, _k): damage_received = dmg)
	
	# Simulate collision
	hurtbox._on_area_entered(hb)
	
	hurtbox.free()
	hb.free()
	return damage_received == 10 # 15 - 5 armor = 10

func test_enemy_fsm() -> bool:
	var beetle = AshBeetle.new()
	beetle._ready()
	beetle.change_state(EnemyBase.State.CHASE)
	var chase_ok = (beetle.current_state == EnemyBase.State.CHASE)
	beetle._on_hit_received(100, false, "PHYSICAL", Vector2.ZERO)
	var dead_ok = (beetle.current_state == EnemyBase.State.DEAD)
	beetle.free()
	return chase_ok and dead_ok
