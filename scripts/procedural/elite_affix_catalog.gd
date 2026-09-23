# scripts/procedural/elite_affix_catalog.gd
class_name EliteAffixCatalog
extends Resource

## Catalog registering all 15 Elite Affixes, incompatibility matrices, and budget selection rules.

static var _affixes: Dictionary = {}
static var _initialized: bool = false

static func _ensure_initialized() -> void:
	if _initialized:
		return
	_initialized = true
	
	var affix_script = load("res://scripts/procedural/elite_affix.gd")
	if not affix_script:
		return
		
	# 1. FAST (Cost 2)
	_affixes["FAST"] = affix_script.new(
		"FAST", "Swift", 0, 2, Color(1.0, 0.9, 0.2),
		["ARMORED"], 1.1, 1.1, 1.5, "speed_dash", "NONE"
	)
	
	# 2. ARMORED (Cost 3)
	_affixes["ARMORED"] = affix_script.new(
		"ARMORED", "Ironclad", 1, 3, Color(0.6, 0.6, 0.7),
		["FAST", "TELEPORTING"], 1.6, 1.1, 0.85, "damage_reduction", "PHYSICAL"
	)
	
	# 3. REGENERATING (Cost 3)
	_affixes["REGENERATING"] = affix_script.new(
		"REGENERATING", "Vitalizing", 2, 3, Color(0.2, 0.9, 0.3),
		["EXPLOSIVE"], 1.3, 1.0, 1.0, "passive_heal", "POISON"
	)
	
	# 4. EXPLOSIVE (Cost 3)
	_affixes["EXPLOSIVE"] = affix_script.new(
		"EXPLOSIVE", "Volatile", 3, 3, Color(1.0, 0.4, 0.1),
		["REGENERATING", "FROZEN"], 1.0, 1.4, 1.1, "death_nova", "FIRE"
	)
	
	# 5. VAMPIRIC (Cost 3)
	_affixes["VAMPIRIC"] = affix_script.new(
		"VAMPIRIC", "Sanguine", 4, 3, Color(0.8, 0.1, 0.3),
		["SHIELDED"], 1.2, 1.2, 1.1, "life_steal", "POISON"
	)
	
	# 6. SHIELDED (Cost 3)
	_affixes["SHIELDED"] = affix_script.new(
		"SHIELDED", "Barrier", 5, 3, Color(0.2, 0.7, 1.0),
		["VAMPIRIC"], 1.4, 1.0, 1.0, "energy_shield", "ELECTRIC"
	)
	
	# 7. TELEPORTING (Cost 4)
	_affixes["TELEPORTING"] = affix_script.new(
		"TELEPORTING", "Blinking", 6, 4, Color(0.8, 0.3, 1.0),
		["ARMORED"], 1.1, 1.2, 1.2, "blink_escape", "ELECTRIC"
	)
	
	# 8. BERSERKER (Cost 3)
	_affixes["BERSERKER"] = affix_script.new(
		"BERSERKER", "Frenzied", 7, 3, Color(0.9, 0.1, 0.1),
		["SHIELDED"], 1.25, 1.5, 1.3, "enrage_low_hp", "PHYSICAL"
	)
	
	# 9. SUMMONER (Cost 4)
	_affixes["SUMMONER"] = affix_script.new(
		"SUMMONER", "Broodmaster", 8, 4, Color(0.5, 0.2, 0.8),
		["SPLIT"], 1.3, 1.0, 0.9, "spawn_minions", "NONE"
	)
	
	# 10. REFLECTIVE (Cost 4)
	_affixes["REFLECTIVE"] = affix_script.new(
		"REFLECTIVE", "Mirror-Shielded", 9, 4, Color(0.9, 0.9, 1.0),
		["EXPLOSIVE", "TELEPORTING"], 1.3, 1.1, 0.95, "damage_reflection", "PHYSICAL"
	)
	
	# 11. FROZEN (Cost 3)
	_affixes["FROZEN"] = affix_script.new(
		"FROZEN", "Glacial", 10, 3, Color(0.4, 0.9, 1.0),
		["BURNING", "EXPLOSIVE"], 1.2, 1.15, 0.9, "frost_aura", "ICE"
	)
	
	# 12. BURNING (Cost 3)
	_affixes["BURNING"] = affix_script.new(
		"BURNING", "Ignited", 11, 3, Color(1.0, 0.3, 0.0),
		["FROZEN"], 1.15, 1.35, 1.1, "burn_trail", "FIRE"
	)
	
	# 13. POISONOUS (Cost 3)
	_affixes["POISONOUS"] = affix_script.new(
		"POISONOUS", "Toxic", 12, 3, Color(0.3, 0.9, 0.2),
		["ELECTRIC"], 1.2, 1.2, 1.0, "poison_cloud", "POISON"
	)
	
	# 14. ELECTRIC (Cost 3)
	_affixes["ELECTRIC"] = affix_script.new(
		"ELECTRIC", "Overcharged", 13, 3, Color(0.9, 0.9, 0.3),
		["POISONOUS"], 1.1, 1.3, 1.25, "chain_lightning", "ELECTRIC"
	)
	
	# 15. SPLIT (Cost 4)
	_affixes["SPLIT"] = affix_script.new(
		"SPLIT", "Multiplying", 14, 4, Color(0.7, 0.4, 0.9),
		["SUMMONER"], 1.2, 1.0, 1.1, "split_on_death", "NONE"
	)

static func get_affix(id: String) -> Resource:
	_ensure_initialized()
	if _affixes.has(id):
		return _affixes[id]
	return null

static func get_all_affix_ids() -> Array:
	_ensure_initialized()
	return _affixes.keys()

static func are_compatible(affix_id_1: String, affix_id_2: String) -> bool:
	_ensure_initialized()
	var a1 = get_affix(affix_id_1)
	var a2 = get_affix(affix_id_2)
	if not a1 or not a2:
		return false
	if affix_id_1 in a2.incompatible_affixes or affix_id_2 in a1.incompatible_affixes:
		return false
	return true

static func select_affixes_for_budget(
	max_budget: int,
	rng_seed: int = 12345,
	forced_biome: String = ""
) -> Array:
	_ensure_initialized()
	var rng = RandomNumberGenerator.new()
	rng.seed = rng_seed
	
	var chosen: Array = []
	var remaining_budget = max_budget
	var available = get_all_affix_ids().duplicate()
	available.sort() # Ensure deterministic iteration
	
	# Filter/prioritize biome signature affixes if provided
	if forced_biome == "mining":
		available = ["ARMORED", "ELECTRIC", "EXPLOSIVE", "FAST", "SHIELDED", "TELEPORTING"]
	elif forced_biome == "forest":
		available = ["POISONOUS", "BERSERKER", "REGENERATING", "FROZEN", "VAMPIRIC", "SUMMONER"]
	elif forced_biome == "cave":
		available = ["FROZEN", "REFLECTIVE", "BURNING", "SPLIT", "ARMORED", "TELEPORTING"]
	
	# Shuffle available list deterministically
	for i in range(available.size() - 1, 0, -1):
		var j = rng.randi_range(0, i)
		var temp = available[i]
		available[i] = available[j]
		available[j] = temp
		
	for id in available:
		var candidate = get_affix(id)
		if not candidate:
			continue
		if candidate.difficulty_cost > remaining_budget:
			continue
			
		var is_compat = true
		for existing in chosen:
			if not are_compatible(existing.affix_id, candidate.affix_id):
				is_compat = false
				break
				
		if is_compat:
			chosen.append(candidate)
			remaining_budget -= candidate.difficulty_cost
			if remaining_budget <= 0:
				break
				
	return chosen
