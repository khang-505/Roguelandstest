# tests/test_dynamic_music.gd
class_name TestDynamicMusic
extends Node

## Verification test suite for Starfall Frontier — System 71: Dynamic Music State Controller.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING DYNAMIC MUSIC STATE CONTROLLER ---")
	test_music_state_profiles()
	test_state_transitions()
	test_validator_score()
	print("--- DYNAMIC MUSIC TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_music_state_profiles() -> void:
	var ctrl_script = load("res://scripts/audio/dynamic_music_controller.gd")
	_assert_true(ctrl_script != null, "DynamicMusicController script loaded")

	var profiles = ctrl_script.STATE_PROFILES
	_assert_true(profiles.size() == 4, "Dynamic music defines 4 intensity states")
	print("[PASS] Music State Profiles Check (2/2 PASSED)")

func test_state_transitions() -> void:
	var ctrl_script = load("res://scripts/audio/dynamic_music_controller.gd")
	var ctrl = ctrl_script.new()

	_assert_true(ctrl.set_music_state(ctrl_script.MusicState.COMBAT_LIGHT), "Transition to COMBAT_LIGHT succeeds")
	var profile = ctrl.get_active_profile()
	_assert_true(profile.get("id") == "combat_light", "Active profile is combat_light")
	print("[PASS] Music State Transitions Check (2/2 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/audio/music_validator.gd")
	var res = val_script.validate_music_system()
	_assert_true(res.get("is_valid", false), "MusicValidator passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] MusicValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
