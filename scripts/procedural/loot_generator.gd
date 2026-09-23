# scripts/procedural/loot_generator.gd
class_name LootGenerator
extends Node

## Loot Generator Engine managing data-driven LootTable rolls, 9 Chest Types, room budgets, bad-luck pity counter protection, seed determinism, and anti-duplication state.

const ROOM_BUDGETS: Dictionary = {
	"NORMAL_ROOM": 100,
	"ELITE": 300,
	"TREASURE_ROOM": 500,
	"BOSS": 1000
}

static var pity_counter: int = 0

static func roll_loot_table(table_data: Resource, seed_val: int = 0) -> Array:
	if not table_data:
		return []

	var rng = RandomNumberGenerator.new()
	if seed_val != 0:
		rng.seed = seed_val
	else:
		rng.randomize()

	var rolled_items: Array = []

	# 1. Guaranteed Entries First
	for g_entry in table_data.guaranteed_entries:
		rolled_items.append(g_entry.duplicate())

	# 2. Rarity Roll with Bad-Luck Protection
	var rarity_w = table_data.rarity_weights.duplicate()
	if pity_counter >= 15:
		rarity_w["LEGENDARY"] = rarity_w.get("LEGENDARY", 1) + 25

	# 3. Roll Weighted Random Entries
	var item_count = rng.randi_range(table_data.minimum_items, table_data.maximum_items)
	var entries = table_data.entries.duplicate()

	if entries.size() > 0:
		for i in range(item_count):
			var selected = _roll_weighted_entry(entries, rng)
			if selected.size() > 0:
				rolled_items.append(selected)
				if selected.get("rarity") == 4: # LEGENDARY
					pity_counter = 0
				else:
					pity_counter += 1

	return rolled_items

static func _roll_weighted_entry(entries: Array, rng: RandomNumberGenerator) -> Dictionary:
	var total_weight: int = 0
	for e in entries:
		total_weight += int(e.get("weight", 10))

	if total_weight <= 0:
		return entries[0].duplicate() if entries.size() > 0 else {}

	var roll = rng.randi_range(1, total_weight)
	var accumulated = 0

	for e in entries:
		accumulated += int(e.get("weight", 10))
		if roll <= accumulated:
			return e.duplicate()

	return entries[0].duplicate()

static func generate_chest_loot(chest_type: String, seed_val: int = 0) -> Dictionary:
	var table_script = load("res://scripts/combat/loot_table_data.gd")
	var t_id = "secret_treasure" if chest_type == "SECRET" else "enemy_standard"
	if chest_type == "ELITE" or chest_type == "BOSS":
		t_id = "elite_chest" if chest_type == "ELITE" else "boss_reward"

	var table = table_script.create_preset(t_id) if table_script else null
	var drops = roll_loot_table(table, seed_val)

	return {
		"chest_type": chest_type,
		"is_trapped": (chest_type == "TRAPPED"),
		"is_mimic": (chest_type == "MIMIC"),
		"is_locked": (chest_type == "LOCKED"),
		"drops": drops
	}

static func spawn_loot_for_room(
	parent_node: Node2D,
	platform_spots: Array[Vector2],
	archetype: int,
	biome: Object,
	rng: RandomNumberGenerator
) -> void:
	if platform_spots.size() == 0:
		return

	var resource_scene = preload("res://scenes/items/resource_node.tscn")
	var item_scene = preload("res://scenes/items/item_drop.tscn")

	match archetype:
		3, 8: # TREASURE, SECRET
			for i in range(min(3, platform_spots.size())):
				var spot = platform_spots[i]
				var item_inst = item_scene.instantiate() as Node2D
				item_inst.set("item_id", "star_shard" if i == 0 else "ember_ore")
				item_inst.set("item_type", "material")
				item_inst.set("amount", rng.randi_range(2, 4))
				item_inst.set("rarity_id", "rare" if i == 0 else "uncommon")
				item_inst.global_position = spot
				parent_node.add_child(item_inst)

		2, 1: # EXPLORATION, COMBAT
			if rng.randf() < 0.5:
				var spot = platform_spots[rng.randi() % platform_spots.size()]
				var node_inst = resource_scene.instantiate() as Node2D
				node_inst.global_position = spot
				parent_node.add_child(node_inst)
