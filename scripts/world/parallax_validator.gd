# scripts/world/parallax_validator.gd
class_name ParallaxValidator
extends Resource

## Quality Score Engine evaluating Parallax Layers, Scroll Factors, Camera Position Calculation, and Biome Palettes.

static func validate_parallax_system() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var ctrl_script = load("res://scripts/world/parallax_background_controller.gd")
	if not ctrl_script:
		warnings.append("ParallaxBackgroundController script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	var ctrl = ctrl_script.new()

	# 1. 4 Depth Layers & Scroll Factors (30 Points)
	var factors = ctrl_script.LAYER_SCROLL_FACTORS
	if factors.size() == 4 and factors[ctrl_script.ParallaxLayer.SKY] == Vector2.ZERO:
		total_score += 30.0
		details["layers_score"] = 30.0
	else:
		warnings.append("4 depth layers & sky zero scroll check failed")

	# 2. Camera Offset Calculation (25 Points)
	var cam_pos = Vector2(1000.0, 500.0)
	var near_offset = ctrl.calculate_layer_offset(ctrl_script.ParallaxLayer.NEAR_RUINS, cam_pos) # factor (0.80, 0.50) -> (800, 250)

	if is_equal_approx(near_offset.x, 800.0) and is_equal_approx(near_offset.y, 250.0):
		total_score += 25.0
		details["offset_calc_score"] = 25.0
	else:
		warnings.append("Parallax layer offset calculation failed")

	# 3. Biome Palettes Check (25 Points)
	var cryo_sky_color = ctrl.get_layer_color(ctrl_script.ParallaxLayer.SKY, "cryo")
	if cryo_sky_color.b > cryo_sky_color.r:
		total_score += 25.0
		details["biome_palettes_score"] = 25.0
	else:
		warnings.append("Biome palette color retrieval failed")

	# 4. Fallback Biome Palette Guard (20 Points)
	var fallback_color = ctrl.get_layer_color(ctrl_script.ParallaxLayer.SKY, "non_existent_biome")
	if fallback_color != Color.WHITE:
		total_score += 20.0
		details["fallback_guard_score"] = 20.0
	else:
		warnings.append("Fallback biome palette guard failed")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
