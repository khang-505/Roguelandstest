# scripts/combat/projectile.gd
class_name Projectile
extends Area2D

## Data-Driven Projectile Entity supporting 14 Projectile Types, ownership rules, damage calculations, homing/bouncing/piercing/chain physics, explosions, and object pooling.

@export var data: Resource # ProjectileData

# Ownership & Team Tracking
var owner_node: Node = null
var owner_type: String = "PLAYER" # "PLAYER", "ENEMY", "BOSS", "ENVIRONMENT"
var team: int = 0 # 0 = PLAYER, 1 = ENEMY, 2 = NEUTRAL
var source_weapon: Resource = null
var source_ability: Resource = null
var source_enemy: Resource = null

# Physics & Motion State
var velocity: Vector2 = Vector2.RIGHT
var current_speed: float = 400.0
var distance_traveled: float = 0.0
var lifetime_remaining: float = 3.0
var is_returning: bool = false
var homing_target: Node2D = null

# Hit & Continuation Registry
var already_hit_targets: Array = []
var hit_count: int = 0
var bounce_count_remaining: int = 0
var chain_count_remaining: int = 0

# Signals
signal hit_target(target: Node, damage: float, is_crit: bool)
signal projectile_exploded(center: Vector2, radius: float)
signal projectile_expired()

@onready var hitbox: Hitbox = $Hitbox if has_node("Hitbox") else null

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func init_projectile(
	p_data: Resource,
	p_pos: Vector2,
	p_dir: Vector2,
	p_owner: Node = null,
	p_team: int = 0
) -> void:
	data = p_data
	owner_node = p_owner
	team = p_team
	global_position = p_pos
	
	already_hit_targets.clear()
	hit_count = 0
	distance_traveled = 0.0
	is_returning = false
	homing_target = null
	
	if data:
		var dir_norm = p_dir.normalized()
		if dir_norm == Vector2.ZERO:
			dir_norm = Vector2.RIGHT
			
		# Apply spread angle if defined
		if data.spread > 0.0:
			var rand_angle = randf_range(-data.spread * 0.5, data.spread * 0.5)
			dir_norm = dir_norm.rotated(rand_angle)
			
		current_speed = data.speed
		velocity = dir_norm * current_speed
		lifetime_remaining = data.lifetime
		bounce_count_remaining = data.bounce_count
		chain_count_remaining = data.chain_count
	else:
		current_speed = 400.0
		velocity = p_dir.normalized() * current_speed
		lifetime_remaining = 3.0

func _physics_process(delta: float) -> void:
	if not data:
		_simple_move(delta)
		return
		
	lifetime_remaining -= delta
	if lifetime_remaining <= 0.0:
		_on_expiration()
		return
		
	# 1. Trajectory Physics Updates per ProjectileType
	var p_type = data.projectile_type
	
	# Speed Acceleration & Drag
	if data.acceleration != 0.0:
		current_speed = clamp(current_speed + data.acceleration * delta, 0.0, data.max_speed)
		velocity = velocity.normalized() * current_speed
		
	if data.drag > 0.0:
		current_speed = max(0.0, current_speed - data.drag * delta)
		velocity = velocity.normalized() * current_speed

	match p_type:
		ProjectileData.ProjectileType.ARC, ProjectileData.ProjectileType.DROPPED:
			velocity.y += data.gravity * delta
		ProjectileData.ProjectileType.HOMING:
			_update_homing(delta)
		ProjectileData.ProjectileType.RETURNING:
			_update_returning(delta)

	var move_step = velocity * delta
	global_position += move_step
	distance_traveled += move_step.length()
	
	if distance_traveled >= data.max_range:
		if p_type == ProjectileData.ProjectileType.RETURNING and not is_returning:
			is_returning = true
		else:
			_on_expiration()
			return

	queue_redraw()

func _simple_move(delta: float) -> void:
	var move_step = velocity * delta
	global_position += move_step
	distance_traveled += move_step.length()
	if distance_traveled >= 500.0:
		queue_free()

func _update_homing(delta: float) -> void:
	if not is_instance_valid(homing_target):
		_find_homing_target()
		if not is_instance_valid(homing_target):
			return
			
	var target_pos = homing_target.global_position if homing_target.has_method("get_global_position") else homing_target.position
	var target_dir = (target_pos - global_position).normalized()
	
	var current_dir = velocity.normalized()
	var new_dir = current_dir.slerp(target_dir, clamp(data.turn_rate * delta, 0.0, 1.0)).normalized()
	velocity = new_dir * current_speed

func _find_homing_target() -> void:
	var targets = get_tree().get_nodes_in_group("enemies" if team == 0 else "player")
	var best_dist = 400.0 # Search radius
	var best_node = null
	
	for t in targets:
		if is_instance_valid(t) and t != owner_node:
			var t_pos = t.global_position if t.has_method("get_global_position") else t.position
			var d = global_position.distance_to(t_pos)
			if d < best_dist:
				best_dist = d
				best_node = t
	homing_target = best_node

func _update_returning(delta: float) -> void:
	if not is_instance_valid(owner_node):
		return
	var owner_pos = owner_node.global_position if owner_node.has_method("get_global_position") else owner_node.position
	var return_dir = (owner_pos - global_position).normalized()
	velocity = return_dir * current_speed
	
	if global_position.distance_to(owner_pos) <= 20.0 and is_returning:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		var hurtbox = area as Hurtbox
		if hurtbox.team != team:
			_process_impact(area.get_parent() if area.get_parent() else area)

func _on_body_entered(body: Node2D) -> void:
	if body == owner_node and not is_returning:
		return
	if body.is_in_group("player") and team == 0 and not is_returning:
		return
		
	if body.is_in_group("enemies") or body.is_in_group("player") or body.has_method("take_damage"):
		_process_impact(body)
	elif body is TileMap or body is StaticBody2D or body.is_in_group("terrain"):
		_process_terrain_impact(body)

func _process_impact(target: Node) -> void:
	if not is_instance_valid(target) or already_hit_targets.has(target):
		return
		
	already_hit_targets.append(target)
	hit_count += 1
	
	# Damage Calculation Pipeline
	var base_dmg = data.damage if data else 20.0
	var crit_roll = (randf() <= (data.crit_chance if data else 0.1))
	var final_dmg = base_dmg * (data.crit_multiplier if (data and crit_roll) else 1.0)
	
	var dmg_script = load("res://scripts/combat/damage_calculator.gd")
	if dmg_script:
		var calc_res = dmg_script.calculate_damage(final_dmg, 0.0, data.damage_type if data else "ENERGY", 0.0, 0.0)
		final_dmg = calc_res.get("final_damage", final_dmg)
		
	if target.has_method("take_damage"):
		target.take_damage(final_dmg)
		
	if target.has_method("apply_knockback") and data:
		var knock_dir = velocity.normalized()
		target.apply_knockback(knock_dir * data.knockback)
		
	if target.has_method("apply_status_effect") and data:
		for status in data.status_effects:
			target.apply_status_effect(status, 3.0)
			
	emit_signal("hit_target", target, final_dmg, crit_roll)
	
	# Explosion Check
	if data and data.explosion_radius > 0.0:
		_trigger_explosion()
		
	# Piercing / Continuation Check
	if data and data.piercing and hit_count < data.max_hits:
		return # Continue trajectory
		
	# Chain Jump Check
	if data and chain_count_remaining > 0:
		chain_count_remaining -= 1
		_chain_to_next_target(target)
		return
		
	if not data or data.destroy_on_hit:
		_on_expiration()

func _process_terrain_impact(body: Node2D) -> void:
	# Bouncing Check
	if data and bounce_count_remaining > 0:
		bounce_count_remaining -= 1
		velocity = velocity.bounce(Vector2.UP if velocity.y > 0 else Vector2.RIGHT)
		return
		
	# Breakable Check
	if body.has_method("destroy"):
		body.destroy()
	elif body.has_method("take_damage"):
		body.take_damage(data.damage if data else 20.0)
		
	if data and data.explosion_radius > 0.0:
		_trigger_explosion()
		
	_on_expiration()

func _chain_to_next_target(current_target: Node) -> void:
	var candidates = get_tree().get_nodes_in_group("enemies" if team == 0 else "player")
	var next_node = null
	var best_dist = 300.0
	
	for c in candidates:
		if is_instance_valid(c) and c != current_target and not already_hit_targets.has(c):
			var c_pos = c.global_position if c.has_method("get_global_position") else c.position
			var d = global_position.distance_to(c_pos)
			if d < best_dist:
				best_dist = d
				next_node = c
				
	if next_node:
		var n_pos = next_node.global_position if next_node.has_method("get_global_position") else next_node.position
		velocity = (n_pos - global_position).normalized() * current_speed
	else:
		_on_expiration()

func _trigger_explosion() -> void:
	if not data:
		return
	var exp_script = load("res://scripts/combat/explosion_engine.gd")
	if exp_script:
		var targets = get_tree().get_nodes_in_group("enemies" if team == 0 else "player")
		var breakables = get_tree().get_nodes_in_group("breakables")
		exp_script.trigger_explosion(
			global_position,
			data.explosion_radius,
			data.explosion_damage,
			data.knockback,
			data.status_effects,
			team,
			targets,
			breakables
		)
		emit_signal("projectile_exploded", global_position, data.explosion_radius)

func _on_expiration() -> void:
	emit_signal("projectile_expired")
	queue_free()

func _draw() -> void:
	var color = Color.AQUA
	if data:
		match data.damage_type:
			"FIRE": color = Color.ORANGE_RED
			"ICE": color = Color.CYAN
			"PHYSICAL": color = Color.WHITE
			"ELECTRIC": color = Color.YELLOW
			"POISON": color = Color.LIME_GREEN
	draw_circle(Vector2.ZERO, 4.0, color)
