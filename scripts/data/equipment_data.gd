# scripts/data/equipment_data.gd
class_name EquipmentData
extends Resource

## Data class representing armor equipment, stat modifiers, and build trade-offs.

enum EquipmentSlot { HELMET, CHEST, LEGS, BOOTS, ACCESSORY }
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, MYTHIC }

@export var equipment_id: String = ""
@export var display_name: String = ""
@export var slot: EquipmentSlot = EquipmentSlot.CHEST
@export var rarity: Rarity = Rarity.COMMON

@export var bonus_hp: int = 0
@export var bonus_defense: int = 0
@export var bonus_attack: int = 0
@export var bonus_speed: float = 0.0
@export var bonus_crit_chance: float = 0.0

static var registry: Dictionary = {}

static func _setup_registry() -> void:
	if registry.size() > 0:
		return

	# 1. Iron Helmet (HELMET)
	var h1 = EquipmentData.new()
	h1.equipment_id = "iron_helmet"
	h1.display_name = "Iron Vanguard Helmet"
	h1.slot = EquipmentSlot.HELMET
	h1.bonus_hp = 25
	h1.bonus_defense = 5
	h1.rarity = Rarity.UNCOMMON
	registry[h1.equipment_id] = h1

	# 2. Titan Chestplate (CHEST - Tank Tradeoff: High Def, -5 Speed)
	var c1 = EquipmentData.new()
	c1.equipment_id = "titan_chest"
	c1.display_name = "Titan Heavy Chestplate"
	c1.slot = EquipmentSlot.CHEST
	c1.bonus_hp = 60
	c1.bonus_defense = 14
	c1.bonus_speed = -5.0
	c1.rarity = Rarity.RARE
	registry[c1.equipment_id] = c1

	# 3. Swift Leggings (LEGS)
	var l1 = EquipmentData.new()
	l1.equipment_id = "swift_leggings"
	l1.display_name = "Hyperion Swift Leggings"
	l1.slot = EquipmentSlot.LEGS
	l1.bonus_speed = 25.0
	l1.bonus_defense = 3
	l1.rarity = Rarity.UNCOMMON
	registry[l1.equipment_id] = l1

	# 4. Hyperion Swift Boots (BOOTS)
	var b1 = EquipmentData.new()
	b1.equipment_id = "swift_boots"
	b1.display_name = "Hyperion Swift Boots"
	b1.slot = EquipmentSlot.BOOTS
	b1.bonus_speed = 30.0
	b1.bonus_crit_chance = 0.05
	b1.rarity = Rarity.UNCOMMON
	registry[b1.equipment_id] = b1

	# 5. Assassin Boots (BOOTS - Assassin Tradeoff: High Speed & Crit, -15 HP)
	var b2 = EquipmentData.new()
	b2.equipment_id = "assassin_boots"
	b2.display_name = "Shadow Assassin Boots"
	b2.slot = EquipmentSlot.BOOTS
	b2.bonus_speed = 40.0
	b2.bonus_crit_chance = 0.12
	b2.bonus_hp = -15
	b2.rarity = Rarity.RARE
	registry[b2.equipment_id] = b2

	# 6. Critical Lens Accessory (ACCESSORY - Glass Cannon Tradeoff: High Damage, -20 HP)
	var a1 = EquipmentData.new()
	a1.equipment_id = "crit_lens"
	a1.display_name = "Plasma Crit Lens"
	a1.slot = EquipmentSlot.ACCESSORY
	a1.bonus_attack = 15
	a1.bonus_crit_chance = 0.18
	a1.bonus_hp = -20
	a1.rarity = Rarity.EPIC
	registry[a1.equipment_id] = a1

static func get_equipment(p_id: String) -> EquipmentData:
	_setup_registry()
	if registry.has(p_id):
		return registry[p_id]
	return null
