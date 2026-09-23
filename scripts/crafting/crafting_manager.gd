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
	r1.material_requirements = {"ember_ore": 2, "star_shard": 1}
	r1.output_item_id = "plasma_cutter_mk2"
	r1.required_hub_level = 1
	recipe_registry[r1.recipe_id] = r1

	var r2 = RecipeData.new()
	r2.recipe_id = "frost_rifle_mk2"
	r2.display_name = "Frost Rifle Mk2"
	r2.category = RecipeData.Category.WEAPON
	r2.material_requirements = {"cryo_crystal": 2, "star_shard": 1}
	r2.output_item_id = "frost_rifle_mk2"
	r2.required_hub_level = 1
	recipe_registry[r2.recipe_id] = r2

	var r3 = RecipeData.new()
	r3.recipe_id = "ember_staff_mk2"
	r3.display_name = "Ember Staff Mk2"
	r3.category = RecipeData.Category.WEAPON
	r3.material_requirements = {"ember_ore": 3, "star_shard": 1}
	r3.output_item_id = "ember_staff_mk2"
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

	var unlocked_weapons: Array = player_profile.get("unlocked_weapons", ["plasma_cutter"])
	if recipe.output_item_id in unlocked_weapons:
		return {"can_craft": false, "reason": "Bạn đã sở hữu vũ khí này rồi!"}

	var persistent_materials: Dictionary = player_profile.get("persistent_materials", {})
	for mat_id in recipe.material_requirements.keys():
		var req_qty = recipe.material_requirements[mat_id]
		var player_qty = persistent_materials.get(mat_id, 0)
		if player_qty < req_qty:
			return {"can_craft": false, "reason": "Cần thêm %s (%d/%d)" % [mat_id.replace("_", " "), player_qty, req_qty]}

	return {"can_craft": true, "reason": "Sẵn sàng chế tạo!"}

static func craft_recipe(recipe_id: String) -> Dictionary:
	_setup_registry()
	var recipe = get_recipe(recipe_id)
	if recipe == null:
		return {"success": false, "message": "Công thức không hợp lệ!"}

	var profile = SaveManager.profile_data
	var validation = can_craft(recipe, profile)
	if not validation["can_craft"]:
		return {"success": false, "message": validation["reason"]}

	# Atomic Resource Consumption
	var persistent_materials: Dictionary = profile.get("persistent_materials", {})
	for mat_id in recipe.material_requirements.keys():
		var req_qty = recipe.material_requirements[mat_id]
		persistent_materials[mat_id] -= req_qty
	profile["persistent_materials"] = persistent_materials

	# Add Crafted Item Output to Unlocked Recipes / Weapons
	var unlocked_weapons: Array = profile.get("unlocked_weapons", ["plasma_cutter"])
	if not (recipe.output_item_id in unlocked_weapons):
		unlocked_weapons.append(recipe.output_item_id)
	profile["unlocked_weapons"] = unlocked_weapons

	SaveManager.save_game()
	return {"success": true, "message": "Đã chế tạo thành công %s!" % recipe.display_name}
