# scripts/combat/ranged_weapon_catalog.gd
class_name RangedWeaponCatalog
extends Resource

## Catalog registering pre-loaded Ranged Weapon Archetypes, fire modes, trajectories, and ammo configs.

static var _weapons: Dictionary = {}
static var _initialized: bool = false

static func _ensure_initialized() -> void:
	if _initialized:
		return
	_initialized = true
	
	var data_script = load("res://scripts/combat/ranged_weapon_data.gd")
	if not data_script:
		return
		
	# 1. Sidearm Blaster (Pistol)
	var pistol = data_script.new("sidearm_blaster", "Sidearm Blaster", 0, 0, 0, 22.0, 450.0, 12)
	pistol.fire_rate = 3.5
	pistol.projectile_speed = 650.0
	pistol.reload_duration = 1.2
	pistol.damage_type = "PHYSICAL"
	pistol.muzzle_sfx = "sfx_shot_pistol"
	_weapons["sidearm_blaster"] = pistol
	
	# 2. Pulse Rifle (Rifle)
	var rifle = data_script.new("pulse_rifle", "Pulse Rifle", 1, 2, 0, 18.0, 550.0, 30)
	rifle.fire_rate = 8.0
	rifle.projectile_speed = 750.0
	rifle.reload_duration = 1.8
	rifle.damage_type = "ENERGY"
	rifle.muzzle_sfx = "sfx_shot_rifle"
	_weapons["pulse_rifle"] = rifle
	
	# 3. Scatter Shotgun (Shotgun)
	var shotgun = data_script.new("scatter_shotgun", "Scatter Shotgun", 2, 0, 0, 12.0, 300.0, 6)
	shotgun.fire_rate = 1.2
	shotgun.pellet_count = 6
	shotgun.spread_angle = 22.0
	shotgun.projectile_speed = 500.0
	shotgun.reload_duration = 2.2
	shotgun.damage_type = "PHYSICAL"
	shotgun.muzzle_sfx = "sfx_shot_shotgun"
	_weapons["scatter_shotgun"] = shotgun
	
	# 4. Compound Bow (Bow)
	var bow = data_script.new("compound_bow", "Viper Compound Bow", 3, 3, 3, 40.0, 650.0, 1) # BOW, CHARGE, PIERCING
	bow.fire_rate = 1.5
	bow.projectile_speed = 900.0
	bow.crit_chance = 0.30
	bow.reload_duration = 0.5
	bow.damage_type = "PHYSICAL"
	bow.status_effect = "POISON"
	bow.muzzle_sfx = "sfx_shot_bow"
	_weapons["compound_bow"] = bow
	
	# 5. Overcharge Laser (Energy Weapon)
	var energy = data_script.new("overcharge_laser", "Overcharge Laser", 4, 2, 0, 24.0, 500.0, 0) # ENERGY_WEAPON, AUTOMATIC
	energy.uses_energy = true
	energy.fire_rate = 6.0
	energy.heat_per_shot = 15.0
	energy.cool_rate = 35.0
	energy.damage_type = "ELECTRIC"
	energy.muzzle_sfx = "sfx_shot_energy"
	_weapons["overcharge_laser"] = energy
	
	# 6. Plasma Mortar (Launcher)
	var launcher = data_script.new("plasma_mortar", "Plasma Mortar", 5, 0, 1, 60.0, 450.0, 4) # LAUNCHER, SINGLE, ARC
	launcher.fire_rate = 1.0
	launcher.projectile_speed = 400.0
	launcher.reload_duration = 2.5
	launcher.damage_type = "EXPLOSIVE"
	launcher.muzzle_sfx = "sfx_shot_launcher"
	_weapons["plasma_mortar"] = launcher
	
	# 7. Continuous Beam Emitter (Beam)
	var beam = data_script.new("beam_emitter", "Continuous Beam Emitter", 6, 4, 8, 14.0, 400.0, 0) # BEAM, HOLD, BEAM
	beam.uses_energy = true
	beam.fire_rate = 10.0
	beam.heat_per_shot = 8.0
	beam.cool_rate = 45.0
	beam.damage_type = "ENERGY"
	beam.muzzle_sfx = "sfx_shot_beam"
	_weapons["beam_emitter"] = beam
	
	# 8. Burst Carbine (Burst Weapon)
	var burst = data_script.new("burst_carbine", "Burst Carbine", 7, 1, 0, 20.0, 500.0, 24) # BURST_WEAPON, BURST
	burst.fire_rate = 2.5
	burst.projectile_speed = 700.0
	burst.reload_duration = 1.5
	burst.damage_type = "PHYSICAL"
	burst.muzzle_sfx = "sfx_shot_burst"
	_weapons["burst_carbine"] = burst

static func get_weapon(id: String) -> Resource:
	_ensure_initialized()
	if _weapons.has(id):
		return _weapons[id]
	return null

static func get_all_weapon_ids() -> Array:
	_ensure_initialized()
	return _weapons.keys()
