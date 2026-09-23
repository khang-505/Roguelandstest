# scripts/combat/melee_validator.gd
class_name MeleeValidator
extends Resource

## Quality Score Engine evaluating Melee Weapon Archetypes, Attack Types, Armor Break, Weight Scaling, and Whiff/Hit Feedback.

static func validate_melee() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []
	
	# 1. Weapon Archetypes & Hitbox Shapes (30 Points)
	var cat_script = load("res://scripts/combat/melee_weapon_catalog.gd")
	var archetype_score = 0.0
	if cat_script:
		var ids = cat_script.get_all_weapon_ids()
		if ids.size() >= 4:
			archetype_score = 30.0
		else:
			warnings.append("Expected at least 4 melee weapon archetypes (Found %d)" % ids.size())
	else:
		warnings.append("MeleeWeaponCatalog script not found")
	total_score += archetype_score
	details["archetype_score"] = archetype_score
	
	# 2. Attack Types & Directional Coverage (25 Points)
	var stagger_script = load("res://scripts/combat/melee_stagger_engine.gd")
	var attack_type_score = 0.0
	if stagger_script and cat_script:
		var sword = cat_script.get_weapon("plasma_sword")
		var light_res = stagger_script.process_melee_impact(sword, "LIGHT", 20.0, 1.0, false)
		var heavy_res = stagger_script.process_melee_impact(sword, "HEAVY", 20.0, 1.0, false)
		var charged_res = stagger_script.process_melee_impact(sword, "CHARGED", 20.0, 1.0, false)
		var down_res = stagger_script.process_melee_impact(sword, "DOWN", 20.0, 1.0, false)
		
		if charged_res["damage"] > heavy_res["damage"] and heavy_res["damage"] > light_res["damage"] and down_res.has("stagger_triggered"):
			attack_type_score = 25.0
		else:
			warnings.append("Attack type damage scaling hierarchy invalid")
	else:
		warnings.append("MeleeStaggerEngine script not found")
	total_score += attack_type_score
	details["attack_type_score"] = attack_type_score
	
	# 3. Armor Break & Stagger Engine (25 Points)
	var stagger_engine_score = 0.0
	if stagger_script and cat_script:
		var hammer = cat_script.get_weapon("titan_hammer")
		var armor_res = stagger_script.process_melee_impact(hammer, "HEAVY", 30.0, 1.0, false)
		var staggered_res = stagger_script.process_melee_impact(hammer, "LIGHT", 0.0, 1.0, true)
		
		if armor_res["armor_broken"] and staggered_res["damage"] > hammer.base_damage:
			stagger_engine_score = 25.0
		else:
			warnings.append("Armor break or stagger window bonus calculation failed")
	total_score += stagger_engine_score
	details["stagger_engine_score"] = stagger_engine_score
	
	# 4. Weight Mitigation & Whiff/Hit Audio Feedback (20 Points)
	var feedback_score = 0.0
	if stagger_script and cat_script:
		var sword = cat_script.get_weapon("plasma_sword")
		var light_weight = stagger_script.process_melee_impact(sword, "LIGHT", 0.0, 0.5, false)
		var heavy_weight = stagger_script.process_melee_impact(sword, "LIGHT", 0.0, 2.5, false)
		var whiff_res = stagger_script.process_melee_impact(sword, "WHIFF", 0.0, 1.0, false)
		
		if light_weight["final_knockback"] > heavy_weight["final_knockback"] and whiff_res["is_whiff"]:
			feedback_score = 20.0
		else:
			warnings.append("Weight knockback scaling or whiff feedback failed")
	total_score += feedback_score
	details["feedback_score"] = feedback_score
	
	var is_valid = total_score >= 70.0 and warnings.size() == 0
	
	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
