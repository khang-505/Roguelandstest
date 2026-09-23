# scripts/procedural/room_variant_manager.gd
class_name RoomVariantManager
extends Node

## Assembles procedural content variants for enemy, hazard, and loot slots based on room budget.

static func assemble_room_variant(
	template: Object,
	platform_spots: Array,
	biome: Object,
	rng: RandomNumberGenerator
) -> Dictionary:
	var enemy_count = template.get("enemy_budget") if (template and "enemy_budget" in template) else 3
	var hazard_count = template.get("hazard_budget") if (template and "hazard_budget" in template) else 2
	var loot_count = template.get("loot_budget") if (template and "loot_budget" in template) else 2

	var selected_spots = platform_spots.duplicate()
	selected_spots.shuffle()

	var enemy_spots: Array = []
	for i in range(min(enemy_count, selected_spots.size())):
		enemy_spots.append(selected_spots[i])

	var loot_spots: Array = []
	for i in range(enemy_spots.size(), min(enemy_spots.size() + loot_count, selected_spots.size())):
		loot_spots.append(selected_spots[i])

	return {
		"template": template,
		"enemy_spots": enemy_spots,
		"loot_spots": loot_spots,
		"variant_id": "var_%d" % (rng.randi() % 100)
	}
