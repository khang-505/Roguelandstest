# tests/test_phase2_0.gd
class_name TestPhase20
extends Node

## Verification test runner for Phase 2.0 Weapon Modifier Engine.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 2.0 MODIFIER ENGINE ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_seeded_determinism():
		print("[PASS] Seeded Determinism: Seed 999 -> identical affixes twice")
		pass_count += 1
	else:
		print("[FAIL] Seeded determinism failed")
		fail_count += 1

	if test_compatibility_validation():
		print("[PASS] Compatibility Filtering: Melee weapon rejects Ranged-only affixes")
		pass_count += 1
	else:
		print("[FAIL] Compatibility filtering failed")
		fail_count += 1
		
	if test_stacking_math():
		print("[PASS] Modifier Stacking Math: (Base + Add) * (1 + Mult)")
		pass_count += 1
	else:
		print("[FAIL] Stacking math failed")
		fail_count += 1

	if test_no_duplicates():
		print("[PASS] Affix Uniqueness: No duplicate affix IDs rolled")
		pass_count += 1
	else:
		print("[FAIL] Duplicate affixes check failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_seeded_determinism() -> bool:
	var weaponA = WeaponData.new()
	weaponA.category = WeaponData.WeaponCategory.MELEE
	var affixes1 = ModifierGenerator.generate_affixes(weaponA, 2, 999)
	var affixes2 = ModifierGenerator.generate_affixes(weaponA, 2, 999)
	
	if affixes1.size() != affixes2.size():
		return false
		
	for i in range(affixes1.size()):
		if affixes1[i]["id"] != affixes2[i]["id"] or affixes1[i]["value"] != affixes2[i]["value"]:
			return false
	return true

func test_compatibility_validation() -> bool:
	var melee_weapon = WeaponData.new()
	melee_weapon.category = WeaponData.WeaponCategory.MELEE
	var affixes = ModifierGenerator.generate_affixes(melee_weapon, 10, 12345)
	
	for affix in affixes:
		if affix["id"] == "proj_speed":
			return false # Proj speed is for Ranged only
	return true

func test_stacking_math() -> bool:
	var weapon = WeaponData.new()
	weapon.base_damage = 100
	weapon.affixes = [
		{"stat": "damage", "operation": "ADD", "value": 20.0},
		{"stat": "damage", "operation": "MULTIPLY", "value": 0.10}
	]
	# Expected: (100 + 20) * (1.0 + 0.10) = 120 * 1.10 = 132
	var final_damage = weapon.get_modified_damage()
	return final_damage == 132

func test_no_duplicates() -> bool:
	var weapon = WeaponData.new()
	weapon.category = WeaponData.WeaponCategory.RANGED
	var affixes = ModifierGenerator.generate_affixes(weapon, 4, 8888)
	var seen: Dictionary = {}
	for affix in affixes:
		var id_str = affix["id"]
		if seen.has(id_str):
			return false
		seen[id_str] = true
	return true
