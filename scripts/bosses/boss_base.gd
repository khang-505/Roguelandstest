# scripts/bosses/boss_base.gd
class_name BossBase
extends CharacterBody2D

## Base class for Biome Guardian Bosses featuring multi-phase transitions and FSM.

enum BossState { INTRO, IDLE, COMBAT, TRANSITION, STUNNED, DEAD }
enum BossPhase { PHASE_1, PHASE_2, PHASE_3 }

signal boss_phase_changed(old_phase: BossPhase, new_phase: BossPhase)
signal boss_defeated(boss_id: String, death_position: Vector2)

@export var boss_id: String = "molten_warden"
@export var display_name: String = "The Molten Warden"
@export var max_hp: int = 400
@export var move_speed: float = 50.0

var current_state: BossState = BossState.INTRO
var current_phase: BossPhase = BossPhase.PHASE_1
var current_hp: int = 400

var has_entered_phase_2: bool = false
var has_entered_phase_3: bool = false
var is_enraged: bool = false
var state_timer: float = 0.0
var attack_cooldown_timer: float = 0.0

var target_player: CharacterBody2D = null

@onready var hurtbox: Hurtbox = $Hurtbox if has_node("Hurtbox") else null
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null

func _ready() -> void:
	current_hp = max_hp
	if hurtbox:
		hurtbox.hit_received.connect(_on_hit_received)
	EventBus.enemy_spawned.emit(self)
	change_state(BossState.IDLE)

func _physics_process(delta: float) -> void:
	if current_state == BossState.DEAD:
		return

	state_timer -= delta
	attack_cooldown_timer = maxf(0.0, attack_cooldown_timer - delta)

	if target_player == null or not is_instance_valid(target_player):
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target_player = players[0] as CharacterBody2D

	match current_state:
		BossState.IDLE:
			_process_idle_state(delta)
		BossState.COMBAT:
			_process_combat_state(delta)
		BossState.TRANSITION:
			_process_transition_state(delta)
		BossState.STUNNED:
			_process_stunned_state(delta)

	if not is_on_floor():
		velocity.y += 980.0 * delta

	move_and_slide()

func change_state(new_state: BossState) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	state_timer = 0.0

func _on_hit_received(damage: int, _is_crit: bool, _damage_type: String, knockback_vector: Vector2) -> void:
	if current_state == BossState.DEAD or current_state == BossState.TRANSITION:
		return

	current_hp = max(0, current_hp - damage)
	velocity += knockback_vector * 0.2 # Resists heavy knockback

	_check_phase_thresholds()

	if current_hp <= 0:
		_die()

func _check_phase_thresholds() -> void:
	var hp_pct = float(current_hp) / float(max_hp)

	if hp_pct <= 0.33 and not has_entered_phase_3:
		has_entered_phase_3 = true
		_transition_to_phase(BossPhase.PHASE_3)
	elif hp_pct <= 0.66 and not has_entered_phase_2:
		has_entered_phase_2 = true
		_transition_to_phase(BossPhase.PHASE_2)

func _transition_to_phase(new_phase: BossPhase) -> void:
	var old_phase = current_phase
	current_phase = new_phase
	change_state(BossState.TRANSITION)
	state_timer = 1.5 # 1.5s phase transition grace period
	boss_phase_changed.emit(old_phase, new_phase)
	_on_phase_changed(old_phase, new_phase)

func _on_phase_changed(_old_phase: BossPhase, _new_phase: BossPhase) -> void:
	# Overridden by specific boss implementation
	pass

func _process_idle_state(_delta: float) -> void:
	velocity.x = 0.0
	if target_player and state_timer <= 0.0:
		change_state(BossState.COMBAT)

func _process_combat_state(_delta: float) -> void:
	if not target_player:
		change_state(BossState.IDLE)
		return

	var dist = global_position.distance_to(target_player.global_position)
	var dir = signf(target_player.global_position.x - global_position.x)
	velocity.x = dir * move_speed

	if sprite and dir != 0.0:
		sprite.flip_h = (dir == -1)

	if attack_cooldown_timer <= 0.0 and dist <= 160.0:
		_execute_boss_attack()

func _process_transition_state(_delta: float) -> void:
	velocity.x = 0.0
	if state_timer <= 0.0:
		change_state(BossState.COMBAT)

func _process_stunned_state(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)
	if state_timer <= 0.0:
		change_state(BossState.COMBAT)

func _execute_boss_attack() -> void:
	# Overridden by specific boss implementation
	attack_cooldown_timer = 2.0

func _die() -> void:
	if current_state == BossState.DEAD:
		return
	change_state(BossState.DEAD)
	velocity = Vector2.ZERO
	boss_defeated.emit(boss_id, global_position)
	EventBus.enemy_died.emit(global_position, boss_id)
	queue_free()
