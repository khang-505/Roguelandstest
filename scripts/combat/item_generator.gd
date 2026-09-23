# scripts/combat/item_generator.gd
class_name ItemGenerator
extends RefCounted

## Equipment & Item Generator creating data-driven base stats, rarity scaling, affix prefixes/suffixes, and build synergy tags.

const RARITY_MULTIPLIERS: Dictionary = {
	0: 1.0,  # COMMON
	1: 1.25, # UNCOMMON
	2: 1.60, # RARE
	3: 2.00, # EPIC
	4: 2.60, # LEGENDARY
	5: 3.50  # MYTHIC
}

const RARITY_AFFIX_SLOTS: Dictionary = {
	0: 1, # COMMON
	1: 2, # UNCOMMON
	2: 3, # RARE
	3: 4, # EPIC
	4: 5, # LEGENDARY
	5: 5  # MYTHIC
}

static var AFFIX_REGISTRY: Array = [
	{"id": "dmg_up", "name": "Slaying", "type": "PREFIX", "stat": "damage", "value": 0.15, "synergy": "MELEE_BUILD"},
	{"id": "spd_up", "name": "Accelerated", "type": "PREFIX", "stat": "attack_speed", "value": 0.20, "synergy": "PROJECTILE_BUILD"},
	{"id": "crit_up", "name": "Lethal", "type": "PREFIX", "stat": "crit_chance", "value": 0.10, "synergy": "CRIT_BUILD"},
	{"id": "crit_dmg", "name": "Devastating", "type": "PREFIX", "stat": "crit_damage", "value": 0.35, "synergy": "CRIT_BUILD"},
	{"id": "proj_cnt", "name": "Multi-Shot", "type": "PREFIX", "stat": "projectile_count", "value": 1.0, "synergy": "PROJECTILE_BUILD"},
	{"id": "dash_dmg", "name": "Swift", "type": "SUFFIX", "stat": "dash_damage", "value": 0.30, "synergy": "DASH_BUILD"},
	{"id": "burn_ch", "name": "Igniting", "type": "PREFIX", "stat": "burn_chance", "value": 0.25, "synergy": "BURN_BUILD"},
	{"id": "freez_ch", "name": "Glacial", "type": "PREFIX", "stat": "freeze_chance", "value": 0.20, "synergy": "FREEZE_BUILD"},
	{"id": "move_spd", "name": "Fleet", "type": "SUFFIX", "stat": "move_speed", "value": 0.15, "synergy": "DASH_BUILD"},
	{"id": "max_hp", "name": "Fortified", "type": "PREFIX", "stat": "max_hp", "value": 25.0, "synergy": "TANK_BUILD"},
	{"id": "shield", "name": "Shielded", "type": "PREFIX", "stat": "shield", "value": 20.0, "synergy": "TANK_BUILD"},
	{"id": "loot_ch", "name": "Prosperous", "type": "SUFFIX", "stat": "loot_chance", "value": 0.20, "synergy": "FARMING_BUILD"}
]

static func generate_equipment(base_item_id: String, rarity_tier: int = 0, seed_val: int = 0) -> Dictionary:
	var rng = RandomNumberGenerator.new()
	if seed_val != 0:
		rng.seed = seed_val
	else:
		rng.randomize()
		
	var mult = RARITY_MULTIPLIERS.get(rarity_tier, 1.0)
	var slots = RARITY_AFFIX_SLOTS.get(rarity_tier, 1)
	
	var base_dmg = 20.0 * mult
	var base_name = base_item_id.capitalize()
	
	# Roll Affixes
	var selected_affixes: Array = []
	var synergies: Array = []
	var prefix_name = ""
	var suffix_name = ""
	
	var available = AFFIX_REGISTRY.duplicate()
	available.shuffle()
	
	for i in range(min(slots, available.size())):
		var affix = available[i]
		selected_affixes.append(affix)
		if not synergies.has(affix["synergy"]):
			synergies.append(affix["synergy"])
			
		if affix["type"] == "PREFIX" and prefix_name == "":
			prefix_name = affix["name"]
		elif affix["type"] == "SUFFIX" and suffix_name == "":
			suffix_name = "of " + affix["name"]

	var full_display_name = base_name
	if prefix_name != "": full_display_name = prefix_name + " " + full_display_name
	if suffix_name != "": full_display_name = full_display_name + " " + suffix_name

	return {
		"item_id": base_item_id,
		"display_name": full_display_name,
		"rarity_tier": rarity_tier,
		"base_damage": base_dmg,
		"rarity_multiplier": mult,
		"affixes": selected_affixes,
		"synergies": synergies,
		"slots": slots
	}
