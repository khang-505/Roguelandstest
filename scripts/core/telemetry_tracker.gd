# scripts/core/telemetry_tracker.gd
class_name TelemetryTracker
extends Resource

## Privacy-compliant Local Telemetry & Analytics Tracker logging run metrics for balance tuning.

signal event_logged(event_name: String, data: Dictionary)

var logged_events: Array[Dictionary] = []
var session_stats: Dictionary = {
	"total_kills": 0,
	"total_damage_dealt": 0.0,
	"total_damage_taken": 0.0,
	"deaths": 0,
	"runs_completed": 0,
	"weapon_usage": {}
}

func log_event(event_name: String, data: Dictionary = {}) -> void:
	var entry = {
		"event": event_name,
		"timestamp": Time.get_unix_time_from_system() if Time.has_method("get_unix_time_from_system") else 0.0,
		"data": data
	}
	logged_events.append(entry)

	# Update session summary metrics
	match event_name:
		"enemy_killed":
			session_stats["total_kills"] += 1
		"damage_dealt":
			session_stats["total_damage_dealt"] += float(data.get("amount", 0.0))
		"damage_taken":
			session_stats["total_damage_taken"] += float(data.get("amount", 0.0))
		"player_death":
			session_stats["deaths"] += 1
		"run_completed":
			session_stats["runs_completed"] += 1
		"weapon_fired":
			var w_id = str(data.get("weapon_id", "unknown"))
			if session_stats["weapon_usage"].has(w_id):
				session_stats["weapon_usage"][w_id] += 1
			else:
				session_stats["weapon_usage"][w_id] = 1

	event_logged.emit(event_name, data)

func get_session_summary() -> Dictionary:
	return session_stats.duplicate(true)

func export_telemetry_json() -> String:
	return JSON.stringify({
		"session_stats": session_stats,
		"event_count": logged_events.size()
	})
