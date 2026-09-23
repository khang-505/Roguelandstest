# scripts/combat/hit_reaction_validator.gd
class_name HitReactionValidator
extends RefCounted

## Quality Score Engine evaluating HitReactionData presets across 12 Reaction Types, 5 Target Weight categories, Wall Bounce math, Hitstop duration calculations, and 1000 stress iterations.

static func validate_hit_reactions() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	# 1. 12 Reaction Types & HitReactionData Model (25 Points)
	var data_script = load("res://scripts/combat/hit_reaction_data.gd")
	var types_score = 0.0
	
	if data_script:
		var valid_count = 0
		for t in range(12):
			var data = data_script.create_preset(t)
			if data and data.display_name != "" and data.duration > 0.0:
				valid_count += 1
		if valid_count == 12:
			types_score = 25.0
		else:
			warnings.append("Expected 12 valid HitReactionData presets (Got %d)" % valid_count)
	else:
		warnings.append("HitReactionData script missing")
	total_score += types_score
	details["types_score"] = types_score

	# 2. Target Weight Scaling & Force Math (25 Points)
	var engine_script = load("res://scripts/combat/hit_reaction_engine.gd")
	var weight_score = 0.0
	
	if engine_script:
		var light_imp = engine_script.calculate_knockback_impulse(200.0, 0.0, Vector2.RIGHT, 0) # LIGHT (0.5 mass)
		var heavy_imp = engine_script.calculate_knockback_impulse(200.0, 0.0, Vector2.RIGHT, 2) # HEAVY (2.0 mass)
		var boss_imp = engine_script.calculate_knockback_impulse(200.0, 0.0, Vector2.RIGHT, 4) # BOSS (10.0 mass recoil)
		
		if light_imp.x >= 3.5 * heavy_imp.x and boss_imp.x == 20.0:
			weight_score = 25.0
		else:
			warnings.append("Target weight knockback scaling or boss recoil math failed")
	else:
		warnings.append("HitReactionEngine script missing")
	total_score += weight_score
	details["weight_score"] = weight_score

	# 3. Wall Bounce & Boundary Safeguards (25 Points)
	var wall_score = 0.0
	if engine_script:
		var bounce_res = engine_script.calculate_wall_bounce(Vector2(400.0, 0.0), Vector2.LEFT)
		if bounce_res.get("is_wall_bounce", false) and bounce_res.get("impact_damage", 0.0) == 60.0:
			wall_score = 25.0
		else:
			warnings.append("Wall Bounce velocity reflection or impact damage math failed")
	total_score += wall_score
	details["wall_score"] = wall_score

	# 4. Hitstop & 1000 Stress Iterations (25 Points)
	var stress_score = 0.0
	if engine_script and data_script:
		var valid_count = 0
		var h_data = data_script.create_preset(1) # HEAVY_HIT
		for i in range(1000):
			var res = engine_script.process_hit_reaction(null, null, h_data, Vector2.RIGHT, i % 2 == 0)
			if res.has("impulse") and res.get("hit_stop_duration", 0.0) > 0.0:
				valid_count += 1
		if valid_count == 1000:
			stress_score = 25.0
		else:
			warnings.append("1000 hit reaction stress calculations failed")
	total_score += stress_score
	details["stress_score"] = stress_score

	var is_valid = total_score >= 70.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
