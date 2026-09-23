# scripts/ui/hud_controller.gd
class_name HUDController
extends Control

## Controls HUD overlay display for player health, energy, realtime backpack inventory, loot popups, and active stats.

@onready var hp_bar: ProgressBar = $MarginContainer/VBoxContainer/HBoxContainer/HPBar if has_node("MarginContainer/VBoxContainer/HBoxContainer/HPBar") else null
@onready var hp_text: Label = $MarginContainer/VBoxContainer/HBoxContainer/HPText if has_node("MarginContainer/VBoxContainer/HBoxContainer/HPText") else null
@onready var energy_bar: ProgressBar = $MarginContainer/VBoxContainer/EnergyBar if has_node("MarginContainer/VBoxContainer/EnergyBar") else null
@onready var credits_label: Label = $MarginContainer/VBoxContainer/CreditsLabel if has_node("MarginContainer/VBoxContainer/CreditsLabel") else null
@onready var weapon_label: Label = $MarginContainer/VBoxContainer/WeaponLabel if has_node("MarginContainer/VBoxContainer/WeaponLabel") else null
@onready var instability_label: Label = $TopRight/InstabilityLabel if has_node("TopRight/InstabilityLabel") else null

var notification_timer: float = 0.0
var notif_label: Label = null

func _ready() -> void:
	add_to_group("hud")
	EventBus.player_hp_changed.connect(_on_hp_changed)
	EventBus.player_energy_changed.connect(_on_energy_changed)
	EventBus.loot_collected.connect(_on_loot_collected)
	EventBus.xp_gained.connect(_on_xp_gained)

	# Create Pickup Notification Banner
	notif_label = Label.new()
	notif_label.name = "PickupNotifLabel"
	notif_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notif_label.modulate = Color(1.0, 0.9, 0.2, 0.0)
	notif_label.anchor_left = 0.5
	notif_label.anchor_right = 0.5
	notif_label.anchor_top = 0.0
	notif_label.offset_left = -150
	notif_label.offset_right = 150
	notif_label.offset_top = 40
	add_child(notif_label)

	update_hud_display()

func _process(delta: float) -> void:
	if notification_timer > 0.0:
		notification_timer -= delta
		if notification_timer <= 0.0 and notif_label:
			notif_label.modulate.a = 0.0

func _on_xp_gained(current_xp: int, max_xp: int, level: int) -> void:
	_update_weapon_xp_label(current_xp, max_xp, level)

func update_hud_display() -> void:
	_on_hp_changed(GameManager.player_current_hp, GameManager.player_max_hp)
	_on_energy_changed(GameManager.player_current_energy, GameManager.player_max_energy)
	
	if credits_label:
		if GameManager.current_state == GameManager.GameState.HUB:
			var profile = SaveManager.profile_data
			var mats = profile.get("persistent_materials", {})
			if not typeof(mats) == TYPE_DICTIONARY: mats = {}
			credits_label.text = "KHO HUB: Ember Ore (%d) | Cryo Crystal (%d) | Bio Sample (%d) | Star Shards (%d)" % [
				mats.get("ember_ore", 0),
				mats.get("cryo_crystal", 0),
				mats.get("bio_sample", 0),
				profile.get("total_shards", 0)
			]
		else:
			var mats = GameManager.backpack_materials
			credits_label.text = "BALO MAN: Ember Ore (%d) | Cryo Crystal (%d) | Bio Sample (%d) | Shards (%d) | Gold (%d)" % [
				mats.get("ember_ore", 0),
				mats.get("cryo_crystal", 0),
				mats.get("bio_sample", 0),
				GameManager.backpack_shards,
				GameManager.backpack_credits
			]

	_update_weapon_xp_label(GameManager.player_xp, GameManager.xp_to_next_level, GameManager.player_level)

func _update_weapon_xp_label(current_xp: int, max_xp: int, level: int) -> void:
	var players = get_tree().get_nodes_in_group("player")
	if weapon_label:
		var w_name = "Default"
		if players.size() > 0 and players[0].get("current_weapon") != null:
			var w = players[0].current_weapon as WeaponData
			if w:
				w_name = w.display_name
		weapon_label.text = "Lvl %d (%d/%d XP) | Vũ khí: %s" % [level, current_xp, max_xp, w_name]
		
	_update_hotbar()

func _update_hotbar() -> void:
	var hotbar = get_node_or_null("HotbarContainer")
	if not hotbar: return
	
	for child in hotbar.get_children():
		child.queue_free()
		
	var idx = 1
	for item in GameManager.run_backpack:
		if item["type"] == "consumable":
			var btn = Button.new()
			btn.text = "[%d] %s (x%d)" % [idx, item["id"].capitalize().replace("_", " "), item["amount"]]
			btn.custom_minimum_size = Vector2(100, 40)
			var capture_id = item["id"]
			btn.pressed.connect(func(): _on_hotbar_pressed(capture_id))
			hotbar.add_child(btn)
			idx += 1

func _on_hotbar_pressed(item_id: String) -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0 and players[0].has_method("_use_consumable_from_backpack"):
		players[0]._use_consumable_from_backpack(item_id)
		update_hud_display()

func set_instability_display(val: float) -> void:
	if instability_label:
		instability_label.text = "Instability: %.1f%%" % val

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

func _on_loot_collected(item_id: String, _name: String, amount: int) -> void:
	update_hud_display()
	
	# Show Banner Notification
	if notif_label:
		var display_name = item_id.replace("_", " ").capitalize()
		notif_label.text = "📦 VỪA NHẶT: +%d %s" % [amount, display_name]
		notif_label.modulate = Color(1.0, 0.9, 0.2, 1.0)
		notification_timer = 2.0
