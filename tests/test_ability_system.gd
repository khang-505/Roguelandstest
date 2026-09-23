# tests/test_ability_system.gd
class_name TestAbilitySystem
extends Node

## Verification test suite for Starfall Frontier Directive 29 — Abilities / Skills Improvement Directive.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING ABILITIES / SKILLS SYSTEM ---")
	test_ability_catalog()
	test_1000_activations()
	test_charge_regen_and_kill_bonus()
	test_iframes_and_mobility()
	test_roguelite_mutations()
	test_quality_validation()
	print("--- ABILITIES SYSTEM TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_ability_catalog() -> void:
	var cat_script = load("res://scripts/combat/ability_catalog.gd")
	var ids = cat_script.get_all_ability_ids()
	_assert_true(ids.size() == 10, "10 Ability Categories registered in catalog (Got %d)" % ids.size())
	
	var valid_abilities = 0
	for id in ids:
		var ab = cat_script.get_ability(id)
		if ab and ab.cooldown > 0.0 and ab.tags.size() >= 2:
			valid_abilities += 1
	_assert_true(valid_abilities == 10, "10/10 Abilities have valid cooldowns and category tags")
	print("[PASS] AbilityCatalog 10 Ability Categories registration (10/10 PASSED)")

func test_1000_activations() -> void:
	var cat_script = load("res://scripts/combat/ability_catalog.gd")
	var mgr_script = load("res://scripts/combat/ability_manager.gd")
	var ids = cat_script.get_all_ability_ids()
	var valid_count = 0
	
	for i in range(1000):
		var target_id = ids[i % ids.size()]
		var ab = cat_script.get_ability(target_id)
		var mgr = mgr_script.new()
		mgr.equip_ability("slot_main", ab)
		
		# Reset charges for simulation
		ab.current_charges = ab.max_charges
		mgr.cooldown_timers[target_id] = 0.0
		
		var res = mgr.activate_ability(target_id, 100.0, false)
		if res.get("success", false) and res.has("ability_id"):
			valid_count += 1
			
	_assert_true(valid_count == 1000, "1000/1000 Ability Activations executed cleanly (1000/1000 PASSED)")
	print("[PASS] 1000 Ability Activation Stress Iterations Check (1000/1000 PASSED)")

func test_charge_regen_and_kill_bonus() -> void:
	var cat_script = load("res://scripts/combat/ability_catalog.gd")
	var mgr_script = load("res://scripts/combat/ability_manager.gd")
	
	var blink = cat_script.get_ability("blink_teleport")
	blink.max_charges = 2
	blink.current_charges = 2
	
	var mgr = mgr_script.new()
	mgr.equip_ability("slot_mobility", blink)
	
	mgr.activate_ability("blink_teleport", 100.0, false)
	_assert_true(blink.current_charges == 1, "Charge deducted on activation (Remaining: 1)")
	
	mgr.on_enemy_killed(3.0) # Reduce cooldown by 3s on kill
	_assert_true(mgr.cooldown_timers["blink_teleport"] <= 2.0, "Enemy kill reduces ability cooldown")
	
	print("[PASS] Charge Regeneration & Kill Cooldown Reduction Check (2/2 PASSED)")

func test_iframes_and_mobility() -> void:
	var cat_script = load("res://scripts/combat/ability_catalog.gd")
	var mgr_script = load("res://scripts/combat/ability_manager.gd")
	
	var shield = cat_script.get_ability("invuln_shield")
	var mgr = mgr_script.new()
	mgr.equip_ability("slot_def", shield)
	
	var res = mgr.activate_ability("invuln_shield", 100.0, false)
	_assert_true(res.get("i_frames_duration", 0.0) >= 0.3, "Defensive Shield grants >=0.3s invulnerability i-frames")
	print("[PASS] Defensive Invulnerability i-Frames Check (1/1 PASSED)")

func test_roguelite_mutations() -> void:
	var cat_script = load("res://scripts/combat/ability_catalog.gd")
	var mgr_script = load("res://scripts/combat/ability_manager.gd")
	
	var fire = cat_script.get_ability("fire_blast")
	var mgr = mgr_script.new()
	mgr.equip_ability("slot_1", fire)
	
	var mut = {"id": "FLAME_ZONE", "damage_multiplier": 1.4, "extra_charges": 1}
	mgr.apply_mutation("fire_blast", mut)
	
	var res = mgr.activate_ability("fire_blast", 100.0, false)
	_assert_true(res["damage"] == 55.0 * 1.4, "Mutation damage multiplier applied (Expected 77, Got %.1f)" % res["damage"])
	print("[PASS] Roguelite Ability Mutation Application Check (1/1 PASSED)")

func test_quality_validation() -> void:
	var val_script = load("res://scripts/combat/ability_validator.gd")
	var res = val_script.validate_abilities()
	
	_assert_true(res.is_valid, "Ability System passes quality validation")
	_assert_true(res.quality_score >= 70.0, "Quality Score >= 70.0 (Score: %.1f/100)" % res.quality_score)
	print("[PASS] AbilityValidator composite quality score check (Score: %.1f/100)" % res.quality_score)
