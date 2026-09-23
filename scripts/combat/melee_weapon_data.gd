# scripts/combat/melee_weapon_data.gd
class_name MeleeWeaponData
extends Resource

## Data Resource defining Melee Weapon Archetypes, Hitbox Arcs, Stagger Power, Armor Break, and Special Effects.

enum WeaponType {
	SWORD,
	HAMMER,
	SPEAR,
	DUAL_BLADES
}

enum HitboxShape {
	ARC,
	RECTANGLE,
	BROAD_AREA,
	FAST_SHORT
}

@export var weapon_id: String = ""
@export var weapon_name: String = "Melee Weapon"
@export var weapon_type: WeaponType = WeaponType.SWORD
@export var hitbox_shape: HitboxShape = HitboxShape.ARC

@export var base_damage: float = 25.0
@export var attack_speed: float = 1.0 # Multiplier
@export var attack_range: float = 60.0 # Pixels
@export var hitbox_width: float = 50.0
@export var hitbox_height: float = 60.0

@export var knockback_force: float = 140.0
@export var stagger_power: float = 30.0
@export var armor_break_power: float = 20.0
@export var combo_count: int = 3

@export var damage_type: String = "PHYSICAL"
@export var status_effect: String = "NONE"
@export var whiff_sfx: String = "sfx_swing_sword"
@export var hit_sfx: String = "sfx_hit_metal"

func _init(
	p_id: String = "",
	p_name: String = "Melee Weapon",
	p_type: WeaponType = WeaponType.SWORD,
	p_shape: HitboxShape = HitboxShape.ARC,
	p_dmg: float = 25.0,
	p_range: float = 60.0,
	p_stagger: float = 30.0,
	p_armor_break: float = 20.0
) -> void:
	weapon_id = p_id
	weapon_name = p_name
	weapon_type = p_type
	hitbox_shape = p_shape
	base_damage = p_dmg
	attack_range = p_range
	stagger_power = p_stagger
	armor_break_power = p_armor_break
