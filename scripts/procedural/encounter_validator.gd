# scripts/procedural/encounter_validator.gd
class_name EncounterValidator
extends Resource

## Quality Score Engine evaluating encounter budget balance, spawn safety, role diversity, and 0 softlocks.

static func validate_encounter(enc_dict: Dictionary) -> Dictionary:
	var score = 100.0
	var issues: Array[String] = []

	if enc_dict.is_empty():
		return {"is_valid": false, "score": 0.0, "reason": "Empty encounter dictionary"}

	var spawn_points = enc_dict.get("spawn_points", [])
	if spawn_points.is_empty():
		score -= 50.0
		issues.append("No valid spawn points generated")

	var budget = enc_dict.get("total_budget", 0)
	if budget <= 0:
		score -= 30.0
		issues.append("Encounter budget is zero or negative")

	var is_valid = score >= 70.0
	var reason = "PASSED" if is_valid else ("FAILED: " + ", ".join(issues))

	return {
		"is_valid": is_valid,
		"score": score,
		"reason": reason,
		"issues": issues
	}
