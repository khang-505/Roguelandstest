# scripts/enemies/exploder_bug.gd
class_name ExploderBug
extends EnemyBase

## Exploder enemy archetype charging rapidly and detonating into an explosive AoE blast.

var is_exploding: bool = false

func _process_chase_state(delta: float) -> void:
	if not target_player or not is_instance_valid(target_player):
		change_state(State.IDLE)
		return

	var dist = global_position.distance_to(target_player.global_position)
	if dist <= 36.0 and not is_exploding:
		change_state(State.TELEGRAPH)
		state_timer = 0.3 # Fast telegraph before explosion
	else:
		var dir = signf(target_player.global_position.x - global_position.x)
		var speed = (enemy_data.move_speed if enemy_data else 110.0) * (1.3 if is_enraged else 1.0)
		velocity.x = dir * speed
		scale.x = abs(scale.x) * (1 if dir >= 0 else -1)

func _process_telegraph_state(_delta: float) -> void:
	velocity.x = 0.0
	# Rapid flashing red/white
	if visual:
		visual.modulate = Color(1.0, 0.1, 0.1, 1.0) if int(state_timer * 30) % 2 == 0 else Color(1.0, 1.0, 1.0, 1.0)
	if state_timer <= 0.0:
		change_state(State.ATTACK)

func _process_attack_state(_delta: float) -> void:
	if not is_exploding:
		_detonate()

func _detonate() -> void:
	is_exploding = true
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_sfx"): am.play_sfx("explosion")
	
	# AoE Damage check around explosion center
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		if is_instance_valid(p) and global_position.distance_to(p.global_position) <= 72.0:
			if p.has_method("take_damage"):
				var dmg = enemy_data.touch_damage * 2 if enemy_data else 25
				var kb = (p.global_position - global_position).normalized() * 250.0
				p.take_damage(dmg, kb)

	EventBus.damage_dealt.emit(global_position, 0, true, "EXPLOSION!")
	_die()
