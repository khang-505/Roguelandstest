# tests/performance_validator.gd
class_name PerformanceValidator
extends Resource

## Quality Score Engine evaluating Performance Sampling, Node Count Caps, and Memory Leak Prevention.

static func validate_performance() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var prof_script = load("res://tests/test_performance_profiler.gd")
	if not prof_script:
		warnings.append("TestPerformanceProfiler script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	var prof = prof_script.new()
	var res = prof.profile_performance_metrics(100)

	# 1. 100 Samples Execution (50 Points)
	if res.get("total_samples", 0) == 100 and res.get("passed_samples", 0) == 100:
		total_score += 50.0
		details["sampling_score"] = 50.0
	else:
		warnings.append("Expected 100/100 performance samples passed")

	# 2. Zero Memory Leaks (50 Points)
	if not res.get("has_leaks", true):
		total_score += 50.0
		details["no_leaks_score"] = 50.0
	else:
		warnings.append("Memory leak detected during performance profiling")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
