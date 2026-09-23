# scripts/ui/game_over_screen.gd
class_name GameOverController
extends Control

## Game Over & Expedition Summary Dialog Controller.

func _ready() -> void:
	var title_label = find_child("TitleLabel", true, false) as Label
	var summary_label = find_child("SummaryLabel", true, false) as Label
	var restart_btn = find_child("RestartButton", true, false) as Button
	var menu_btn = find_child("MenuButton", true, false) as Button

	var is_victory = GameManager.current_state == GameManager.GameState.RESULTS or GameManager.current_state == GameManager.GameState.EXTRACTION
	if title_label:
		title_label.text = "EXPEDITION SUCCESSFUL!" if is_victory else "EXPEDITION ENDED"
		title_label.modulate = Color(0.2, 0.9, 0.4, 1.0) if is_victory else Color(0.9, 0.3, 0.2, 1.0)

	if summary_label:
		var mins = int(GameManager.run_time_seconds) / 60
		var secs = int(GameManager.run_time_seconds) % 60
		summary_label.text = (
			"Expedition Depth: %d\n" +
			"Player Level: %d\n" +
			"Enemies Defeated: %d\n" +
			"Survial Time: %02d:%02d\n" +
			"Credits Gathered: %d\n" +
			"Star-Shards Earned: %d"
		) % [
			GameManager.expedition_depth,
			GameManager.player_level,
			GameManager.enemies_killed,
			mins, secs,
			GameManager.run_credits,
			GameManager.run_shards
		]
		
	var hint_label = find_child("HintLabel", true, false) as Label
	if hint_label:
		var hints = [
			"Tip: Elite enemies (Purple glow) attack much faster. Keep your distance!",
			"Tip: Bosses will enrage at 33% HP. Save your burst damage for the end.",
			"Tip: You keep all gathered materials & shards in your base stash upon extraction.",
			"Tip: Try a different Class Origin if you're struggling to survive.",
			"Tip: Don't forget to visit the Forge in Hub to craft stronger Mk2 weapons."
		]
		hint_label.text = hints[randi() % hints.size()]

	if restart_btn:
		restart_btn.pressed.connect(_on_restart_pressed)
	if menu_btn:
		menu_btn.pressed.connect(_on_menu_pressed)

func _on_restart_pressed() -> void:
	GameManager.restart_expedition()

func _on_menu_pressed() -> void:
	GameManager.change_state(GameManager.GameState.HUB)
