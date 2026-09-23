# scripts/procedural/secret_loot_table.gd
class_name SecretLootTable
extends Resource

## Dedicated secret reward pool with rarity weighting, materials, and credit caches.

static var RARE_ITEMS: Array[Dictionary] = [
	{"id": "quantum_core", "type": "material", "amount": 3, "rarity": "rare"},
	{"id": "plasma_cell", "type": "material", "amount": 5, "rarity": "rare"},
	{"id": "star_credits", "type": "currency", "amount": 50, "rarity": "rare"}
]

static var EPIC_ITEMS: Array[Dictionary] = [
	{"id": "star_shard", "type": "material", "amount": 2, "rarity": "epic"},
	{"id": "hyper_crystal", "type": "material", "amount": 2, "rarity": "epic"},
	{"id": "star_credits", "type": "currency", "amount": 120, "rarity": "epic"}
]

static var LEGENDARY_ITEMS: Array[Dictionary] = [
	{"id": "ancient_artifact", "type": "artifact", "amount": 1, "rarity": "legendary"},
	{"id": "void_essence", "type": "material", "amount": 1, "rarity": "legendary"},
	{"id": "star_credits", "type": "currency", "amount": 250, "rarity": "legendary"}
]

static func roll_secret_reward(rng: RandomNumberGenerator, reward_mult: float = 1.0) -> Dictionary:
	var roll = rng.randf()
	var selected_pool: Array[Dictionary] = RARE_ITEMS

	if roll < 0.15 * reward_mult:
		selected_pool = LEGENDARY_ITEMS
	elif roll < 0.50 * reward_mult:
		selected_pool = EPIC_ITEMS

	var idx = rng.randi() % selected_pool.size()
	var loot = selected_pool[idx].duplicate()
	if loot.get("type") == "currency":
		loot["amount"] = int(loot["amount"] * reward_mult)

	return loot
