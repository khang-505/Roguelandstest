# scripts/core/telemetry_validator.gd
class_name TelemetryValidator
extends Resource

## Quality Score Engine evaluating Local Telemetry Event Logging, Session Summary Aggregation, and JSON Exporting.

static func validate_telemetry() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var tracker_script = load("res://scripts/core/telemetry_tracker.gd")
	if not tracker_script:
		warnings.append("TelemetryTracker script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	var tracker = tracker_script.new()

	# 1. Event Logging & Signal Emission (30 Points)
	var signal_emitted = false
	tracker.event_logged.connect(func(_name, _data): signal_emitted = true)

	tracker.log_event("enemy_killed", {"enemy_id": "ash_beetle"})
	if tracker.logged_events.size() == 1 and signal_emitted:
		total_score += 30.0
		details["event_logging_score"] = 30.0
	else:
		warnings.append("Event logging check failed")

	# 2. Session Summary Aggregation (25 Points)
	tracker.log_event("damage_dealt", {"amount": 150.0})
	tracker.log_event("weapon_fired", {"weapon_id": "plasma_caster"})

	var summary = tracker.get_session_summary()
	if summary.get("total_kills") == 1 and is_equal_approx(summary.get("total_damage_dealt"), 150.0) and summary["weapon_usage"].get("plasma_caster") == 1:
		total_score += 25.0
		details["summary_aggregation_score"] = 25.0
	else:
		warnings.append("Session summary aggregation check failed")

	# 3. JSON Exporting (25 Points)
	var json_str = tracker.export_telemetry_json()
	if json_str.contains("session_stats") and json_str.contains("event_count"):
		total_score += 25.0
		details["json_export_score"] = 25.0
	else:
		warnings.append("JSON exporting check failed")

	# 4. Zero Data Safety Guard (20 Points)
	var fresh_tracker = tracker_script.new()
	var fresh_summary = fresh_tracker.get_session_summary()
	if fresh_summary.get("total_kills") == 0 and fresh_tracker.logged_events.size() == 0:
		total_score += 20.0
		details["zero_data_guard_score"] = 20.0
	else:
		warnings.append("Zero data safety guard failed")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
