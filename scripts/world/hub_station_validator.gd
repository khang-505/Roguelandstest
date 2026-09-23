# scripts/world/hub_station_validator.gd
class_name HubStationValidator
extends Resource

## Quality Score Engine evaluating Hub Station Facilities, Upgrade Costs, Max Levels, and Capability Unlocks.

static func validate_hub_station() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var mgr_script = load("res://scripts/world/hub_station_manager.gd")
	if not mgr_script:
		warnings.append("HubStationManager script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	# 1. 5 Facilities Catalog (30 Points)
	var facs = mgr_script.FACILITIES
	if facs.size() == 5:
		total_score += 30.0
		details["facilities_score"] = 30.0
	else:
		warnings.append("Expected 5 facilities in Hub Station catalog")

	# 2. Upgrade Cost & Level Check (25 Points)
	var check_poor = mgr_script.can_upgrade_facility("workshop", 1, 50) # Level 2 costs 200 credits
	var check_rich = mgr_script.can_upgrade_facility("workshop", 1, 300)

	if not check_poor.get("can_upgrade", true) and check_rich.get("can_upgrade", false) and check_rich.get("cost") == 200:
		total_score += 25.0
		details["upgrade_cost_score"] = 25.0
	else:
		warnings.append("Facility upgrade cost & level check failed")

	# 3. Capability Unlocks Check (25 Points)
	var caps_lvl2 = mgr_script.get_unlocked_capabilities("workshop", 2)
	if caps_lvl2.has("basic_crafting") and caps_lvl2.has("relic_fusion"):
		total_score += 25.0
		details["capabilities_score"] = 25.0
	else:
		warnings.append("Capability unlocks check failed")

	# 4. Max Level Guard (20 Points)
	var check_max = mgr_script.can_upgrade_facility("workshop", 5, 99999)
	if not check_max.get("can_upgrade", true) and check_max.get("reason") == "max_level_reached":
		total_score += 20.0
		details["max_level_score"] = 20.0
	else:
		warnings.append("Max level upgrade guard failed")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
