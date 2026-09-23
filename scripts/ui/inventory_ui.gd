# scripts/ui/inventory_ui.gd
class_name InventoryUIController
extends Control

## Displays Backpack (in-run) and Base Stash (persistent vault).

func _ready() -> void:
	var close_button = find_child("CloseButton", true, false) as Button
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	update_display()

func update_display() -> void:
	var stats = find_child("StatsLabel", true, false) as Label
	if stats == null:
		return

	var profile = SaveManager.profile_data
	var origin_id = profile.get("active_origin", "vanguard")
	var origin = OriginData.get_origin(origin_id)
	var stash_mats = profile.get("persistent_materials", {})
	if not typeof(stash_mats) == TYPE_DICTIONARY:
		stash_mats = {}

	var saved_armor: Dictionary = profile.get("equipped_armor", {})
	var slot_names = {
		str(EquipmentData.EquipmentSlot.HELMET): "Mũ (Helmet)",
		str(EquipmentData.EquipmentSlot.CHEST): "Áo giáp (Chest)",
		str(EquipmentData.EquipmentSlot.LEGS): "Quần (Legs)",
		str(EquipmentData.EquipmentSlot.BOOTS): "Giày (Boots)",
		str(EquipmentData.EquipmentSlot.ACCESSORY): "Phụ kiện (Accessory)"
	}

	var eq_summary = ""
	var w_name = "Chưa trang bị"
	if profile.get("equipped_weapon", "") != "":
		var w = WeaponData.get_weapon(profile["equipped_weapon"])
		if w: w_name = w.display_name
	eq_summary += "• Vũ khí (Weapon): %s\n" % w_name
	
	for s_key in slot_names.keys():
		var label = slot_names[s_key]
		var item_name = "Chưa trang bị"
		if saved_armor.has(s_key):
			var eq = EquipmentData.get_equipment(saved_armor[s_key])
			if eq: item_name = eq.display_name
		eq_summary += "• %s: %s\n" % [label, item_name]

	var archetype = "Frontier Operative"
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0 and players[0].has_method("get_build_archetype"):
		archetype = players[0].get_build_archetype()

	# BUG-002: Fetch consumable count directly from active backpack
	var hp_potions = 0
	var ep_potions = 0
	for item in GameManager.run_backpack:
		if item["id"] == "health_potion": hp_potions += item["amount"]
		elif item["id"] == "energy_elixir": ep_potions += item["amount"]

	var text = "=== OPERATIVE PROFILE & BUILD ARCHETYPE ===\n"
	text += "Class Origin: %s | Active Build: [%s]\n" % [origin.display_name, archetype]
	text += "Health Potions [1]: %d | Energy Elixirs [2]: %d\n\n" % [hp_potions, ep_potions]
	text += "🛡️ === 5 VỊ TRÍ TRANG BỊ (EQUIPPED SLOTS) ===\n"
	text += eq_summary + "\n"

	text += "🏛️ === KHO LƯU TRỮ CĂN CỨ (BASE STASH - SAVED) ===\n"
	text += "Tổng Credits: %d | Tổng Star-Shards: %d\n" % [profile.get("total_credits", 0), profile.get("total_shards", 0)]
	text += "Ember Ore trong kho: %d | Cryo Crystal: %d\n" % [stash_mats.get("ember_ore", 0), stash_mats.get("cryo_crystal", 0)]
	text += "Bio Sample trong kho: %d | Star Shards: %d\n" % [stash_mats.get("bio_sample", 0), stash_mats.get("star_shard", 0)]

	stats.text = text
	
	_update_backpack_ui()

func _update_backpack_ui() -> void:
	var container = find_child("BackpackContainer", true, false) as VBoxContainer
	if not container: return
	
	# Clear children
	for child in container.get_children():
		child.queue_free()
		
	if GameManager.current_state != GameManager.GameState.EXPLORATION and GameManager.current_state != GameManager.GameState.COMBAT:
		return
		
	var title = Label.new()
	title.text = "🎒 === BALO TRONG MÀN CHƠI (EXPEDITION BACKPACK) ===\nCredits trong balo: %d\nSlots Used: %d / %d" % [GameManager.backpack_credits, GameManager.run_backpack.size(), GameManager.MAX_BACKPACK_SIZE]
	container.add_child(title)
	
	for idx in range(GameManager.run_backpack.size()):
		var item = GameManager.run_backpack[idx]
		
		var hbox = HBoxContainer.new()
		var label = Label.new()
		label.text = "- %s (x%d)" % [item["id"], item["amount"]]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(label)
		
		if item["type"] == "equipment":
			var eq_btn = Button.new()
			eq_btn.text = "Equip"
			eq_btn.pressed.connect(func(): _equip_item(idx))
			hbox.add_child(eq_btn)
		elif item["type"] == "consumable":
			var use_btn = Button.new()
			use_btn.text = "Use"
			use_btn.pressed.connect(func(): _use_consumable(idx))
			hbox.add_child(use_btn)
			
		var discard_btn = Button.new()
		discard_btn.text = "Discard"
		discard_btn.pressed.connect(func(): _discard_item(idx))
		hbox.add_child(discard_btn)
		
		container.add_child(hbox)

	if GameManager.backpack_materials.size() > 0:
		var mat_title = Label.new()
		mat_title.text = "\n⛏️ === VẬT LIỆU ĐÃ THU THẬP (MATERIALS) ==="
		container.add_child(mat_title)
		
		for mat_id in GameManager.backpack_materials.keys():
			var amt = GameManager.backpack_materials[mat_id]
			var mat_lbl = Label.new()
			mat_lbl.text = "- %s (x%d)" % [mat_id.capitalize().replace("_", " "), amt]
			container.add_child(mat_lbl)

func _use_consumable(idx: int) -> void:
	if idx < 0 or idx >= GameManager.run_backpack.size(): return
	var item = GameManager.run_backpack[idx]
	if item["type"] != "consumable": return
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0 and players[0].has_method("consume_item"):
		if players[0].consume_item(item["id"]):
			item["amount"] -= 1
			if item["amount"] <= 0:
				GameManager.run_backpack.remove_at(idx)
			update_display()

func _equip_item(idx: int) -> void:
	if idx < 0 or idx >= GameManager.run_backpack.size(): return
	var item = GameManager.run_backpack[idx]
	if item["type"] != "equipment": return
	
	var profile = SaveManager.profile_data
	
	var w = WeaponData.get_weapon(item["id"])
	if w:
		var old_w = profile.get("equipped_weapon", "")
		
		profile["equipped_weapon"] = item["id"]
		SaveManager.save_game()
		
		# BUG-005: Remove new item FIRST to free up backpack slot
		GameManager.run_backpack.remove_at(idx)
		
		if old_w != "" and old_w != item["id"]:
			GameManager.add_to_backpack(old_w, "equipment", 1)
		
		update_display()
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			players[0].equip_new_weapon(item["id"])
		return
	
	var eq = EquipmentData.get_equipment(item["id"])
	if eq:
		var slot_key = str(eq.slot)
		if not profile.has("equipped_armor"): profile["equipped_armor"] = {}
		
		var _old_id = ""
		if profile["equipped_armor"].has(slot_key):
			_old_id = profile["equipped_armor"][slot_key]
			
		profile["equipped_armor"][slot_key] = item["id"]
		SaveManager.save_game()
		
		# BUG-005: Remove new item from backpack FIRST to free slot
		GameManager.run_backpack.remove_at(idx)
		
		# Move old equipped to backpack AFTER freeing the slot
		if _old_id != "":
			GameManager.add_to_backpack(_old_id, "equipment", 1)
		
		# Refresh UI and Player Stats
		update_display()
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			players[0]._load_equipped_armor()
			var active_origin_id = SaveManager.profile_data.get("active_origin", "vanguard")
			var origin = OriginData.get_origin(active_origin_id)
			players[0].recalculate_total_stats(origin)

func _discard_item(idx: int) -> void:
	if idx >= 0 and idx < GameManager.run_backpack.size():
		GameManager.run_backpack.remove_at(idx)
		update_display()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.physical_keycode == KEY_I):
		_on_close_pressed()

func _on_close_pressed() -> void:
	queue_free()
