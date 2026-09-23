# scripts/procedural/room_data.gd
class_name RoomData
extends Resource

## Data-Driven Room Template Definition for Starfall Frontier room modules.

@export var room_id: String = "combat_std_01"
@export var room_type: String = "COMBAT" # START, COMBAT, EXPLORATION, TREASURE, ELITE, EVENT, SHOP, REST, CHALLENGE, CAVE, SECRET, MINI_BOSS, BOSS, EXIT
@export var size_category: String = "MEDIUM" # SMALL, MEDIUM, LARGE, VERTICAL, ARENA
@export var allowed_biomes: Array = ["emberwild", "frostgrave", "verdant_abyss", "alien_void"]

@export var difficulty_min: float = 1.0
@export var difficulty_max: float = 3.0

@export var enemy_budget: int = 4
@export var hazard_budget: int = 2
@export var loot_budget: int = 3

@export var connectors: Array = ["LEFT", "RIGHT"]

static var room_registry: Dictionary = {}

static func _setup_registry() -> void:
	if room_registry.size() > 0:
		return

	# Archetype Templates
	var types = [
		"START", "COMBAT", "EXPLORATION", "TREASURE", "ELITE", 
		"EVENT", "SHOP", "REST", "CHALLENGE", "CAVE", "SECRET", 
		"MINI_BOSS", "BOSS", "EXIT"
	]

	var self_script = load("res://scripts/procedural/room_data.gd") as GDScript

	for t in types:
		for i in range(1, 4):
			var r = self_script.new() as Resource
			r.set("room_id", "%s_mod_0%d" % [t.to_lower(), i])
			r.set("room_type", t)
			r.set("size_category", "ARENA" if (t == "BOSS" or t == "MINI_BOSS") else ("VERTICAL" if i == 2 else "MEDIUM"))
			r.set("allowed_biomes", ["emberwild", "frostgrave", "verdant_abyss", "alien_void"])
			r.set("enemy_budget", 6 if t == "ELITE" else (8 if t == "BOSS" else 3))
			r.set("hazard_budget", 2)
			r.set("loot_budget", 5 if (t == "TREASURE" or t == "SECRET") else 2)
			r.set("connectors", ["LEFT", "RIGHT", "UP", "DOWN"])
			room_registry[r.get("room_id")] = r

static func get_registry() -> Dictionary:
	_setup_registry()
	return room_registry

static func get_room_data(r_id: String) -> Object:
	_setup_registry()
	if room_registry.has(r_id):
		return room_registry[r_id]
	return room_registry.values()[0] if room_registry.size() > 0 else null
