# scripts/procedural/enemy_family_catalog.gd
class_name EnemyFamilyCatalog
extends Resource

## Catalog defining 5 core enemy families across all biomes with tactical synergy pairings.

static func get_all_families() -> Array[Dictionary]:
	return [
		{
			"family_id": "drone",
			"family_name": "Automated Drone Family",
			"members": ["scout_drone", "combat_drone", "shield_drone", "elite_overseer"],
			"primary_biome": "industrial_core",
			"synergy_partner": "robot"
		},
		{
			"family_id": "crawler",
			"family_name": "Chitinous Crawler Family",
			"members": ["normal_crawler", "acid_spitter", "subterranean_burrower", "alpha_broodmother"],
			"primary_biome": "emberwild",
			"synergy_partner": "predator"
		},
		{
			"family_id": "robot",
			"family_name": "Heavy Security Robot Family",
			"members": ["security_automaton", "heavy_tread_tank", "plasma_disruptor", "boss_titan"],
			"primary_biome": "industrial_core",
			"synergy_partner": "drone"
		},
		{
			"family_id": "predator",
			"family_name": "Bio-Sphere Predator Family",
			"members": ["canopy_stalker", "spore_hive", "toxic_leaper", "ancient_guardian"],
			"primary_biome": "verdant_abyss",
			"synergy_partner": "crawler"
		},
		{
			"family_id": "cryo",
			"family_name": "Glacial Cryo Family",
			"members": ["ice_burrower", "frost_spectre", "cryo_sentinel", "frost_stalker_alpha"],
			"primary_biome": "frostgrave",
			"synergy_partner": "drone"
		}
	]

static func get_family_by_id(f_id: String) -> Dictionary:
	for f in get_all_families():
		if f.get("family_id") == f_id:
			return f
	return get_all_families()[0]
