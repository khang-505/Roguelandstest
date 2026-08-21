# scripts/ui/main_menu.gd
class_name MainMenuController
extends Control

## Controls Main Menu interaction.

func _on_start_expedition_pressed() -> void:
	GameManager.start_new_expedition()

func _on_quit_pressed() -> void:
	get_tree().quit()
