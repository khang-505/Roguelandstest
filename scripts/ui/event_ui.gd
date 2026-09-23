# scripts/ui/event_ui.gd
class_name EventUI
extends Control

## UI Modal rendering non-combat event choices and processing outcomes.

signal event_finished()

@onready var title_label: Label = find_child("TitleLabel", true, false) as Label
@onready var desc_label: Label = find_child("DescLabel", true, false) as Label
@onready var options_container: VBoxContainer = find_child("OptionsContainer", true, false) as VBoxContainer

var event_data: Dictionary

func setup_event(data: Dictionary) -> void:
	event_data = data
	if title_label: title_label.text = data.get("title", "Event")
	if desc_label: desc_label.text = data.get("description", "")
	_build_options()

func _build_options() -> void:
	if options_container == null:
		return
	for c in options_container.get_children():
		c.queue_free()

	var options = event_data.get("options", [])
	for opt in options:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(320, 44)
		btn.text = opt["text"]
		var act = opt["action"]
		btn.pressed.connect(func(): _on_option_selected(act))
		options_container.add_child(btn)

func _on_option_selected(action: String) -> void:
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_sfx"): am.play_sfx("pickup")
	_execute_action(action)
	event_finished.emit()
	queue_free()

func _execute_action(action: String) -> void:
	var tree = get_tree()
	var players = tree.get_nodes_in_group("player") if tree else []
	var player = players[0] if players.size() > 0 else null

	match action:
		"shrine_power":
			if player and "bonus_attack_stat" in player:
				player.bonus_attack_stat += 8
				player.max_hp = max(10, int(player.max_hp * 0.85))
				player.current_hp = min(player.current_hp, player.max_hp)
				EventBus.player_hp_changed.emit(player.current_hp, player.max_hp)
		"shrine_credits":
			GameManager.add_to_backpack("credit", "credit", 15)
		"repair_bot":
			if GameManager.backpack_credits >= 50:
				GameManager.backpack_credits -= 50
				GameManager.add_to_backpack("frost_rifle", "equipment", 1)
		"scrap_bot":
			GameManager.add_to_backpack("ember_ore", "material", 3)
		"buy_stim":
			if GameManager.backpack_credits >= 100:
				GameManager.backpack_credits -= 100
				if player and player.get("current_weapon") and player.current_weapon:
					player.current_weapon.critical_chance += 0.10
		"heal_full":
			if GameManager.backpack_credits >= 50:
				GameManager.backpack_credits -= 50
				if player:
					player.current_hp = player.max_hp
					EventBus.player_hp_changed.emit(player.current_hp, player.max_hp)
