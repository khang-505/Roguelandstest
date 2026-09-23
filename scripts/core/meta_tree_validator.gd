# scripts/core/meta_tree_validator.gd
class_name MetaTreeValidator
extends Resource

## Quality Score Engine evaluating Meta-Progression Tree Node Catalog, Prerequisites, Ranks, Currency Checks, and Stat Summation.

static func validate_meta_tree() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var tree_script = load("res://scripts/core/meta_progression_tree.gd")
	if not tree_script:
		warnings.append("MetaProgressionTree script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	# 1. 4 Branches & Node Count (30 Points)
	var nodes = tree_script.TREE_NODES
	if nodes.size() >= 6:
		total_score += 30.0
		details["nodes_score"] = 30.0
	else:
		warnings.append("Expected at least 6 nodes in meta tree catalog")

	# 2. Prerequisites Check (25 Points)
	# off_crit_1 requires off_atk_1 rank >= 1
	var check_no_prereq = tree_script.can_upgrade_node("off_crit_1", {}, 1000, 1000)
	var check_with_prereq = tree_script.can_upgrade_node("off_crit_1", {"off_atk_1": 1}, 1000, 1000)

	if not check_no_prereq.get("can_upgrade", true) and check_with_prereq.get("can_upgrade", false):
		total_score += 25.0
		details["prereq_score"] = 25.0
	else:
		warnings.append("Prerequisite validation failed")

	# 3. Currency Cost Check (25 Points)
	var check_poor = tree_script.can_upgrade_node("off_atk_1", {}, 10, 10) # Needs 100 credits
	if not check_poor.get("can_upgrade", true) and check_poor.get("reason") == "insufficient_credits":
		total_score += 25.0
		details["currency_score"] = 25.0
	else:
		warnings.append("Insufficient currency guard failed")

	# 4. Stat Bonus Summation (20 Points)
	var ranks = {"off_atk_1": 3, "def_hp_1": 2} # off_atk_1: 3 * 0.05 = 0.15; def_hp_1: 2 * 20 = 40 HP
	var bonuses = tree_script.calculate_meta_tree_bonuses(ranks)

	if is_equal_approx(bonuses.get("bonus_attack_mult", 0.0), 0.15) and bonuses.get("bonus_hp_flat", 0) == 40:
		total_score += 20.0
		details["stat_sum_score"] = 20.0
	else:
		warnings.append("Meta-tree stat bonus summation failed")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
