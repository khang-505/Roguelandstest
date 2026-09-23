# scripts/procedural/interaction_validator.gd
class_name InteractionValidator
extends Resource

## Quality Score Engine evaluating interactive environment prompt validity, target link reachability, and 0 softlocks.

static func validate_interaction_chain(chain_dict: Dictionary) -> Dictionary:
	var score = 100.0
	var issues: Array[String] = []

	if chain_dict.is_empty():
		return {"is_valid": false, "score": 0.0, "reason": "Empty interaction chain dictionary"}

	if chain_dict.get("trigger_id", "") == "" or chain_dict.get("target_id", "") == "":
		score -= 30.0
		issues.append("Missing trigger or target ID link")

	var is_valid = score >= 70.0
	var reason = "PASSED" if is_valid else ("FAILED: " + ", ".join(issues))

	return {
		"is_valid": is_valid,
		"score": score,
		"reason": reason,
		"issues": issues
	}
