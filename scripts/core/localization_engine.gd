# scripts/core/localization_engine.gd
class_name LocalizationEngine
extends Resource

## Data-driven Multi-Language Translation Manager supporting EN, VI, ES, and JA with string interpolation & fallbacks.

signal locale_changed(new_locale: String)

static var LOCALES: Array[String] = ["en", "vi", "es", "ja"]

static var TRANSLATIONS: Dictionary = {
	"en": {
		"HUD_HEALTH": "Health",
		"HUD_SHIELD": "Shield",
		"UI_PLAY": "Start Expedition",
		"UI_SETTINGS": "Settings",
		"UI_QUIT": "Quit Game",
		"MSG_LEVEL_UP": "Level Up! Reached Level {level}",
		"MSG_CREDITS": "Credits: {amount}"
	},
	"vi": {
		"HUD_HEALTH": "Máu",
		"HUD_SHIELD": "Giáp Chắn",
		"UI_PLAY": "Bắt Đầu Thám Hiểm",
		"UI_SETTINGS": "Cài Đặt",
		"UI_QUIT": "Thoát Game",
		"MSG_LEVEL_UP": "Lên Cấp! Đạt Cấp {level}",
		"MSG_CREDITS": "Credits: {amount}"
	},
	"es": {
		"HUD_HEALTH": "Salud",
		"HUD_SHIELD": "Escudo",
		"UI_PLAY": "Iniciar Expedición",
		"UI_SETTINGS": "Opciones",
		"UI_QUIT": "Salir",
		"MSG_LEVEL_UP": "¡Nivel Consegido! Nivel {level}",
		"MSG_CREDITS": "Créditos: {amount}"
	},
	"ja": {
		"HUD_HEALTH": "体力",
		"HUD_SHIELD": "シールド",
		"UI_PLAY": "遠征開始",
		"UI_SETTINGS": "設定",
		"UI_QUIT": "終了",
		"MSG_LEVEL_UP": "レベルアップ！レベル {level} に到達",
		"MSG_CREDITS": "クレジット: {amount}"
	}
}

@export var current_locale: String = "en"

func set_locale(locale: String) -> bool:
	if not LOCALES.has(locale):
		return false
	current_locale = locale
	locale_changed.emit(locale)
	return true

func translate(key: String, params: Dictionary = {}) -> String:
	var loc_dict = TRANSLATIONS.get(current_locale, TRANSLATIONS["en"])
	var text = ""

	if loc_dict.has(key):
		text = loc_dict[key]
	elif TRANSLATIONS["en"].has(key):
		text = TRANSLATIONS["en"][key] # Fallback to English
	else:
		return key # Key missing

	# String parameter interpolation
	for p_key in params.keys():
		var placeholder = "{" + str(p_key) + "}"
		text = text.replace(placeholder, str(params[p_key]))

	return text
