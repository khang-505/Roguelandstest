# scripts/procedural/boss_validator.gd
class_name BossValidator
extends Resource

## Quality Score Engine evaluating Boss Data, Phase Architecture, Telegraph Lifecycles, Counterplay Openings, and Rewards.

static func validate_boss(boss_data) -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []
	
	if not boss_data:
		return {
			"is_valid": false,
			"quality_score": 0.0,
			"details": {},
			"warnings": ["BossData is null"]
		}
		
	# 1. Phase Structure (30 Points)
	var phase_score = 0.0
	if boss_data.phases.size() >= 2:
		phase_score += 15.0
		var prev_threshold = 1.1
		var valid_thresholds = true
		for p in boss_data.phases:
			var t = p.get("hp_threshold", 1.0)
			if t >= prev_threshold:
				valid_thresholds = false
				warnings.append("Invalid phase threshold order: %f >= %f" % [t, prev_threshold])
			prev_threshold = t
		if valid_thresholds:
			phase_score += 15.0
	else:
		warnings.append("Boss must have at least 2 phases (Found %d)" % boss_data.phases.size())
	total_score += phase_score
	details["phase_score"] = phase_score
	
	# 2. Attack Cooldowns & Telegraphs (25 Points)
	var attack_score = 0.0
	if boss_data.attack_patterns.size() >= 3:
		attack_score += 10.0
		var valid_telegraphs = true
		for atk in boss_data.attack_patterns:
			var t_dur = atk.get("telegraph_duration", 0.0)
			var r_dur = atk.get("recovery_duration", 0.0)
			if t_dur <= 0.0 or r_dur <= 0.0:
				valid_telegraphs = false
				warnings.append("Attack %s lacks valid telegraph/recovery duration" % atk.get("id", ""))
		if valid_telegraphs:
			attack_score += 15.0
	else:
		warnings.append("Boss should have at least 3 distinct attack patterns")
	total_score += attack_score
	details["attack_score"] = attack_score
	
	# 3. Counterplay & Weaknesses (25 Points)
	var counterplay_score = 0.0
	if not boss_data.primary_weakness.is_empty():
		counterplay_score += 10.0
	var has_counterplay_text = true
	for atk in boss_data.attack_patterns:
		if atk.get("counterplay", "").is_empty():
			has_counterplay_text = false
			break
	if has_counterplay_text:
		counterplay_score += 15.0
	total_score += counterplay_score
	details["counterplay_score"] = counterplay_score
	
	# 4. Rewards & Progression (20 Points)
	var reward_score = 0.0
	var loot = boss_data.loot_table
	if loot.get("currency_multiplier", 1.0) >= 3.0:
		reward_score += 10.0
	if loot.has("choice_rewards") and loot.has("guaranteed_drops"):
		reward_score += 10.0
	total_score += reward_score
	details["reward_score"] = reward_score
	
	var is_valid = total_score >= 70.0 and warnings.size() == 0
	
	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
