# scripts/ui/main_menu.gd
class_name MainMenuController
extends Control

## Controls Main Menu interaction.

func _ready() -> void:
	var start_btn = find_child("StartButton", true, false) as Button
	var quit_btn = find_child("QuitButton", true, false) as Button
	if start_btn:
		start_btn.pressed.connect(_on_start_expedition_pressed)
	if quit_btn:
		quit_btn.pressed.connect(_on_quit_pressed)

func _on_start_expedition_pressed() -> void:
	GameManager.start_new_expedition()

func _on_quit_pressed() -> void:
	get_tree().quit()
