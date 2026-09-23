# scripts/combat/loot_table_data.gd
class_name LootTableData
extends Resource

## Data Resource defining data-driven Loot Tables across 11 Loot Categories, 6 Rarity Tiers, weighted entry probabilities, guaranteed rewards, and duplicate handling rules.

enum LootCategory {
	WEAPON,
	ABILITY,
	ARMOR,
	ARTIFACT,
	PASSIVE,
	RESOURCE,
	CURRENCY,
	HEALING,
	UPGRADE_MATERIAL,
	KEY_ITEM,
	SPECIAL_REWARD
}

enum RarityTier {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY,
	MYTHIC
}

enum DuplicateRule {
	ALLOW,
	CONVERT_CURRENCY,
	UPGRADE_ITEM,
	REROLL_AFFIX,
	DISMANTLE
}

@export var id: String = "enemy_standard"
@export var display_name: String = "Standard Enemy Loot Table"

@export var entries: Array = [] # Array of Dictionary entries
@export var rarity_weights: Dictionary = {
	"COMMON": 50,
	"UNCOMMON": 30,
	"RARE": 15,
	"EPIC": 4,
	"LEGENDARY": 1,
	"MYTHIC": 0
}

@export var guaranteed_entries: Array = [] # Array of Dictionary entries guaranteed to drop
@export var minimum_items: int = 1 # Minimum item drops
@export var maximum_items: int = 3 # Maximum item drops

@export var duplicate_rule: DuplicateRule = DuplicateRule.CONVERT_CURRENCY
@export var biome_rules: Array = [] # Applicable biomes
@export var room_rules: Array = [] # Applicable room archetypes
@export var difficulty_multiplier: float = 1.0 # Scaling multiplier
@export var boss_rules: Dictionary = {} # Special boss drop rules

func _init(
	p_id: String = "enemy_standard",
	p_name: String = "Standard Enemy Loot Table",
	p_min: int = 1,
	p_max: int = 3
) -> void:
	id = p_id
	display_name = p_name
	minimum_items = p_min
	maximum_items = p_max

## Static Preset Builder for signature Loot Tables
static func create_preset(p_id: String) -> Resource:
	var table = new()
	table.id = p_id.to_lower()
	
	match table.id:
		"enemy_standard":
			table.display_name = "Standard Enemy Loot Table"
			table.minimum_items = 1
			table.maximum_items = 2
			table.entries = [
				{"item_id": "credit", "category": LootCategory.CURRENCY, "rarity": RarityTier.COMMON, "weight": 40, "min_amount": 5, "max_amount": 15},
				{"item_id": "ember_ore", "category": LootCategory.RESOURCE, "rarity": RarityTier.COMMON, "weight": 35, "min_amount": 1, "max_amount": 3},
				{"item_id": "health_potion", "category": LootCategory.HEALING, "rarity": RarityTier.UNCOMMON, "weight": 20, "min_amount": 1, "max_amount": 1},
				{"item_id": "plasma_rifle", "category": LootCategory.WEAPON, "rarity": RarityTier.RARE, "weight": 5, "min_amount": 1, "max_amount": 1}
			]
		"elite_chest":
			table.display_name = "Elite Encounter Loot Table"
			table.minimum_items = 2
			table.maximum_items = 4
			table.rarity_weights = {"COMMON": 20, "UNCOMMON": 40, "RARE": 25, "EPIC": 12, "LEGENDARY": 3, "MYTHIC": 0}
			table.guaranteed_entries = [
				{"item_id": "star_shard", "category": LootCategory.UPGRADE_MATERIAL, "rarity": RarityTier.RARE, "amount": 2}
			]
			table.entries = [
				{"item_id": "fire_blast", "category": LootCategory.ABILITY, "rarity": RarityTier.RARE, "weight": 30, "min_amount": 1, "max_amount": 1},
				{"item_id": "shield_relic", "category": LootCategory.ARTIFACT, "rarity": RarityTier.EPIC, "weight": 25, "min_amount": 1, "max_amount": 1},
				{"item_id": "cryo_crystal", "category": LootCategory.RESOURCE, "rarity": RarityTier.UNCOMMON, "weight": 45, "min_amount": 2, "max_amount": 5}
			]
		"boss_reward":
			table.display_name = "Boss Signature Reward Table"
			table.minimum_items = 3
			table.maximum_items = 5
			table.rarity_weights = {"COMMON": 0, "UNCOMMON": 10, "RARE": 40, "EPIC": 35, "LEGENDARY": 14, "MYTHIC": 1}
			table.guaranteed_entries = [
				{"item_id": "quantum_core", "category": LootCategory.KEY_ITEM, "rarity": RarityTier.LEGENDARY, "amount": 1},
				{"item_id": "credits_large", "category": LootCategory.CURRENCY, "rarity": RarityTier.EPIC, "amount": 250}
			]
			table.entries = [
				{"item_id": "singularity_cannon", "category": LootCategory.WEAPON, "rarity": RarityTier.LEGENDARY, "weight": 40, "min_amount": 1, "max_amount": 1},
				{"item_id": "overclock_chip", "category": LootCategory.PASSIVE, "rarity": RarityTier.EPIC, "weight": 35, "min_amount": 1, "max_amount": 1},
				{"item_id": "mythic_core", "category": LootCategory.SPECIAL_REWARD, "rarity": RarityTier.MYTHIC, "weight": 5, "min_amount": 1, "max_amount": 1}
			]
		"secret_treasure":
			table.display_name = "Secret Chamber Treasure Table"
			table.minimum_items = 2
			table.maximum_items = 3
			table.rarity_weights = {"COMMON": 10, "UNCOMMON": 30, "RARE": 35, "EPIC": 20, "LEGENDARY": 5, "MYTHIC": 0}
			table.entries = [
				{"item_id": "hyper_blade", "category": LootCategory.WEAPON, "rarity": RarityTier.EPIC, "weight": 30, "min_amount": 1, "max_amount": 1},
				{"item_id": "ancient_blueprint", "category": LootCategory.SPECIAL_REWARD, "rarity": RarityTier.RARE, "weight": 40, "min_amount": 1, "max_amount": 1},
				{"item_id": "bio_sample", "category": LootCategory.RESOURCE, "rarity": RarityTier.UNCOMMON, "weight": 30, "min_amount": 3, "max_amount": 6}
			]
			
	return table
