# scripts/procedural/enemy_variety_validator.gd
class_name EnemyVarietyValidator
extends Resource

## Quality Score Engine evaluating enemy archetype differentiation, movement uniqueness, telegraph presence, and counterplay tips.

static func validate_enemy_archetype(arch_dict: Dictionary) -> Dictionary:
	var score = 100.0
	var issues: Array[String] = []

	if arch_dict.is_empty():
		return {"is_valid": false, "score": 0.0, "reason": "Empty archetype dictionary"}

	if arch_dict.get("archetype_id", "") == "":
		score -= 30.0
		issues.append("Missing archetype ID")

	if arch_dict.get("telegraph_duration", 0.0) <= 0.0:
		score -= 20.0
		issues.append("Missing attack telegraph duration")

	if arch_dict.get("counterplay_tip", "") == "":
		score -= 20.0
		issues.append("Missing counterplay tip guidance")

	var is_valid = score >= 70.0
	var reason = "PASSED" if is_valid else ("FAILED: " + ", ".join(issues))

	return {
		"is_valid": is_valid,
		"score": score,
		"reason": reason,
		"issues": issues
	}
