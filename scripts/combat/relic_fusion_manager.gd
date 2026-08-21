# scripts/combat/relic_fusion_manager.gd
class_name RelicFusionManager
extends Node

## Manages data-driven Relic Fusion matrix, atomic fragment transactions, and combat singularity bursts.

class FusionRecipe:
	var recipe_id: String
	var display_name: String
	var description: String
	var required_fragments: Dictionary # Fragment ID -> quantity
	var output_relic_id: String
	var cooldown_seconds: float
	
	func _init(p_id: String, p_name: String, p_desc: String, p_reqs: Dictionary, p_out: String, p_cd: float = 10.0) -> void:
		recipe_id = p_id
		display_name = p_name
		description = p_desc
		required_fragments = p_reqs
		output_relic_id = p_out
		cooldown_seconds = p_cd

static var fusion_registry: Dictionary = {}
static var last_fusion_time: Dictionary = {}

static func _static_init() -> void:
	_setup_registry()

static func _setup_registry() -> void:
	if fusion_registry.size() > 0:
		return

	# 1. Molten Singularity (Fire + Void + Crystal)
	var r1 = FusionRecipe.new(
		"molten_singularity",
		"Molten Singularity",
		"Pulls hostiles inward and bursts flame dealing 60 Burn damage.",
		{"ember_ore": 5, "star_shard": 5, "cryo_crystal": 5},
		"relic_molten_singularity",
		12.0
	)
	fusion_registry[r1.recipe_id] = r1

	# 2. Absolute Zero Pulse (Ice + Shock + Core)
	var r2 = FusionRecipe.new(
		"absolute_zero_pulse",
		"Absolute Zero Pulse",
		"Freezes all enemies and chains static shock damage.",
		{"cryo_crystal": 8, "star_shard": 5, "ember_ore": 2},
		"relic_absolute_zero",
		10.0
	)
	fusion_registry[r2.recipe_id] = r2

	# 3. Toxic Spore Cataclysm (Poison + Bio + Shard)
	var r3 = FusionRecipe.new(
		"toxic_spore_cataclysm",
		"Toxic Spore Cataclysm",
		"Applies 5 stacks of deadly poison to all room hostiles.",
		{"bio_sample": 10, "star_shard": 5, "ember_ore": 3},
		"relic_toxic_spore",
		15.0
	)
	fusion_registry[r3.recipe_id] = r3

static func get_recipe(p_id: String) -> FusionRecipe:
	_setup_registry()
	if fusion_registry.has(p_id):
		return fusion_registry[p_id]
	return null

static func can_fuse(recipe: FusionRecipe, profile: Dictionary) -> Dictionary:
	if recipe == null:
		return {"can_fuse": false, "reason": "Invalid fusion recipe"}

	var persistent_materials: Dictionary = profile.get("persistent_materials", {})
	for frag_id in recipe.required_fragments.keys():
		var req_qty = recipe.required_fragments[frag_id]
		var player_qty = persistent_materials.get(frag_id, 0)
		if player_qty < req_qty:
			return {"can_fuse": false, "reason": "Missing fragments: %s (%d/%d)" % [frag_id, player_qty, req_qty]}

	return {"can_fuse": true, "reason": "Ready to fuse"}

static func fuse_relic(recipe_id: String) -> bool:
	_setup_registry()
	var recipe = get_recipe(recipe_id)
	if recipe == null:
		return false

	var profile = SaveManager.profile_data
	var validation = can_fuse(recipe, profile)
	if not validation["can_fuse"]:
		return false

	# Atomic Resource Consumption
	var persistent_materials: Dictionary = profile.get("persistent_materials", {})
	for frag_id in recipe.required_fragments.keys():
		var req_qty = recipe.required_fragments[frag_id]
		persistent_materials[frag_id] -= req_qty
	profile["persistent_materials"] = persistent_materials

	# Add Fused Relic Output to Persistent Inventory
	var unlocked_relics: Array = profile.get("unlocked_relics", [])
	if not (recipe.output_relic_id in unlocked_relics):
		unlocked_relics.append(recipe.output_relic_id)
	profile["unlocked_relics"] = unlocked_relics

	SaveManager.save_game()
	return true

static func execute_relic_burst(relic_id: String, tree: SceneTree, user_pos: Vector2) -> bool:
	_setup_registry()
	if tree == null:
		return false

	var enemies = tree.get_nodes_in_group("enemies")
	match relic_id:
		"relic_molten_singularity":
			for enemy in enemies:
				if is_instance_valid(enemy) and enemy is CharacterBody2D:
					if enemy.global_position.distance_to(user_pos) <= 220.0:
						enemy.global_position = enemy.global_position.move_toward(user_pos, 40.0) # Pull force
						StatusEffectManager.apply_status(enemy, StatusEffectManager.StatusType.BURN, 4.0, 15)
			return true

		"relic_absolute_zero":
			for enemy in enemies:
				if is_instance_valid(enemy) and enemy is Node2D:
					StatusEffectManager.apply_status(enemy, StatusEffectManager.StatusType.FREEZE, 3.0, 0, 0.5)
					StatusEffectManager.apply_status(enemy, StatusEffectManager.StatusType.SHOCK, 1.0, 20)
			return true

		"relic_toxic_spore":
			for enemy in enemies:
				if is_instance_valid(enemy) and enemy is Node2D:
					for i in range(5):
						StatusEffectManager.apply_status(enemy, StatusEffectManager.StatusType.POISON, 5.0, 8)
			return true

	return false
