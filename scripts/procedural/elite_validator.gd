# scripts/procedural/elite_validator.gd
class_name EliteValidator
extends Resource

## Quality Score Engine evaluating Elite Enemy procedural composition, budget compliance, modifier compatibility, telegraphs, and rewards.

static func validate_elite(elite_data: Dictionary) -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []
	
	# 1. Budget Compliance (30 Points)
	var cost = elite_data.get("total_cost", 0)
	var budget = elite_data.get("difficulty_budget", 6)
	var budget_score = 0.0
	if cost > 0 and cost <= budget:
		budget_score = 30.0
	elif cost > budget:
		budget_score = 10.0
		warnings.append("Elite total cost (%d) exceeds difficulty budget (%d)." % [cost, budget])
	else:
		warnings.append("Elite has 0 affix cost.")
	total_score += budget_score
	details["budget_score"] = budget_score
	
	# 2. Modifier Compatibility (25 Points)
	var catalog_script = load("res://scripts/procedural/elite_affix_catalog.gd")
	var affix_ids: Array = elite_data.get("affix_ids", [])
	var compat_score = 25.0
	for i in range(affix_ids.size()):
		for j in range(i + 1, affix_ids.size()):
			if not catalog_script.are_compatible(affix_ids[i], affix_ids[j]):
				compat_score = 0.0
				warnings.append("Incompatible affixes combined: %s and %s" % [affix_ids[i], affix_ids[j]])
				break
		if compat_score == 0.0:
			break
	total_score += compat_score
	details["compatibility_score"] = compat_score
	
	# 3. Tactical Threat & Variety (25 Points)
	var behaviors: Array = elite_data.get("granted_behaviors", [])
	var hp = elite_data.get("composite_hp", 100.0)
	var variety_score = 0.0
	if behaviors.size() > 0:
		variety_score += 15.0
	if hp > 0 and hp <= 1000.0: # Ensure reasonable HP scaling, not 5000x sponge
		variety_score += 10.0
	total_score += variety_score
	details["variety_score"] = variety_score
	
	# 4. Reward & Telegraph Balance (20 Points)
	var telegraph: Dictionary = elite_data.get("telegraph", {})
	var rewards: Dictionary = elite_data.get("rewards", {})
	var reward_score = 0.0
	if not telegraph.get("nameplate", "").is_empty() and telegraph.has("aura_color"):
		reward_score += 10.0
	if rewards.get("currency_multiplier", 1.0) >= 2.0 and rewards.has("reward_choices"):
		reward_score += 10.0
	total_score += reward_score
	details["reward_score"] = reward_score
	
	var is_valid = total_score >= 70.0 and warnings.size() == 0
	
	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
