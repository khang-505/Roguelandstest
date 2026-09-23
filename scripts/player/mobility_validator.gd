# scripts/player/mobility_validator.gd
class_name MobilityValidator
extends RefCounted

## Quality Score Engine evaluating MobilityProfile reach math, DashController charge pipelines, i-frames, breakable interactions, and 1000 procedural traversal stress checks.

static func validate_mobility() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	# 1. MobilityProfile Reach Math (25 Points)
	var profile_script = load("res://scripts/player/mobility_profile.gd")
	var profile_score = 0.0
	if profile_script:
		var profile = profile_script.new(220.0, 96.0, 160.0, 140.0, 2, true)
		var horiz_reach = profile.get_max_horizontal_reach() # 160 + (140 * 2) = 440
		var vert_reach = profile.get_max_vertical_reach() # 96 * 2 + 70 = 262
		
		if horiz_reach == 440.0 and vert_reach == 262.0 and profile.can_traverse_gap(400.0) and not profile.can_traverse_gap(500.0):
			profile_score = 25.0
		else:
			warnings.append("MobilityProfile reach calculation mismatch")
	else:
		warnings.append("MobilityProfile script missing")
	total_score += profile_score
	details["profile_score"] = profile_score

	# 2. DashController Charge Pipeline & Input Buffer (25 Points)
	var controller_script = load("res://scripts/player/dash_controller.gd")
	var pipeline_score = 0.0
	if controller_script and profile_script:
		var profile = profile_script.new(220.0, 96.0, 160.0, 140.0, 2, true)
		var controller = controller_script.new(profile)
		
		var dash1 = controller.attempt_dash(Vector2.RIGHT)
		var dash2 = controller.attempt_dash(Vector2.RIGHT)
		var dash3 = controller.attempt_dash(Vector2.RIGHT) # Should fail
		
		if dash1.get("success", false) and dash2.get("success", false) and not dash3.get("success", false):
			controller.update(profile.dash_cooldown + 0.05)
			if controller.current_charges == 1:
				pipeline_score = 25.0
			else:
				warnings.append("Dash charge recovery timer failed")
		else:
			warnings.append("Multi-charge dash depletion pipeline failed")
	else:
		warnings.append("DashController script missing")
	total_score += pipeline_score
	details["pipeline_score"] = pipeline_score

	# 3. Combat Integration & Invulnerability i-Frames (25 Points)
	var combat_score = 0.0
	if controller_script and profile_script:
		var profile = profile_script.new()
		var controller = controller_script.new(profile)
		controller.attempt_dash(Vector2.RIGHT)
		
		var is_invuln = controller.is_invulnerable()
		var attack_res = controller.trigger_dash_attack()
		var break_res = controller.check_breakable_collision(null)
		
		if is_invuln and attack_res.get("success", false) and break_res:
			combat_score = 25.0
		else:
			warnings.append("Dash combat strike, i-frames, or breakable barrier collision failed")
	total_score += combat_score
	details["combat_score"] = combat_score

	# 4. 1000 Procedural Traversal & Level Design Checks (25 Points)
	var procedural_score = 0.0
	if profile_script:
		var profile = profile_script.new()
		var biomes = ["Jungle", "Mine", "Machine", "Frozen"]
		var successful_traversals = 0
		
		for i in range(1000):
			var biome = biomes[i % biomes.size()]
			var gap_width = 100.0 + float(i % 300) # Gap range 100px to 400px (Max reach is 440px)
			var vert_height = 50.0 + float(i % 200) # Vertical height range 50px to 250px (Max reach is 262px)
			
			match biome:
				"Jungle":
					if profile.can_traverse_height(vert_height):
						successful_traversals += 1
				"Mine":
					if profile.can_traverse_gap(gap_width):
						successful_traversals += 1
				"Machine":
					if profile.can_traverse_gap(gap_width * 0.8) and profile.can_traverse_height(vert_height * 0.8):
						successful_traversals += 1
				"Frozen":
					if profile.can_traverse_gap(gap_width) and profile.air_dash:
						successful_traversals += 1
						
		if successful_traversals == 1000:
			procedural_score = 25.0
		else:
			warnings.append("Procedural traversal reachability check failed (Passed %d/1000)" % successful_traversals)
	total_score += procedural_score
	details["procedural_score"] = procedural_score

	var is_valid = total_score >= 70.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
