# scripts/enemies/enemy_base.gd
class_name EnemyBase
extends CharacterBody2D

## Base class for all enemies utilizing a Finite State Machine (FSM) with Telegraph & Behavior Adaptation.

enum State { IDLE, PATROL, CHASE, TELEGRAPH, ATTACK, STUNNED, DEAD }

@export var enemy_data: EnemyData

var current_state: State = State.IDLE
var current_hp: int = 45
var max_hp: int = 45
var is_elite: bool = false

var target_player: CharacterBody2D = null
var patrol_dir: int = 1
var state_timer: float = 0.0
var hurt_flash_timer: float = 0.0
var is_enraged: bool = false

@onready var hurtbox: Hurtbox = $Hurtbox if has_node("Hurtbox") else null
@onready var visual: Sprite2D = $Visual if has_node("Visual") else null

func _ready() -> void:
	if enemy_data:
		max_hp = enemy_data.max_hp
	
	if is_elite:
		max_hp = int(max_hp * 3.0)
		scale *= 1.3
		if visual:
			visual.modulate = Color(0.8, 0.2, 0.9, 1.0) # Elite Purple Tint
			
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
		State.TELEGRAPH:
			_process_telegraph_state(delta)
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
		# Enter Telegraph charging warning state!
		change_state(State.TELEGRAPH)
		state_timer = 0.4 if not is_elite else 0.2 # Elites telegraph 50% faster!
	elif dist > detect_r * 1.5:
		target_player = null
		change_state(State.IDLE)
	else:
		var dir = signf(target_player.global_position.x - global_position.x)
		var base_speed = enemy_data.move_speed if enemy_data else 65.0
		if is_elite: base_speed *= 1.2
		var speed = base_speed * (1.3 if is_enraged else 1.0) # Behavior Adaptation: +30% Speed when enraged
		velocity.x = dir * speed
		scale.x = abs(scale.x) * (1 if dir >= 0 else -1)

func _process_telegraph_state(_delta: float) -> void:
	velocity.x = 0.0
	# Flash yellow/red warning glow during telegraph
	if visual:
		visual.modulate = Color(1.0, 0.8, 0.1, 1.0)
	if state_timer <= 0.0:
		change_state(State.ATTACK)

func _process_attack_state(_delta: float) -> void:
	velocity.x = 0.0
	if visual:
		visual.modulate = Color(1.0, 0.2, 0.1, 1.0) # Red strike flash

	if target_player and is_instance_valid(target_player):
		var dist = global_position.distance_to(target_player.global_position)
		if dist <= (enemy_data.attack_range * 1.3 if enemy_data else 32.0):
			if target_player.has_method("take_damage"):
				var dmg = enemy_data.touch_damage if enemy_data else 12
				if is_elite: dmg = int(dmg * 1.5)
				var kb = (target_player.global_position - global_position).normalized() * 120.0
				target_player.take_damage(dmg, kb)

	var cd = (enemy_data.attack_cooldown if enemy_data else 1.2) * (0.7 if is_enraged else 1.0)
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
	if current_state == State.DEAD:
		return
		
	current_hp -= damage
	velocity += knockback_vector

	# Behavior Adaptation (<50% HP Enrage)
	if current_hp <= int(max_hp * 0.5) and not is_enraged:
		is_enraged = true
		DamageNumber.create(global_position, 0, true, "ENRAGED!", get_parent())

	change_state(State.STUNNED)
	state_timer = 0.15
	hurt_flash_timer = 0.2

	if current_hp <= 0:
		_die()

func _update_hurt_flash(delta: float) -> void:
	if hurt_flash_timer > 0.0:
		hurt_flash_timer -= delta
		if visual:
			visual.modulate = Color(1.0, 1.0, 1.0, 1.0)
		if hurt_flash_timer <= 0.0 and visual:
			visual.modulate = Color(1.0, 1.0, 1.0, 1.0) # Normal color

func _die() -> void:
	change_state(State.DEAD)
	var type_id = enemy_data.id if enemy_data else "ash_beetle"
	EventBus.enemy_died.emit(global_position, type_id)
	
	_spawn_loot_drop()
	
	queue_free()

func _spawn_loot_drop() -> void:
	var parent_stage = get_parent()
	if parent_stage == null:
		return

	var roll = randf()
	var drop_type = "material"
	var drop_id = "ember_ore"
	var amount = randi_range(1, 2)
	var rarity = "common"
	
	if is_elite:
		drop_type = "material"
		drop_id = "star_shard" if randf() < 0.5 else "cryo_crystal"
		amount = randi_range(2, 4)
		rarity = "uncommon"
	elif roll < 0.60:
		# 60% Material Drop
		drop_type = "material"
		var m_roll = randf()
		if m_roll < 0.25: drop_id = "star_shard"; rarity = "uncommon"
		elif m_roll < 0.50: drop_id = "bio_sample"
		elif m_roll < 0.75: drop_id = "cryo_crystal"
		else: drop_id = "ember_ore"
	elif roll < 0.85:
		# 25% Gold (Credit)
		drop_type = "credit"
		drop_id = "credit"
		amount = randi_range(5, 12)
	else:
		# 15% Consumable / Equipment
		drop_type = "consumable"
		drop_id = "health_potion" if randf() < 0.6 else "energy_elixir"
		
	var item_scene = load("res://scenes/items/item_drop.tscn")
	if item_scene:
		var item_inst = item_scene.instantiate() as Node2D
		item_inst.set("item_id", drop_id)
		item_inst.set("item_type", drop_type)
		item_inst.set("amount", amount)
		item_inst.set("rarity_id", rarity)
		item_inst.global_position = global_position
		parent_stage.add_child(item_inst)
