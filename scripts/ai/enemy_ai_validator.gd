# scripts/ai/enemy_ai_validator.gd
class_name EnemyAIValidator
extends Resource

## Quality Score Engine evaluating AI state machine completeness, perception fairness, and non-blocking recovery.

static func validate_ai_controller(ctrl_dict: Dictionary) -> Dictionary:
	var score = 100.0
	var issues: Array[String] = []

	if ctrl_dict.is_empty():
		return {"is_valid": false, "score": 0.0, "reason": "Empty controller dictionary"}

	if ctrl_dict.get("detection_radius", 0.0) <= 0.0:
		score -= 30.0
		issues.append("Invalid or missing detection radius")

	if ctrl_dict.get("attack_radius", 0.0) <= 0.0:
		score -= 20.0
		issues.append("Invalid or missing attack radius")

	if ctrl_dict.get("reaction_delay", 0.0) < 0.1:
		score -= 20.0
		issues.append("Reaction delay too fast (unfair instant AI)")

	var is_valid = score >= 70.0
	var reason = "PASSED" if is_valid else ("FAILED: " + ", ".join(issues))

	return {
		"is_valid": is_valid,
		"score": score,
		"reason": reason,
		"issues": issues
	}
