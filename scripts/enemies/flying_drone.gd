# scripts/enemies/flying_drone.gd
class_name FlyingDrone
extends EnemyBase

## Flying Ranged enemy archetype hovering above target and strafing with projectiles.

const PROJECTILE_SCENE = preload("res://scenes/weapons/projectile.tscn")

@export var hover_height: float = 70.0

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return

	state_timer -= delta
	_update_hurt_flash(delta)

	match current_state:
		State.IDLE, State.PATROL:
			velocity = velocity.lerp(Vector2.ZERO, 4.0 * delta)
			_look_for_player()
		State.CHASE:
			if target_player and is_instance_valid(target_player):
				var target_pos = target_player.global_position + Vector2(0, -hover_height)
				var dir = (target_pos - global_position).normalized()
				var speed = (enemy_data.move_speed if enemy_data else 80.0) * (1.3 if is_enraged else 1.0)
				velocity = velocity.lerp(dir * speed, 5.0 * delta)

				if global_position.distance_to(target_player.global_position) <= 160.0 and state_timer <= 0.0:
					change_state(State.TELEGRAPH)
					state_timer = 0.35
		State.TELEGRAPH:
			velocity = velocity.lerp(Vector2.ZERO, 6.0 * delta)
			if visual: visual.modulate = Color(1.0, 0.8, 0.2, 1.0)
			if state_timer <= 0.0:
				change_state(State.ATTACK)
		State.ATTACK:
			if target_player and is_instance_valid(target_player):
				_shoot_at_player()
			state_timer = 1.8 if not is_enraged else 1.1
			change_state(State.CHASE)
		State.STUNNED:
			velocity = velocity.lerp(Vector2.ZERO, 8.0 * delta)
			if state_timer <= 0.0:
				change_state(State.CHASE)

	move_and_slide()

func _shoot_at_player() -> void:
	if not target_player or not is_instance_valid(target_player):
		return

	var proj = PROJECTILE_SCENE.instantiate() as Projectile
	proj.team = Hitbox.Team.ENEMY
	proj.damage = enemy_data.touch_damage if enemy_data else 10
	proj.speed = 280.0
	proj.direction = (target_player.global_position - global_position).normalized()
	proj.global_position = global_position
	
	if get_parent():
		get_parent().add_child(proj)
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_sfx"): am.play_sfx("attack_laser")
