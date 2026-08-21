# scripts/combat/hitbox.gd
class_name Hitbox
extends Area2D

## Reusable Hitbox component dealing damage and knockback on collision.

enum Team { PLAYER, ENEMY, NEUTRAL }

@export var team: Team = Team.PLAYER
@export var damage: int = 18
@export var critical_chance: float = 0.10
@export var critical_multiplier: float = 1.5
@export var knockback_force: float = 140.0
@export var damage_type: WeaponData.DamageType = WeaponData.DamageType.PHYSICAL
@export var is_active: bool = true

func _ready() -> void:
	collision_layer = 16 if team == Team.PLAYER else 32
	collision_mask = 32 if team == Team.PLAYER else 16

func get_calculated_damage() -> Dictionary:
	var is_crit = (randf() < critical_chance)
	var final_damage = int(damage * (critical_multiplier if is_crit else 1.0))
	return {
		"damage": max(1, final_damage),
		"is_crit": is_crit,
		"damage_type": damage_type,
		"knockback": knockback_force
	}
