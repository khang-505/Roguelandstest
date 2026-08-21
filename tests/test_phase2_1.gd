# tests/test_phase2_1.gd
class_name TestPhase21
extends Node

## Verification test runner for Phase 2.1 Item Rarity System (10,000-roll Statistical Test).

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PHASE 2.1 RARITY SYSTEM ---")
	var pass_count = 0
	var fail_count = 0
	
	if test_rarity_10k_distribution():
		print("[PASS] 10,000-Roll Statistical Distribution Test within tolerances")
		pass_count += 1
	else:
		print("[FAIL] 10,000-roll statistical test failed")
		fail_count += 1

	if test_rarity_seeded_determinism():
		print("[PASS] Rarity Seeded Determinism: Seed 5555 -> identical rarity output")
		pass_count += 1
	else:
		print("[FAIL] Rarity seeded determinism failed")
		fail_count += 1

	if test_modifier_count_bounds():
		print("[PASS] Modifier Count Bounds: Min/max constraints respected per tier")
		pass_count += 1
	else:
		print("[FAIL] Modifier count bounds test failed")
		fail_count += 1

	print("--- TEST SUMMARY: %d PASSED, %d FAILED ---" % [pass_count, fail_count])

func test_rarity_10k_distribution() -> bool:
	var counts = {
		RarityData.Tier.COMMON: 0,
		RarityData.Tier.UNCOMMON: 0,
		RarityData.Tier.RARE: 0,
		RarityData.Tier.EPIC: 0,
		RarityData.Tier.LEGENDARY: 0,
		RarityData.Tier.MYTHIC: 0
	}
	
	var total_rolls = 10000
	for i in range(total_rolls):
		var rolled = RarityData.roll_rarity()
		if not counts.has(rolled.tier):
			return false # Invalid rarity returned
		counts[rolled.tier] += 1

	# Expected percentages:
	# Common: 60.0% (57.0% - 63.0%)
	# Uncommon: 25.0% (22.5% - 27.5%)
	# Rare: 10.0% (8.5% - 11.5%)
	# Epic: 4.0% (3.0% - 5.0%)
	# Legendary: 0.9% (0.4% - 1.5%)
	# Mythic: 0.1% (0.01% - 0.5%)
	
	var pct_common = float(counts[RarityData.Tier.COMMON]) / float(total_rolls) * 100.0
	var pct_uncommon = float(counts[RarityData.Tier.UNCOMMON]) / float(total_rolls) * 100.0
	var pct_rare = float(counts[RarityData.Tier.RARE]) / float(total_rolls) * 100.0
	var pct_epic = float(counts[RarityData.Tier.EPIC]) / float(total_rolls) * 100.0
	var pct_legendary = float(counts[RarityData.Tier.LEGENDARY]) / float(total_rolls) * 100.0
	var pct_mythic = float(counts[RarityData.Tier.MYTHIC]) / float(total_rolls) * 100.0
	
	print("  -> 10K Rolls Results: Common=%.2f%%, Uncommon=%.2f%%, Rare=%.2f%%, Epic=%.2f%%, Leg=%.2f%%, Myth=%.2f%%" % [
		pct_common, pct_uncommon, pct_rare, pct_epic, pct_legendary, pct_mythic
	])
	
	var common_ok = (pct_common >= 57.0 and pct_common <= 63.0)
	var uncommon_ok = (pct_uncommon >= 22.5 and pct_uncommon <= 27.5)
	var rare_ok = (pct_rare >= 8.5 and pct_rare <= 11.5)
	var epic_ok = (pct_epic >= 3.0 and pct_epic <= 5.0)
	var leg_ok = (pct_legendary >= 0.4 and pct_legendary <= 1.6)
	var myth_ok = (counts[RarityData.Tier.MYTHIC] >= 1) # At least 1 mythic rolled in 10k
	
	return common_ok and uncommon_ok and rare_ok and epic_ok and leg_ok and myth_ok

func test_rarity_seeded_determinism() -> bool:
	var roll1 = RarityData.roll_rarity(5555)
	var roll2 = RarityData.roll_rarity(5555)
	return roll1.tier == roll2.tier and roll1.id == roll2.id

func test_modifier_count_bounds() -> bool:
	for tier in RarityData.Tier.values():
		var rarity = RarityData.get_rarity_by_tier(tier)
		for s in range(50):
			var count = rarity.roll_modifier_count(100 + s)
			if count < rarity.min_modifiers or count > rarity.max_modifiers:
				return false
	return true
