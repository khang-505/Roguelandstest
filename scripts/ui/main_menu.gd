# scripts/ui/main_menu.gd
class_name MainMenuController
extends Control

## Controls Main Menu interaction.

@onready var start_button: Button = $VBoxContainer/StartButton if has_node("VBoxContainer/StartButton") else null
@onready var quit_button: Button = $VBoxContainer/QuitButton if has_node("VBoxContainer/QuitButton") else null

func _ready() -> void:
	if start_button and not start_button.pressed.is_connected(_on_start_expedition_pressed):
		start_button.pressed.connect(_on_start_expedition_pressed)
	if quit_button and not quit_button.pressed.is_connected(_on_quit_pressed):
		quit_button.pressed.connect(_on_quit_pressed)

func _on_start_expedition_pressed() -> void:
	GameManager.start_new_expedition()

func _on_quit_pressed() -> void:
	get_tree().quit()
