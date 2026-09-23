# scripts/combat/damage_number_validator.gd
class_name DamageNumberValidator
extends Resource

## Quality Score Engine evaluating Floating Damage Number Formatting, Color Coding, Crit Scaling, and Queue Capping.

static func validate_damage_numbers() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var eng_script = load("res://scripts/combat/damage_number_engine.gd")
	if not eng_script:
		warnings.append("DamageNumberEngine script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	# 1. Damage Number Formatting & Colors (30 Points)
	var fire_data = eng_script.format_number_data(45.0, "FIRE", false)
	var crit_data = eng_script.format_number_data(120.0, "PHYSICAL", true)

	if fire_data.get("color") == Color(1.0, 0.4, 0.0) and crit_data.get("scale") == 1.6 and crit_data.get("is_bold"):
		total_score += 30.0
		details["formatting_score"] = 30.0
	else:
		warnings.append("Damage number color coding or crit scale check failed")

	# 2. Heal & Shield Formatting (25 Points)
	var heal_data = eng_script.format_number_data(25.0, "PHYSICAL", false, false, true)
	var shield_data = eng_script.format_number_data(40.0, "PHYSICAL", false, true, false)

	if heal_data.get("text") == "+25" and shield_data.get("color") == Color(0.0, 0.6, 1.0):
		total_score += 25.0
		details["special_format_score"] = 25.0
	else:
		warnings.append("Heal or shield formatting check failed")

	# 3. Queue Number & Buffer Cap (25 Points)
	eng_script.clear_queue()
	for i in range(250): # Queue 250 items (> 200 cap)
		eng_script.queue_number(Vector2(i, i), 10.0, "PHYSICAL", false)

	var queue = eng_script.get_active_queue()
	if queue.size() == 200: # Capped at 200
		total_score += 25.0
		details["queue_cap_score"] = 25.0
	else:
		warnings.append("Active damage number queue buffer cap failed (Size %d)" % queue.size())

	# 4. Clear Queue (20 Points)
	eng_script.clear_queue()
	if eng_script.get_active_queue().size() == 0:
		total_score += 20.0
		details["clear_queue_score"] = 20.0
	else:
		warnings.append("Clear queue failed")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
