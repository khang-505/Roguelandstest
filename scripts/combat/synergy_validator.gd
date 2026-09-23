# scripts/combat/synergy_validator.gd
class_name SynergyValidator
extends Resource

## Quality Score Engine evaluating Synergy Catalog completeness, Tier 1/2/3 activations, and stat aggregation.

static func validate_synergies() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []
	
	var catalog_script = load("res://scripts/combat/synergy_catalog.gd")
	var engine_script = load("res://scripts/combat/synergy_engine.gd")
	
	if not catalog_script or not engine_script:
		warnings.append("Synergy catalog or engine script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}
		
	# 1. Catalog Archetypes Check (30 Points)
	var tags = catalog_script.get_all_synergy_tags()
	if tags.size() >= 8:
		total_score += 30.0
		details["archetypes_score"] = 30.0
	else:
		warnings.append("Expected at least 8 synergy archetypes, found %d" % tags.size())
		
	# 2. Tier 1 (2-item) Activation (25 Points)
	var weapon_fire2 = {"synergies": ["FIRE"]}
	var art_fire1 = load("res://scripts/combat/artifact_catalog.gd").get_artifact("pyro_core") # tags: ["fire", ...]
	
	var res_t1 = engine_script.calculate_build_synergies(weapon_fire2, [], [art_fire1])
	var active_syn1 = res_t1.get("active_synergies", [])
	
	if active_syn1.size() == 1 and active_syn1[0].get("active_tier") == 2:
		total_score += 25.0
		details["tier1_score"] = 25.0
	else:
		warnings.append("Tier 1 (2-item) activation check failed")
		
	# 3. Tier 3 (6-item) Activation & Special Effects (25 Points)
	var weapon_fire6 = {"synergies": ["FIRE", "FIRE", "FIRE", "FIRE", "FIRE", "FIRE"]}
	var res_t3 = engine_script.calculate_build_synergies(weapon_fire6)
	var active_syn3 = res_t3.get("active_synergies", [])
	var bonuses3 = res_t3.get("aggregate_bonuses", {})
	
	if active_syn3.size() == 1 and active_syn3[0].get("active_tier") == 6 and bonuses3.get("bonus_attack", 0) == 50:
		total_score += 25.0
		details["tier3_score"] = 25.0
	else:
		warnings.append("Tier 3 (6-item) activation check failed: %s" % str(res_t3))
		
	# 4. Zero Item Safety (20 Points)
	var res_empty = engine_script.calculate_build_synergies()
	if res_empty.get("active_synergies", []).size() == 0 and res_empty.get("tag_counts", {}).size() == 0:
		total_score += 20.0
		details["safety_score"] = 20.0
	else:
		warnings.append("Zero item safety check failed")
		
	var is_valid = total_score >= 80.0 and warnings.size() == 0
	
	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
