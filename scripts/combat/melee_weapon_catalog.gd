# scripts/combat/melee_weapon_catalog.gd
class_name MeleeWeaponCatalog
extends Resource

## Catalog registering pre-loaded Melee Weapon Archetypes, hitbox shapes, and attack patterns.

static var _weapons: Dictionary = {}
static var _initialized: bool = false

static func _ensure_initialized() -> void:
	if _initialized:
		return
	_initialized = true
	
	var data_script = load("res://scripts/combat/melee_weapon_data.gd")
	if not data_script:
		return
		
	# 1. Plasma Sword (Balanced)
	var sword = data_script.new(
		"plasma_sword", "Plasma Broadsword", 0, 0, # SWORD, ARC
		28.0, 60.0, 30.0, 20.0
	)
	sword.attack_speed = 1.0
	sword.knockback_force = 140.0
	sword.combo_count = 3
	sword.damage_type = "PHYSICAL"
	sword.whiff_sfx = "sfx_swing_sword"
	sword.hit_sfx = "sfx_hit_slash"
	_weapons["plasma_sword"] = sword
	
	# 2. Titan Hammer (Slow / Heavy Stagger)
	var hammer = data_script.new(
		"titan_hammer", "Titan War Hammer", 1, 2, # HAMMER, BROAD_AREA
		45.0, 75.0, 80.0, 60.0
	)
	hammer.attack_speed = 0.65
	hammer.knockback_force = 320.0
	hammer.combo_count = 2
	hammer.damage_type = "EXPLOSIVE"
	hammer.whiff_sfx = "sfx_swing_heavy"
	hammer.hit_sfx = "sfx_hit_impact"
	_weapons["titan_hammer"] = hammer
	
	# 3. Spire Spear (Long Reach / Piercing)
	var spear = data_script.new(
		"spire_spear", "Spire Lance", 2, 1, # SPEAR, RECTANGLE
		32.0, 110.0, 40.0, 35.0
	)
	spear.attack_speed = 0.9
	spear.knockback_force = 180.0
	spear.combo_count = 3
	spear.damage_type = "PHYSICAL"
	spear.whiff_sfx = "sfx_swing_thrust"
	spear.hit_sfx = "sfx_hit_pierce"
	_weapons["spire_spear"] = spear
	
	# 4. Dual Daggers (Fast / Short Range)
	var daggers = data_script.new(
		"dual_daggers", "Twin Venom Daggers", 3, 3, # DUAL_BLADES, FAST_SHORT
		18.0, 40.0, 15.0, 10.0
	)
	daggers.attack_speed = 1.4
	daggers.knockback_force = 80.0
	daggers.combo_count = 4
	daggers.damage_type = "POISON"
	daggers.whiff_sfx = "sfx_swing_fast"
	daggers.hit_sfx = "sfx_hit_slice"
	_weapons["dual_daggers"] = daggers

static func get_weapon(id: String) -> Resource:
	_ensure_initialized()
	if _weapons.has(id):
		return _weapons[id]
	return null

static func get_all_weapon_ids() -> Array:
	_ensure_initialized()
	return _weapons.keys()
