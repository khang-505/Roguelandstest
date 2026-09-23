# scripts/world/interactive_chest.gd
class_name InteractiveChest
extends Area2D

## World node representing interactive loot containers, treasure chests, locked vaults, and mimic traps.

signal chest_opened(chest_id: String, loot: Dictionary)
signal mimic_triggered(chest_id: String, mimic_data: Dictionary)

enum ChestTier { WOODEN, SILVER, GOLD, VOID }

@export var chest_id: String = "chest_001"
@export var is_opened: bool = false
@export var is_locked: bool = false
@export var required_key_id: String = "" # e.g. "void_key" or empty for none
@export var tier: ChestTier = ChestTier.GOLD
@export var mimic_chance: float = 0.05 # 5% chance by default

var visual_rect: ColorRect = null

const TIER_COLORS = {
	ChestTier.WOODEN: Color(0.6, 0.4, 0.2), # Brown
	ChestTier.SILVER: Color(0.75, 0.75, 0.8), # Silver
	ChestTier.GOLD: Color(0.9, 0.75, 0.1), # Gold
	ChestTier.VOID: Color(0.5, 0.1, 0.8) # Void Purple
}

const TIER_LOOT_MULTIPLIERS = {
	ChestTier.WOODEN: 1.0,
	ChestTier.SILVER: 1.5,
	ChestTier.GOLD: 2.5,
	ChestTier.VOID: 4.0
}

func _ready() -> void:
	if get_child_count() == 0:
		var col = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(24, 18)
		col.shape = shape
		add_child(col)

		visual_rect = ColorRect.new()
		visual_rect.size = Vector2(24, 18)
		visual_rect.position = Vector2(-12, -9)
		visual_rect.color = TIER_COLORS.get(tier, Color(0.9, 0.7, 0.1))
		add_child(visual_rect)

func open_chest(has_key: bool = false, rng_override: float = -1.0) -> Dictionary:
	if is_opened:
		return {"success": false, "reason": "already_opened"}

	if is_locked and not has_key:
		return {"success": false, "reason": "locked_requires_key", "required_key": required_key_id}

	# Check mimic trap roll
	var roll = rng_override if rng_override >= 0.0 else randf()
	if roll < mimic_chance:
		is_opened = true
		if visual_rect: visual_rect.color = Color(0.8, 0.1, 0.1) # Red mimic alert
		var mimic_info = {"chest_id": chest_id, "tier": tier, "hp": 150, "attack": 25}
		mimic_triggered.emit(chest_id, mimic_info)
		return {"success": true, "is_mimic": true, "mimic_data": mimic_info}

	is_opened = true
	if visual_rect: visual_rect.color = Color(0.3, 0.3, 0.3) # Opened state gray

	var state_class = load("res://scripts/procedural/interaction_state.gd")
	if state_class:
		state_class.set_state(chest_id, "COMPLETED")

	# Roll chest loot
	var loot_class = load("res://scripts/procedural/secret_loot_table.gd")
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var mult = TIER_LOOT_MULTIPLIERS.get(tier, 1.0)
	var loot = loot_class.roll_secret_reward(rng, mult) if loot_class else {"id": "star_shard", "amount": int(10 * mult)}

	chest_opened.emit(chest_id, loot)
	return {"success": true, "is_mimic": false, "loot": loot, "tier_multiplier": mult}
