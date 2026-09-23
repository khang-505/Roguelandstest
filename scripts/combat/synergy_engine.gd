# scripts/combat/synergy_engine.gd
class_name SynergyEngine
extends Resource

## Scans equipped build items for synergy tags, calculates tier thresholds (2/4/6), and aggregates build bonuses.

static func calculate_build_synergies(
	equipped_weapon: Dictionary = {},
	equipped_armor: Array = [],
	equipped_artifacts: Array = [],
	equipped_abilities: Array = []
) -> Dictionary:
	
	# 1. Collect tag counts
	var tag_counts: Dictionary = {}
	
	# Helper lambda to add tags
	var _add_tags = func(tags: Array):
		for t in tags:
			var tag_str = str(t).to_upper()
			if tag_counts.has(tag_str):
				tag_counts[tag_str] += 1
			else:
				tag_counts[tag_str] = 1

	# Weapon tags
	if equipped_weapon.has("synergies") and equipped_weapon["synergies"] is Array:
		_add_tags.call(equipped_weapon["synergies"])

	# Armor tags
	for item in equipped_armor:
		if item and item is EquipmentData:
			# Check if equipment has tags property or infer from slot/id
			var eq: EquipmentData = item as EquipmentData
			if eq.get("tags") is Array:
				_add_tags.call(eq.get("tags"))

	# Artifact tags
	for art in equipped_artifacts:
		if art and art is ArtifactData:
			var artifact: ArtifactData = art as ArtifactData
			_add_tags.call(artifact.tags)

	# Ability tags
	for ab in equipped_abilities:
		if ab and ab.get("tags") is Array:
			_add_tags.call(ab.get("tags"))

	# 2. Evaluate active tiers
	var active_synergies: Array[Dictionary] = []
	var aggregate_bonuses: Dictionary = {
		"bonus_attack": 0,
		"bonus_defense": 0,
		"bonus_hp": 0,
		"bonus_speed": 0.0,
		"crit_chance": 0.0,
		"lifesteal": 0.0,
		"attack_speed_mult": 0.0,
		"damage_reduction_flat": 0.0,
		"special_effects": []
	}

	var cat_script = load("res://scripts/combat/synergy_catalog.gd")
	if not cat_script:
		return {"active_synergies": active_synergies, "aggregate_bonuses": aggregate_bonuses, "tag_counts": tag_counts}

	for tag in tag_counts.keys():
		var count: int = tag_counts[tag]
		var syn = cat_script.get_synergy(tag)
		if syn.size() == 0:
			continue

		var highest_tier: int = 0
		var active_tier_data: Dictionary = {}

		if count >= 6 and syn["tiers"].has(6):
			highest_tier = 6
			active_tier_data = syn["tiers"][6]
		elif count >= 4 and syn["tiers"].has(4):
			highest_tier = 4
			active_tier_data = syn["tiers"][4]
		elif count >= 2 and syn["tiers"].has(2):
			highest_tier = 2
			active_tier_data = syn["tiers"][2]

		if highest_tier > 0:
			active_synergies.append({
				"tag": tag,
				"name": syn["name"],
				"count": count,
				"active_tier": highest_tier,
				"tier_data": active_tier_data,
				"description": active_tier_data.get("description", "")
			})

			# Sum stats into aggregate_bonuses
			for key in active_tier_data.keys():
				var val = active_tier_data[key]
				if key == "description":
					continue
				elif typeof(val) == TYPE_BOOL and val == true:
					aggregate_bonuses["special_effects"].append("%s_%s" % [tag, key])
				elif aggregate_bonuses.has(key):
					aggregate_bonuses[key] += val
				else:
					aggregate_bonuses[key] = val

	return {
		"active_synergies": active_synergies,
		"aggregate_bonuses": aggregate_bonuses,
		"tag_counts": tag_counts
	}
