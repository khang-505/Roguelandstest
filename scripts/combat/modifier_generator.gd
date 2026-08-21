# scripts/combat/modifier_generator.gd
class_name ModifierGenerator
extends Node

## Deterministic Data-Driven Weapon Modifier Engine & Random Affix Generator.

class AffixDefinition:
	var id: String
	var display_name: String
	var stat: String # "damage", "critical_chance", "attack_speed", "projectile_speed", "lifesteal", "knockback_force"
	var operation: String # "ADD", "MULTIPLY", "SET"
	var min_value: float
	var max_value: float
	var weight: float
	var allowed_categories: Array[WeaponData.WeaponCategory]

	func _init(p_id: String, p_name: String, p_stat: String, p_op: String, p_min: float, p_max: float, p_weight: float, p_cats: Array[WeaponData.WeaponCategory]) -> void:
		id = p_id
		display_name = p_name
		stat = p_stat
		operation = p_op
		min_value = p_min
		max_value = p_max
		weight = p_weight
		allowed_categories = p_cats

static var registry: Array[AffixDefinition] = []

static func _static_init() -> void:
	_setup_registry()

static func _setup_registry() -> void:
	if registry.size() > 0:
		return
		
	var all_cats: Array[WeaponData.WeaponCategory] = [
		WeaponData.WeaponCategory.MELEE,
		WeaponData.WeaponCategory.RANGED,
		WeaponData.WeaponCategory.ENERGY,
		WeaponData.WeaponCategory.SPECIAL
	]
	var ranged_cats: Array[WeaponData.WeaponCategory] = [
		WeaponData.WeaponCategory.RANGED,
		WeaponData.WeaponCategory.ENERGY,
		WeaponData.WeaponCategory.SPECIAL
	]
	
	registry.append(AffixDefinition.new("damage_mult", "Empowered", "damage", "MULTIPLY", 0.08, 0.25, 40.0, all_cats))
	registry.append(AffixDefinition.new("damage_add", "Heavy", "damage", "ADD", 3.0, 10.0, 35.0, all_cats))
	registry.append(AffixDefinition.new("crit_chance", "Vicious", "critical_chance", "ADD", 0.05, 0.20, 30.0, all_cats))
	registry.append(AffixDefinition.new("attack_speed", "Swift", "attack_speed", "MULTIPLY", 0.05, 0.20, 35.0, all_cats))
	registry.append(AffixDefinition.new("lifesteal", "Vampiric", "lifesteal", "ADD", 0.04, 0.12, 15.0, all_cats))
	registry.append(AffixDefinition.new("knockback", "Impactful", "knockback_force", "ADD", 20.0, 60.0, 25.0, all_cats))
	registry.append(AffixDefinition.new("proj_speed", "Accelerated", "projectile_speed", "MULTIPLY", 0.15, 0.40, 30.0, ranged_cats))

static func get_compatible_affixes(category: WeaponData.WeaponCategory) -> Array[AffixDefinition]:
	_setup_registry()
	var list: Array[AffixDefinition] = []
	for affix in registry:
		if category in affix.allowed_categories:
			list.append(affix)
	return list

static func generate_affixes(weapon: WeaponData, count: int, seed_val: int = -1) -> Array[Dictionary]:
	_setup_registry()
	var rng = RandomNumberGenerator.new()
	if seed_val != -1:
		rng.seed = seed_val
	else:
		rng.randomize()

	var compatible = get_compatible_affixes(weapon.category)
	var chosen: Array[Dictionary] = []
	var selected_ids: Array[String] = []

	var target_count = min(count, compatible.size())
	
	while chosen.size() < target_count:
		var available: Array[AffixDefinition] = []
		var total_weight: float = 0.0
		for affix in compatible:
			if not (affix.id in selected_ids):
				available.append(affix)
				total_weight += affix.weight

		if available.size() == 0 or total_weight <= 0.0:
			break

		var roll = rng.randf() * total_weight
		var cumulative = 0.0
		var selected_affix: AffixDefinition = null

		for affix in available:
			cumulative += affix.weight
			if roll <= cumulative:
				selected_affix = affix
				break

		if selected_affix == null:
			selected_affix = available[available.size() - 1]

		selected_ids.append(selected_affix.id)
		
		# Generate value within bounds
		var raw_val = rng.randf_range(selected_affix.min_value, selected_affix.max_value)
		# Round to 2 decimal places for clean float precision
		var val = snappedf(raw_val, 0.01)

		chosen.append({
			"id": selected_affix.id,
			"display_name": selected_affix.display_name,
			"stat": selected_affix.stat,
			"operation": selected_affix.operation,
			"value": val
		})

	return chosen

static func apply_affixes_to_weapon(weapon: WeaponData, count: int, seed_val: int = -1) -> void:
	weapon.affixes = generate_affixes(weapon, count, seed_val)
