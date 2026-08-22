# scripts/ui/game_over_screen.gd
class_name GameOverController
extends Control

## Game Over & Expedition Summary Dialog Controller.

func _ready() -> void:
	var summary_label = find_child("SummaryLabel", true, false) as Label
	var restart_btn = find_child("RestartButton", true, false) as Button
	var menu_btn = find_child("MenuButton", true, false) as Button

	if summary_label:
		summary_label.text = "Enemies: %d\nCredits: %d\nShards: %d" % [
			GameManager.enemies_killed,
			GameManager.run_credits,
			GameManager.run_shards
		]

	if restart_btn:
		restart_btn.pressed.connect(_on_restart_pressed)
	if menu_btn:
		menu_btn.pressed.connect(_on_menu_pressed)

func _on_restart_pressed() -> void:
	GameManager.restart_expedition()

func _on_menu_pressed() -> void:
	GameManager.change_state(GameManager.GameState.MAIN_MENU)
