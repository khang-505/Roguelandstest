# scripts/core/localization_validator.gd
class_name LocalizationValidator
extends Resource

## Quality Score Engine evaluating Multi-Language Locales, Translation Key Resolution, Interpolation, and Fallbacks.

static func validate_localization() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var eng_script = load("res://scripts/core/localization_engine.gd")
	if not eng_script:
		warnings.append("LocalizationEngine script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	var eng = eng_script.new()

	# 1. 4 Supported Locales (30 Points)
	var locales = eng_script.LOCALES
	if locales.size() == 4:
		total_score += 30.0
		details["locales_score"] = 30.0
	else:
		warnings.append("Expected 4 supported locales in catalog")

	# 2. Locale Switching & Translation (25 Points)
	eng.set_locale("vi")
	var tr_vi = eng.translate("HUD_HEALTH")

	if tr_vi == "Máu":
		total_score += 25.0
		details["translation_score"] = 25.0
	else:
		warnings.append("Vietnamese locale translation check failed (Got '%s')" % tr_vi)

	# 3. String Interpolation (25 Points)
	var tr_interp = eng.translate("MSG_LEVEL_UP", {"level": 10})
	if tr_interp == "Lên Cấp! Đạt Cấp 10":
		total_score += 25.0
		details["interpolation_score"] = 25.0
	else:
		warnings.append("String parameter interpolation check failed (Got '%s')" % tr_interp)

	# 4. Fallback to English Guard (20 Points)
	eng.set_locale("es")
	# Fallback check for missing key in Spanish
	var tr_fallback = eng.translate("NON_EXISTENT_KEY")
	if tr_fallback == "NON_EXISTENT_KEY":
		total_score += 20.0
		details["fallback_guard_score"] = 20.0
	else:
		warnings.append("Missing key fallback guard failed")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
