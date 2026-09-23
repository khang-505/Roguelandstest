# scripts/ui/shop_ui.gd
class_name ShopUIController
extends Control

## UI Controller for the Base Hub Shop Economy Station.

func _ready() -> void:
	var buy_pot_btn = find_child("BuyPotionButton", true, false) as Button
	var buy_elixir_btn = find_child("BuyElixirButton", true, false) as Button
	var buy_iron_skin_btn = find_child("BuyIronSkinButton", true, false) as Button
	var buy_berserker_btn = find_child("BuyBerserkerButton", true, false) as Button
	var buy_helmet_btn = find_child("BuyHelmetButton", true, false) as Button
	var buy_chest_btn = find_child("BuyChestButton", true, false) as Button
	var sell_mats_btn = find_child("SellMaterialsButton", true, false) as Button
	var close_btn = find_child("CloseButton", true, false) as Button

	if buy_pot_btn:
		buy_pot_btn.pressed.connect(func(): _buy_consumable("health_potion", 40, "Health Potion"))
	if buy_elixir_btn:
		buy_elixir_btn.pressed.connect(func(): _buy_consumable("energy_elixir", 35, "Energy Elixir"))
	if buy_iron_skin_btn:
		buy_iron_skin_btn.pressed.connect(func(): _buy_consumable("iron_skin_potion", 50, "Iron Skin Potion"))
	if buy_berserker_btn:
		buy_berserker_btn.pressed.connect(func(): _buy_consumable("berserker_brew", 60, "Berserker Brew"))
	if buy_helmet_btn:
		buy_helmet_btn.pressed.connect(func(): _buy_equipment("iron_helmet", 150))
	if buy_chest_btn:
		buy_chest_btn.pressed.connect(func(): _buy_equipment("titan_chest", 300))
	if sell_mats_btn:
		sell_mats_btn.pressed.connect(_sell_all_materials)
	if close_btn:
		close_btn.pressed.connect(_on_close_pressed)

	update_display()

func update_display() -> void:
	var status_label = find_child("StatusLabel", true, false) as Label
	if status_label:
		var profile = SaveManager.profile_data
		var slots_used = GameManager.run_backpack.size()
		var slots_max = GameManager.MAX_BACKPACK_SIZE
		status_label.text = "Credits hiện có: %d | Backpack Capacity: %d / %d" % [
			profile.get("total_credits", 0),
			slots_used,
			slots_max
		]

func _show_feedback(msg: String) -> void:
	var feedback = find_child("FeedbackLabel", true, false) as Label
	if feedback:
		feedback.text = msg
	update_display()

func _buy_consumable(item_id: String, cost: int, display_name: String) -> void:
	var profile = SaveManager.profile_data
	var credits = profile.get("total_credits", 0)
	
	if credits >= cost:
		if GameManager.add_to_backpack(item_id, "consumable", 1):
			profile["total_credits"] = credits - cost
			SaveManager.save_game()
			_show_feedback("Đã mua 1 %s! Vật phẩm đã được thêm vào Balo." % display_name)
		else:
			_show_feedback("Mua thất bại! Balo đã đầy (Mở 'I' để kiểm tra).")
	else:
		_show_feedback("Không đủ Credits! (Cần %d Credits)" % cost)

func _buy_equipment(eq_id: String, cost: int) -> void:
	var profile = SaveManager.profile_data
	var credits = profile.get("total_credits", 0)
	var eq = EquipmentData.get_equipment(eq_id)
	if eq == null:
		return

	if credits >= cost:
		profile["total_credits"] = credits - cost
		var saved_armor: Dictionary = profile.get("equipped_armor", {})
		
		# BUG-004: Stash the currently equipped armor if it exists
		var slot_key = str(eq.slot)
		if saved_armor.has(slot_key) and saved_armor[slot_key] != "":
			var old_eq = saved_armor[slot_key]
			var stashed = profile.get("stashed_equipment", [])
			stashed.append(old_eq)
			profile["stashed_equipment"] = stashed
			
		saved_armor[slot_key] = eq_id
		profile["equipped_armor"] = saved_armor
		SaveManager.save_game()

		# Update active player if in scene
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0 and players[0].has_method("_load_equipped_armor"):
			players[0]._load_equipped_armor()
			var active_origin_id = profile.get("active_origin", "vanguard")
			var origin = OriginData.get_origin(active_origin_id)
			players[0].recalculate_total_stats(origin)

		_show_feedback("Đã mua & Trang bị %s! (Cộng %d HP, %d Def)" % [eq.display_name, eq.bonus_hp, eq.bonus_defense])
	else:
		_show_feedback("Không đủ Credits! Cần %d Credits để mua %s" % [cost, eq.display_name])

func _sell_all_materials() -> void:
	var profile = SaveManager.profile_data
	var stash_mats: Dictionary = profile.get("persistent_materials", {})
	var earned = 0

	for mat_id in stash_mats.keys():
		var qty = stash_mats[mat_id]
		if qty > 0:
			var price = 25 if mat_id == "star_shard" else 15
			earned += qty * price
			stash_mats[mat_id] = 0

	if earned > 0:
		profile["total_credits"] = profile.get("total_credits", 0) + earned
		profile["persistent_materials"] = stash_mats
		SaveManager.save_game()
		_show_feedback("Đã bán tất cả nguyên liệu trong kho! Nhận được %d Credits" % earned)
	else:
		_show_feedback("Không có nguyên liệu nào trong kho để bán!")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()

func _on_close_pressed() -> void:
	queue_free()
