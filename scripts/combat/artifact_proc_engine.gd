# scripts/combat/artifact_proc_engine.gd
class_name ArtifactProcEngine
extends Resource

## Engine for evaluating equipped Artifact proc triggers and applying runtime proc effects.

signal artifact_procced(artifact_id: String, proc_effect_id: String, proc_value: float, context: Dictionary)

static func process_trigger(equipped_artifacts: Array, trigger_type: int, context: Dictionary = {}, current_time: float = 0.0, rng_override: float = -1.0) -> Array[Dictionary]:
	var proc_results: Array[Dictionary] = []
	
	for art in equipped_artifacts:
		if not art or not (art is ArtifactData):
			continue
		var artifact: ArtifactData = art as ArtifactData
		
		# Match trigger
		if artifact.proc_trigger != trigger_type:
			continue
			
		# Check internal cooldown
		if artifact.is_on_cooldown(current_time):
			continue
			
		# Check proc chance
		var roll = rng_override if rng_override >= 0.0 else randf()
		if roll > artifact.proc_chance:
			continue
			
		# Successfully trigger proc
		if artifact.trigger_proc(current_time):
			var result = {
				"artifact_id": artifact.artifact_id,
				"proc_effect_id": artifact.proc_effect_id,
				"proc_value": artifact.proc_value,
				"context": context,
				"success": true
			}
			proc_results.append(result)
			
	return proc_results

## Applies static passive stats from equipped artifacts into a stat dictionary
static func calculate_artifact_passive_stats(equipped_artifacts: Array) -> Dictionary:
	var total_stats = {
		"bonus_attack": 0,
		"bonus_defense": 0,
		"bonus_hp": 0,
		"bonus_speed": 0.0,
		"crit_chance": 0.0
	}
	
	for art in equipped_artifacts:
		if not art or not (art is ArtifactData):
			continue
		var artifact: ArtifactData = art as ArtifactData
		for stat_key in artifact.passive_stats.keys():
			var val = artifact.passive_stats[stat_key]
			if total_stats.has(stat_key):
				total_stats[stat_key] += val
			else:
				total_stats[stat_key] = val
				
	return total_stats
