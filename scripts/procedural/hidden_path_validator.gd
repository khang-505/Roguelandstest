# scripts/procedural/hidden_path_validator.gd
class_name HiddenPathValidator
extends Resource

## Quality Score Engine evaluating discoverability, traversal feasibility, non-blocking routes, and 0 softlocks.

static func validate_hidden_path(path_dict: Dictionary) -> Dictionary:
	var score = 100.0
	var issues: Array[String] = []

	if path_dict.is_empty():
		return {"is_valid": false, "score": 0.0, "reason": "Empty hidden path dictionary"}

	# 1. Clue Presence Check
	if path_dict.get("clue_type", "") == "":
		score -= 30.0
		issues.append("Missing environmental clue hint")

	# 2. Non-blocking Main Progression Check
	if not path_dict.get("is_optional", true):
		score -= 50.0
		issues.append("Hidden path blocks mandatory main progression route")

	# 3. Traversal Physics Check
	var ability = path_dict.get("required_ability", "NONE")
	if ability != "NONE" and ability != "DOUBLE_JUMP" and ability != "DASH" and ability != "WALL_JUMP":
		score -= 25.0
		issues.append("Invalid or impossible movement ability requirement: %s" % ability)

	# 4. Reconnection / Loop Termination Check
	if not path_dict.get("reconnects", true):
		score -= 15.0
		issues.append("Hidden route does not reconnect to main topology")

	# 5. Reward Validity Check
	var loot = path_dict.get("loot", {})
	if loot.is_empty() or loot.get("id", "") == "":
		score -= 20.0
		issues.append("Hidden path has empty or invalid reward drop")

	var is_valid = score >= 70.0
	var reason = "PASSED" if is_valid else ("FAILED: " + ", ".join(issues))

	return {
		"is_valid": is_valid,
		"score": score,
		"reason": reason,
		"issues": issues
	}
