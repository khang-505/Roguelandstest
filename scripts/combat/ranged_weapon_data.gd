# scripts/combat/ranged_weapon_data.gd
class_name RangedWeaponData
extends Resource

## Data Resource defining Ranged Weapon Archetypes, Fire Modes, Trajectories, Ammo Magazines, and Energy Heat Dissipation.

enum WeaponType {
	PISTOL,
	RIFLE,
	SHOTGUN,
	BOW,
	ENERGY_WEAPON,
	LAUNCHER,
	BEAM,
	BURST_WEAPON
}

enum FireMode {
	SINGLE,
	BURST,
	AUTOMATIC,
	CHARGE,
	HOLD
}

enum TrajectoryType {
	STRAIGHT,
	ARC,
	HOMING,
	PIERCING,
	EXPLOSIVE,
	BOUNCING,
	RETURNING,
	CHAIN_LIGHTNING,
	BEAM
}

@export var weapon_id: String = ""
@export var weapon_name: String = "Ranged Weapon"
@export var weapon_type: WeaponType = WeaponType.PISTOL
@export var fire_mode: FireMode = FireMode.SINGLE
@export var trajectory_type: TrajectoryType = TrajectoryType.STRAIGHT

@export var base_damage: float = 20.0
@export var fire_rate: float = 4.0 # Shots per second
@export var effective_range: float = 500.0 # Pixels
@export var projectile_speed: float = 600.0
@export var spread_angle: float = 0.0 # Degrees
@export var pellet_count: int = 1
@export var crit_chance: float = 0.10

@export var uses_energy: bool = false
@export var magazine_capacity: int = 12
@export var reload_duration: float = 1.5 # Seconds
@export var heat_per_shot: float = 15.0 # Heat accumulation percentage
@export var cool_rate: float = 40.0 # Heat dissipation per second

@export var damage_type: String = "PHYSICAL"
@export var status_effect: String = "NONE"
@export var muzzle_sfx: String = "sfx_shot_pistol"
@export var impact_vfx_id: String = "vfx_bullet_spark"

func _init(
	p_id: String = "",
	p_name: String = "Ranged Weapon",
	p_type: WeaponType = WeaponType.PISTOL,
	p_fire: FireMode = FireMode.SINGLE,
	p_traj: TrajectoryType = TrajectoryType.STRAIGHT,
	p_dmg: float = 20.0,
	p_range: float = 500.0,
	p_mag: int = 12
) -> void:
	weapon_id = p_id
	weapon_name = p_name
	weapon_type = p_type
	fire_mode = p_fire
	trajectory_type = p_traj
	base_damage = p_dmg
	effective_range = p_range
	magazine_capacity = p_mag
