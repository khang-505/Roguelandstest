# scripts/procedural/biome_validator.gd
class_name BiomeValidator
extends Node

## Validates biome data integrity, compatibility tags, and non-empty enemy/loot pools.

static func validate_biome(biome_data: Object) -> Dictionary:
	var result = {
		"is_valid": true,
		"errors": []
	}

	if biome_data == null:
		result.is_valid = false
		result.errors.append("BiomeData object is null")
		return result

	var b_id = biome_data.id if "id" in biome_data else ""
	if b_id == "":
		result.is_valid = false
		result.errors.append("Biome ID is empty")

	var e_pool = biome_data.enemy_pool if "enemy_pool" in biome_data else []
	if e_pool.size() == 0:
		result.is_valid = false
		result.errors.append("Enemy pool is empty")

	var r_pool = biome_data.resource_pool if "resource_pool" in biome_data else []
	if r_pool.size() == 0:
		result.is_valid = false
		result.errors.append("Resource pool is empty")

	return result

static func validate_biome_transition(from_biome: Object, to_biome: Object) -> bool:
	if from_biome == null or to_biome == null:
		return true

	var tags_a = from_biome.compatibility_tags if "compatibility_tags" in from_biome else []
	var tags_b = to_biome.compatibility_tags if "compatibility_tags" in to_biome else []

	# Incompatible pairs check (e.g. frozen vs lava/volcanic direct jump)
	if "frozen" in tags_a and "volcanic" in tags_b:
		return false
	return true
