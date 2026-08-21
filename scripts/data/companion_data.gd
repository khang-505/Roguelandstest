# scripts/data/companion_data.gd
class_name CompanionData
extends Resource

enum Type { MINER, COMBAT, SUPPORT }

@export var companion_id: String = "miner_drone"
@export var display_name: String = "Miner Drone Mk1"
@export var type: Type = Type.MINER
@export var move_speed: float = 180.0
@export var follow_distance: float = 32.0
@export var activation_range: float = 140.0
@export var cooldown: float = 3.0
@export var power_level: int = 1
