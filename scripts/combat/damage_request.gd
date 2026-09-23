# scripts/combat/damage_request.gd
class_name DamageRequest
extends Resource

## Data Resource defining a complete, standardized Damage Request passed to the centralized DamageCalculator pipeline.

@export var source: Node = null # Attacker/Owner node reference
@export var target: Node = null # Victim target node reference

@export var base_damage: float = 20.0 # Raw base damage value
@export var damage_type: String = "PHYSICAL" # "PHYSICAL", "ENERGY", "FIRE", "ICE", "ELECTRIC", "POISON", "EXPLOSIVE", "VOID", "TRUE"
@export var attack_type: String = "MELEE_LIGHT" # "MELEE_LIGHT", "MELEE_HEAVY", "RANGED", "ABILITY", "PROJECTILE", "EXPLOSION", "HAZARD", "DOT"

@export var weapon_id: String = "" # Source weapon ID if applicable
@export var ability_id: String = "" # Source ability ID if applicable
@export var projectile_id: String = "" # Source projectile ID if applicable

@export var critical_chance: float = 0.10 # Base crit probability (0.0 to 1.0)
@export var critical_multiplier: float = 1.5 # Crit damage multiplier
@export var critical_bonus: float = 0.0 # Flat bonus added to crit chance

@export var armor_penetration: float = 0.0 # Flat armor ignored
@export var resistance_penetration: float = 0.0 # Percentage elemental resistance ignored (0.0 to 1.0)

@export var knockback: float = 50.0 # Base knockback force
@export var stagger: float = 10.0 # Stagger posture damage

@export var status_effects: Array = [] # Status effects applied on successful hit
@export var flags: Dictionary = {} # Conditional flags: is_airborne_target, is_frozen_target, is_marked_target, is_full_health_target, is_rear_attack, is_after_dash, guaranteed_crit

func _init(
	p_base_damage: float = 20.0,
	p_damage_type: String = "PHYSICAL",
	p_attack_type: String = "MELEE_LIGHT",
	p_crit_chance: float = 0.10,
	p_crit_multiplier: float = 1.5
) -> void:
	base_damage = p_base_damage
	damage_type = p_damage_type
	attack_type = p_attack_type
	critical_chance = p_crit_chance
	critical_multiplier = p_crit_multiplier

## Sets a conditional critical flag (e.g. "is_frozen_target", true)
func set_flag(flag_name: String, value: bool = true) -> void:
	flags[flag_name] = value

## Returns flag value or false
func get_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false)
