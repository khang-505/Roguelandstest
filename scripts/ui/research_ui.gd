# scripts/ui/research_ui.gd
class_name ResearchUIController
extends Control

## UI Controller for Research Lab dialog.

func _ready() -> void:
	var close_btn = find_child("CloseButton", true, false) as Button
	if close_btn:
		close_btn.pressed.connect(_on_close_pressed)
	update_display()

func update_display() -> void:
	var status_label = find_child("StatusLabel", true, false) as Label
	if status_label:
		var profile = SaveManager.profile_data
		var shards = profile.get("total_shards", 0)
		var unlocked = profile.get("unlocked_research", [])
		status_label.text = "Star-Shards: %d  |  Unlocked Research: %d" % [shards, unlocked.size()]

func _on_close_pressed() -> void:
	queue_free()
