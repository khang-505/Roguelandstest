# scripts/procedural/elite_affix.gd
class_name EliteAffix
extends Resource

## Data Resource defining Elite Affixes, difficulty costs, visual telegraphs, and stat/behavior modifiers.

enum AffixType {
	FAST,
	ARMORED,
	REGENERATING,
	EXPLOSIVE,
	VAMPIRIC,
	SHIELDED,
	TELEPORTING,
	BERSERKER,
	SUMMONER,
	REFLECTIVE,
	FROZEN,
	BURNING,
	POISONOUS,
	ELECTRIC,
	SPLIT
}

@export var affix_id: String = ""
@export var affix_name: String = "Elite Affix"
@export var affix_type: AffixType = AffixType.FAST
@export var difficulty_cost: int = 2
@export var visual_color: Color = Color.YELLOW
@export var sound_id: String = "sfx_affix_generic"
@export var incompatible_affixes: Array = []

@export var health_multiplier: float = 1.0
@export var damage_multiplier: float = 1.0
@export var speed_multiplier: float = 1.0
@export var Granted_behavior: String = ""
@export var element_type: String = "NONE" # NONE, FIRE, ICE, ELECTRIC, POISON, PHYSICAL

func _init(
	p_id: String = "",
	p_name: String = "Elite Affix",
	p_type: AffixType = AffixType.FAST,
	p_cost: int = 2,
	p_color: Color = Color.YELLOW,
	p_incompatible: Array = [],
	p_hp_mult: float = 1.0,
	p_dmg_mult: float = 1.0,
	p_spd_mult: float = 1.0,
	p_behavior: String = "",
	p_element: String = "NONE"
) -> void:
	affix_id = p_id
	affix_name = p_name
	affix_type = p_type
	difficulty_cost = p_cost
	visual_color = p_color
	incompatible_affixes = p_incompatible
	health_multiplier = p_hp_mult
	damage_multiplier = p_dmg_mult
	speed_multiplier = p_spd_mult
	Granted_behavior = p_behavior
	element_type = p_element
