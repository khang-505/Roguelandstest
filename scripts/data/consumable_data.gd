# scripts/data/consumable_data.gd
class_name ConsumableData
extends Resource

## Data class for single-use consumable items (Potions, Elixirs, Buffs).

enum ConsumableType { HEALTH_POTION, ENERGY_ELIXIR, ATTACK_BUFF }

@export var item_id: String = ""
@export var display_name: String = ""
@export var type: ConsumableType = ConsumableType.HEALTH_POTION
@export var restore_amount: float = 40.0
@export var duration_seconds: float = 0.0
@export var credit_cost: int = 50

static var registry: Dictionary = {}

static func _setup_registry() -> void:
	if registry.size() > 0:
		return

	var p1 = ConsumableData.new()
	p1.item_id = "health_potion"
	p1.display_name = "Nanite Health Potion"
	p1.type = ConsumableType.HEALTH_POTION
	p1.restore_amount = 50.0
	p1.credit_cost = 40
	registry[p1.item_id] = p1

	var e1 = ConsumableData.new()
	e1.item_id = "energy_elixir"
	e1.display_name = "Plasma Energy Elixir"
	e1.type = ConsumableType.ENERGY_ELIXIR
	e1.restore_amount = 60.0
	e1.credit_cost = 35
	registry[e1.item_id] = e1

	var b1 = ConsumableData.new()
	b1.item_id = "attack_buff"
	b1.display_name = "Overcharge Damage Buff"
	b1.type = ConsumableType.ATTACK_BUFF
	b1.restore_amount = 15.0
	b1.duration_seconds = 15.0
	b1.credit_cost = 75
	registry[b1.item_id] = b1

static func get_consumable(p_id: String) -> ConsumableData:
	_setup_registry()
	if registry.has(p_id):
		return registry[p_id]
	return null
