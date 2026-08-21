# scripts/crafting/crafting_manager.gd
class_name CraftingManager
extends Node

## Manages data-driven crafting validation, atomic resource transactions, and recipe execution.

static var recipe_registry: Dictionary = {}

static func _static_init() -> void:
	_setup_registry()

static func _setup_registry() -> void:
	if recipe_registry.size() > 0:
		return

	var r1 = RecipeData.new()
	r1.recipe_id = "plasma_cutter_mk2"
	r1.display_name = "Plasma Cutter Mk2"
	r1.category = RecipeData.Category.WEAPON
	r1.material_requirements = {"ember_ore": 10, "star_shard": 5}
	r1.output_item_id = "plasma_cutter_mk2"
	r1.required_hub_level = 1
	recipe_registry[r1.recipe_id] = r1

	var r2 = RecipeData.new()
	r2.recipe_id = "frost_rifle_mk2"
	r2.display_name = "Frost Rifle Mk2"
	r2.category = RecipeData.Category.WEAPON
	r2.material_requirements = {"cryo_crystal": 12, "star_shard": 8}
	r2.output_item_id = "frost_rifle_mk2"
	r2.required_hub_level = 2
	recipe_registry[r2.recipe_id] = r2

	var r3 = RecipeData.new()
	r3.recipe_id = "health_stim"
	r3.display_name = "Nanite Health Stim"
	r3.category = RecipeData.Category.CONSUMABLE
	r3.material_requirements = {"bio_sample": 5, "ember_ore": 3}
	r3.output_item_id = "health_stim"
	r3.required_hub_level = 1
	recipe_registry[r3.recipe_id] = r3

static func get_recipe(p_id: String) -> RecipeData:
	_setup_registry()
	if recipe_registry.has(p_id):
		return recipe_registry[p_id]
	return null

static func can_craft(recipe: RecipeData, player_profile: Dictionary) -> Dictionary:
	if recipe == null:
		return {"can_craft": false, "reason": "Invalid recipe"}

	# 1. Check Hub level requirement
	var current_hub = player_profile.get("hub_level", 1)
	if current_hub < recipe.required_hub_level:
		return {"can_craft": false, "reason": "Requires Hub Level %d" % recipe.required_hub_level}

	# 2. Check Research prerequisite requirement
	if recipe.required_research_id != "":
		var unlocked_research: Array = player_profile.get("unlocked_research", [])
		if not (recipe.required_research_id in unlocked_research):
			return {"can_craft": false, "reason": "Requires Research: %s" % recipe.required_research_id}

	# 3. Check Material Requirements
	var persistent_materials: Dictionary = player_profile.get("persistent_materials", {})
	for mat_id in recipe.material_requirements.keys():
		var req_qty = recipe.material_requirements[mat_id]
		var player_qty = persistent_materials.get(mat_id, 0)
		if player_qty < req_qty:
			return {"can_craft": false, "reason": "Missing materials: %s (%d/%d)" % [mat_id, player_qty, req_qty]}

	return {"can_craft": true, "reason": "Ready to craft"}

static func craft_recipe(recipe_id: String) -> bool:
	_setup_registry()
	var recipe = get_recipe(recipe_id)
	if recipe == null:
		return false

	var profile = SaveManager.profile_data
	var validation = can_craft(recipe, profile)
	if not validation["can_craft"]:
		return false

	# Atomic Resource Consumption
	var persistent_materials: Dictionary = profile.get("persistent_materials", {})
	for mat_id in recipe.material_requirements.keys():
		var req_qty = recipe.material_requirements[mat_id]
		persistent_materials[mat_id] -= req_qty
	profile["persistent_materials"] = persistent_materials

	# Add Crafted Item Output to Unlocked Recipes / Inventory
	var unlocked_recipes: Array = profile.get("unlocked_recipes", [])
	if not (recipe.output_item_id in unlocked_recipes):
		unlocked_recipes.append(recipe.output_item_id)
	profile["unlocked_recipes"] = unlocked_recipes

	SaveManager.save_game()
	return true
