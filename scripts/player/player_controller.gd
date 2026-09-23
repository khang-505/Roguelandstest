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
var available_weapons: Array[WeaponData] = []
var active_weapon_index: int = 0
var attack_cooldown_timer: float = 0.0
var attack_active_timer: float = 0.0

# Hurt flash
var hurt_flash_timer: float = 0.0

@onready var visual: Sprite2D = $Visual if has_node("Visual") else null
@onready var weapon_visual: Sprite2D = $Visual/WeaponVisual if has_node("Visual/WeaponVisual") else null
@onready var attack_hitbox: Area2D = $AttackHitbox if has_node("AttackHitbox") else null
@onready var hitbox_shape: CollisionShape2D = $AttackHitbox/HitboxShape if has_node("AttackHitbox/HitboxShape") else null
@onready var hurtbox: Hurtbox = $Hurtbox if has_node("Hurtbox") else null

enum PlayerState { IDLE, MOVING, ATTACKING, HURT, DODGING, USING_ITEM, DEAD }
var current_player_state: PlayerState = PlayerState.IDLE

# Equipment & Defense
var equipped_armor: Dictionary = {}
var total_defense: int = 0
var bonus_attack_stat: int = 0

# Temporary Consumable Buffs
var temp_bonus_defense: int = 0
var temp_bonus_attack: int = 0
var temp_bonus_speed: float = 0.0
var buff_timer: float = 0.0

func _ready() -> void:
	current_hp = GameManager.player_current_hp
	max_hp = GameManager.player_max_hp
	current_energy = GameManager.player_current_energy

	# Load origin and starting weapon
	var active_origin_id = SaveManager.profile_data.get("active_origin", "vanguard")
	var origin = OriginData.get_origin(active_origin_id)
	
	_load_equipped_armor()
	recalculate_total_stats(origin)
	_setup_weapon_inventory(origin.starting_weapon_id)

	# Connect hurtbox and signals
	if hurtbox:
		hurtbox.hit_received.connect(_on_hit_received)
	EventBus.player_leveled_up.connect(_on_leveled_up)

	# Make sure attack hitbox starts disabled
	if hitbox_shape:
		hitbox_shape.disabled = true

	EventBus.player_hp_changed.emit(current_hp, max_hp)
	EventBus.player_energy_changed.emit(current_energy, max_energy)

func _on_leveled_up(new_level: int) -> void:
	current_hp = max_hp
	GameManager.player_current_hp = current_hp
	EventBus.player_hp_changed.emit(current_hp, max_hp)
	DamageNumber.create(global_position, new_level, true, "LEVEL UP!", get_parent())

	var lvl_scene = load("res://scenes/ui/level_up_ui.tscn")
	if lvl_scene:
		var lvl_inst = lvl_scene.instantiate()
		var stage = get_parent()
		if stage:
			stage.call_deferred("add_child", lvl_inst)

func _load_equipped_armor() -> void:
	equipped_armor.clear()
	var saved_armor: Dictionary = SaveManager.profile_data.get("equipped_armor", {})
	for slot_key in saved_armor.keys():
		var item_id = saved_armor[slot_key]
		var eq = EquipmentData.get_equipment(item_id)
		if eq:
			equipped_armor[eq.slot] = eq

func recalculate_total_stats(origin: OriginData) -> void:
	var base_speed = 160.0 * (1.0 + origin.speed_modifier)
	var add_hp = 0
	total_defense = 0
	bonus_attack_stat = 0
	var add_speed = 0.0

	for eq in equipped_armor.values():
		if eq is EquipmentData:
			add_hp += eq.bonus_hp
			total_defense += eq.bonus_defense
			bonus_attack_stat += eq.bonus_attack
			add_speed += eq.bonus_speed

	max_hp = GameManager.player_max_hp + add_hp
	current_hp = min(current_hp, max_hp)
	move_speed = base_speed + add_speed

func get_build_archetype() -> String:
	var total_hp = max_hp
	var total_def = total_defense + temp_bonus_defense
	var _total_atk = bonus_attack_stat + temp_bonus_attack
	var total_spd = move_speed + temp_bonus_speed
	var is_ranged = (current_weapon and (current_weapon.category == WeaponData.WeaponCategory.RANGED or current_weapon.category == WeaponData.WeaponCategory.ENERGY))
	
	# Spec: RANGED = Ranged weapon, Mobility, Kiting
	if is_ranged:
		return "Ranged DPS"
	# Spec: MELEE TANK = HP / Defense / Melee
	elif total_hp >= 140 or total_def >= 12:
		return "Melee Tank"
	# Spec: ASSASSIN = Crit / Speed / Burst
	elif total_spd >= 185.0:
		return "Assassin"
	else:
		return "Frontier Operative"

func consume_item(item_id: String) -> bool:
	match item_id:
		"health_potion":
			if current_hp >= max_hp: return false
			current_hp = min(max_hp, current_hp + 50)
			GameManager.player_current_hp = current_hp
			EventBus.player_hp_changed.emit(current_hp, max_hp)
			DamageNumber.create(global_position, 50, false, "HEAL", get_parent())
			return true
		"energy_elixir":
			if current_energy >= max_energy: return false
			current_energy = min(max_energy, current_energy + 60.0)
			GameManager.player_current_energy = current_energy
			EventBus.player_energy_changed.emit(current_energy, max_energy)
			DamageNumber.create(global_position, 60, false, "ENERGY", get_parent())
			return true
		"iron_skin_potion":
			temp_bonus_defense = 5
			buff_timer = 30.0
			DamageNumber.create(global_position, 0, false, "DEFENSE UP", get_parent())
			return true
		"berserker_brew":
			temp_bonus_attack = 10
			temp_bonus_speed = 30.0
			buff_timer = 30.0
			DamageNumber.create(global_position, 0, false, "BERSERK", get_parent())
			return true
	return false

func _use_consumable_from_backpack(target_id: String) -> void:
	for i in range(GameManager.run_backpack.size()):
		var item = GameManager.run_backpack[i]
		if item["id"] == target_id:
			if consume_item(target_id):
				item["amount"] -= 1
				if item["amount"] <= 0:
					GameManager.run_backpack.remove_at(i)
			return

func _setup_weapon_inventory(starting_weapon_id: String) -> void:
	available_weapons.clear()
	var equipped_id = SaveManager.profile_data.get("equipped_weapon", starting_weapon_id)
	if equipped_id == "": equipped_id = starting_weapon_id
	
	var equipped = WeaponData.get_weapon(equipped_id)
	if equipped:
		available_weapons.append(equipped)
		current_weapon = equipped
		_update_weapon_visual()

func _update_weapon_visual() -> void:
	if weapon_visual and current_weapon:
		var tex_path = "res://art/weapons/" + current_weapon.id + ".png"
		if ResourceLoader.exists(tex_path):
			weapon_visual.texture = load(tex_path)
		else:
			weapon_visual.texture = load("res://art/weapons/plasma_blade.png")

func equip_new_weapon(w_id: String) -> void:
	var w = WeaponData.get_weapon(w_id)
	if w:
		available_weapons.clear()
		available_weapons.append(w)
		current_weapon = w
		active_weapon_index = 0
		_update_weapon_visual()
		var hud_nodes = get_tree().get_nodes_in_group("hud")
		for h in hud_nodes:
			if h.has_method("update_hud_display"):
				h.update_hud_display()

func switch_weapon(next: bool = true) -> void:
	if available_weapons.size() <= 1:
		return
	if next:
		active_weapon_index = (active_weapon_index + 1) % available_weapons.size()
	else:
		active_weapon_index = (active_weapon_index - 1 + available_weapons.size()) % available_weapons.size()
	current_weapon = available_weapons[active_weapon_index]
	_update_weapon_visual()
	
	var hud_nodes = get_tree().get_nodes_in_group("hud")
	for h in hud_nodes:
		if h.has_method("update_hud_display"):
			h.update_hud_display()

var ability_cooldown_timer: float = 0.0

func use_active_ability() -> void:
	if ability_cooldown_timer > 0.0:
		return

	var active_origin = SaveManager.profile_data.get("active_origin", "vanguard")
	var req_energy = 25.0
	if current_energy < req_energy:
		return

	current_energy -= req_energy
	GameManager.player_current_energy = current_energy
	EventBus.player_energy_changed.emit(current_energy, max_energy)

	match active_origin:
		"vanguard":
			ability_cooldown_timer = 4.0
			DamageNumber.create(global_position, 40, true, "SHIELD CHARGE", get_parent())
			velocity.x = facing_direction * 450.0
			is_invulnerable = true
			await get_tree().create_timer(0.25).timeout
			is_invulnerable = false
		"scout":
			ability_cooldown_timer = 3.5
			DamageNumber.create(global_position, 25, false, "FROST NOVA", get_parent())
			var enemies = get_tree().get_nodes_in_group("enemies")
			for e in enemies:
				if is_instance_valid(e) and global_position.distance_to(e.global_position) <= 96.0:
					StatusEffectManager.apply_status(e, StatusEffectManager.StatusType.FREEZE, 3.0, 15)
		"mystic":
			ability_cooldown_timer = 3.0
			DamageNumber.create(global_position, 30, true, "FLAME BURST", get_parent())
			for i in range(-1, 2):
				var proj = PROJECTILE_SCENE.instantiate() as Projectile
				proj.team = Hitbox.Team.PLAYER
				proj.damage = 30
				proj.speed = 360.0
				proj.direction = Vector2(facing_direction, i * 0.3).normalized()
				proj.global_position = global_position + Vector2(facing_direction * 14, 0)
				if get_parent(): get_parent().add_child(proj)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if Input.is_action_just_pressed("switch_weapon"):
			switch_weapon(true)
		elif Input.is_action_just_pressed("ability"):
			use_active_ability()
		elif Input.is_action_just_pressed("use_elixir"):
			_use_consumable_from_backpack("energy_elixir")
		elif event.keycode == KEY_B or Input.is_action_just_pressed("inventory"):
			_toggle_backpack_ui()

func _toggle_backpack_ui() -> void:
	var existing = get_tree().get_nodes_in_group("backpack_ui")
	if existing.size() > 0:
		existing[0].queue_free()
		return

	var bp_scene = load("res://scenes/ui/backpack_ui.tscn")
	if bp_scene:
		var bp_inst = bp_scene.instantiate()
		bp_inst.add_to_group("backpack_ui")
		var stage = get_parent()
		if stage: stage.add_child(bp_inst)

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
		_handle_crouch_input()
		_handle_jump(delta)
		_handle_movement(delta)
		_handle_dash_input()
		_handle_attack_input()

	move_and_slide()

var is_crouching: bool = false

func _handle_crouch_input() -> void:
	if Input.is_physical_key_pressed(KEY_CTRL) or Input.is_action_pressed("move_down"):
		if not is_crouching:
			is_crouching = true
			if visual:
				visual.scale.y = 0.65
				visual.position.y = -6
	else:
		if is_crouching:
			is_crouching = false
			if visual:
				visual.scale.y = 1.0
				visual.position.y = -12

func _update_timers(delta: float) -> void:
	if is_on_floor():
		coyote_timer = coyote_time
		jumps_left = max_jumps
	else:
		coyote_timer = maxf(0.0, coyote_timer - delta)

	jump_buffer_timer = maxf(0.0, jump_buffer_timer - delta)
	dash_cooldown_timer = maxf(0.0, dash_cooldown_timer - delta)
	attack_cooldown_timer = maxf(0.0, attack_cooldown_timer - delta)
	ability_cooldown_timer = maxf(0.0, ability_cooldown_timer - delta)
	
	if buff_timer > 0.0:
		buff_timer -= delta
		if buff_timer <= 0.0:
			temp_bonus_defense = 0
			temp_bonus_attack = 0
			temp_bonus_speed = 0.0
			DamageNumber.create(global_position, 0, false, "BUFF EXPIRED", get_parent())

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)

func _handle_movement(delta: float) -> void:
	var move_input = Input.get_axis("move_left", "move_right")

	if move_input != 0.0:
		facing_direction = 1 if move_input > 0 else -1
		# Flip player visual
		scale.x = abs(scale.x) * facing_direction
		var current_speed = move_speed + temp_bonus_speed
		if is_crouching:
			current_speed *= 0.5
		velocity.x = move_toward(velocity.x, move_input * current_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)

func _handle_jump(_delta: float) -> void:
	# Drop down through one-way platforms when pressing Down (S or Down Arrow)
	# if Input.is_action_just_pressed("move_down") or Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
	# 	if is_on_floor():
	# 		position.y += 3.0
	# 		return

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time

	if jump_buffer_timer > 0.0:
		if is_on_floor() or coyote_timer > 0.0:
			_execute_jump()
		else: # Air jump (Infinite jumps)
			_execute_jump()

func _execute_jump() -> void:
	velocity.y = jump_force
	jumps_left -= 1
	coyote_timer = 0.0
	jump_buffer_timer = 0.0
	_play_sfx("jump")

func _handle_dash_input() -> void:
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0.0 and current_energy >= 15.0:
		is_dashing = true
		is_invulnerable = true
		dash_timer = dash_duration
		dash_cooldown_timer = dash_cooldown
		current_energy = maxf(0.0, current_energy - 15.0)
		EventBus.player_energy_changed.emit(current_energy, max_energy)
		_play_sfx("dash")

func _play_sfx(sfx_name: String) -> void:
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_sfx"):
		am.play_sfx(sfx_name)

func _perform_dash(delta: float) -> void:
	dash_timer -= delta
	velocity.x = facing_direction * dash_speed
	velocity.y = 0.0

	if dash_timer <= 0.0:
		is_dashing = false
		is_invulnerable = false

func _handle_attack_input() -> void:
	if Input.is_action_just_pressed("attack") and attack_cooldown_timer <= 0.0:
		var speed = current_weapon.get_modified_attack_speed() if current_weapon else 1.5
		attack_cooldown_timer = 1.0 / maxf(0.1, speed)
		_execute_attack()

const PROJECTILE_SCENE = preload("res://scenes/weapons/projectile.tscn")

func _execute_attack() -> void:
	if current_weapon == null:
		current_weapon = WeaponData.new()

	current_player_state = PlayerState.ATTACKING

	# Phase 1: Wind-up (0.08s preparation)
	if visual:
		visual.modulate = Color(1.0, 0.9, 0.4, 1.0)
	await get_tree().create_timer(0.08).timeout
	if not is_instance_valid(self): return

	# Phase 2 & 3: Active Frame & Hit Detection (0.15s)
	if attack_hitbox:
		attack_hitbox.damage = current_weapon.get_modified_damage() + bonus_attack_stat + temp_bonus_attack
		attack_hitbox.critical_chance = current_weapon.get_modified_critical_chance()
		attack_hitbox.critical_multiplier = current_weapon.critical_multiplier
		attack_hitbox.knockback_force = current_weapon.get_modified_knockback()
		attack_hitbox.damage_type = current_weapon.damage_type

	# Mouse Aim Direction Vector
	var mouse_pos = get_global_mouse_position()
	var spawn_y_off = -4.0 if is_crouching else -10.0
	var origin_pos = global_position + Vector2(0, spawn_y_off)
	var aim_dir = (mouse_pos - origin_pos).normalized()
	if aim_dir.length_squared() < 0.01:
		aim_dir = Vector2(facing_direction, 0)

	# Flip facing direction towards mouse position on attack
	facing_direction = 1 if mouse_pos.x >= global_position.x else -1
	scale.x = abs(scale.x) * facing_direction

	if current_weapon.category == WeaponData.WeaponCategory.MELEE:
		var proj = PROJECTILE_SCENE.instantiate() as Projectile
		proj.team = Hitbox.Team.PLAYER
		proj.damage = current_weapon.get_modified_damage() + bonus_attack_stat + temp_bonus_attack
		proj.speed = 400.0 # Fast melee slash
		proj.max_range = current_weapon.attack_range
		if proj.max_range <= 0.0: proj.max_range = 60.0
		proj.direction = aim_dir
		proj.damage_type = current_weapon.damage_type
		proj.global_position = origin_pos + aim_dir * 14.0
		# Make the visual look like a melee wave
		var v = proj.find_child("Visual", true, false)
		if v: v.modulate = Color(1.0, 0.5, 0.2, 1.0) # Slash color
		
		var stage = get_parent()
		if stage: stage.add_child(proj)
	else:
		var proj = PROJECTILE_SCENE.instantiate() as Projectile
		proj.team = Hitbox.Team.PLAYER
		proj.damage = current_weapon.get_modified_damage() + bonus_attack_stat + temp_bonus_attack
		var p_speed = current_weapon.get_modified_projectile_speed()
		proj.speed = p_speed if p_speed > 0 else 380.0
		proj.direction = aim_dir
		proj.damage_type = current_weapon.damage_type
		proj.global_position = origin_pos + aim_dir * 14.0
		var stage = get_parent()
		if stage: stage.add_child(proj)

	# Phase 4: Recovery (0.08s recovery)
	await get_tree().create_timer(0.08).timeout
	if not is_instance_valid(self): return
	if visual:
		visual.modulate = Color(1.0, 1.0, 1.0, 1.0)
	current_player_state = PlayerState.IDLE

func _update_attack_hitbox(delta: float) -> void:
	if attack_active_timer > 0.0:
		attack_active_timer -= delta
		if attack_active_timer <= 0.0 and hitbox_shape:
			hitbox_shape.disabled = true

func _update_hurt_flash(delta: float) -> void:
	if hurt_flash_timer > 0.0:
		hurt_flash_timer -= delta
		if visual:
			# Flash red/normal
			if int(hurt_flash_timer * 20) % 2 == 0:
				visual.modulate = Color(1.0, 0.2, 0.2, 1.0)
			else:
				visual.modulate = Color(1.0, 1.0, 1.0, 1.0)
		if hurt_flash_timer <= 0.0 and visual:
			visual.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_hit_received(damage: int, _is_crit: bool, _damage_type: String, knockback_vector: Vector2) -> void:
	if is_invulnerable or current_hp <= 0:
		return
	take_damage(damage, knockback_vector)

func take_damage(amount: int, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if is_invulnerable or current_hp <= 0:
		return

	var net_damage = max(1, amount - (total_defense + temp_bonus_defense))
	current_hp = max(0, current_hp - net_damage)
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
