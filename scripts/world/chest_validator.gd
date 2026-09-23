# scripts/world/chest_validator.gd
class_name ChestValidator
extends Resource

## Quality Score Engine evaluating Chest Tiers, Locked Mechanics, Mimics, and Loot Multipliers.

static func validate_chests() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var chest_script = load("res://scripts/world/interactive_chest.gd")
	if not chest_script:
		warnings.append("InteractiveChest script not loaded")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	# 1. 4 Tier Creation & Multipliers (30 Points)
	var c_wood = chest_script.new()
	c_wood.tier = chest_script.ChestTier.WOODEN
	
	var c_void = chest_script.new()
	c_void.tier = chest_script.ChestTier.VOID

	var res_w = c_wood.open_chest(false, 0.99)
	var res_v = c_void.open_chest(false, 0.99)

	if res_w.get("tier_multiplier", 0.0) == 1.0 and res_v.get("tier_multiplier", 0.0) == 4.0:
		total_score += 30.0
		details["tiers_score"] = 30.0
	else:
		warnings.append("Tier loot multiplier check failed")

	# 2. Lock & Key Mechanics (25 Points)
	var c_lock = chest_script.new()
	c_lock.is_locked = true
	c_lock.required_key_id = "gold_key"

	var res_locked_no_key = c_lock.open_chest(false, 0.99)
	var res_locked_key = c_lock.open_chest(true, 0.99)

	if not res_locked_no_key.get("success", true) and res_locked_key.get("success", false):
		total_score += 25.0
		details["lock_key_score"] = 25.0
	else:
		warnings.append("Lock & key open verification failed")

	# 3. Mimic Trap Roll (25 Points)
	var c_mimic = chest_script.new()
	c_mimic.mimic_chance = 0.50
	var res_mimic = c_mimic.open_chest(false, 0.10) # Forced roll 0.10 < 0.50 -> Mimic

	if res_mimic.get("is_mimic", false):
		total_score += 25.0
		details["mimic_score"] = 25.0
	else:
		warnings.append("Mimic trap trigger roll failed")

	# 4. Already Opened Protection (20 Points)
	var res_double = c_wood.open_chest(false, 0.99) # Second open call
	if res_double.get("reason") == "already_opened":
		total_score += 20.0
		details["opened_guard_score"] = 20.0
	else:
		warnings.append("Already opened chest guard failed")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
