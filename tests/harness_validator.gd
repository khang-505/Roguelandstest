# tests/harness_validator.gd
class_name HarnessValidator
extends Resource

## Quality Score Engine evaluating 500-Encounter Combat Harness execution and 100% Success Rates.

static func validate_combat_harness() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var harness_script = load("res://tests/test_automated_combat_harness.gd")
	if not harness_script:
		warnings.append("TestAutomatedCombatHarness script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	var harness = harness_script.new()

	# 1. 500 Encounters Execution (50 Points)
	var res = harness.run_combat_harness(500)
	if res.get("total", 0) == 500 and res.get("successful", 0) == 500:
		total_score += 50.0
		details["harness_runs_score"] = 50.0
	else:
		warnings.append("Expected 500/500 successful combat encounters, got %d" % res.get("successful", 0))

	# 2. 100% Success Rate (50 Points)
	if is_equal_approx(res.get("success_rate", 0.0), 1.0):
		total_score += 50.0
		details["success_rate_score"] = 50.0
	else:
		warnings.append("Success rate < 100% (Got %.2f)" % res.get("success_rate", 0.0))

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
