# scripts/data/loot_table_data.gd
class_name LootTableData
extends Resource

@export var id: String = "ember_beetle_loot"
@export var min_drop_count: int = 1
@export var max_drop_count: int = 3
@export var item_pools: Array[ItemData] = []
@export var drop_probabilities: Array[float] = [0.85, 0.15] # Matches items in pool
