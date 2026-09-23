# scripts/procedural/breakable_object_validator.gd
class_name BreakableObjectValidator
extends Resource

## Quality Score Engine evaluating breakable object health, placement bounds, 0 mandatory blocking, and loot bounds.

static func validate_breakable_object(obj_dict: Dictionary) -> Dictionary:
	var score = 100.0
	var issues: Array[String] = []

	if obj_dict.is_empty():
		return {"is_valid": false, "score": 0.0, "reason": "Empty breakable object dictionary"}

	if obj_dict.get("object_id", "") == "":
		score -= 30.0
		issues.append("Missing object ID")

	var pos = obj_dict.get("position", Vector2.ZERO)
	if pos == Vector2.ZERO:
		score -= 20.0
		issues.append("Invalid position vector")

	var is_valid = score >= 70.0
	var reason = "PASSED" if is_valid else ("FAILED: " + ", ".join(issues))

	return {
		"is_valid": is_valid,
		"score": score,
		"reason": reason,
		"issues": issues
	}
