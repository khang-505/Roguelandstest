# scripts/ui/game_over_screen.gd
class_name GameOverController
extends Control

## Game Over & Expedition Summary Dialog Controller.

@onready var summary_label: Label = $VBoxContainer/SummaryLabel if has_node("VBoxContainer/SummaryLabel") else null

func _ready() -> void:
	if summary_label:
		summary_label.text = "Enemies Neutralized: %d\nCredits Acquired: %d\nStar-Shards Harvested: %d" % [
			GameManager.enemies_killed,
			GameManager.run_credits,
			GameManager.run_shards
		]

func _on_restart_pressed() -> void:
	GameManager.restart_expedition()

func _on_menu_pressed() -> void:
	GameManager.change_state(GameManager.GameState.MAIN_MENU)
