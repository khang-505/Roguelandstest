# scripts/bosses/frost_stalker_alpha.gd
class_name FrostStalkerAlpha
extends BossBase

## Planet 2 Guardian Boss: Frost Stalker Alpha (Frostgrave Apex Predator).

const PROJECTILE_SCENE = preload("res://scenes/weapons/projectile.tscn")

var base_attack_cd: float = 1.8

func _ready() -> void:
	boss_id = "frost_stalker_alpha"
	display_name = "Frost Stalker Alpha"
	max_hp = 550
	current_hp = max_hp
	move_speed = 70.0
	super._ready()

func _on_phase_changed(_old_phase: BossPhase, new_phase: BossPhase) -> void:
	match new_phase:
		BossPhase.PHASE_2:
			base_attack_cd = 1.3
			move_speed = 90.0
			_trigger_blizzard_surge()
		BossPhase.PHASE_3:
			if not is_enraged:
				is_enraged = true
				base_attack_cd = 0.9
				move_speed = 120.0
				_trigger_frost_burst()

func _execute_boss_attack() -> void:
	attack_cooldown_timer = base_attack_cd
	if not target_player or not is_instance_valid(target_player):
		return

	# Ice Dash Slash or Icicle Volley
	var dist = global_position.distance_to(target_player.global_position)
	if dist <= 64.0:
		# Rapid Melee Slash + Slow
		if target_player.has_method("take_damage"):
			var dmg = 20 if not is_enraged else 32
			target_player.take_damage(dmg)
			StatusEffectManager.apply_status(target_player, StatusEffectManager.StatusType.FREEZE, 2.0, 10)
	else:
		# Icicle Volley
		for i in range(-2, 3):
			var proj = PROJECTILE_SCENE.instantiate() as Projectile
			proj.team = Hitbox.Team.ENEMY
			proj.damage = 15 if not is_enraged else 22
			proj.speed = 320.0
			var dir = (target_player.global_position - global_position).normalized()
			proj.direction = dir.rotated(i * 0.15)
			proj.global_position = global_position
			if get_parent(): get_parent().add_child(proj)

func _trigger_blizzard_surge() -> void:
	_play_sfx("boss_roar")
	if target_player and is_instance_valid(target_player):
		StatusEffectManager.apply_status(target_player, StatusEffectManager.StatusType.SLOW, 4.0, 0)

func _trigger_frost_burst() -> void:
	_play_sfx("boss_roar")
	var enemies = get_tree().get_nodes_in_group("player")
	for p in enemies:
		if is_instance_valid(p):
			StatusEffectManager.apply_status(p, StatusEffectManager.StatusType.FREEZE, 3.0, 20)

func _play_sfx(sfx_name: String) -> void:
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_sfx"):
		am.play_sfx(sfx_name)
