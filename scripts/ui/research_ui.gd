# scripts/ui/research_ui.gd
class_name ResearchUIController
extends Control

## UI Controller for Research Lab dialog.

@onready var status_label: Label = $VBoxContainer/StatusLabel if has_node("VBoxContainer/StatusLabel") else null

func _ready() -> void:
	update_display()

func update_display() -> void:
	if status_label:
		var profile = SaveManager.profile_data
		var shards = profile.get("total_shards", 0)
		var unlocked = profile.get("unlocked_research", [])
		status_label.text = "Star-Shards: %d  |  Unlocked Research: %d" % [shards, unlocked.size()]

func _on_unlock_basic_combat_pressed() -> void:
	ProgressionTree.unlock_research("basic_combat")
	update_display()

func _on_unlock_advanced_combat_pressed() -> void:
	ProgressionTree.unlock_research("advanced_combat")
	update_display()

func _on_close_pressed() -> void:
	visible = false
