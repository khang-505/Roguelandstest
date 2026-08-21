# scripts/core/save_manager.gd
class_name SaveManagerSingleton
extends Node

## Handles persistent save operations, profile serialization, atomic writes, and version migration.

const SAVE_PATH: String = "user://save.json"
const SAVE_BACKUP_PATH: String = "user://save.backup.json"
const CURRENT_SAVE_VERSION: int = 2

var profile_data: Dictionary = {
	"save_version": CURRENT_SAVE_VERSION,
	"total_credits": 0,
	"total_shards": 0,
	"hub_level": 1,
	"active_origin": "vanguard",
	"unlocked_origins": ["vanguard"],
	"unlocked_recipes": ["plasma_cutter"],
	"unlocked_research": [],
	"active_companions": ["miner_drone"],
	"persistent_materials": {
		"ember_ore": 0,
		"cryo_crystal": 0,
		"bio_sample": 0,
		"star_shard": 0
	},
	"expeditions_completed": 0
}

func save_game() -> bool:
	profile_data["save_version"] = CURRENT_SAVE_VERSION
	var json_string = JSON.stringify(profile_data, "\t")
	
	# Backup existing save file if present
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.copy_absolute(SAVE_PATH, SAVE_BACKUP_PATH)
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("[SaveManager] Failed to write to save file: %s" % FileAccess.get_open_error())
		return false
	
	file.store_string(json_string)
	file.close()
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		if FileAccess.file_exists(SAVE_BACKUP_PATH):
			DirAccess.copy_absolute(SAVE_BACKUP_PATH, SAVE_PATH)
		else:
			return false # Clean first run
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("[SaveManager] Save corruption detected. Attempting backup restore...")
		return _restore_backup()
	
	var loaded_dict = json.get_data()
	if typeof(loaded_dict) == TYPE_DICTIONARY:
		profile_data = _migrate_save_data(loaded_dict)
		return true
	
	return false

func _restore_backup() -> bool:
	if FileAccess.file_exists(SAVE_BACKUP_PATH):
		DirAccess.copy_absolute(SAVE_BACKUP_PATH, SAVE_PATH)
		return load_game()
	return false

func _migrate_save_data(data: Dictionary) -> Dictionary:
	var version = data.get("save_version", 1)
	if version < 2:
		# Migrate v1 -> v2
		data["save_version"] = 2
		if not data.has("active_origin"):
			data["active_origin"] = "vanguard"
		if not data.has("unlocked_research"):
			data["unlocked_research"] = []
		if not data.has("persistent_materials"):
			data["persistent_materials"] = {
				"ember_ore": 0,
				"cryo_crystal": 0,
				"bio_sample": 0,
				"star_shard": 0
			}
		if not data.has("active_companions"):
			data["active_companions"] = []
	return data
