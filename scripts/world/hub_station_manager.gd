# scripts/world/hub_station_manager.gd
class_name HubStationManager
extends Resource

## Base Station Hub Controller managing facility levels (Workshop, Stash, Research Lab, Mission Board, Merchant Stall) and station upgrades.

signal facility_upgraded(facility_id: String, new_level: int)

static var FACILITIES: Dictionary = {
	"workshop": {
		"id": "workshop",
		"display_name": "Equipment Workshop",
		"description": "Crafts weapons, armor, and handles item synthesis & relic fusion.",
		"max_level": 5,
		"level_costs": [0, 200, 500, 1200, 3000],
		"unlocks": {
			1: ["basic_crafting"],
			2: ["relic_fusion"],
			3: ["affix_reroll"],
			4: ["legendary_recipes"],
			5: ["masterwork_refinement"]
		}
	},
	"stash": {
		"id": "stash",
		"display_name": "Base Stash Vault",
		"description": "Stores persistent loot, gear, and materials.",
		"max_level": 5,
		"level_costs": [0, 100, 300, 800, 2000],
		"unlocks": {
			1: ["stash_tabs_1"],
			2: ["stash_tabs_2"],
			3: ["auto_material_deposit"],
			4: ["stash_tabs_3"],
			5: ["infinite_material_storage"]
		}
	},
	"research_lab": {
		"id": "research_lab",
		"display_name": "Research & Tech Lab",
		"description": "Researches permanent operative upgrades and meta-tree nodes.",
		"max_level": 5,
		"level_costs": [0, 250, 600, 1500, 3500],
		"unlocks": {
			1: ["meta_tree_branch_1"],
			2: ["meta_tree_branch_2"],
			3: ["synergy_enhancements"],
			4: ["meta_tree_branch_3"],
			5: ["ultimate_synergies"]
		}
	},
	"mission_board": {
		"id": "mission_board",
		"display_name": "Expedition Mission Board",
		"description": "Posts daily bounties, contracts, and planet sector maps.",
		"max_level": 5,
		"level_costs": [0, 150, 400, 1000, 2500],
		"unlocks": {
			1: ["tier1_contracts"],
			2: ["tier2_contracts"],
			3: ["daily_bounties"],
			4: ["tier3_contracts"],
			5: ["boss_hunt_contracts"]
		}
	},
	"merchant_stall": {
		"id": "merchant_stall",
		"display_name": "Starfall Merchant",
		"description": "Buys and sells rare weapons, artifacts, and consumables.",
		"max_level": 5,
		"level_costs": [0, 200, 500, 1200, 3000],
		"unlocks": {
			1: ["common_stock"],
			2: ["uncommon_stock"],
			3: ["rare_artifacts_stock"],
			4: ["epic_gear_stock"],
			5: ["black_market_stock"]
		}
	}
}

static func can_upgrade_facility(facility_id: String, current_level: int, available_credits: int) -> Dictionary:
	if not FACILITIES.has(facility_id):
		return {"can_upgrade": false, "reason": "facility_not_found"}

	var fac = FACILITIES[facility_id]
	var next_level = current_level + 1

	if next_level > fac["max_level"]:
		return {"can_upgrade": false, "reason": "max_level_reached"}

	var cost = fac["level_costs"][next_level - 1]
	if available_credits < cost:
		return {"can_upgrade": false, "reason": "insufficient_credits", "cost": cost}

	return {"can_upgrade": true, "cost": cost, "next_level": next_level}

static func get_unlocked_capabilities(facility_id: String, current_level: int) -> Array:
	if not FACILITIES.has(facility_id):
		return []

	var fac = FACILITIES[facility_id]
	var capabilities: Array = []

	for lvl in range(1, current_level + 1):
		if fac["unlocks"].has(lvl):
			for cap in fac["unlocks"][lvl]:
				capabilities.append(cap)

	return capabilities
