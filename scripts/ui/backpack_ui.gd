# scripts/ui/backpack_ui.gd
class_name BackpackUIController
extends Control

## In-Run Backpack Overlay Window displaying physical slots, material stack counts, and equipped items.

@onready var items_container: VBoxContainer = $ScrollContainer/VBoxContainer if has_node("ScrollContainer/VBoxContainer") else null

func _ready() -> void:
	update_display()

func update_display() -> void:
	var title = find_child("TitleLabel", true, false) as Label
	if title: title.text = "🎒 BALO CHUYẾN ĐI (IN-RUN BACKPACK)"

	var status = find_child("StatusLabel", true, false) as Label
	if status:
		status.text = "Sức chứa: %d/%d Ô | Vàng: %d | Star Shards: %d" % [
			GameManager.run_backpack.size(),
			GameManager.MAX_BACKPACK_SIZE,
			GameManager.backpack_credits,
			GameManager.backpack_shards
		]

	var container = find_child("ItemsContainer", true, false) as VBoxContainer
	if container == null and items_container:
		container = items_container

	if container:
		for c in container.get_children():
			if c.name.begins_with("Slot_"):
				c.queue_free()

		if GameManager.run_backpack.size() == 0:
			var empty_lbl = Label.new()
			empty_lbl.name = "Slot_Empty"
			empty_lbl.text = "Balo đang trống..."
			empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			container.add_child(empty_lbl)
		else:
			for i in range(GameManager.run_backpack.size()):
				var item = GameManager.run_backpack[i]
				var item_name = item["id"].replace("_", " ").capitalize()
				var lbl = Label.new()
				lbl.name = "Slot_%d" % i
				lbl.text = "Slot %d: %s (x%d) [%s]" % [
					i + 1, item_name, item["amount"], item["type"].capitalize()
				]
				container.add_child(lbl)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("inventory") or (event is InputEventKey and event.pressed and event.keycode == KEY_B):
		queue_free()
		get_viewport().set_input_as_handled()
