# scripts/ui/research_ui.gd
class_name ResearchUIController
extends Control

## UI Controller for Research Lab dialog with static and dynamic node unlock handlers.

@onready var container: VBoxContainer = $ScrollContainer/VBoxContainer if has_node("ScrollContainer/VBoxContainer") else null

func _ready() -> void:
	var basic_btn = find_child("UnlockBasicButton", true, false) as Button
	var adv_btn = find_child("UnlockAdvancedButton", true, false) as Button
	var mag_btn = find_child("UnlockMagnetButton", true, false) as Button
	var close_btn = find_child("CloseButton", true, false) as Button

	if basic_btn and not basic_btn.pressed.is_connected(_on_basic_pressed):
		basic_btn.pressed.connect(_on_basic_pressed)
	if adv_btn and not adv_btn.pressed.is_connected(_on_adv_pressed):
		adv_btn.pressed.connect(_on_adv_pressed)
	if mag_btn and not mag_btn.pressed.is_connected(_on_mag_pressed):
		mag_btn.pressed.connect(_on_mag_pressed)
	if close_btn and not close_btn.pressed.is_connected(_on_close_pressed):
		close_btn.pressed.connect(_on_close_pressed)

	update_display()

func _on_basic_pressed() -> void:
	_unlock("basic_combat")

func _on_adv_pressed() -> void:
	_unlock("advanced_combat")

func _on_mag_pressed() -> void:
	_unlock("magnet_array")

func update_display() -> void:
	var status_label = find_child("StatusLabel", true, false) as Label
	var profile = SaveManager.profile_data
	var shards = profile.get("total_shards", 0)
	var unlocked: Array = profile.get("unlocked_research", [])

	if status_label:
		status_label.text = "Star-Shards hiện có: %d  |  Đã mở khóa: %d" % [shards, unlocked.size()]

	var basic_btn = find_child("UnlockBasicButton", true, false) as Button
	var adv_btn = find_child("UnlockAdvancedButton", true, false) as Button
	var mag_btn = find_child("UnlockMagnetButton", true, false) as Button

	ProgressionTree._setup_registry()

	if basic_btn:
		var n = ProgressionTree.get_node_data("basic_combat")
		var val = ProgressionTree.can_unlock(n, profile)
		if "basic_combat" in unlocked:
			basic_btn.text = "Basic Combat (+15% HP) [ĐÃ MỞ KHÓA]"
			basic_btn.disabled = true
		else:
			basic_btn.text = "Basic Combat (+15% HP) - 2 Star-Shards"
			basic_btn.disabled = not val["can_unlock"]

	if adv_btn:
		var n = ProgressionTree.get_node_data("advanced_combat")
		var val = ProgressionTree.can_unlock(n, profile)
		if "advanced_combat" in unlocked:
			adv_btn.text = "Advanced Combat (+20% Damage) [ĐÃ MỞ KHÓA]"
			adv_btn.disabled = true
		else:
			adv_btn.text = "Advanced Combat (+20% Damage) - 5 Star-Shards"
			adv_btn.disabled = not val["can_unlock"]

	if mag_btn:
		var n = ProgressionTree.get_node_data("magnet_array")
		var val = ProgressionTree.can_unlock(n, profile)
		if "magnet_array" in unlocked:
			mag_btn.text = "Magnet Array (+24px Tầm Nhặt) [ĐÃ MỞ KHÓA]"
			mag_btn.disabled = true
		else:
			mag_btn.text = "Magnet Array (+24px Tầm Nhặt) - 3 Star-Shards"
			mag_btn.disabled = not val["can_unlock"]

	# Render Tier 2 Dynamic Upgrade Buttons if parent nodes are unlocked
	_render_tier2_buttons(profile, unlocked)

func _render_tier2_buttons(profile: Dictionary, unlocked: Array) -> void:
	if container == null:
		return

	# Remove old tier2 buttons
	for c in container.get_children():
		if c.name.begins_with("Tier2_"):
			c.queue_free()

	var close_btn = find_child("CloseButton", true, false) as Button
	var idx = close_btn.get_index() if close_btn else container.get_child_count()

	var tier2_nodes = ["titan_physique", "master_smith", "swift_boots"]
	for node_id in tier2_nodes:
		var node = ProgressionTree.get_node_data(node_id)
		if node == null:
			continue
			
		var val = ProgressionTree.can_unlock(node, profile)
		var is_unlocked = node_id in unlocked

		var btn = Button.new()
		btn.name = "Tier2_" + node_id
		btn.custom_minimum_size = Vector2(0, 32)

		if is_unlocked:
			btn.text = "%s [ĐÃ MỞ KHÓA]" % node.display_name
			btn.disabled = true
			btn.modulate = Color(0.4, 0.9, 0.4, 1.0)
		elif val["can_unlock"]:
			btn.text = "%s - %d Star-Shards" % [node.display_name, node.cost_shards]
			btn.disabled = false
			btn.modulate = Color.WHITE
		else:
			btn.text = "%s (%s)" % [node.display_name, val["reason"]]
			btn.disabled = true
			btn.modulate = Color(0.6, 0.6, 0.6, 0.6)

		var n_id = node_id
		btn.pressed.connect(func(): _unlock(n_id))
		container.add_child(btn)
		container.move_child(btn, idx)
		idx += 1

func _unlock(node_id: String) -> void:
	var result = ProgressionTree.unlock_research(node_id)
	var feedback_label = find_child("FeedbackLabel", true, false) as Label
	if feedback_label:
		feedback_label.text = result["message"]
	update_display()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()

func _on_close_pressed() -> void:
	queue_free()
