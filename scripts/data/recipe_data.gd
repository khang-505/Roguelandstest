# scripts/data/recipe_data.gd
class_name RecipeData
extends Resource

enum Category { WEAPON, CONSUMABLE, COMPANION_MODULE, UTILITY }

@export var recipe_id: String = "plasma_cutter_mk2"
@export var display_name: String = "Plasma Cutter Mk2"
@export var category: Category = Category.WEAPON
@export var material_requirements: Dictionary = {
	"ember_ore": 10,
	"star_shard": 5
}
@export var output_item_id: String = "plasma_cutter_mk2"
@export var output_quantity: int = 1
@export var required_hub_level: int = 1
@export var required_research_id: String = ""
