# scripts/world/weather_validator.gd
class_name WeatherValidator
extends Resource

## Quality Score Engine evaluating Weather Presets, Wind Vectors, Particle Density, and Weather Transition Signals.

static func validate_weather_system() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var ctrl_script = load("res://scripts/world/weather_controller.gd")
	if not ctrl_script:
		warnings.append("WeatherController script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	var ctrl = ctrl_script.new()

	# 1. 4 Presets Catalog Check (30 Points)
	var presets = ctrl_script.PRESETS
	if presets.size() == 4:
		total_score += 30.0
		details["presets_score"] = 30.0
	else:
		warnings.append("Expected 4 weather presets in catalog")

	# 2. Weather Change & Preset Fetching (25 Points)
	ctrl.set_weather(ctrl_script.WeatherType.CRYO_BLIZZARD)
	var active_data = ctrl.get_active_preset()

	if active_data.get("id") == "cryo_blizzard" and active_data.get("density") == 150:
		total_score += 25.0
		details["change_score"] = 25.0
	else:
		warnings.append("Weather change & active preset check failed")

	# 3. Wind Vector & Tint Specifications (25 Points)
	var wind: Vector2 = active_data.get("wind", Vector2.ZERO)
	var tint: Color = active_data.get("tint", Color.WHITE)

	if wind.x < 0.0 and tint.b > 1.0: # Subzero blizzard has leftward wind & blue tint
		total_score += 25.0
		details["spec_score"] = 25.0
	else:
		warnings.append("Wind vector & tint specifications check failed")

	# 4. Signal Emission (20 Points)
	var signal_emitted = false
	ctrl.weather_changed.connect(func(_type, _data): signal_emitted = true)
	ctrl.set_weather(ctrl_script.WeatherType.PLASMA_RAIN)

	if signal_emitted and ctrl.current_weather == ctrl_script.WeatherType.PLASMA_RAIN:
		total_score += 20.0
		details["signal_score"] = 20.0
	else:
		warnings.append("Weather changed signal emission failed")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
