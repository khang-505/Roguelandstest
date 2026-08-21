# scripts/enemies/ash_beetle.gd
class_name AshBeetle
extends EnemyBase

## Original Emberwild Biome Enemy: Ash Beetle. Fast, subterranean insect.

func _ready() -> void:
	if enemy_data == null:
		enemy_data = EnemyData.new()
		enemy_data.id = "ash_beetle"
		enemy_data.display_name = "Ash Beetle"
		enemy_data.max_hp = 45
		enemy_data.touch_damage = 12
		enemy_data.move_speed = 65.0
	super._ready()
