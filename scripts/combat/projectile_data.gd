# scripts/combat/projectile_data.gd
class_name ProjectileData
extends Resource

## Data Resource defining data-driven projectile parameters across all 14 Projectile Types, ownership rules, damage pipelines, trajectory physics, and visual feedback.

enum ProjectileType {
	BASIC,
	FAST,
	SLOW,
	ARC,
	HOMING,
	PIERCING,
	BOUNCING,
	EXPLOSIVE,
	CHAIN,
	RETURNING,
	BEAM,
	BURST,
	SPREAD,
	DROPPED
}

enum OwnershipType {
	PLAYER,
	ENEMY,
	BOSS,
	ENVIRONMENT
}

@export var id: String = "proj_basic"
@export var display_name: String = "Basic Energy Bolt"
@export var projectile_type: ProjectileType = ProjectileType.BASIC

@export var speed: float = 400.0 # Velocity in px/s
@export var acceleration: float = 0.0 # Velocity rate of change in px/s^2
@export var max_speed: float = 800.0 # Speed cap
@export var lifetime: float = 3.0 # Expiration duration in seconds

@export var gravity: float = 0.0 # Downward acceleration px/s^2
@export var drag: float = 0.0 # Friction drag factor
@export var homing_strength: float = 300.0 # Steering acceleration for HOMING type
@export var turn_rate: float = 3.14 # Max radians per second turn speed for HOMING

@export var direction: Vector2 = Vector2.RIGHT # Normalized initial trajectory direction
@export var spread: float = 0.0 # Angular variance in radians
@export var max_range: float = 500.0 # Maximum travel distance cap in px

@export var damage: float = 20.0 # Base impact damage
@export var crit_chance: float = 0.10 # Critical hit probability (0.0 to 1.0)
@export var crit_multiplier: float = 1.5 # Damage multiplier on crit roll
@export var damage_type: String = "ENERGY" # "PHYSICAL", "ENERGY", "FIRE", "ICE", "POISON", "ELECTRIC"

@export var piercing: bool = false # Whether projectile passes through targets
@export var max_hits: int = 1 # Max target hits before destruction
@export var bounce_count: int = 0 # Max terrain/surface bounces remaining
@export var chain_count: int = 0 # Max target chain jumps remaining

@export var explosion_radius: float = 0.0 # Radius for EXPLOSIVE type in px
@export var explosion_damage: float = 0.0 # Explosive area damage

@export var knockback: float = 50.0 # Knockback impulse force
@export var stagger: float = 10.0 # Posture/stagger impact

@export var status_effects: Array = [] # Array of status effect IDs (e.g., ["BURN", "SLOW"])

@export var collision_layers: int = 1 # Physics collision layer
@export var collision_masks: int = 2 # Physics collision mask
@export var friendly_fire: bool = false # Whether projectile hits same team entities
@export var destroy_on_hit: bool = true # Whether destroyed on non-piercing contact

@export var trail_vfx: String = "trail_plasma"
@export var impact_vfx: String = "impact_spark"
@export var spawn_sfx: String = "sfx_laser_fire"
@export var impact_sfx: String = "sfx_laser_hit"

func _init(
	p_id: String = "proj_basic",
	p_name: String = "Basic Energy Bolt",
	p_type: ProjectileType = ProjectileType.BASIC,
	p_speed: float = 400.0,
	p_damage: float = 20.0
) -> void:
	id = p_id
	display_name = p_name
	projectile_type = p_type
	speed = p_speed
	damage = p_damage

## Preset Constructor for 14 Projectile Types
static func create_preset(p_type: ProjectileType) -> Resource:
	var data = new()
	data.projectile_type = p_type
	
	match p_type:
		ProjectileType.BASIC:
			data.id = "proj_basic"
			data.display_name = "Plasma Bolt"
			data.speed = 450.0
			data.damage = 25.0
		ProjectileType.FAST:
			data.id = "proj_fast"
			data.display_name = "Sniper Needle"
			data.speed = 900.0
			data.lifetime = 1.5
			data.damage = 40.0
		ProjectileType.SLOW:
			data.id = "proj_slow"
			data.display_name = "Heavy Plasma Orb"
			data.speed = 180.0
			data.damage = 60.0
			data.knockback = 120.0
		ProjectileType.ARC:
			data.id = "proj_arc"
			data.display_name = "Lobbed Grenade"
			data.speed = 350.0
			data.gravity = 400.0
			data.damage = 30.0
		ProjectileType.HOMING:
			data.id = "proj_homing"
			data.display_name = "Seeker Missile"
			data.speed = 320.0
			data.homing_strength = 450.0
			data.turn_rate = 4.0
			data.damage = 35.0
		ProjectileType.PIERCING:
			data.id = "proj_piercing"
			data.display_name = "Penetrator Ray"
			data.speed = 600.0
			data.piercing = true
			data.max_hits = 4
			data.destroy_on_hit = false
			data.damage = 30.0
		ProjectileType.BOUNCING:
			data.id = "proj_bouncing"
			data.display_name = "Ricochet Round"
			data.speed = 500.0
			data.bounce_count = 3
			data.destroy_on_hit = false
			data.damage = 25.0
		ProjectileType.EXPLOSIVE:
			data.id = "proj_explosive"
			data.display_name = "High-Explosive Shell"
			data.speed = 400.0
			data.explosion_radius = 120.0
			data.explosion_damage = 50.0
			data.damage = 20.0
		ProjectileType.CHAIN:
			data.id = "proj_chain"
			data.display_name = "Tesla Chain Arc"
			data.speed = 550.0
			data.chain_count = 3
			data.damage_type = "ELECTRIC"
			data.damage = 22.0
		ProjectileType.RETURNING:
			data.id = "proj_returning"
			data.display_name = "Glaive Boomerang"
			data.speed = 450.0
			data.max_range = 300.0
			data.damage = 30.0
		ProjectileType.BEAM:
			data.id = "proj_beam"
			data.display_name = "Continuous Laser Beam"
			data.speed = 1200.0
			data.lifetime = 0.5
			data.damage = 15.0
			data.damage_type = "ENERGY"
		ProjectileType.BURST:
			data.id = "proj_burst"
			data.display_name = "Cluster Shell"
			data.speed = 380.0
			data.damage = 35.0
		ProjectileType.SPREAD:
			data.id = "proj_spread"
			data.display_name = "Shotgun Pellets"
			data.speed = 520.0
			data.spread = 0.35
			data.damage = 18.0
		ProjectileType.DROPPED:
			data.id = "proj_dropped"
			data.display_name = "Orbital Air Strike"
			data.speed = 600.0
			data.gravity = 800.0
			data.direction = Vector2.DOWN
			data.damage = 70.0
			
	return data
