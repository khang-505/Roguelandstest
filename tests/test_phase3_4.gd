# tests/test_phase3_4.gd
class_name TestPhase34
extends Node

## Verification test runner for Phase 3.4 Origin Archetypes.

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 3.4 ORIGIN ARCHETYPES ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_origin_registry_loading():
		print("[PASS] 5 Original Character Origins registered (Vanguard, Scout, Engineer, Mystic, Nomad)")
		pass_count += 1
	else:
		print("[FAIL] Origin registry test failed")
		fail_count += 1

	if test_origin_stat_application():
		print("[PASS] Stat Calculation Math: Vanguard +20% HP calculates 120 HP from base 100 HP")
		pass_count += 1
	else:
		print("[FAIL] Stat application math failed")
		fail_count += 1

	if test_origin_persistent_save():
		print("[PASS] Origin Persistence: Selection saves to profile & updates active origin")
		pass_count += 1
	else:
		print("[FAIL] Origin persistence test failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_origin_registry_loading() -> bool:
	var origins = ["vanguard", "scout", "engineer", "mystic", "nomad"]
	for o_id in origins:
		var data = OriginData.get_origin(o_id)
		if data == null or data.origin_id != o_id:
			return false
	return true

func test_origin_stat_application() -> bool:
	var v = OriginData.get_origin("vanguard")
	var base_hp = 100
	var effective_hp = int(base_hp * (1.0 + v.hp_modifier))
	return effective_hp == 120

func test_origin_persistent_save() -> bool:
	var ui = OriginSelectUIController.new()
	ui.select_origin("scout")
	var saved_id = SaveManager.profile_data.get("active_origin", "")
	ui.free()
	return saved_id == "scout"
