# scripts/data/curse_data.gd
class_name CurseData
extends Resource

## Data class representing Curses and Corruption debuffs.

@export var curse_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var corruption_value: float = 10.0

@export var stat_debuffs: Dictionary = {}
@export var mutation_effect_id: String = ""

static var _curses: Dictionary = {}
static var _initialized: bool = false

static func _ensure_initialized() -> void:
	if _initialized:
		return
	_initialized = true

	# 1. Corrupted Glass
	var c1 = CurseData.new()
	c1.curse_id = "corrupted_glass"
	c1.display_name = "Corrupted Glass"
	c1.description = "Reduces Max HP by 20% and disables health potion healing over time."
	c1.corruption_value = 25.0
	c1.stat_debuffs = {"max_hp_mult": -0.20}
	c1.mutation_effect_id = "disable_regen"
	_curses[c1.curse_id] = c1

	# 2. Shadow Bleed
	var c2 = CurseData.new()
	c2.curse_id = "shadow_bleed"
	c2.display_name = "Shadow Bleed"
	c2.description = "Dashing drains 5 HP per dash."
	c2.corruption_value = 25.0
	c2.mutation_effect_id = "dash_drain"
	_curses[c2.curse_id] = c2

	# 3. Weight of Greed
	var c3 = CurseData.new()
	c3.curse_id = "weight_of_greed"
	c3.display_name = "Weight of Greed"
	c3.description = "Movement speed reduced by 15%."
	c3.corruption_value = 25.0
	c3.stat_debuffs = {"move_speed_flat": -30.0}
	_curses[c3.curse_id] = c3

	# 4. Void Resonance
	var c4 = CurseData.new()
	c4.curse_id = "void_resonance"
	c4.display_name = "Void Resonance"
	c4.description = "Enemies spawn with +30% attack speed."
	c4.corruption_value = 25.0
	c4.mutation_effect_id = "enemy_frenzy"
	_curses[c4.curse_id] = c4

static func get_curse(id: String) -> CurseData:
	_ensure_initialized()
	if _curses.has(id):
		return _curses[id].duplicate()
	return null

static func get_all_curse_ids() -> Array:
	_ensure_initialized()
	return _curses.keys()
