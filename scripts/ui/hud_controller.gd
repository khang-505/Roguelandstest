# scripts/ui/hud_controller.gd
class_name HUDController
extends Control

## Controls HUD overlay display for player health, energy, loot count, and active weapon.

@onready var hp_bar: ProgressBar = $MarginContainer/VBoxContainer/HBoxContainer/HPBar if has_node("MarginContainer/VBoxContainer/HBoxContainer/HPBar") else null
@onready var hp_text: Label = $MarginContainer/VBoxContainer/HBoxContainer/HPText if has_node("MarginContainer/VBoxContainer/HBoxContainer/HPText") else null
@onready var energy_bar: ProgressBar = $MarginContainer/VBoxContainer/EnergyBar if has_node("MarginContainer/VBoxContainer/EnergyBar") else null
@onready var credits_label: Label = $MarginContainer/VBoxContainer/CreditsLabel if has_node("MarginContainer/VBoxContainer/CreditsLabel") else null
@onready var weapon_label: Label = $MarginContainer/VBoxContainer/WeaponLabel if has_node("MarginContainer/VBoxContainer/WeaponLabel") else null

func _ready() -> void:
	EventBus.player_hp_changed.connect(_on_hp_changed)
	EventBus.player_energy_changed.connect(_on_energy_changed)
	EventBus.loot_collected.connect(_on_loot_collected)
	update_hud_display()

func update_hud_display() -> void:
	_on_hp_changed(GameManager.player_current_hp, GameManager.player_max_hp)
	_on_energy_changed(GameManager.player_current_energy, GameManager.player_max_energy)
	if credits_label:
		credits_label.text = "Credits: %d  |  Shards: %d" % [GameManager.run_credits, GameManager.run_shards]
	if weapon_label:
		weapon_label.text = "Weapon: Plasma Cutter [Physical]"

func _on_hp_changed(current: int, max_val: int) -> void:
	if hp_bar:
		hp_bar.max_value = max_val
		hp_bar.value = current
	if hp_text:
		hp_text.text = "%d / %d" % [current, max_val]

func _on_energy_changed(current: float, max_val: float) -> void:
	if energy_bar:
		energy_bar.max_value = max_val
		energy_bar.value = current

func _on_loot_collected(_id: String, _name: String, _amount: int) -> void:
	if credits_label:
		credits_label.text = "Credits: %d  |  Shards: %d" % [GameManager.run_credits, GameManager.run_shards]
