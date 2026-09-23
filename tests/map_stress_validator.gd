# tests/map_stress_validator.gd
class_name MapStressValidator
extends Resource

## Quality Score Engine evaluating 1,000 Map Seed Stress Tests and Biome Reachability.

static func validate_map_stress() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var stress_script = load("res://tests/test_procedural_map_stress.gd")
	if not stress_script:
		warnings.append("TestProceduralMapStress script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	var stress = stress_script.new()

	# 1. 1,000 Map Seeds Execution (50 Points)
	var res = stress.run_map_stress_test(1000)
	if res.get("total", 0) == 1000 and res.get("successful", 0) == 1000:
		total_score += 50.0
		details["map_seeds_score"] = 50.0
	else:
		warnings.append("Expected 1000/1000 successful map seed runs")

	# 2. 100% Success Rate (50 Points)
	if is_equal_approx(res.get("success_rate", 0.0), 1.0):
		total_score += 50.0
		details["success_rate_score"] = 50.0
	else:
		warnings.append("Success rate < 100%")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
