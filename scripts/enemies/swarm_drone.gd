# scripts/enemies/swarm_drone.gd
class_name SwarmDrone
extends EnemyBase

## Fast low-HP swarm drone.

func _ready() -> void:
	if enemy_data == null:
		enemy_data = EnemyData.new()
		enemy_data.id = "swarm_drone"
		enemy_data.display_name = "Swarm Drone"
		enemy_data.max_hp = 15
		enemy_data.move_speed = 95.0
		enemy_data.touch_damage = 8
		enemy_data.detection_radius = 180.0
		enemy_data.attack_range = 20.0
	super._ready()
