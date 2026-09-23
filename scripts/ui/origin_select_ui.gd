# scripts/ui/origin_select_ui.gd
class_name OriginSelectUIController
extends Control

## UI Controller for Origin Archetype & Companion Selection.

func _ready() -> void:
	var title = find_child("TitleLabel", true, false) as Label
	if title: title.text = "ORIGIN & COMPANION STATION"
	var desc = find_child("DescLabel", true, false) as Label
	if desc: desc.text = "Đang chọn Class Vanguard (+20% HP)"
	var v_btn = find_child("VanguardButton", true, false) as Button
	if v_btn: v_btn.text = "Chọn Vanguard (+20% HP, Đao Plasma)"
	var s_btn = find_child("ScoutButton", true, false) as Button
	if s_btn: s_btn.text = "Chọn Scout (+15% Tốc độ, Súng Băng)"
	var m_btn = find_child("MysticButton", true, false) as Button
	if m_btn: m_btn.text = "Chọn Mystic (+30% Năng lượng, Gậy Lửa)"
	var c_btn = find_child("CloseButton", true, false) as Button
	if c_btn: c_btn.text = "ĐÓNG TRẠM ĐỒNG HÀNH"
	var vanguard_btn = find_child("VanguardButton", true, false) as Button
	var scout_btn = find_child("ScoutButton", true, false) as Button
	var mystic_btn = find_child("MysticButton", true, false) as Button
	var close_btn = find_child("CloseButton", true, false) as Button

	if vanguard_btn:
		vanguard_btn.pressed.connect(func(): select_origin("vanguard"))
	if scout_btn:
		scout_btn.pressed.connect(func(): select_origin("scout"))
	if mystic_btn:
		mystic_btn.pressed.connect(func(): select_origin("mystic"))
	if close_btn:
		close_btn.pressed.connect(_on_close_pressed)

	_update_display()

func select_origin(origin_id: String) -> void:
	var origin = OriginData.get_origin(origin_id)
	if origin:
		SaveManager.profile_data["active_origin"] = origin_id
		SaveManager.save_game()

		# Apply stats dynamically to GameManager
		var base_hp = 100
		GameManager.player_max_hp = int(base_hp * (1.0 + origin.hp_modifier))
		GameManager.player_current_hp = GameManager.player_max_hp
		GameManager.player_max_energy = 100.0 * (1.3 if origin_id == "mystic" else 1.0)
		GameManager.player_current_energy = GameManager.player_max_energy

		_update_display()

func _update_display() -> void:
	var desc_label = find_child("DescLabel", true, false) as Label
	if desc_label:
		var current_origin_id = SaveManager.profile_data.get("active_origin", "vanguard")
		var origin = OriginData.get_origin(current_origin_id)
		desc_label.text = "DANG CHON CLASS: %s\n%s" % [origin.display_name.to_upper(), origin.description]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()
func _on_close_pressed() -> void:
	queue_free()



