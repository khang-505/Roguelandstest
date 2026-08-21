# scripts/ui/settings_menu.gd
class_name SettingsMenuController
extends Control

## User Settings Manager & UI Controller for Accessibility and Audio options.

const SETTINGS_PATH: String = "user://settings.json"

static var user_settings: Dictionary = {
	"screen_shake_enabled": true,
	"flash_reduction_enabled": false,
	"colorblind_mode": false,
	"master_volume": 1.0,
	"music_volume": 0.8,
	"sfx_volume": 1.0,
	"aim_assist_enabled": true
}

@onready var status_label: Label = $VBoxContainer/StatusLabel if has_node("VBoxContainer/StatusLabel") else null

func _ready() -> void:
	load_settings()
	update_display()

static func save_settings() -> bool:
	var json_string = JSON.stringify(user_settings, "\t")
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(json_string)
	file.close()
	return true

static func load_settings() -> bool:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return false
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return false
	var json_string = file.get_as_text()
	file.close()
	var json = JSON.new()
	if json.parse(json_string) == OK:
		var dict = json.get_data()
		if typeof(dict) == TYPE_DICTIONARY:
			user_settings = dict
			return true
	return false

func update_display() -> void:
	if status_label:
		status_label.text = "Screen Shake: %s | Colorblind: %s | Master Vol: %d%%" % [
			"ON" if user_settings.get("screen_shake_enabled", true) else "OFF",
			"ON" if user_settings.get("colorblind_mode", false) else "OFF",
			int(user_settings.get("master_volume", 1.0) * 100)
		]

func _on_toggle_screen_shake_pressed() -> void:
	var curr = user_settings.get("screen_shake_enabled", true)
	user_settings["screen_shake_enabled"] = not curr
	save_settings()
	update_display()

func _on_toggle_colorblind_pressed() -> void:
	var curr = user_settings.get("colorblind_mode", false)
	user_settings["colorblind_mode"] = not curr
	save_settings()
	update_display()

func _on_close_pressed() -> void:
	visible = false
