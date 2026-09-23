# scripts/combat/combat_state_machine.gd
class_name CombatStateMachine
extends RefCounted

## State Machine managing Real-time Combat States, Attack Lifecycles, Micro-Freeze Hit Stops, and Cancel Windows.

enum CombatState {
	IDLE,
	MOVE,
	ATTACK_STARTUP,
	ATTACK_ACTIVE,
	ATTACK_RECOVERY,
	HEAVY_ATTACK,
	ABILITY,
	DASH,
	HIT_STUN,
	DEAD
}

var current_state: CombatState = CombatState.IDLE
var state_timer: float = 0.0
var hit_stop_timer: float = 0.0

var startup_duration: float = 0.1
var active_duration: float = 0.15
var recovery_duration: float = 0.2

signal combat_state_changed(old_state: CombatState, new_state: CombatState)
signal hit_stop_triggered(duration: float)

func _init() -> void:
	current_state = CombatState.IDLE

func update(delta: float) -> void:
	if hit_stop_timer > 0.0:
		hit_stop_timer -= delta
		return
		
	if state_timer > 0.0:
		state_timer -= delta
		if state_timer <= 0.0:
			_on_state_timer_expired()

func start_attack(p_startup: float = 0.1, p_active: float = 0.15, p_recovery: float = 0.2) -> bool:
	if not can_attack():
		return false
		
	startup_duration = p_startup
	active_duration = p_active
	recovery_duration = p_recovery
	
	_change_state(CombatState.ATTACK_STARTUP)
	state_timer = startup_duration
	return true

func start_dash(dash_duration: float = 0.25) -> bool:
	if not can_dash():
		return false
		
	_change_state(CombatState.DASH)
	state_timer = dash_duration
	return true

func trigger_hit_stun(stun_duration: float = 0.3) -> void:
	_change_state(CombatState.HIT_STUN)
	state_timer = stun_duration

func apply_hit_stop(duration: float) -> void:
	hit_stop_timer = max(hit_stop_timer, duration)
	emit_signal("hit_stop_triggered", duration)

func can_attack() -> bool:
	return current_state in [CombatState.IDLE, CombatState.MOVE, CombatState.ATTACK_RECOVERY]

func can_dash() -> bool:
	# Allows dash cancel during ATTACK_RECOVERY
	return current_state in [CombatState.IDLE, CombatState.MOVE, CombatState.ATTACK_RECOVERY]

func can_move() -> bool:
	return current_state in [CombatState.IDLE, CombatState.MOVE]

func _on_state_timer_expired() -> void:
	match current_state:
		CombatState.ATTACK_STARTUP:
			_change_state(CombatState.ATTACK_ACTIVE)
			state_timer = active_duration
		CombatState.ATTACK_ACTIVE:
			_change_state(CombatState.ATTACK_RECOVERY)
			state_timer = recovery_duration
		CombatState.ATTACK_RECOVERY, CombatState.DASH, CombatState.HIT_STUN, CombatState.HEAVY_ATTACK, CombatState.ABILITY:
			_change_state(CombatState.IDLE)

func _change_state(new_state: CombatState) -> void:
	var old = current_state
	current_state = new_state
	emit_signal("combat_state_changed", old, new_state)
