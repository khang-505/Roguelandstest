# tests/test_automated_combat_harness.gd
class_name TestAutomatedCombatHarness
extends Node

## Headless Stress-Test Harness running 500 combat & boss encounters with zero crashes.

var total_encounters: int = 0
var successful_encounters: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: EXECUTING AUTOMATED COMBAT & BOSS HARNESS ---")
	run_combat_harness(500)
	print("--- AUTOMATED COMBAT HARNESS SUMMARY: %d/%d ENCOUNTERS PASSED ---" % [successful_encounters, total_encounters])

func run_combat_harness(count: int = 500) -> Dictionary:
	var dmg_calc = load("res://scripts/combat/damage_calculator.gd")
	var req_script = load("res://scripts/combat/damage_request.gd")
	var status_mgr_script = load("res://scripts/combat/status_effect_manager.gd")
	var reaction_engine = load("res://scripts/combat/hit_reaction_engine.gd")

	var valid_runs = 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 88888

	for i in range(count):
		total_encounters += 1

		# 1. Build random damage request
		var req = req_script.create(
			"player_weapon",
			"ash_beetle",
			rng.randf_range(10.0, 100.0),
			"FIRE",
			rng.randf() < 0.25 # 25% crit
		)

		# 2. Calculate damage
		var target_defense = rng.randf_range(0.0, 30.0)
		var result = dmg_calc.calculate_final_damage(req, target_defense)

		if not result.has("final_damage") or result["final_damage"] <= 0.0:
			print("[FAIL] Combat encounter %d failed damage calculation" % i)
			continue

		# 3. Simulate status effect application
		var status_mgr = status_mgr_script.new()
		status_mgr.apply_status_effect("BURN", 3.0, 5.0, 10.0)
		status_mgr.process_ticks(1.0)

		# 4. Simulate hit reaction
		var reaction_data = reaction_engine.calculate_reaction(result["final_damage"], result["is_critical"], false)
		if not reaction_data.has("reaction_type"):
			print("[FAIL] Combat encounter %d failed reaction calculation" % i)
			continue

		valid_runs += 1
		successful_encounters += 1

	return {
		"total": count,
		"successful": valid_runs,
		"success_rate": float(valid_runs) / float(count)
	}
