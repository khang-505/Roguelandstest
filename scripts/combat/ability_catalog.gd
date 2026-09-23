# scripts/combat/ability_catalog.gd
class_name AbilityCatalog
extends Resource

## Catalog registering pre-loaded Abilities across all 10 categories.

static var _abilities: Dictionary = {}
static var _initialized: bool = false

static func _ensure_initialized() -> void:
	if _initialized:
		return
	_initialized = true
	
	var data_script = load("res://scripts/combat/ability_data.gd")
	if not data_script:
		return
		
	# 1. Fire Blast (OFFENSIVE)
	var fire = data_script.new("fire_blast", "Fire Blast", 0, 1, 4.0, 20.0, 55.0) # OFFENSIVE, DIRECTIONAL
	fire.element = "FIRE"
	fire.status_effect = "BURN"
	fire.tags = ["offensive", "fire", "burst"]
	_abilities["fire_blast"] = fire
	
	# 2. Invulnerability Shield (DEFENSIVE)
	var shield = data_script.new("invuln_shield", "Barrier Shield", 1, 0, 8.0, 25.0, 0.0) # DEFENSIVE, SELF
	shield.i_frames_duration = 0.4
	shield.duration = 4.0
	shield.tags = ["defensive", "i_frames", "shield"]
	_abilities["invuln_shield"] = shield
	
	# 3. Blink Teleport (MOBILITY)
	var blink = data_script.new("blink_teleport", "Blink Teleport", 2, 1, 5.0, 15.0, 0.0) # MOBILITY, DIRECTIONAL
	blink.max_charges = 2
	blink.current_charges = 2
	blink.range_radius = 250.0
	blink.i_frames_duration = 0.2
	blink.tags = ["mobility", "teleport", "charges"]
	_abilities["blink_teleport"] = blink
	
	# 4. Freeze Supernova (CROWD_CONTROL)
	var freeze = data_script.new("freeze_nova", "Freeze Supernova", 3, 2, 10.0, 30.0, 30.0) # CROWD_CONTROL, GROUND_AOE
	freeze.range_radius = 200.0
	freeze.element = "ICE"
	freeze.status_effect = "FREEZE"
	freeze.duration = 2.5
	freeze.tags = ["cc", "freeze", "aoe"]
	_abilities["freeze_nova"] = freeze
	
	# 5. Toxic Spore Cloud (AREA_DAMAGE)
	var spore = data_script.new("toxic_spore_cloud", "Toxic Spore Cloud", 4, 2, 8.0, 25.0, 40.0) # AREA_DAMAGE, GROUND_AOE
	spore.range_radius = 180.0
	spore.element = "POISON"
	spore.status_effect = "POISON"
	spore.duration = 5.0
	spore.tags = ["area_damage", "poison", "dot"]
	_abilities["toxic_spore_cloud"] = spore
	
	# 6. Overclock Frenzy (BUFF)
	var frenzy = data_script.new("overclock_frenzy", "Overclock Frenzy", 5, 0, 12.0, 35.0, 0.0) # BUFF, SELF
	frenzy.duration = 6.0
	frenzy.tags = ["buff", "attack_speed", "move_speed"]
	_abilities["overclock_frenzy"] = frenzy
	
	# 7. Armor Shatter Wave (DEBUFF)
	var shatter = data_script.new("armor_shatter_wave", "Armor Shatter Wave", 6, 1, 9.0, 25.0, 25.0) # DEBUFF, DIRECTIONAL
	shatter.range_radius = 220.0
	shatter.status_effect = "ARMOR_SHATTER"
	shatter.duration = 4.0
	shatter.tags = ["debuff", "armor_break", "vulnerability"]
	_abilities["armor_shatter_wave"] = shatter
	
	# 8. Guardian Sentinel Drone (SUMMON)
	var drone = data_script.new("guardian_sentinel_drone", "Guardian Sentinel Drone", 7, 2, 15.0, 40.0, 20.0) # SUMMON, GROUND_AOE
	drone.duration = 10.0
	drone.tags = ["summon", "drone", "turret"]
	_abilities["guardian_sentinel_drone"] = drone
	
	# 9. Secret Scanner (UTILITY)
	var scanner = data_script.new("secret_scanner", "Secret Scanner", 8, 0, 6.0, 10.0, 0.0) # UTILITY, SELF
	scanner.range_radius = 400.0
	scanner.duration = 5.0
	scanner.tags = ["utility", "secret_reveal", "scan"]
	_abilities["secret_scanner"] = scanner
	
	# 10. Grapple Beam (EXPLORATION)
	var grapple = data_script.new("grapple_beam", "Grapple Beam", 9, 1, 3.0, 10.0, 0.0) # EXPLORATION, DIRECTIONAL
	grapple.range_radius = 350.0
	grapple.tags = ["exploration", "grapple", "vertical_traversal"]
	_abilities["grapple_beam"] = grapple

static func get_ability(id: String) -> Resource:
	_ensure_initialized()
	if _abilities.has(id):
		var copy = _abilities[id].duplicate()
		copy.current_charges = copy.max_charges
		return copy
	return null

static func get_all_ability_ids() -> Array:
	_ensure_initialized()
	return _abilities.keys()
