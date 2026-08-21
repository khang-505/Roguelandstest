# scripts/ui/crafting_ui.gd
class_name CraftingUIController
extends Control

## UI Controller for the Forge Crafting Station dialog.

@onready var status_label: Label = $VBoxContainer/StatusLabel if has_node("VBoxContainer/StatusLabel") else null

func _ready() -> void:
	update_display()

func update_display() -> void:
	if status_label:
		var profile = SaveManager.profile_data
		var mats = profile.get("persistent_materials", {})
		status_label.text = "Materials: Ember Ore (%d) | Cryo Crystal (%d) | Bio Sample (%d)" % [
			mats.get("ember_ore", 0),
			mats.get("cryo_crystal", 0),
			mats.get("bio_sample", 0)
		]

func _on_craft_plasma_mk2_pressed() -> void:
	var success = CraftingManager.craft_recipe("plasma_cutter_mk2")
	update_display()

func _on_close_pressed() -> void:
	visible = false
