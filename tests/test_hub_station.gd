# tests/test_hub_station.gd
class_name TestHubStation
extends Node

## Verification test suite for Starfall Frontier — System 54: Hub Town / Base Station Infrastructure.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING HUB STATION INFRASTRUCTURE ---")
	test_facilities_catalog()
	test_facility_upgrades()
	test_validator_score()
	print("--- HUB STATION SYSTEM TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_facilities_catalog() -> void:
	var mgr_script = load("res://scripts/world/hub_station_manager.gd")
	_assert_true(mgr_script != null, "HubStationManager script loaded")

	var facs = mgr_script.FACILITIES
	_assert_true(facs.size() == 5, "Hub station contains 5 facilities")
	print("[PASS] Facilities Catalog Check (2/2 PASSED)")

func test_facility_upgrades() -> void:
	var mgr_script = load("res://scripts/world/hub_station_manager.gd")

	var check = mgr_script.can_upgrade_facility("research_lab", 1, 300) # Costs 250
	_assert_true(check.get("can_upgrade", false), "Research Lab upgrade succeeds with 300 credits")

	var caps = mgr_script.get_unlocked_capabilities("research_lab", 2)
	_assert_true(caps.has("meta_tree_branch_2"), "Level 2 Research Lab unlocks meta tree branch 2")
	print("[PASS] Facility Upgrades & Unlocks Check (2/2 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/world/hub_station_validator.gd")
	var res = val_script.validate_hub_station()
	_assert_true(res.get("is_valid", false), "HubStationValidator passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] HubStationValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
