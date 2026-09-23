# scripts/procedural/breakable_object_data.gd
class_name BreakableObjectData
extends Resource

## Data Resource defining breakable categories, damage types, HP, and loot linkage.

enum ObjectType {
	CRATE,
	BARREL,
	ROCK,
	CRYSTAL,
	WOODEN_STRUCTURE,
	WEAK_WALL,
	BREAKABLE_DOOR,
	BREAKABLE_PLATFORM,
	CONTAINER,
	VEGETATION,
	MACHINE,
	DEBRIS
}

enum Category {
	DECORATIVE,
	RESOURCE,
	REWARD,
	SECRET,
	PATH_BLOCKER,
	COMBAT_OBJECT,
	ENVIRONMENTAL
}

@export var object_id: String = ""
@export var object_type: ObjectType = ObjectType.CRATE
@export var category: Category = Category.REWARD

@export var max_health: float = 50.0
@export var armor: float = 0.0

@export var required_damage_type: String = "ANY" # ANY, PHYSICAL, MINING, EXPLOSIVE, ENERGY, FIRE
@export var required_ability: String = "NONE"

@export var can_reveal_secret: bool = false
@export var can_open_path: bool = false
@export var can_drop_resource: bool = true

@export var biome_tags: Array[String] = []

func _init(
	p_id: String = "",
	p_type: ObjectType = ObjectType.CRATE,
	p_cat: Category = Category.REWARD,
	p_hp: float = 50.0,
	p_dmg_type: String = "ANY"
) -> void:
	object_id = p_id
	object_type = p_type
	category = p_cat
	max_health = p_hp
	required_damage_type = p_dmg_type

static func get_type_name(t: ObjectType) -> String:
	match t:
		ObjectType.CRATE: return "Wooden Crate"
		ObjectType.BARREL: return "Explosive Barrel"
		ObjectType.ROCK: return "Mining Ore Rock"
		ObjectType.CRYSTAL: return "Energy Crystal Node"
		ObjectType.WOODEN_STRUCTURE: return "Wooden Barrier"
		ObjectType.WEAK_WALL: return "Cracked Weak Wall"
		ObjectType.BREAKABLE_DOOR: return "Destructible Security Door"
		ObjectType.BREAKABLE_PLATFORM: return "Fragile Ledge"
		ObjectType.CONTAINER: return "Supply Container"
		ObjectType.VEGETATION: return "Thorn Vine Patch"
		ObjectType.MACHINE: return "Abandoned Terminal Machine"
		ObjectType.DEBRIS: return "Scrap Debris Cluster"
	return "Breakable Object"
