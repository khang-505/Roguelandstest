# scripts/core/meta_progression_tree.gd
class_name MetaProgressionTree
extends Resource

## Persistent Skill Tree Node Network managing permanent meta-progression upgrades, prerequisites, ranks, and currency spending.

signal node_upgraded(node_id: String, new_rank: int)

static var TREE_NODES: Dictionary = {
	# OFFENSE BRANCH
	"off_atk_1": {
		"id": "off_atk_1",
		"branch": "OFFENSE",
		"display_name": "Kinetic Calibration",
		"description": "+5% Attack Damage per rank.",
		"prerequisites": [],
		"max_rank": 5,
		"cost_per_rank": 100,
		"currency_type": "credits",
		"stat_key": "bonus_attack_mult",
		"stat_value": 0.05
	},
	"off_crit_1": {
		"id": "off_crit_1",
		"branch": "OFFENSE",
		"display_name": "Targeting Matrix",
		"description": "+2% Critical Chance per rank.",
		"prerequisites": ["off_atk_1"],
		"max_rank": 5,
		"cost_per_rank": 200,
		"currency_type": "shards",
		"stat_key": "bonus_crit_flat",
		"stat_value": 0.02
	},

	# DEFENSE BRANCH
	"def_hp_1": {
		"id": "def_hp_1",
		"branch": "DEFENSE",
		"display_name": "Subdermal Plating",
		"description": "+20 Max Health per rank.",
		"prerequisites": [],
		"max_rank": 5,
		"cost_per_rank": 100,
		"currency_type": "credits",
		"stat_key": "bonus_hp_flat",
		"stat_value": 20
	},
	"def_armor_1": {
		"id": "def_armor_1",
		"branch": "DEFENSE",
		"display_name": "Aegis Weave",
		"description": "+4 Armor Defense per rank.",
		"prerequisites": ["def_hp_1"],
		"max_rank": 5,
		"cost_per_rank": 150,
		"currency_type": "credits",
		"stat_key": "bonus_defense_flat",
		"stat_value": 4
	},

	# ECONOMY BRANCH
	"eco_credit_1": {
		"id": "eco_credit_1",
		"branch": "ECONOMY",
		"display_name": "Scavenger Protocol",
		"description": "+10% Credit drop gains per rank.",
		"prerequisites": [],
		"max_rank": 3,
		"cost_per_rank": 200,
		"currency_type": "credits",
		"stat_key": "credit_gain_mult",
		"stat_value": 0.10
	},

	# UTILITY BRANCH
	"uti_dash_1": {
		"id": "uti_dash_1",
		"branch": "UTILITY",
		"display_name": "Hydraulic Thrusters",
		"description": "+10 Movement Speed per rank.",
		"prerequisites": [],
		"max_rank": 3,
		"cost_per_rank": 150,
		"currency_type": "credits",
		"stat_key": "bonus_speed_flat",
		"stat_value": 10.0
	}
}

static func can_upgrade_node(node_id: String, current_ranks: Dictionary, available_credits: int, available_shards: int) -> Dictionary:
	if not TREE_NODES.has(node_id):
		return {"can_upgrade": false, "reason": "node_not_found"}

	var node = TREE_NODES[node_id]
	var current_rank = int(current_ranks.get(node_id, 0))

	if current_rank >= node["max_rank"]:
		return {"can_upgrade": false, "reason": "max_rank_reached"}

	# Check prerequisites
	for prereq in node["prerequisites"]:
		if int(current_ranks.get(prereq, 0)) < 1:
			return {"can_upgrade": false, "reason": "prerequisite_missing", "prereq": prereq}

	# Check cost
	var cost = node["cost_per_rank"] * (current_rank + 1)
	if node["currency_type"] == "credits" and available_credits < cost:
		return {"can_upgrade": false, "reason": "insufficient_credits", "cost": cost}
	elif node["currency_type"] == "shards" and available_shards < cost:
		return {"can_upgrade": false, "reason": "insufficient_shards", "cost": cost}

	return {"can_upgrade": true, "cost": cost, "currency_type": node["currency_type"]}

static func calculate_meta_tree_bonuses(current_ranks: Dictionary) -> Dictionary:
	var bonuses = {
		"bonus_attack_mult": 0.0,
		"bonus_crit_flat": 0.0,
		"bonus_hp_flat": 0,
		"bonus_defense_flat": 0,
		"credit_gain_mult": 0.0,
		"bonus_speed_flat": 0.0
	}

	for node_id in current_ranks.keys():
		var rank = int(current_ranks[node_id])
		if rank <= 0 or not TREE_NODES.has(node_id):
			continue
		var node = TREE_NODES[node_id]
		var stat_key = node["stat_key"]
		var val = node["stat_value"] * rank

		if bonuses.has(stat_key):
			bonuses[stat_key] += val

	return bonuses
