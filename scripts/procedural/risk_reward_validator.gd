# scripts/procedural/risk_reward_validator.gd
class_name RiskRewardValidator
extends Resource

## Quality Score Engine evaluating Risk/Reward Catalog, deterministic seed generation, pact acceptance, and stat aggregation.

static func validate_risk_reward_system() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var mgr_script = load("res://scripts/procedural/risk_reward_manager.gd")
	if not mgr_script:
		warnings.append("RiskRewardManager script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	var mgr = mgr_script.new()

	# 1. Catalog Completeness (30 Points)
	if mgr_script.PACT_CATALOG.size() >= 5:
		total_score += 30.0
		details["catalog_score"] = 30.0
	else:
		warnings.append("Expected at least 5 pacts in catalog")

	# 2. Deterministic Choice Selection (25 Points)
	var choices1 = mgr.get_random_pact_choices(3, 12345)
	var choices2 = mgr.get_random_pact_choices(3, 12345)

	if choices1.size() == 3 and choices1[0]["id"] == choices2[0]["id"]:
		total_score += 25.0
		details["determinism_score"] = 25.0
	else:
		warnings.append("Deterministic pact choices check failed")

	# 3. Pact Acceptance & Aggregation (25 Points)
	mgr.accept_pact(mgr_script.PACT_CATALOG[0]) # Blood Bargain: enemy_dmg +0.40, loot +0.80
	mgr.accept_pact(mgr_script.PACT_CATALOG[1]) # Glass Cannon: hp -0.30, attack +0.60

	var mods = mgr.get_aggregate_modifiers()
	if is_equal_approx(mods.get("enemy_damage_mult", 0.0), 0.40) and is_equal_approx(mods.get("loot_drop_mult", 0.0), 0.80) and is_equal_approx(mods.get("player_attack_mult", 0.0), 0.60):
		total_score += 25.0
		details["aggregation_score"] = 25.0
	else:
		warnings.append("Aggregate risk/reward modifiers calculation failed")

	# 4. Zero Active Pact Safety (20 Points)
	var fresh_mgr = mgr_script.new()
	var empty_mods = fresh_mgr.get_aggregate_modifiers()
	if empty_mods.get("enemy_damage_mult", -1.0) == 0.0 and fresh_mgr.active_pacts.size() == 0:
		total_score += 20.0
		details["safety_score"] = 20.0
	else:
		warnings.append("Zero active pact safety check failed")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
