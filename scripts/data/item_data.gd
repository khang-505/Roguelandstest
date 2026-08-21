# scripts/data/item_data.gd
class_name ItemData
extends Resource

enum ItemType { ORE, CRYSTAL, ORGANIC, SHARD, CORE, CONSUMABLE }

@export var id: String = "ember_ore"
@export var display_name: String = "Ember Ore"
@export var item_type: ItemType = ItemType.ORE
@export var description: String = "A glowing mineral harvested from volcanic biomes."
@export var value: int = 15
@export var stack_max: int = 99
@export var icon_texture: Texture2D
