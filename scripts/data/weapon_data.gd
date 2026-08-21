# scripts/data/weapon_data.gd
class_name WeaponData
extends Resource

enum WeaponCategory { MELEE, RANGED, ENERGY, SPECIAL }
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, MYTHIC }
enum DamageType { PHYSICAL, ENERGY, FIRE, ICE, ELECTRIC, VOID, POISON, EXPLOSIVE }

@export var id: String = "plasma_cutter"
@export var display_name: String = "Plasma Cutter"
@export var category: WeaponCategory = WeaponCategory.MELEE
@export var rarity: Rarity = Rarity.COMMON
@export var damage_type: DamageType = DamageType.PHYSICAL
@export var base_damage: int = 18
@export var attack_speed: float = 1.5 # attacks per second
@export var attack_range: float = 32.0
@export var critical_chance: float = 0.10 # 10%
@export var critical_multiplier: float = 1.5
@export var knockback_force: float = 120.0
@export var energy_cost: float = 0.0
@export var projectile_speed: float = 350.0
@export var sprite_texture: Texture2D
