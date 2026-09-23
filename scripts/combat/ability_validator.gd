# scripts/combat/ability_validator.gd
class_name AbilityValidator
extends Resource

## Quality Score Engine evaluating Ability Categories, Activation Pipelines, Charge Regeneration, Mutations, and Exploration Integration.

static func validate_abilities() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []
	
	# 1. 10 Ability Categories (30 Points)
	var cat_script = load("res://scripts/combat/ability_catalog.gd")
	var category_score = 0.0
	if cat_script:
		var ids = cat_script.get_all_ability_ids()
		if ids.size() >= 10:
			category_score = 30.0
		else:
			warnings.append("Expected at least 10 ability categories (Found %d)" % ids.size())
	else:
		warnings.append("AbilityCatalog script not found")
	total_score += category_score
	details["category_score"] = category_score
	
	# 2. Activation Pipeline & Charges (25 Points)
	var mgr_script = load("res://scripts/combat/ability_manager.gd")
	var pipeline_score = 0.0
	if mgr_script and cat_script:
		var fire = cat_script.get_ability("fire_blast")
		var mgr = mgr_script.new()
		mgr.equip_ability("slot_1", fire)
		
		var res1 = mgr.activate_ability("fire_blast", 100.0, false)
		var res2 = mgr.activate_ability("fire_blast", 100.0, false) # Should fail (0 charges)
		
		if res1.get("success", false) and not res2.get("success", false):
			pipeline_score = 25.0
		else:
			warnings.append("Activation pipeline energy/charge check failed")
	else:
		warnings.append("AbilityManager script not found")
	total_score += pipeline_score
	details["pipeline_score"] = pipeline_score
	
	# 3. Roguelite Mutations & Build Synergies (25 Points)
	var mutation_score = 0.0
	if mgr_script and cat_script:
		var blink = cat_script.get_ability("blink_teleport")
		var mgr = mgr_script.new()
		mgr.equip_ability("slot_mobility", blink)
		
		var mut = {"id": "EXTRA_CHARGE", "extra_charges": 1, "cooldown_reduction": 0.25}
		var applied = mgr.apply_mutation("blink_teleport", mut)
		
		if applied and blink.max_charges == 3:
			mutation_score = 25.0
		else:
			warnings.append("Mutation extra charge application failed")
	total_score += mutation_score
	details["mutation_score"] = mutation_score
	
	# 4. Invulnerability i-Frames & Exploration Integration (20 Points)
	var exploration_score = 0.0
	if cat_script:
		var shield = cat_script.get_ability("invuln_shield")
		var scanner = cat_script.get_ability("secret_scanner")
		
		if shield.i_frames_duration >= 0.3 and scanner.tags.has("secret_reveal"):
			exploration_score = 20.0
		else:
			warnings.append("Invulnerability i-frames or secret scanner tags missing")
	total_score += exploration_score
	details["exploration_score"] = exploration_score
	
	var is_valid = total_score >= 70.0 and warnings.size() == 0
	
	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
