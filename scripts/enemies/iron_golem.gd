# scripts/enemies/iron_golem.gd
class_name IronGolem
extends EnemyBase

## Heavy tank enemy with high HP, heavy damage, and knockback resistance.

func _ready() -> void:
	if enemy_data == null:
		enemy_data = EnemyData.new()
		enemy_data.id = "iron_golem"
		enemy_data.display_name = "Iron Golem"
		enemy_data.max_hp = 120
		enemy_data.move_speed = 35.0
		enemy_data.touch_damage = 28
		enemy_data.detection_radius = 160.0
		enemy_data.attack_range = 32.0
	super._ready()

func _on_hit_received(damage: int, is_crit: bool, damage_type: String, knockback_vector: Vector2) -> void:
	# Resists 70% knockback
	super._on_hit_received(damage, is_crit, damage_type, knockback_vector * 0.3)
