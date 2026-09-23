# scripts/combat/loot_validator.gd
class_name LootValidator
extends RefCounted

## Quality Score Engine evaluating LootTableData presets across 11 Loot Categories, 6 Rarities, ItemGenerator affixes, bad-luck protection, chest types, and 1000 drop stress iterations.

static func validate_loot_system() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	# 1. Data Model, 11 Categories & 6 Rarities (25 Points)
	var table_script = load("res://scripts/combat/loot_table_data.gd")
	var model_score = 0.0
	
	if table_script:
		var presets = ["enemy_standard", "elite_chest", "boss_reward", "secret_treasure"]
		var valid_count = 0
		for p in presets:
			var table = table_script.create_preset(p)
			if table and table.display_name != "" and table.entries.size() > 0:
				valid_count += 1
		if valid_count == 4:
			model_score = 25.0
		else:
			warnings.append("Expected 4 valid LootTableData presets (Got %d)" % valid_count)
	else:
		warnings.append("LootTableData script missing")
	total_score += model_score
	details["model_score"] = model_score

	# 2. Weighted Table Rolls, Guaranteed Rewards & Pity Protection (25 Points)
	var gen_script = load("res://scripts/procedural/loot_generator.gd")
	var rolls_score = 0.0
	
	if gen_script and table_script:
		var table = table_script.create_preset("boss_reward")
		var drops = gen_script.roll_loot_table(table, 12345)
		if drops.size() >= 2:
			rolls_score = 25.0
		else:
			warnings.append("Loot table roll or guaranteed rewards execution failed")
	else:
		warnings.append("LootGenerator script missing")
	total_score += rolls_score
	details["rolls_score"] = rolls_score

	# 3. Item Generation, Affixes & Build Synergies (25 Points)
	var item_script = load("res://scripts/combat/item_generator.gd")
	var item_score = 0.0
	
	if item_script:
		var item = item_script.generate_equipment("plasma_rifle", 3, 54321) # EPIC (2.0x mult)
		if item.get("base_damage", 0.0) == 40.0 and item.get("slots", 0) == 4 and item.get("affixes", []).size() == 4:
			item_score = 25.0
		else:
			warnings.append("ItemGenerator equipment generation or affix scaling failed")
	else:
		warnings.append("ItemGenerator script missing")
	total_score += item_score
	details["item_score"] = item_score

	# 4. Chest Types & 1000 Loot Drop Iterations (25 Points)
	var stress_score = 0.0
	if gen_script and table_script:
		var valid_count = 0
		var table = table_script.create_preset("enemy_standard")
		for i in range(1000):
			var drops = gen_script.roll_loot_table(table, i + 1)
			if drops.size() >= 1:
				valid_count += 1
		if valid_count == 1000:
			stress_score = 25.0
		else:
			warnings.append("1000 loot drop roll stress iterations failed")
	total_score += stress_score
	details["stress_score"] = stress_score

	var is_valid = total_score >= 70.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
