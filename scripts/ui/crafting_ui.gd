# scripts/ui/crafting_ui.gd
class_name CraftingUIController
extends Control

## UI Controller for the Forge Crafting Station dialog.

func _ready() -> void:
	var title = find_child("TitleLabel", true, false) as Label
	if title: title.text = "FORGE CRAFTING STATION (XƯỞNG CHẾ TẠO)"
	var fb = find_child("FeedbackLabel", true, false) as Label
	if fb: fb.text = "Chọn vũ khí muốn chế tạo bên dưới:"
	var cp = find_child("CraftPlasmaButton", true, false) as Button
	if cp: cp.text = "Chế tạo Plasma Cutter (2 Ember Ore, 1 Star Shard)"
	var cf = find_child("CraftFrostButton", true, false) as Button
	if cf: cf.text = "Chế tạo Frost Rifle (2 Cryo Crystal, 1 Star Shard)"
	var ce = find_child("CraftEmberButton", true, false) as Button
	if ce: ce.text = "Chế tạo Ember Staff (3 Ember Ore, 1 Star Shard)"
	var c_btn = find_child("CloseButton", true, false) as Button
	if c_btn: c_btn.text = "ĐÓNG XƯỞNG CHẾ TẠO"
	var craft_plasma_btn = find_child("CraftPlasmaButton", true, false) as Button
	var craft_frost_btn = find_child("CraftFrostButton", true, false) as Button
	var craft_ember_btn = find_child("CraftEmberButton", true, false) as Button
	var close_btn = find_child("CloseButton", true, false) as Button

	if craft_plasma_btn:
		craft_plasma_btn.pressed.connect(func(): _craft("plasma_cutter_mk2"))
	if craft_frost_btn:
		craft_frost_btn.pressed.connect(func(): _craft("frost_rifle_mk2"))
	if craft_ember_btn:
		craft_ember_btn.pressed.connect(func(): _craft("ember_staff_mk2"))
	if close_btn:
		close_btn.pressed.connect(_on_close_pressed)

	update_display()

func update_display() -> void:
	var status_label = find_child("StatusLabel", true, false) as Label
	var profile = SaveManager.profile_data
	var mats = profile.get("persistent_materials", {})
	
	if status_label:
		status_label.text = "Kho: Ember Ore (%d) | Cryo Crystal (%d) | Star Shards (%d)" % [
			mats.get("ember_ore", 0),
			mats.get("cryo_crystal", 0),
			mats.get("star_shard", 0)
		]
		
	var craft_plasma_btn = find_child("CraftPlasmaButton", true, false) as Button
	var craft_frost_btn = find_child("CraftFrostButton", true, false) as Button
	var craft_ember_btn = find_child("CraftEmberButton", true, false) as Button
	
	if craft_plasma_btn:
		var recipe = CraftingManager.get_recipe("plasma_cutter_mk2")
		craft_plasma_btn.text = "Craft Plasma Cutter Mk2 (Cost: 2 Ember Ore, 1 Star Shard)"
		craft_plasma_btn.disabled = not CraftingManager.can_craft(recipe, profile)["can_craft"]
		
	if craft_frost_btn:
		var recipe = CraftingManager.get_recipe("frost_rifle_mk2")
		craft_frost_btn.text = "Craft Frost Rifle Mk2 (Cost: 2 Cryo Crystal, 1 Star Shard)"
		craft_frost_btn.disabled = not CraftingManager.can_craft(recipe, profile)["can_craft"]
		
	if craft_ember_btn:
		var recipe = CraftingManager.get_recipe("ember_staff_mk2")
		craft_ember_btn.text = "Craft Ember Staff Mk2 (Cost: 3 Ember Ore, 1 Star Shard)"
		craft_ember_btn.disabled = not CraftingManager.can_craft(recipe, profile)["can_craft"]

func _craft(recipe_id: String) -> void:
	var result = CraftingManager.craft_recipe(recipe_id)
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
