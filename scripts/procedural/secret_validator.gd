# scripts/procedural/secret_validator.gd
class_name SecretValidator
extends Resource

## Quality Score Engine evaluating discoverability, traversal feasibility, 0 main-path blocking, and reward validity.

static func validate_secret(secret_dict: Dictionary) -> Dictionary:
	var score = 100.0
	var issues: Array[String] = []

	if secret_dict.is_empty():
		return {"is_valid": false, "score": 0.0, "reason": "Empty secret dictionary"}

	# 1. Clue Check
	if secret_dict.get("clue_type", -1) < 0:
		score -= 30.0
		issues.append("Missing environmental clue hint")

	# 2. Non-blocking check
	if not secret_dict.get("is_optional", true):
		score -= 50.0
		issues.append("Secret blocks mandatory main progression route")

	# 3. Traversal Physics Check
	var ability = secret_dict.get("required_ability", "NONE")
	if ability != "NONE" and ability != "DOUBLE_JUMP" and ability != "DASH" and ability != "WALL_JUMP":
		score -= 25.0
		issues.append("Invalid or impossible movement ability requirement: %s" % ability)

	# 4. Reward Validity Check
	var loot = secret_dict.get("loot", {})
	if loot.is_empty() or loot.get("id", "") == "":
		score -= 20.0
		issues.append("Secret has empty or invalid reward drop")

	var is_valid = score >= 70.0
	var reason = "PASSED" if is_valid else ("FAILED: " + ", ".join(issues))

	return {
		"is_valid": is_valid,
		"score": score,
		"reason": reason,
		"issues": issues
	}
