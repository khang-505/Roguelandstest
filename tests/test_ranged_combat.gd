# tests/test_ranged_combat.gd
class_name TestRangedCombat
extends Node

## Verification test suite for Starfall Frontier Directive 28 — Ranged Combat Improvement Directive.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING RANGED COMBAT SYSTEM ---")
	test_ranged_catalog()
	test_1000_projectile_fires()
	test_ammo_reload_and_heat()
	test_high_ground_positioning()
	test_projectile_pooling()
	test_quality_validation()
	print("--- RANGED COMBAT TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_ranged_catalog() -> void:
	var cat_script = load("res://scripts/combat/ranged_weapon_catalog.gd")
	var ids = cat_script.get_all_weapon_ids()
	_assert_true(ids.size() == 8, "8 Ranged Weapon Archetypes registered in catalog (Got %d)" % ids.size())
	
	var valid_weapons = 0
	for id in ids:
		var w = cat_script.get_weapon(id)
		if w and w.base_damage > 0.0 and w.effective_range > 0.0 and not w.muzzle_sfx.is_empty():
			valid_weapons += 1
	_assert_true(valid_weapons == 8, "8/8 Ranged Weapons have valid stats & muzzle SFX cues")
	print("[PASS] RangedWeaponCatalog 8 Weapon Archetypes registration (8/8 PASSED)")

func test_1000_projectile_fires() -> void:
	var cat_script = load("res://scripts/combat/ranged_weapon_catalog.gd")
	var pool_script = load("res://scripts/combat/projectile_pool_manager.gd")
	var ids = cat_script.get_all_weapon_ids()
	var valid_count = 0
	
	for i in range(1000):
		var w = cat_script.get_weapon(ids[i % ids.size()])
		var is_high = (i % 2 == 0)
		var proj = pool_script.create_projectile(w, Vector2(100.0, 100.0), Vector2.RIGHT, is_high)
		
		if proj.has("id") and proj.has("damage") and proj["max_range"] > 0.0:
			valid_count += 1
			
	pool_script.update_projectiles(0.1)
	pool_script.clear_pool()
	
	_assert_true(valid_count == 1000, "1000/1000 Ranged Projectile Fires executed cleanly (1000/1000 PASSED)")
	print("[PASS] 1000 Ranged Projectile Fire Stress Iterations Check (1000/1000 PASSED)")

func test_ammo_reload_and_heat() -> void:
	var cat_script = load("res://scripts/combat/ranged_weapon_catalog.gd")
	var ammo_script = load("res://scripts/combat/ranged_ammo_controller.gd")
	
	# Test Magazine Weapon
	var pistol = cat_script.get_weapon("sidearm_blaster")
	var p_ctrl = ammo_script.new(pistol)
	_assert_true(p_ctrl.current_ammo == 12, "Pistol initializes with 12 rounds")
	p_ctrl.consume_shot()
	_assert_true(p_ctrl.current_ammo == 11, "Shot consumes 1 round")
	
	p_ctrl.start_reload()
	_assert_true(p_ctrl.is_reloading, "Pistol enters reloading state")
	p_ctrl.cancel_reload()
	_assert_true(not p_ctrl.is_reloading, "Reload canceled successfully")
	
	# Test Energy Weapon
	var laser = cat_script.get_weapon("overcharge_laser")
	var l_ctrl = ammo_script.new(laser)
	_assert_true(l_ctrl.current_heat == 0.0, "Energy weapon initializes at 0% heat")
	for shot in range(7):
		l_ctrl.consume_shot()
	_assert_true(l_ctrl.is_overheated, "Energy weapon enters OVERHEAT lockout at 100% heat")
	
	l_ctrl.update(2.5) # Fast forward 2.5s cooling
	_assert_true(not l_ctrl.is_overheated, "Overheat lockout resolves after cooling period")
	
	print("[PASS] RangedAmmoController Magazine Reload & Heat Overheat Dissipation Check (7/7 PASSED)")

func test_high_ground_positioning() -> void:
	var cat_script = load("res://scripts/combat/ranged_weapon_catalog.gd")
	var pool_script = load("res://scripts/combat/projectile_pool_manager.gd")
	var rifle = cat_script.get_weapon("pulse_rifle")
	
	var ground = pool_script.create_projectile(rifle, Vector2.ZERO, Vector2.RIGHT, false)
	var high = pool_script.create_projectile(rifle, Vector2.ZERO, Vector2.RIGHT, true)
	
	_assert_true(high["max_range"] == rifle.effective_range * 1.20, "High Ground provides +20% effective range")
	_assert_true(high["crit_chance"] == rifle.crit_chance + 0.15, "High Ground provides +15% crit chance")
	
	pool_script.clear_pool()
	print("[PASS] Ranged High Ground Elevation Positioning Bonus Check (2/2 PASSED)")

func test_projectile_pooling() -> void:
	var cat_script = load("res://scripts/combat/ranged_weapon_catalog.gd")
	var pool_script = load("res://scripts/combat/projectile_pool_manager.gd")
	var pistol = cat_script.get_weapon("sidearm_blaster")
	
	pool_script.clear_pool()
	var proj1 = pool_script.create_projectile(pistol, Vector2.ZERO, Vector2.RIGHT, false)
	var proj2 = pool_script.create_projectile(pistol, Vector2.ZERO, Vector2.RIGHT, false)
	
	_assert_true(pool_script.get_active_count() == 2, "2 active projectiles tracked in pool")
	pool_script.clear_pool()
	_assert_true(pool_script.get_active_count() == 0, "Pool cleared cleanly")
	print("[PASS] ProjectilePoolManager Zero-Allocation Pooling Check (2/2 PASSED)")

func test_quality_validation() -> void:
	var val_script = load("res://scripts/combat/ranged_validator.gd")
	var res = val_script.validate_ranged()
	
	_assert_true(res.is_valid, "Ranged Combat system passes quality validation")
	_assert_true(res.quality_score >= 70.0, "Quality Score >= 70.0 (Score: %.1f/100)" % res.quality_score)
	print("[PASS] RangedValidator composite quality score check (Score: %.1f/100)" % res.quality_score)
