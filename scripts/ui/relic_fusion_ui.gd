# scripts/ui/relic_fusion_ui.gd
class_name RelicFusionUIController
extends Control

## UI Controller for the Relic Fusion Matrix dialog.

@onready var status_label: Label = $VBoxContainer/StatusLabel if has_node("VBoxContainer/StatusLabel") else null

func _ready() -> void:
	update_display()

func update_display() -> void:
	if status_label:
		var profile = SaveManager.profile_data
		var mats = profile.get("persistent_materials", {})
		var relics = profile.get("unlocked_relics", [])
		status_label.text = "Fragments: Ore (%d) | Crystal (%d) | Shard (%d)\nFused Relics: %d" % [
			mats.get("ember_ore", 0),
			mats.get("cryo_crystal", 0),
			mats.get("star_shard", 0),
			relics.size()
		]

func _on_fuse_molten_pressed() -> void:
	RelicFusionManager.fuse_relic("molten_singularity")
	update_display()

func _on_close_pressed() -> void:
	visible = false
