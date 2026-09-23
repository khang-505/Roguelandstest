# scripts/combat/status_effect_data.gd
class_name StatusEffectData
extends Resource

## Data Resource defining Status Effect metadata across 5 Categories, 6 Stacking Behaviors, DoT parameters, debuff modifiers, and visual feedback icons.

enum StatusCategory {
	DAMAGE,
	CONTROL,
	DEFENSIVE,
	OFFENSIVE,
	MARKING
}

enum StackBehavior {
	REFRESH,
	STACK,
	REPLACE,
	IGNORE,
	STRONGEST_WINS,
	EXTEND_DURATION
}

@export var id: String = "burn"
@export var display_name: String = "Burn"
@export var category: StatusCategory = StatusCategory.DAMAGE

@export var duration: float = 4.0 # Base duration in seconds
@export var tick_interval: float = 0.5 # DoT tick interval in seconds

@export var max_stacks: int = 5 # Maximum stack count cap
@export var stack_behavior: StackBehavior = StackBehavior.STACK

@export var damage_type: String = "FIRE" # Element type for DoT calculations
@export var tick_damage: float = 12.0 # Base DoT tick damage

@export var damage_multiplier: float = 1.0 # Incoming/outgoing damage multiplier
@export var movement_multiplier: float = 1.0 # Movement speed multiplier (e.g. 0.5 = 50% slow)
@export var attack_speed_multiplier: float = 1.0 # Attack speed multiplier

@export var resistance_type: String = "FIRE" # Target resistance type checking
@export var visual_effect: String = "vfx_fire_particles"
@export var audio_effect: String = "sfx_burn_loop"
@export var icon: String = "icon_burn"

func _init(
	p_id: String = "burn",
	p_name: String = "Burn",
	p_cat: StatusCategory = StatusCategory.DAMAGE,
	p_dur: float = 4.0,
	p_dmg: float = 12.0
) -> void:
	id = p_id
	display_name = p_name
	category = p_cat
	duration = p_dur
	tick_damage = p_dmg

## Static Preset Builder for signature Status Effects
static func create_preset(p_id: String) -> Resource:
	var data = new()
	data.id = p_id.to_lower()
	
	match data.id:
		"burn":
			data.display_name = "Burn"
			data.category = StatusCategory.DAMAGE
			data.duration = 4.0
			data.tick_interval = 0.5
			data.tick_damage = 12.0
			data.damage_type = "FIRE"
			data.stack_behavior = StackBehavior.STACK
			data.max_stacks = 5
		"poison":
			data.display_name = "Poison"
			data.category = StatusCategory.DAMAGE
			data.duration = 6.0
			data.tick_interval = 1.0
			data.tick_damage = 15.0
			data.damage_type = "POISON"
			data.stack_behavior = StackBehavior.STACK
			data.max_stacks = 5
		"bleed":
			data.display_name = "Bleed"
			data.category = StatusCategory.DAMAGE
			data.duration = 5.0
			data.tick_interval = 0.8
			data.tick_damage = 18.0
			data.damage_type = "PHYSICAL"
			data.stack_behavior = StackBehavior.STACK
			data.max_stacks = 5
		"shock":
			data.display_name = "Shock"
			data.category = StatusCategory.DAMAGE
			data.duration = 3.0
			data.tick_interval = 0.5
			data.tick_damage = 10.0
			data.damage_type = "ELECTRIC"
			data.stack_behavior = StackBehavior.REFRESH
			data.max_stacks = 3
		"slow":
			data.display_name = "Slow"
			data.category = StatusCategory.CONTROL
			data.duration = 3.0
			data.movement_multiplier = 0.5
			data.stack_behavior = StackBehavior.REFRESH
			data.max_stacks = 1
		"freeze":
			data.display_name = "Freeze"
			data.category = StatusCategory.CONTROL
			data.duration = 2.5
			data.movement_multiplier = 0.0
			data.attack_speed_multiplier = 0.0
			data.damage_type = "ICE"
			data.stack_behavior = StackBehavior.REPLACE
			data.max_stacks = 1
		"stun":
			data.display_name = "Stun"
			data.category = StatusCategory.CONTROL
			data.duration = 1.5
			data.movement_multiplier = 0.0
			data.attack_speed_multiplier = 0.0
			data.stack_behavior = StackBehavior.REPLACE
			data.max_stacks = 1
		"root":
			data.display_name = "Root"
			data.category = StatusCategory.CONTROL
			data.duration = 2.0
			data.movement_multiplier = 0.0
			data.stack_behavior = StackBehavior.REFRESH
			data.max_stacks = 1
		"shield":
			data.display_name = "Energy Shield"
			data.category = StatusCategory.DEFENSIVE
			data.duration = 6.0
			data.stack_behavior = StackBehavior.REFRESH
			data.max_stacks = 1
		"armor_break":
			data.display_name = "Armor Break"
			data.category = StatusCategory.OFFENSIVE
			data.duration = 5.0
			data.damage_multiplier = 1.30
			data.stack_behavior = StackBehavior.REFRESH
			data.max_stacks = 3
		"vulnerability":
			data.display_name = "Vulnerability"
			data.category = StatusCategory.OFFENSIVE
			data.duration = 4.0
			data.damage_multiplier = 1.25
			data.stack_behavior = StackBehavior.REFRESH
			data.max_stacks = 1
		"marked":
			data.display_name = "Marked"
			data.category = StatusCategory.MARKING
			data.duration = 8.0
			data.damage_multiplier = 1.20
			data.stack_behavior = StackBehavior.REFRESH
			data.max_stacks = 1
			
	return data
