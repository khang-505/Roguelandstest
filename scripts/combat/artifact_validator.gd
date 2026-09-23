# scripts/combat/artifact_validator.gd
class_name ArtifactValidator
extends Resource

## Quality & Determinism Validator for System 34 (Artifacts / Accessories).

static func validate_artifact_system() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []
	
	# 1. Catalog Size & Completeness (30 Points)
	var catalog_script = load("res://scripts/combat/artifact_catalog.gd")
	var catalog_score = 0.0
	if catalog_script:
		var ids = catalog_script.get_all_artifact_ids()
		if ids.size() >= 15:
			catalog_score = 30.0
		else:
			warnings.append("Expected at least 15 catalog artifacts, found %d" % ids.size())
	else:
		warnings.append("ArtifactCatalog script not loaded")
	total_score += catalog_score
	details["catalog_score"] = catalog_score
	
	# 2. Passive Stat Calculation (25 Points)
	var engine_script = load("res://scripts/combat/artifact_proc_engine.gd")
	var passive_score = 0.0
	if catalog_script and engine_script:
		var a1 = catalog_script.get_artifact("vampiric_fang")
		var a5 = catalog_script.get_artifact("aegis_talisman")
		var stat_dict = engine_script.calculate_artifact_passive_stats([a1, a5])
		
		# Expected: bonus_attack = 5, bonus_hp = 30, bonus_defense = 8
		if stat_dict.get("bonus_attack", 0) == 5 and stat_dict.get("bonus_hp", 0) == 30 and stat_dict.get("bonus_defense", 0) == 8:
			passive_score = 25.0
		else:
			warnings.append("Artifact passive stat aggregation mismatch: %s" % str(stat_dict))
	else:
		warnings.append("ArtifactProcEngine script not loaded")
	total_score += passive_score
	details["passive_score"] = passive_score
	
	# 3. Proc Trigger & Chance (25 Points)
	var proc_score = 0.0
	if catalog_script and engine_script:
		var storm = catalog_script.get_artifact("storm_pendant") # ON_HIT, 20%
		var data_script = load("res://scripts/data/artifact_data.gd")
		
		# Force roll 0.10 (< 0.20) -> Success
		var results = engine_script.process_trigger([storm], data_script.ProcTrigger.ON_HIT, {}, 0.0, 0.10)
		# Force roll 0.50 (> 0.20) -> Fail
		var results_fail = engine_script.process_trigger([storm], data_script.ProcTrigger.ON_HIT, {}, 0.0, 0.50)
		
		if results.size() == 1 and results_fail.size() == 0 and results[0].get("proc_effect_id") == "chain_lightning":
			proc_score = 25.0
		else:
			warnings.append("Proc trigger roll logic failed")
	total_score += proc_score
	details["proc_score"] = proc_score
	
	# 4. Internal Cooldown Enforcement (20 Points)
	var cd_score = 0.0
	if catalog_script and engine_script:
		var storm = catalog_script.get_artifact("storm_pendant") # Cooldown 1.0s
		var data_script = load("res://scripts/data/artifact_data.gd")
		
		# First trigger at t=10.0 -> Success
		var r1 = engine_script.process_trigger([storm], data_script.ProcTrigger.ON_HIT, {}, 10.0, 0.05)
		# Second trigger at t=10.5 -> Cooldown Block
		var r2 = engine_script.process_trigger([storm], data_script.ProcTrigger.ON_HIT, {}, 10.5, 0.05)
		# Third trigger at t=11.5 -> Cooldown Expired, Success
		var r3 = engine_script.process_trigger([storm], data_script.ProcTrigger.ON_HIT, {}, 11.5, 0.05)
		
		if r1.size() == 1 and r2.size() == 0 and r3.size() == 1:
			cd_score = 20.0
		else:
			warnings.append("Internal cooldown enforcement failed")
	total_score += cd_score
	details["cd_score"] = cd_score
	
	var is_valid = total_score >= 80.0 and warnings.size() == 0
	
	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
