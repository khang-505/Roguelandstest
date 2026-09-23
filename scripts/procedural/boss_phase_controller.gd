# scripts/procedural/boss_phase_controller.gd
class_name BossPhaseController
extends RefCounted

## Controller managing Boss FSM states, phase transitions, attack telegraph lifecycles, and arena state integration.

enum BossState {
	INTRO,
	IDLE,
	TELEGRAPH,
	EXECUTE_ATTACK,
	RECOVERY,
	PHASE_TRANSITION,
	ENRAGE,
	STUNNED,
	DEATH
}

var boss_data = null
var current_hp: float = 1000.0
var current_phase_index: int = 1
var current_state: BossState = BossState.INTRO

var is_invulnerable: bool = false
var is_enraged: bool = false
var is_dead: bool = false

var current_attack: Dictionary = {}
var attack_cooldowns: Dictionary = {}
var attack_sequence_history: Array[String] = []

signal phase_changed(new_phase_index: int)
signal state_changed(old_state: BossState, new_state: BossState)
signal attack_telegraphed(attack_info: Dictionary)
signal boss_defeated(reward_data: Dictionary)

func _init(data) -> void:
	boss_data = data
	current_hp = data.max_health
	current_phase_index = 1
	current_state = BossState.INTRO

func take_damage(amount: float) -> bool:
	if is_invulnerable or is_dead:
		return false
		
	current_hp = max(0.0, current_hp - amount)
	var hp_pct = current_hp / boss_data.max_health
	
	if current_hp <= 0.0:
		_trigger_death()
		return true
		
	# Check Enrage Threshold
	if not is_enraged and hp_pct <= boss_data.enrage_hp_threshold:
		is_enraged = true
		_set_state(BossState.ENRAGE)
		
	# Check Phase Transition
	_check_phase_triggers(hp_pct)
	return true

func _check_phase_triggers(hp_pct: float) -> void:
	if current_state == BossState.PHASE_TRANSITION or is_dead:
		return
		
	for phase in boss_data.phases:
		var p_idx = phase.get("phase_index", 1)
		var p_threshold = phase.get("hp_threshold", 1.0)
		
		if p_idx > current_phase_index and hp_pct <= p_threshold:
			_start_phase_transition(p_idx)
			break

func _start_phase_transition(new_phase: int) -> void:
	current_phase_index = new_phase
	is_invulnerable = true
	_set_state(BossState.PHASE_TRANSITION)
	emit_signal("phase_changed", current_phase_index)

func complete_phase_transition() -> void:
	is_invulnerable = false
	_set_state(BossState.IDLE)

func select_next_attack(seed_val: int = 0) -> Dictionary:
	if current_state != BossState.IDLE and current_state != BossState.ENRAGE:
		return {}
		
	# Get unlocked attacks for current phase
	var available_attacks: Array[Dictionary] = []
	var phase_def = boss_data.phases[clamp(current_phase_index - 1, 0, boss_data.phases.size() - 1)]
	var unlocked_ids: Array = phase_def.get("unlocked_attacks", [])
	
	for attack in boss_data.attack_patterns:
		var atk_id = attack.get("id", "")
		if atk_id in unlocked_ids and not _is_attack_on_cooldown(atk_id):
			available_attacks.append(attack)
			
	if available_attacks.is_empty():
		# Fallback to first attack if all on cooldown
		available_attacks.append(boss_data.attack_patterns[0])
		
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_val if seed_val != 0 else int(current_hp * 100)
	var chosen_idx = rng.randi_range(0, available_attacks.size() - 1)
	
	current_attack = available_attacks[chosen_idx]
	_set_state(BossState.TELEGRAPH)
	
	var atk_id = current_attack.get("id", "")
	attack_sequence_history.append(atk_id)
	attack_cooldowns[atk_id] = 3.0 # Set 3s cooldown
	
	emit_signal("attack_telegraphed", current_attack)
	return current_attack

func execute_current_attack() -> void:
	if current_state == BossState.TELEGRAPH:
		_set_state(BossState.EXECUTE_ATTACK)

func recover_from_attack() -> void:
	if current_state == BossState.EXECUTE_ATTACK:
		_set_state(BossState.RECOVERY)

func finish_recovery() -> void:
	if current_state == BossState.RECOVERY:
		_set_state(BossState.IDLE)

func _is_attack_on_cooldown(atk_id: String) -> bool:
	return attack_cooldowns.get(atk_id, 0.0) > 0.0

func update_cooldowns(delta: float) -> void:
	for atk_id in attack_cooldowns.keys():
		attack_cooldowns[atk_id] = max(0.0, attack_cooldowns[atk_id] - delta)

func _trigger_death() -> void:
	is_dead = true
	is_invulnerable = true
	_set_state(BossState.DEATH)
	emit_signal("boss_defeated", boss_data.loot_table)

func _set_state(new_state: BossState) -> void:
	var old = current_state
	current_state = new_state
	emit_signal("state_changed", old, new_state)
