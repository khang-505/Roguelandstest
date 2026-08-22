# scripts/enemies/enemy_base.gd
class_name EnemyBase
extends CharacterBody2D

## Base class for all enemies utilizing a Finite State Machine (FSM).

enum State { IDLE, PATROL, CHASE, ATTACK, STUNNED, DEAD }

@export var enemy_data: EnemyData

var current_state: State = State.IDLE
var current_hp: int = 45
var max_hp: int = 45

var target_player: CharacterBody2D = null
var patrol_dir: int = 1
var state_timer: float = 0.0
var hurt_flash_timer: float = 0.0

@onready var hurtbox: Hurtbox = $Hurtbox if has_node("Hurtbox") else null
@onready var body_rect: ColorRect = $Body if has_node("Body") else null

func _ready() -> void:
	if enemy_data:
		max_hp = enemy_data.max_hp
		current_hp = max_hp
	if hurtbox:
		hurtbox.hit_received.connect(_on_hit_received)
	EventBus.enemy_spawned.emit(self)

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return

	state_timer -= delta
	_update_hurt_flash(delta)

	match current_state:
		State.IDLE:
			_process_idle_state(delta)
		State.PATROL:
			_process_patrol_state(delta)
		State.CHASE:
			_process_chase_state(delta)
		State.ATTACK:
			_process_attack_state(delta)
		State.STUNNED:
			_process_stunned_state(delta)

	if not is_on_floor():
		velocity.y += 980.0 * delta

	move_and_slide()

func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	state_timer = 0.0

func _process_idle_state(_delta: float) -> void:
	velocity.x = 0.0
	_look_for_player()
	if state_timer <= 0.0:
		change_state(State.PATROL)
		state_timer = randf_range(1.5, 3.0)

func _process_patrol_state(_delta: float) -> void:
	var speed = enemy_data.move_speed * 0.5 if enemy_data else 30.0
	velocity.x = patrol_dir * speed

	_look_for_player()
	if is_on_wall() or state_timer <= 0.0:
		patrol_dir *= -1
		change_state(State.IDLE)
		state_timer = randf_range(1.0, 2.0)

func _process_chase_state(_delta: float) -> void:
	if not target_player or not is_instance_valid(target_player):
		change_state(State.IDLE)
		return

	var dist = global_position.distance_to(target_player.global_position)
	var attack_r = enemy_data.attack_range if enemy_data else 24.0
	var detect_r = enemy_data.detection_radius if enemy_data else 140.0

	if dist <= attack_r:
		change_state(State.ATTACK)
	elif dist > detect_r * 1.5:
		target_player = null
		change_state(State.IDLE)
	else:
		var dir = signf(target_player.global_position.x - global_position.x)
		var speed = enemy_data.move_speed if enemy_data else 65.0
		velocity.x = dir * speed
		# Face direction
		scale.x = abs(scale.x) * (1 if dir >= 0 else -1)

func _process_attack_state(_delta: float) -> void:
	velocity.x = 0.0
	if state_timer <= 0.0:
		# Attack impulse — use direct damage for now
		if target_player and is_instance_valid(target_player):
			var dist = global_position.distance_to(target_player.global_position)
			if dist <= (enemy_data.attack_range * 1.2 if enemy_data else 30.0):
				if target_player.has_method("take_damage"):
					var dmg = enemy_data.touch_damage if enemy_data else 12
					var kb = (target_player.global_position - global_position).normalized() * 120.0
					target_player.take_damage(dmg, kb)
		var cd = enemy_data.attack_cooldown if enemy_data else 1.2
		state_timer = cd
		change_state(State.CHASE)

func _process_stunned_state(_delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 400.0 * _delta)
	if state_timer <= 0.0:
		change_state(State.CHASE)

func _look_for_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p = players[0] as CharacterBody2D
		var radius = enemy_data.detection_radius if enemy_data else 140.0
		if global_position.distance_to(p.global_position) <= radius:
			target_player = p
			change_state(State.CHASE)

func _on_hit_received(damage: int, _is_crit: bool, _damage_type: String, knockback_vector: Vector2) -> void:
	current_hp -= damage
	velocity += knockback_vector
	change_state(State.STUNNED)
	state_timer = 0.15
	hurt_flash_timer = 0.2

	if current_hp <= 0:
		_die()

func _update_hurt_flash(delta: float) -> void:
	if hurt_flash_timer > 0.0:
		hurt_flash_timer -= delta
		if body_rect:
			body_rect.color = Color(1.0, 1.0, 1.0, 1.0)
		if hurt_flash_timer <= 0.0 and body_rect:
			body_rect.color = Color(0.8, 0.3, 0.1, 1.0)

func _die() -> void:
	change_state(State.DEAD)
	var type_id = enemy_data.id if enemy_data else "ash_beetle"
	EventBus.enemy_died.emit(global_position, type_id)
	queue_free()
