# scripts/combat/stat_aggregator_validator.gd
class_name StatAggregatorValidator
extends Resource

## Quality Score Engine evaluating Stat Aggregator correctness, caps, multipliers, and negative stat handling.

static func validate_stat_aggregator() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []
	
	var agg_script = load("res://scripts/combat/stat_aggregator.gd")
	if not agg_script:
		warnings.append("StatAggregator script not found")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}
		
	# 1. Base + Equipment + Artifact Summation (30 Points)
	var eq_script = load("res://scripts/data/equipment_data.gd")
	var catalog_script = load("res://scripts/combat/artifact_catalog.gd")
	
	var base_stats = {"attack": 20, "defense": 5, "hp": 100, "speed": 200.0, "crit_chance": 0.05}
	var helm = eq_script.get_equipment("iron_helmet") if eq_script else null # def +5, hp +25
	var art = catalog_script.get_artifact("vampiric_fang") if catalog_script else null # atk +5
	
	var res1 = agg_script.calculate_stats(base_stats, [helm], {}, [art])
	
	# Expected: atk = 25, def = 10, hp = 125
	if res1.get("total_attack", 0) == 25 and res1.get("total_defense", 0) == 10 and res1.get("max_hp", 0) == 125:
		total_score += 30.0
		details["summation_score"] = 30.0
	else:
		warnings.append("Base + Equipment + Artifact stat summation mismatch: %s" % str(res1))
		
	# 2. Crit Chance Cap & Speed Limits (25 Points)
	var high_crit_stats = {"crit_chance": 0.90}
	var high_crit_buffs = [{"bonus_crit_chance": 0.50}] # Total 1.40 -> should cap at 1.0
	var res2 = agg_script.calculate_stats(high_crit_stats, [], {}, [], high_crit_buffs)
	
	if is_equal_approx(res2.get("crit_chance", 0.0), 1.0):
		total_score += 25.0
		details["cap_score"] = 25.0
	else:
		warnings.append("Crit chance cap [1.0] enforcement failed (Got %.2f)" % res2.get("crit_chance", 0.0))
		
	# 3. Damage Reduction Formula Check (25 Points)
	# Def = 100 -> Armor/(Armor+100) = 100/200 = 0.50 (50% reduction)
	var def_100_stats = {"defense": 100}
	var res3 = agg_script.calculate_stats(def_100_stats)
	
	if is_equal_approx(res3.get("damage_reduction", 0.0), 0.50):
		total_score += 25.0
		details["diminishing_defense_score"] = 25.0
	else:
		warnings.append("Damage reduction formula mismatch (Got %.2f, expected 0.50)" % res3.get("damage_reduction", 0.0))
		
	# 4. Multiplier Scaling (20 Points)
	var perk_mods = {"attack_mult": 1.5, "hp_mult": 1.2}
	var res4 = agg_script.calculate_stats(base_stats, [], {}, [], [], perk_mods)
	
	# Base atk 20 * 1.5 = 30, HP 100 * 1.2 = 120
	if res4.get("total_attack", 0) == 30 and res4.get("max_hp", 0) == 120:
		total_score += 20.0
		details["multiplier_score"] = 20.0
	else:
		warnings.append("Perk multiplier scaling failed: %s" % str(res4))
		
	var is_valid = total_score >= 80.0 and warnings.size() == 0
	
	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
