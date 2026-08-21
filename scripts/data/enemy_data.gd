# scripts/data/enemy_data.gd
class_name EnemyData
extends Resource

enum EnemyTier { TRASH, NORMAL, ELITE, MINI_BOSS, BOSS }

@export var id: String = "ash_beetle"
@export var display_name: String = "Ash Beetle"
@export var tier: EnemyTier = EnemyTier.NORMAL
@export var max_hp: int = 45
@export var move_speed: float = 65.0
@export var touch_damage: int = 12
@export var detection_radius: float = 140.0
@export var attack_range: float = 24.0
@export var attack_cooldown: float = 1.2
@export var loot_table_id: String = "ember_beetle_loot"
@export var sprite_texture: Texture2D
