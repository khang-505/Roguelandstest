# scripts/enemies/frost_stalker.gd
class_name FrostStalker
extends EnemyBase

## Ranged Frostgrave enemy shooting Ice projectiles from range.

const PROJECTILE_SCENE = preload("res://scenes/weapons/projectile.tscn")

func _ready() -> void:
	if enemy_data == null:
		enemy_data = EnemyData.new()
		enemy_data.id = "frost_stalker"
		enemy_data.display_name = "Frost Stalker"
		enemy_data.max_hp = 35
		enemy_data.move_speed = 50.0
		enemy_data.attack_range = 160.0
		enemy_data.attack_cooldown = 2.0
		enemy_data.detection_radius = 200.0
	super._ready()

func _process_attack_state(_delta: float) -> void:
	velocity.x = 0.0
	if state_timer <= 0.0:
		if target_player and is_instance_valid(target_player):
			var dir = (target_player.global_position - global_position).normalized()
			var proj = PROJECTILE_SCENE.instantiate() as Projectile
			proj.team = Hitbox.Team.ENEMY
			proj.damage = 15
			proj.speed = 220.0
			proj.direction = dir
			proj.damage_type = WeaponData.DamageType.ICE
			proj.global_position = global_position
			get_parent().add_child(proj)
		state_timer = enemy_data.attack_cooldown
		change_state(State.CHASE)
