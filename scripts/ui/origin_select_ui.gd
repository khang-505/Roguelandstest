# scripts/ui/origin_select_ui.gd
class_name OriginSelectUIController
extends Control

## UI Controller for Origin Archetype Selection.

@onready var desc_label: Label = $VBoxContainer/DescLabel if has_node("VBoxContainer/DescLabel") else null

func select_origin(origin_id: String) -> void:
	var origin = OriginData.get_origin(origin_id)
	if origin:
		SaveManager.profile_data["active_origin"] = origin_id
		SaveManager.save_game()
		
		# Apply stats dynamically to GameManager
		var base_hp = 100
		GameManager.player_max_hp = int(base_hp * (1.0 + origin.hp_modifier))
		GameManager.player_current_hp = GameManager.player_max_hp
		
		if desc_label:
			desc_label.text = "Active Origin: %s\n%s" % [origin.display_name, origin.description]

func _on_vanguard_pressed() -> void:
	select_origin("vanguard")

func _on_scout_pressed() -> void:
	select_origin("scout")

func _on_close_pressed() -> void:
	visible = false
