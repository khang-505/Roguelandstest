# tests/test_telemetry_tracker.gd
class_name TestTelemetryTracker
extends Node

## Verification test suite for Starfall Frontier — System 89: Telemetry & Analytics Tracker.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING TELEMETRY & ANALYTICS TRACKER ---")
	test_telemetry_logging()
	test_session_summary()
	test_validator_score()
	print("--- TELEMETRY TRACKER TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_telemetry_logging() -> void:
	var tracker_script = load("res://scripts/core/telemetry_tracker.gd")
	_assert_true(tracker_script != null, "TelemetryTracker script loaded")

	var tracker = tracker_script.new()
	tracker.log_event("enemy_killed", {"id": "exploder_bug"})
	_assert_true(tracker.logged_events.size() == 1, "Log event adds entry to logged events")
	print("[PASS] Telemetry Logging Check (2/2 PASSED)")

func test_session_summary() -> void:
	var tracker_script = load("res://scripts/core/telemetry_tracker.gd")
	var tracker = tracker_script.new()

	tracker.log_event("enemy_killed")
	tracker.log_event("enemy_killed")
	var summary = tracker.get_session_summary()
	_assert_true(summary.get("total_kills") == 2, "Session summary tracks 2 enemy kills")
	print("[PASS] Session Summary Tracking Check (1/1 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/core/telemetry_validator.gd")
	var res = val_script.validate_telemetry()
	_assert_true(res.get("is_valid", false), "TelemetryValidator passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] TelemetryValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
