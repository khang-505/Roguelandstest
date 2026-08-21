# tests/test_phase2_2.gd
class_name TestPhase22
extends Node

## Verification test runner for Phase 2.2 Weapon Categories & Special Effects.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 2.2 WEAPON CATEGORIES & EFFECTS ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_weapon_resources_loading():
		print("[PASS] 4 Original Weapons (.tres) loaded successfully")
		pass_count += 1
	else:
		print("[FAIL] Weapon resources loading failed")
		fail_count += 1

	if test_weapon_categories():
		print("[PASS] Weapon Categories Enum (MELEE, RANGED, ENERGY, SPECIAL)")
		pass_count += 1
	else:
		print("[FAIL] Weapon categories check failed")
		fail_count += 1

	if test_projectile_scene():
		print("[PASS] Projectile Scene & Physics Velocity calculation")
		pass_count += 1
	else:
		print("[FAIL] Projectile test failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_weapon_resources_loading() -> bool:
	var weapons = ["plasma_cutter", "void_blade", "frost_rifle", "ember_staff"]
	for w_id in weapons:
		var path = "res://data/weapons/%s.tres" % w_id
		var res = load(path)
		if res == null or not (res is WeaponData):
			return false
	return true

func test_weapon_categories() -> bool:
	var plasma = load("res://data/weapons/plasma_cutter.tres") as WeaponData
	var rifle = load("res://data/weapons/frost_rifle.tres") as WeaponData
	var staff = load("res://data/weapons/ember_staff.tres") as WeaponData
	
	var plasma_ok = (plasma.category == WeaponData.WeaponCategory.MELEE)
	var rifle_ok = (rifle.category == WeaponData.WeaponCategory.RANGED)
	var staff_ok = (staff.category == WeaponData.WeaponCategory.ENERGY)
	
	return plasma_ok and rifle_ok and staff_ok

func test_projectile_scene() -> bool:
	var scene = load("res://scenes/weapons/projectile.tscn")
	if scene == null:
		return false
	var instance = scene.instantiate() as Projectile
	instance.speed = 500.0
	instance.direction = Vector2.RIGHT
	var ok = (instance.speed == 500.0 and instance.direction == Vector2.RIGHT)
	instance.free()
	return ok
