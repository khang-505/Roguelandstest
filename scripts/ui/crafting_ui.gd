# scripts/ui/crafting_ui.gd
class_name CraftingUIController
extends Control

## UI Controller for the Forge Crafting Station dialog.

func _ready() -> void:
	var craft_btn = find_child("CraftButton", true, false) as Button
	var close_btn = find_child("CloseButton", true, false) as Button
	
	if craft_btn:
		craft_btn.pressed.connect(_on_craft_plasma_mk2_pressed)
	if close_btn:
		close_btn.pressed.connect(_on_close_pressed)
		
	update_display()

func update_display() -> void:
	var status_label = find_child("StatusLabel", true, false) as Label
	if status_label:
		var profile = SaveManager.profile_data
		var mats = profile.get("persistent_materials", {})
		status_label.text = "Materials: Ember Ore (%d) | Cryo Crystal (%d) | Bio Sample (%d)" % [
			mats.get("ember_ore", 0),
			mats.get("cryo_crystal", 0),
			mats.get("bio_sample", 0)
		]

func _on_craft_plasma_mk2_pressed() -> void:
	CraftingManager.craft_recipe("plasma_cutter_mk2")
	update_display()

func _on_close_pressed() -> void:
	queue_free()
