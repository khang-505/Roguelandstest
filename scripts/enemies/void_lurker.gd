# scripts/enemies/void_lurker.gd
class_name VoidLurker
extends EnemyBase

## Fast ambusher enemy that deals high burst damage.

func _ready() -> void:
	if enemy_data == null:
		enemy_data = EnemyData.new()
		enemy_data.id = "void_lurker"
		enemy_data.display_name = "Void Lurker"
		enemy_data.max_hp = 25
		enemy_data.move_speed = 110.0
		enemy_data.touch_damage = 22
		enemy_data.detection_radius = 120.0
		enemy_data.attack_range = 28.0
	super._ready()
