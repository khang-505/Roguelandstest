# scripts/ui/artifact_ui.gd
class_name ArtifactUIController
extends Control

## UI component displaying equipped Artifact slots and inventory selection.

signal artifact_equipped(artifact_id: String)
signal artifact_unequipped(artifact_id: String)

const MAX_ARTIFACT_SLOTS: int = 3

func _ready() -> void:
	update_display()

func update_display() -> void:
	var stats_label = find_child("ArtifactStatsLabel", true, false) as Label
	if not stats_label:
		return
		
	var profile = SaveManager.profile_data
	var equipped_ids: Array = profile.get("equipped_artifacts", [])
	
	var text = "🔮 === EQUIPPED ARTIFACTS (%d/%d) ===\n" % [equipped_ids.size(), MAX_ARTIFACT_SLOTS]
	
	var catalog_script = load("res://scripts/combat/artifact_catalog.gd")
	var engine_script = load("res://scripts/combat/artifact_proc_engine.gd")
	var equipped_objects: Array = []
	
	if catalog_script:
		for i in range(MAX_ARTIFACT_SLOTS):
			if i < equipped_ids.size():
				var id = str(equipped_ids[i])
				var art = catalog_script.get_artifact(id)
				if art:
					equipped_objects.append(art)
					text += "[Slot %d] %s — %s\n" % [i + 1, art.display_name, art.description]
				else:
					text += "[Slot %d] Empty\n" % (i + 1)
			else:
				text += "[Slot %d] Empty\n" % (i + 1)
				
	if engine_script and equipped_objects.size() > 0:
		var passives = engine_script.calculate_artifact_passive_stats(equipped_objects)
		text += "\n✨ Active Artifact Passive Bonuses:\n"
		text += "• ATK: +%d | DEF: +%d | HP: +%d | SPD: +%.1f | CRIT: +%.1f%%\n" % [
			passives.get("bonus_attack", 0),
			passives.get("bonus_defense", 0),
			passives.get("bonus_hp", 0),
			passives.get("bonus_speed", 0.0),
			passives.get("crit_chance", 0.0) * 100.0
		]
		
	stats_label.text = text

func equip_artifact(artifact_id: String) -> bool:
	var profile = SaveManager.profile_data
	var equipped: Array = profile.get("equipped_artifacts", [])
	
	if equipped.has(artifact_id):
		return false # Already equipped
		
	if equipped.size() >= MAX_ARTIFACT_SLOTS:
		return false # Slots full
		
	equipped.append(artifact_id)
	profile["equipped_artifacts"] = equipped
	SaveManager.save_game()
	
	artifact_equipped.emit(artifact_id)
	update_display()
	return true

func unequip_artifact(artifact_id: String) -> bool:
	var profile = SaveManager.profile_data
	var equipped: Array = profile.get("equipped_artifacts", [])
	
	if not equipped.has(artifact_id):
		return false
		
	equipped.erase(artifact_id)
	profile["equipped_artifacts"] = equipped
	SaveManager.save_game()
	
	artifact_unequipped.emit(artifact_id)
	update_display()
	return true
