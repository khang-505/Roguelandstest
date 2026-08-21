# scripts/data/rarity_data.gd
class_name RarityData
extends Resource

## Data-Driven Item Rarity System with Weighted Probabilities & Stat Multipliers.

enum Tier { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, MYTHIC }

@export var tier: Tier = Tier.COMMON
@export var id: String = "common"
@export var display_name: String = "Common"
@export var weight: float = 60.0
@export var min_modifiers: int = 0
@export var max_modifiers: int = 1
@export var quality_multiplier: float = 1.0
@export var color_hex: String = "#A0A0A0" # Clean gray

static var rarity_table: Array[RarityData] = []

static func _static_init() -> void:
	_setup_table()

static func _setup_table() -> void:
	if rarity_table.size() > 0:
		return

	rarity_table.append(_create_rarity(Tier.COMMON, "common", "Common", 60.0, 0, 1, 1.0, "#A0A0A0"))
	rarity_table.append(_create_rarity(Tier.UNCOMMON, "uncommon", "Uncommon", 25.0, 1, 2, 1.15, "#20C040"))
	rarity_table.append(_create_rarity(Tier.RARE, "rare", "Rare", 10.0, 2, 2, 1.35, "#3080FF"))
	rarity_table.append(_create_rarity(Tier.EPIC, "epic", "Epic", 4.0, 2, 3, 1.60, "#A030FF"))
	rarity_table.append(_create_rarity(Tier.LEGENDARY, "legendary", "Legendary", 0.9, 3, 4, 2.00, "#FF9000"))
	rarity_table.append(_create_rarity(Tier.MYTHIC, "mythic", "Mythic", 0.1, 4, 5, 2.50, "#FF2050"))

static func _create_rarity(p_tier: Tier, p_id: String, p_name: String, p_weight: float, p_min: int, p_max: int, p_qual: float, p_hex: String) -> RarityData:
	var r = RarityData.new()
	r.tier = p_tier
	r.id = p_id
	r.display_name = p_name
	r.weight = p_weight
	r.min_modifiers = p_min
	r.max_modifiers = p_max
	r.quality_multiplier = p_qual
	r.color_hex = p_hex
	return r

static func roll_rarity(seed_val: int = -1) -> RarityData:
	_setup_table()
	var rng = RandomNumberGenerator.new()
	if seed_val != -1:
		rng.seed = seed_val
	else:
		rng.randomize()

	var total_weight: float = 0.0
	for r in rarity_table:
		total_weight += r.weight

	if total_weight <= 0.0:
		return rarity_table[0]

	var roll = rng.randf() * total_weight
	var cumulative: float = 0.0

	for r in rarity_table:
		cumulative += r.weight
		if roll <= cumulative:
			return r

	return rarity_table[rarity_table.size() - 1]

static func get_rarity_by_tier(p_tier: Tier) -> RarityData:
	_setup_table()
	for r in rarity_table:
		if r.tier == p_tier:
			return r
	return rarity_table[0]

func roll_modifier_count(seed_val: int = -1) -> int:
	var rng = RandomNumberGenerator.new()
	if seed_val != -1:
		rng.seed = seed_val
	else:
		rng.randomize()
	return rng.randi_range(min_modifiers, max_modifiers)
