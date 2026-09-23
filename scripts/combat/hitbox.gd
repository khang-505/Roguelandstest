# scripts/combat/hitbox.gd
class_name Hitbox
extends Area2D

## Reusable Hitbox component dealing damage, hit stop, and knockback on collision.

enum Team { PLAYER, ENEMY, NEUTRAL }

@export var team: Team = Team.PLAYER
@export var damage: int = 18
@export var attack_type: String = "LIGHT" # LIGHT, HEAVY, ULTIMATE, BOSS
@export var damage_type: String = "PHYSICAL" # PHYSICAL, FIRE, ICE, ELECTRIC, POISON, EXPLOSIVE, ENERGY
@export var critical_chance: float = 0.10
@export var critical_multiplier: float = 1.5
@export var weapon_multiplier: float = 1.0
@export var ability_multiplier: float = 1.0
@export var knockback_force: float = 140.0
@export var status_effect: String = "NONE"
@export var is_active: bool = true

func _ready() -> void:
	collision_layer = 16 if team == Team.PLAYER else 32
	collision_mask = 32 if team == Team.PLAYER else 16

func get_calculated_damage(target_armor: float = 0.0, target_element: String = "NONE", target_weight: float = 1.0) -> Dictionary:
	var calc_script = load("res://scripts/combat/damage_calculator.gd")
	if calc_script:
		var result = calc_script.calculate_damage(
			float(damage),
			attack_type,
			str(damage_type),
			critical_chance,
			critical_multiplier,
			weapon_multiplier,
			ability_multiplier,
			target_armor,
			target_element,
			target_weight
		)
		result["status_effect"] = status_effect
		return result
		
	var is_crit = (randf() < critical_chance)
	var final_damage = int(damage * (critical_multiplier if is_crit else 1.0))
	return {
		"damage": max(1, final_damage),
		"is_crit": is_crit,
		"damage_type": damage_type,
		"hit_stop_duration": 0.04,
		"knockback_force": knockback_force,
		"status_effect": status_effect
	}
