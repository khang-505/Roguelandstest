# scripts/data/origin_data.gd
class_name OriginData
extends Resource

## Data-Driven Character Origin Archetype System.

enum OriginType { VANGUARD, SCOUT, ENGINEER, MYSTIC, NOMAD }

@export var type: OriginType = OriginType.VANGUARD
@export var origin_id: String = "vanguard"
@export var display_name: String = "Vanguard"
@export var description: String = "Frontline specialist with high health and physical strike bonus."
@export var hp_modifier: float = 0.20 # +20% HP
@export var speed_modifier: float = 0.0
@export var damage_modifier: float = 0.15 # +15% Damage
@export var starting_weapon_id: String = "plasma_cutter"

static var origin_registry: Dictionary = {}

static func _static_init() -> void:
	_setup_registry()

static func _setup_registry() -> void:
	if origin_registry.size() > 0:
		return

	# 1. Vanguard
	var v = OriginData.new()
	v.type = OriginType.VANGUARD
	v.origin_id = "vanguard"
	v.display_name = "Vanguard"
	v.description = "Frontline specialist with +20% HP and +15% Physical Strike."
	v.hp_modifier = 0.20
	v.damage_modifier = 0.15
	v.starting_weapon_id = "plasma_cutter"
	origin_registry["vanguard"] = v

	# 2. Scout
	var s = OriginData.new()
	s.type = OriginType.SCOUT
	s.origin_id = "scout"
	s.display_name = "Scout"
	s.description = "Agile ranger with +20% Movement Speed and +15% Critical Chance."
	s.speed_modifier = 0.20
	s.starting_weapon_id = "frost_rifle"
	origin_registry["scout"] = s

	# 3. Engineer
	var e = OriginData.new()
	e.type = OriginType.ENGINEER
	e.origin_id = "engineer"
	e.display_name = "Engineer"
	e.description = "Drone technician with +20% Companion Power Level."
	e.starting_weapon_id = "ember_staff"
	origin_registry["engineer"] = e

	# 4. Mystic
	var m = OriginData.new()
	m.type = OriginType.MYSTIC
	m.origin_id = "mystic"
	m.display_name = "Mystic"
	m.description = "Quantum adept with +30% Max Energy and status duration bonus."
	m.starting_weapon_id = "void_blade"
	origin_registry["mystic"] = m

	# 5. Nomad
	var n = OriginData.new()
	n.type = OriginType.NOMAD
	n.origin_id = "nomad"
	n.display_name = "Nomad"
	n.description = "Frontier survivor with +50% Resource Drop Yield."
	n.starting_weapon_id = "plasma_cutter"
	origin_registry["nomad"] = n

static func get_origin(o_id: String) -> OriginData:
	_setup_registry()
	if origin_registry.has(o_id):
		return origin_registry[o_id]
	return origin_registry["vanguard"]
