# scripts/combat/hit_reaction_data.gd
class_name HitReactionData
extends Resource

## Data Resource defining Hit Reaction parameters across 12 Reaction Types, 5 Target Weight categories, force vectors, stagger durations, wall bounce rules, and interrupt strengths.

enum ReactionType {
	LIGHT_HIT,
	HEAVY_HIT,
	STAGGER,
	KNOCKBACK,
	KNOCKDOWN,
	LAUNCH,
	AIR_HIT,
	WALL_BOUNCE,
	INTERRUPT,
	STUN,
	FREEZE,
	DEATH
}

enum TargetWeight {
	LIGHT,
	MEDIUM,
	HEAVY,
	MASSIVE,
	BOSS
}

@export var id: String = "react_light"
@export var display_name: String = "Light Hit Reaction"
@export var reaction_type: ReactionType = ReactionType.LIGHT_HIT

@export var force: float = 100.0 # Base horizontal impulse force in px/s
@export var vertical_force: float = 0.0 # Base vertical launch impulse force in px/s
@export var duration: float = 0.20 # Active hit reaction duration in seconds

@export var stagger_duration: float = 0.15 # Stagger posture window in seconds
@export var recovery_duration: float = 0.10 # Recovery transition window in seconds

@export var interrupt_strength: float = 20.0 # Stagger threshold to break poise / hyper armor

@export var airborne: bool = false # Whether target is launched airborne
@export var wall_bounce: bool = false # Whether terrain impact triggers wall bounce

@export var can_chain: bool = true # Whether target can be chained in combo
@export var can_cancel: bool = true # Whether attacker hitstop allows cancel
@export var can_interrupt: bool = true # Whether target action is interrupted

@export var mass_requirement: float = 1.0 # Target mass threshold
@export var resistance_requirement: float = 0.0 # Knockback resistance requirement

func _init(
	p_id: String = "react_light",
	p_type: ReactionType = ReactionType.LIGHT_HIT,
	p_force: float = 100.0,
	p_dur: float = 0.20
) -> void:
	id = p_id
	reaction_type = p_type
	force = p_force
	duration = p_dur

## Static Preset Builder for 12 Reaction Types
static func create_preset(p_type: ReactionType) -> Resource:
	var data = new()
	data.reaction_type = p_type
	
	match p_type:
		ReactionType.LIGHT_HIT:
			data.id = "react_light"
			data.display_name = "Light Hit"
			data.force = 100.0
			data.duration = 0.15
			data.stagger_duration = 0.10
			data.interrupt_strength = 15.0
		ReactionType.HEAVY_HIT:
			data.id = "react_heavy"
			data.display_name = "Heavy Hit"
			data.force = 220.0
			data.duration = 0.35
			data.stagger_duration = 0.25
			data.interrupt_strength = 50.0
		ReactionType.STAGGER:
			data.id = "react_stagger"
			data.display_name = "Stagger"
			data.force = 150.0
			data.duration = 0.40
			data.stagger_duration = 0.40
			data.interrupt_strength = 60.0
		ReactionType.KNOCKBACK:
			data.id = "react_knockback"
			data.display_name = "Knockback"
			data.force = 320.0
			data.duration = 0.30
			data.stagger_duration = 0.20
			data.interrupt_strength = 40.0
		ReactionType.KNOCKDOWN:
			data.id = "react_knockdown"
			data.display_name = "Knockdown"
			data.force = 250.0
			data.vertical_force = -150.0
			data.duration = 0.60
			data.stagger_duration = 0.40
			data.recovery_duration = 0.20
			data.airborne = true
		ReactionType.LAUNCH:
			data.id = "react_launch"
			data.display_name = "Launch"
			data.force = 180.0
			data.vertical_force = -450.0
			data.duration = 0.70
			data.airborne = true
			data.wall_bounce = true
		ReactionType.AIR_HIT:
			data.id = "react_air_hit"
			data.display_name = "Air Hit Juggle"
			data.force = 120.0
			data.vertical_force = -100.0
			data.duration = 0.25
			data.airborne = true
		ReactionType.WALL_BOUNCE:
			data.id = "react_wall_bounce"
			data.display_name = "Wall Bounce Impact"
			data.force = 250.0
			data.vertical_force = -200.0
			data.duration = 0.50
			data.wall_bounce = true
			data.airborne = true
		ReactionType.INTERRUPT:
			data.id = "react_interrupt"
			data.display_name = "Interrupt"
			data.force = 80.0
			data.duration = 0.25
			data.interrupt_strength = 100.0
			data.can_interrupt = true
		ReactionType.STUN:
			data.id = "react_stun"
			data.display_name = "Stun Disable"
			data.force = 0.0
			data.duration = 1.50
			data.stagger_duration = 1.50
		ReactionType.FREEZE:
			data.id = "react_freeze"
			data.display_name = "Freeze Lock"
			data.force = 0.0
			data.duration = 2.50
			data.stagger_duration = 2.50
		ReactionType.DEATH:
			data.id = "react_death"
			data.display_name = "Death Impact"
			data.force = 300.0
			data.vertical_force = -200.0
			data.duration = 1.00
			data.airborne = true
			
	return data
