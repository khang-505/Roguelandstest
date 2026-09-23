# scripts/core/character_loadout_validator.gd
class_name CharacterLoadoutValidator
extends Resource

## Quality Score Engine evaluating Character Operatives Catalog, Default Unlocks, Shard Requirements, and Loadout Specs.

static func validate_character_loadouts() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var mgr_script = load("res://scripts/core/character_loadout_manager.gd")
	if not mgr_script:
		warnings.append("CharacterLoadoutManager script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	# 1. 4 Operative Classes Catalog (30 Points)
	var ops = mgr_script.OPERATIVES
	if ops.size() == 4:
		total_score += 30.0
		details["catalog_score"] = 30.0
	else:
		warnings.append("Expected exactly 4 Operatives in catalog, found %d" % ops.size())

	# 2. Default Unlock Check (25 Points)
	var v_unlocked = mgr_script.is_operative_unlocked("vanguard", [])
	var s_locked   = mgr_script.is_operative_unlocked("shadow_assassin", [])

	if v_unlocked and not s_locked:
		total_score += 25.0
		details["default_unlock_score"] = 25.0
	else:
		warnings.append("Default unlock check failed")

	# 3. Shard Unlock Mechanics (25 Points)
	var res_poor = mgr_script.unlock_operative("shadow_assassin", [], 50) # Needs 100
	var res_rich = mgr_script.unlock_operative("shadow_assassin", [], 150)

	if not res_poor.get("success", true) and res_rich.get("success", false) and res_rich.get("cost") == 100:
		total_score += 25.0
		details["shard_unlock_score"] = 25.0
	else:
		warnings.append("Shard unlock mechanics check failed")

	# 4. Operative Starting Loadouts (20 Points)
	var pyro = mgr_script.get_operative("pyromancer")
	if pyro.get("starting_weapon") == "plasma_caster" and pyro.get("starting_ability") == "fire_blast" and pyro.get("starting_artifact") == "pyro_core":
		total_score += 20.0
		details["loadout_specs_score"] = 20.0
	else:
		warnings.append("Operative starting loadout specs mismatch")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
