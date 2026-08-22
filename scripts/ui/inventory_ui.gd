# scripts/ui/inventory_ui.gd
class_name InventoryUIController
extends Control

## Shows player inventory, persistent resources, and profile stats.

@onready var stats_label: Label = find_child("StatsLabel", true, false) as Label
@onready var close_button: Button = find_child("CloseButton", true, false) as Button

func _ready() -> void:
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	update_display()

func update_display() -> void:
	var stats = find_child("StatsLabel", true, false) as Label
	if stats == null:
		return
	var profile = SaveManager.profile_data
	var origin_id = profile.get("active_origin", "vanguard")
	var origin = OriginData.get_origin(origin_id)
	var mats = profile.get("persistent_materials", {})
	
	var text = "=== OPERATIVE PROFILE ===\n"
	text += "Origin: %s\n" % origin.display_name
	text += "Total Credits: %d\n" % profile.get("total_credits", 0)
	text += "Star-Shards: %d\n" % profile.get("total_shards", 0)
	text += "Hub Level: %d\n\n" % profile.get("hub_level", 1)
	text += "=== PERSISTENT MATERIALS ===\n"
	text += "Ember Ore: %d\n" % mats.get("ember_ore", 0)
	text += "Cryo Crystal: %d\n" % mats.get("cryo_crystal", 0)
	text += "Bio Sample: %d\n" % mats.get("bio_sample", 0)
	text += "Star Shards: %d\n" % mats.get("star_shard", 0)
	
	stats.text = text

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.physical_keycode == KEY_I):
		_on_close_pressed()

func _on_close_pressed() -> void:
	queue_free()
