# scripts/procedural/biome_selector.gd
class_name BiomeSelector
extends Node

## Weighted selection engine determining region biomes based on planet configuration and depth progression.

enum ProgressionStage {
	EARLY_SURFACE,
	MID_EXPANSION,
	DEEP_UNDERGROUND,
	FINAL_BOSS_ZONE
}

static func select_biome_for_region(
	planet_data: Object,
	region_index: int,
	total_regions: int,
	rng: RandomNumberGenerator
) -> Resource:
	var biome_data_class = load("res://scripts/procedural/biome_data.gd")
	if biome_data_class == null or not biome_data_class.has_method("get_biome"):
		return null

	var pool: Array = ["emberwild", "verdant_abyss", "frostgrave", "alien_void", "industrial_core"]
	if planet_data and "biome_pool" in planet_data and planet_data.biome_pool.size() > 0:
		pool = planet_data.biome_pool

	var stage = _get_stage_for_region(region_index, total_regions)
	var chosen_id = pool[0]

	match stage:
		ProgressionStage.EARLY_SURFACE:
			if planet_data and "starting_biome_id" in planet_data and planet_data.starting_biome_id != "":
				chosen_id = planet_data.starting_biome_id
			else:
				chosen_id = pool[0]

		ProgressionStage.MID_EXPANSION:
			if pool.size() > 1:
				chosen_id = pool[rng.randi() % min(2, pool.size())]
			else:
				chosen_id = pool[0]

		ProgressionStage.DEEP_UNDERGROUND:
			if pool.size() > 2:
				chosen_id = pool[min(2, pool.size() - 1)]
			elif pool.size() > 1:
				chosen_id = pool[1]
			else:
				chosen_id = pool[0]

		ProgressionStage.FINAL_BOSS_ZONE:
			if planet_data and "final_biome_id" in planet_data and planet_data.final_biome_id != "":
				chosen_id = planet_data.final_biome_id
			elif pool.size() > 0:
				chosen_id = pool[pool.size() - 1]

	return biome_data_class.get_biome(chosen_id)

static func _get_stage_for_region(idx: int, total: int) -> int:
	if idx == 0:
		return ProgressionStage.EARLY_SURFACE
	elif idx == total - 1:
		return ProgressionStage.FINAL_BOSS_ZONE
	elif idx < total / 2:
		return ProgressionStage.MID_EXPANSION
	else:
		return ProgressionStage.DEEP_UNDERGROUND
