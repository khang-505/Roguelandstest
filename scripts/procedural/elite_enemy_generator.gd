# scripts/procedural/elite_enemy_generator.gd
class_name EliteEnemyGenerator
extends Resource

## Generator that synthesizes Elite Enemies with budget-driven affixes, telegraphs, AI states, and rewards.

static func generate_elite(
	base_archetype,
	difficulty_budget: int = 6,
	seed_val: int = 12345,
	biome_id: String = ""
) -> Dictionary:
	var catalog_script = load("res://scripts/procedural/elite_affix_catalog.gd")
	var archetype_script = load("res://scripts/procedural/enemy_archetype_data.gd")
	var effective_biome = biome_id if not biome_id.is_empty() else base_archetype.biome_id
	
	var selected_affixes: Array = catalog_script.select_affixes_for_budget(
		difficulty_budget, seed_val, effective_biome
	)
	
	var total_cost = 0
	var composite_hp_mult = 1.5 # Base elite health multiplier (1.5x, not 5x)
	var composite_dmg_mult = 1.25 # Base elite damage multiplier (1.25x, not 3x)
	var composite_speed_mult = 1.0
	var affix_names: Array[String] = []
	var affix_ids: Array[String] = []
	var granted_behaviors: Array[String] = []
	var primary_color = Color(1.0, 0.8, 0.2) # Golden aura default
	
	if selected_affixes.size() > 0:
		primary_color = selected_affixes[0].visual_color
		
	for affix in selected_affixes:
		total_cost += affix.difficulty_cost
		composite_hp_mult *= affix.health_multiplier
		composite_dmg_mult *= affix.damage_multiplier
		composite_speed_mult = max(composite_speed_mult, affix.speed_multiplier)
		affix_names.append(affix.affix_name)
		affix_ids.append(affix.affix_id)
		if not affix.Granted_behavior.is_empty():
			granted_behaviors.append(affix.Granted_behavior)
			
	var final_hp = base_archetype.max_health * composite_hp_mult
	var final_dmg = base_archetype.base_damage * composite_dmg_mult
	var final_speed = base_archetype.move_speed * composite_speed_mult
	
	var title_prefix = " ".join(affix_names)
	var elite_title = "ELITE " + (title_prefix + " " if not title_prefix.is_empty() else "") + base_archetype.archetype_name
	
	# Determine preferred room terrain type based on mobility & affix capabilities
	var preferred_terrain = "OPEN_ARENA"
	if "TELEPORTING" in affix_ids or base_archetype.movement_type == archetype_script.MovementType.FLY:
		preferred_terrain = "VERTICAL_ARENA"
	elif "ARMORED" in affix_ids or base_archetype.role == archetype_script.Role.TANK:
		preferred_terrain = "NARROW_CHOKE"
		
	# Build high-value loot reward definition
	var rewards = {
		"currency_multiplier": 3.0,
		"guaranteed_loot_tier": "EPIC" if total_cost >= 6 else "RARE",
		"reward_choices": [
			{"type": "WEAPON", "name": "Elite Plasma Cannon", "tier": "RARE"},
			{"type": "ARTIFACT", "name": "Vampiric Core", "tier": "EPIC"},
			{"type": "CURRENCY", "amount": 250, "tier": "UNCOMMON"}
		]
	}
	
	return {
		"elite_title": elite_title,
		"base_archetype_id": base_archetype.archetype_id,
		"role": base_archetype.role,
		"biome_id": effective_biome,
		"difficulty_budget": difficulty_budget,
		"total_cost": total_cost,
		"affix_ids": affix_ids,
		"affix_names": affix_names,
		"composite_hp": final_hp,
		"composite_damage": final_dmg,
		"composite_speed": final_speed,
		"telegraph": {
			"aura_color": primary_color,
			"icon_id": "icon_elite_warning",
			"nameplate": elite_title,
			"particle_effect": "particles_" + (affix_ids[0].to_lower() if affix_ids.size() > 0 else "gold")
		},
		"granted_behaviors": granted_behaviors,
		"preferred_terrain": preferred_terrain,
		"rewards": rewards
	}

static func get_biome_preset_elites(biome_id: String) -> Array[Dictionary]:
	var archetype_script = load("res://scripts/procedural/enemy_archetype_data.gd")
	var presets: Array[Dictionary] = []
	
	if biome_id == "mining":
		var base_drone = archetype_script.new("sec_drone", "Security Drone", archetype_script.Role.MELEE, "drone", "mining")
		presets.append(generate_elite(base_drone, 6, 1001, "mining"))
		
		var base_mech = archetype_script.new("overclock_mech", "Overclocked Machine", archetype_script.Role.TANK, "mech", "mining")
		presets.append(generate_elite(base_mech, 6, 1002, "mining"))
		
		var base_miner = archetype_script.new("exp_miner", "Explosive Miner", archetype_script.Role.EXPLODER, "cyborg", "mining")
		presets.append(generate_elite(base_miner, 6, 1003, "mining"))
	elif biome_id == "forest":
		var base_pred = archetype_script.new("alpha_pred", "Alpha Predator", archetype_script.Role.ASSASSIN, "beast", "forest")
		presets.append(generate_elite(base_pred, 6, 2001, "forest"))
		
		var base_beast = archetype_script.new("poi_beast", "Poison Beast", archetype_script.Role.SUPPORT, "beast", "forest")
		presets.append(generate_elite(base_beast, 6, 2002, "forest"))
		
		var base_root = archetype_script.new("root_guard", "Root Guardian", archetype_script.Role.TANK, "plant", "forest")
		presets.append(generate_elite(base_root, 6, 2003, "forest"))
	else: # cave / default
		var base_burrower = archetype_script.new("deep_burrower", "Burrower", archetype_script.Role.BURROWER, "crawler", "cave")
		presets.append(generate_elite(base_burrower, 6, 3001, "cave"))
		
		var base_cryst = archetype_script.new("cryst_beast", "Crystal Beast", archetype_script.Role.TANK, "beast", "cave")
		presets.append(generate_elite(base_cryst, 6, 3002, "cave"))
		
		var base_crawl = archetype_script.new("deep_crawler", "Deep Crawler", archetype_script.Role.MELEE, "crawler", "cave")
		presets.append(generate_elite(base_crawl, 6, 3003, "cave"))
		
	return presets
