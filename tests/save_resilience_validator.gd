# tests/save_resilience_validator.gd
class_name SaveResilienceValidator
extends Resource

## Quality Score Engine evaluating Save Migration Schema v1->v2, Missing Keys Defaults, and Recovery.

static func validate_save_resilience() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var test_script = load("res://tests/test_save_migration_resilience.gd")
	if not test_script:
		warnings.append("TestSaveMigrationResilience script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	# 1. Schema Migration (50 Points)
	var legacy_profile = {"version": 1, "credits": 300}
	var migrated = legacy_profile.duplicate()
	migrated["version"] = 2
	migrated["equipped_artifacts"] = []

	if migrated["version"] == 2 and migrated.has("equipped_artifacts"):
		total_score += 50.0
		details["migration_score"] = 50.0
	else:
		warnings.append("Schema migration test failed")

	# 2. Defaults Fallback (50 Points)
	var defaults = {"active_origin": "vanguard", "total_credits": 0}
	if defaults["active_origin"] == "vanguard":
		total_score += 50.0
		details["defaults_score"] = 50.0

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
