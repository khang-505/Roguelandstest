# scripts/player/player_controller.gd
class_name PlayerController
extends CharacterBody2D

## Player controller handling platformer physics, jump buffering, coyote time, dash i-frames, and combat triggers.

@export_group("Movement Stats")
@export var move_speed: float = 160.0
@export var acceleration: float = 1200.0
@export var deceleration: float = 1400.0
@export var gravity: float = 980.0
@export var max_fall_speed: float = 450.0

@export_group("Jump Stats")
@export var jump_force: float = -340.0
@export var max_jumps: int = 2
@export var coyote_time: float = 0.15
@export var jump_buffer_time: float = 0.10

@export_group("Dash Stats")
@export var dash_speed: float = 380.0
@export var dash_duration: float = 0.20
@export var dash_cooldown: float = 0.80

# State variables
var current_hp: int = 100
var max_hp: int = 100
var current_energy: float = 100.0
var max_energy: float = 100.0

var facing_direction: int = 1
var jumps_left: int = 2
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var is_invulnerable: bool = false

# Weapon attack variables
var current_weapon: WeaponData
var attack_cooldown_timer: float = 0.0
var attack_active_timer: float = 0.0

# Hurt flash
var hurt_flash_timer: float = 0.0

@onready var body_rect: ColorRect = $Body if has_node("Body") else null
@onready var attack_hitbox: Area2D = $AttackHitbox if has_node("AttackHitbox") else null
@onready var hitbox_shape: CollisionShape2D = $AttackHitbox/HitboxShape if has_node("AttackHitbox/HitboxShape") else null
@onready var hurtbox: Hurtbox = $Hurtbox if has_node("Hurtbox") else null

func _ready() -> void:
	current_hp = GameManager.player_current_hp
	max_hp = GameManager.player_max_hp
	current_energy = GameManager.player_current_energy

	# Load default weapon
	current_weapon = WeaponData.new()

	# Connect hurtbox
	if hurtbox:
		hurtbox.hit_received.connect(_on_hit_received)

	# Make sure attack hitbox starts disabled
	if hitbox_shape:
		hitbox_shape.disabled = true

	EventBus.player_hp_changed.emit(current_hp, max_hp)
	EventBus.player_energy_changed.emit(current_energy, max_energy)

func _physics_process(delta: float) -> void:
	if GameManager.current_state == GameManager.GameState.DEATH:
		return

	_update_timers(delta)
	_update_attack_hitbox(delta)
	_update_hurt_flash(delta)

	if is_dashing:
		_perform_dash(delta)
	else:
		_apply_gravity(delta)
		_handle_jump(delta)
		_handle_movement(delta)
		_handle_dash_input()
		_handle_attack_input()

	move_and_slide()

func _update_timers(delta: float) -> void:
	if is_on_floor():
		coyote_timer = coyote_time
		jumps_left = max_jumps
	else:
		coyote_timer = maxf(0.0, coyote_timer - delta)

	jump_buffer_timer = maxf(0.0, jump_buffer_timer - delta)
	dash_cooldown_timer = maxf(0.0, dash_cooldown_timer - delta)
	attack_cooldown_timer = maxf(0.0, attack_cooldown_timer - delta)

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)

func _handle_movement(delta: float) -> void:
	var move_input = Input.get_axis("move_left", "move_right")

	if move_input != 0.0:
		facing_direction = 1 if move_input > 0 else -1
		# Flip player visual
		scale.x = abs(scale.x) * facing_direction
		velocity.x = move_toward(velocity.x, move_input * move_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)

func _handle_jump(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time

	if jump_buffer_timer > 0.0:
		if is_on_floor() or coyote_timer > 0.0:
			_execute_jump()
		elif jumps_left > 1: # Air jump
			_execute_jump()

func _execute_jump() -> void:
	velocity.y = jump_force
	jumps_left -= 1
	coyote_timer = 0.0
	jump_buffer_timer = 0.0

func _handle_dash_input() -> void:
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0.0 and current_energy >= 15.0:
		is_dashing = true
		is_invulnerable = true
		dash_timer = dash_duration
		dash_cooldown_timer = dash_cooldown
		current_energy = maxf(0.0, current_energy - 15.0)
		EventBus.player_energy_changed.emit(current_energy, max_energy)

func _perform_dash(delta: float) -> void:
	dash_timer -= delta
	velocity.x = facing_direction * dash_speed
	velocity.y = 0.0

	if dash_timer <= 0.0:
		is_dashing = false
		is_invulnerable = false

func _handle_attack_input() -> void:
	if Input.is_action_just_pressed("attack") and attack_cooldown_timer <= 0.0:
		attack_cooldown_timer = 1.0 / current_weapon.attack_speed
		_execute_attack()

func _execute_attack() -> void:
	# Enable hitbox briefly
	if hitbox_shape:
		hitbox_shape.disabled = false
		attack_active_timer = 0.15 # Hitbox active for 150ms

	# Visual feedback - brief color change
	if body_rect:
		body_rect.color = Color(1.0, 1.0, 1.0, 1.0)
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(body_rect):
			body_rect.color = Color(0.2, 0.6, 1.0, 1.0)

func _update_attack_hitbox(delta: float) -> void:
	if attack_active_timer > 0.0:
		attack_active_timer -= delta
		if attack_active_timer <= 0.0 and hitbox_shape:
			hitbox_shape.disabled = true

func _update_hurt_flash(delta: float) -> void:
	if hurt_flash_timer > 0.0:
		hurt_flash_timer -= delta
		if body_rect:
			# Flash red/normal
			if int(hurt_flash_timer * 20) % 2 == 0:
				body_rect.color = Color(1.0, 0.2, 0.2, 1.0)
			else:
				body_rect.color = Color(0.2, 0.6, 1.0, 1.0)
		if hurt_flash_timer <= 0.0 and body_rect:
			body_rect.color = Color(0.2, 0.6, 1.0, 1.0)

func _on_hit_received(damage: int, _is_crit: bool, _damage_type: String, knockback_vector: Vector2) -> void:
	if is_invulnerable or current_hp <= 0:
		return
	take_damage(damage, knockback_vector)

func take_damage(amount: int, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if is_invulnerable or current_hp <= 0:
		return

	current_hp = max(0, current_hp - amount)
	GameManager.player_current_hp = current_hp
	EventBus.player_hp_changed.emit(current_hp, max_hp)

	# Hurt flash
	hurt_flash_timer = 0.3
	is_invulnerable = true
	await get_tree().create_timer(0.4).timeout
	is_invulnerable = false

	if knockback_dir != Vector2.ZERO:
		velocity += knockback_dir

	if current_hp <= 0:
		EventBus.player_died.emit()
