# scripts/combat/ability_data.gd
class_name AbilityData
extends Resource

## Data Resource defining Ability Metadata, Categories, Charges, Energy Costs, Targeting Types, Invulnerability i-Frames, and Mutations.

enum AbilityCategory {
	OFFENSIVE,
	DEFENSIVE,
	MOBILITY,
	CROWD_CONTROL,
	AREA_DAMAGE,
	BUFF,
	DEBUFF,
	SUMMON,
	UTILITY,
	EXPLORATION
}

enum TargetingType {
	SELF,
	DIRECTIONAL,
	GROUND_AOE,
	TARGET_ENEMY
}

@export var ability_id: String = ""
@export var ability_name: String = "Ability"
@export var description: String = "Activates a special combat or utility effect."
@export var category: AbilityCategory = AbilityCategory.OFFENSIVE
@export var targeting_type: TargetingType = TargetingType.DIRECTIONAL

@export var cooldown: float = 6.0 # Seconds
@export var max_charges: int = 1
@export var current_charges: int = 1
@export var energy_cost: float = 20.0

@export var damage: float = 50.0
@export var range_radius: float = 200.0
@export var duration: float = 3.0
@export var i_frames_duration: float = 0.0

@export var element: String = "FIRE"
@export var status_effect: String = "NONE"
@export var tags: Array = []

@export var active_mutation_id: String = "NONE"
@export var mutation_modifiers: Dictionary = {}

func _init(
	p_id: String = "",
	p_name: String = "Ability",
	p_cat: AbilityCategory = AbilityCategory.OFFENSIVE,
	p_target: TargetingType = TargetingType.DIRECTIONAL,
	p_cd: float = 6.0,
	p_cost: float = 20.0,
	p_dmg: float = 50.0
) -> void:
	ability_id = p_id
	ability_name = p_name
	category = p_cat
	targeting_type = p_target
	cooldown = p_cd
	energy_cost = p_cost
	damage = p_dmg
