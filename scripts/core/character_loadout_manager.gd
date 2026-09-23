# scripts/core/character_loadout_manager.gd
class_name CharacterLoadoutManager
extends Resource

## Operative Character Class Registry & Loadout Unlock System.

static var OPERATIVES: Dictionary = {
	"vanguard": {
		"id": "vanguard",
		"display_name": "Iron Vanguard",
		"archetype": "Juggernaut Tank",
		"description": "Heavy assault operative with high defensive shields and heavy armor.",
		"unlocked_by_default": true,
		"unlock_cost_shards": 0,
		"starting_weapon": "iron_blade",
		"starting_ability": "invuln_shield",
		"starting_artifact": "titan_girdle",
		"base_stats": {"hp": 120, "defense": 10, "attack": 12, "speed": 180.0, "crit_chance": 0.05}
	},
	"shadow_assassin": {
		"id": "shadow_assassin",
		"display_name": "Shadow Assassin",
		"archetype": "Void Skirmisher",
		"description": "Hyper-agile assassin specializing in rapid critical strikes and dash stealth.",
		"unlocked_by_default": false,
		"unlock_cost_shards": 100,
		"starting_weapon": "laser_daggers",
		"starting_ability": "blink_teleport",
		"starting_artifact": "shadow_ring",
		"base_stats": {"hp": 85, "defense": 2, "attack": 18, "speed": 240.0, "crit_chance": 0.18}
	},
	"pyromancer": {
		"id": "pyromancer",
		"display_name": "Flame Archon",
		"archetype": "Pyromancer Mage",
		"description": "Wields intense thermal weaponry, igniting rooms with burn explosions.",
		"unlocked_by_default": false,
		"unlock_cost_shards": 150,
		"starting_weapon": "plasma_caster",
		"starting_ability": "fire_blast",
		"starting_artifact": "pyro_core",
		"base_stats": {"hp": 95, "defense": 4, "attack": 22, "speed": 190.0, "crit_chance": 0.10}
	},
	"cryomancer": {
		"id": "cryomancer",
		"display_name": "Frost Warden",
		"archetype": "Cryomancer Controller",
		"description": "Controls battlefield distance with freezing blasts and subzero barriers.",
		"unlocked_by_default": false,
		"unlock_cost_shards": 200,
		"starting_weapon": "frost_rifle",
		"starting_ability": "freeze_nova",
		"starting_artifact": "frost_clasp",
		"base_stats": {"hp": 105, "defense": 8, "attack": 14, "speed": 195.0, "crit_chance": 0.08}
	}
}

static func get_operative(id: String) -> Dictionary:
	if OPERATIVES.has(id):
		return OPERATIVES[id].duplicate()
	return {}

static func is_operative_unlocked(id: String, unlocked_list: Array) -> bool:
	if not OPERATIVES.has(id):
		return false
	var op = OPERATIVES[id]
	if op["unlocked_by_default"]:
		return true
	return unlocked_list.has(id)

static func unlock_operative(id: String, unlocked_list: Array, available_shards: int) -> Dictionary:
	if not OPERATIVES.has(id):
		return {"success": false, "reason": "operative_not_found"}
	if is_operative_unlocked(id, unlocked_list):
		return {"success": false, "reason": "already_unlocked"}

	var op = OPERATIVES[id]
	var cost = int(op["unlock_cost_shards"])
	if available_shards < cost:
		return {"success": false, "reason": "insufficient_shards", "cost": cost}

	return {"success": true, "cost": cost, "operative_id": id}
