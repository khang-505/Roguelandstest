# scripts/combat/curse_validator.gd
class_name CurseValidator
extends Resource

## Quality Score Engine evaluating Corruption Points, Threshold Triggers, Active Debuff Aggregation, and Cleansing.

static func validate_curse_system() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var mgr_script = load("res://scripts/combat/curse_manager.gd")
	var data_script = load("res://scripts/data/curse_data.gd")

	if not mgr_script or not data_script:
		warnings.append("Curse manager or data script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	var mgr = mgr_script.new()

	# 1. Add Corruption & Threshold Triggers (30 Points)
	var triggered_tiers: Array[int] = []
	mgr.threshold_reached.connect(func(tier): triggered_tiers.append(tier))

	mgr.add_corruption(30.0) # 30% -> Tier 1 (25%) triggered

	if mgr.corruption_points == 30.0 and triggered_tiers.size() == 1 and triggered_tiers[0] == 1:
		total_score += 30.0
		details["threshold_score"] = 30.0
	else:
		warnings.append("Corruption addition or threshold trigger check failed")

	# 2. Add Curse & Debuff Aggregation (25 Points)
	var c1 = data_script.get_curse("corrupted_glass") # corruption +25, hp_mult -0.20
	mgr.add_curse(c1)

	var debuffs = mgr.get_aggregate_curse_debuffs()
	if mgr.corruption_points == 55.0 and is_equal_approx(debuffs.get("max_hp_mult", 0.0), -0.20):
		total_score += 25.0
		details["debuff_score"] = 25.0
	else:
		warnings.append("Curse addition & debuff aggregation failed")

	# 3. Cleanse Mechanics (25 Points)
	mgr.cleanse_corruption(20.0) # 55 -> 35
	if mgr.corruption_points == 35.0:
		total_score += 25.0
		details["cleanse_score"] = 25.0
	else:
		warnings.append("Cleanse corruption points check failed")

	# 4. Remove Curse (20 Points)
	mgr.remove_curse("corrupted_glass") # removes 25 -> 10.0 left
	if mgr.corruption_points == 10.0 and mgr.active_curses.size() == 0:
		total_score += 20.0
		details["remove_curse_score"] = 20.0
	else:
		warnings.append("Remove curse check failed")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
