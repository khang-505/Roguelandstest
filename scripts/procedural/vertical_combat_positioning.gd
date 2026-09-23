# scripts/procedural/vertical_combat_positioning.gd
class_name VerticalCombatPositioning
extends Node

## Tactical enemy placement engine allocating enemy roles according to vertical layer geometry.

enum EnemyVerticalRole {
	GROUND_MELEE,
	UPPER_SNIPER,
	AIR_PATROL,
	CAVE_AMBUSH,
	CENTRAL_TANK
}

static func allocate_enemies_for_vertical_room(
	room_node: Node2D,
	layer_platforms: Dictionary, # Layer ID -> Array[Vector2] platform positions
	enemy_budget: int,
	rng: RandomNumberGenerator
) -> Array[Dictionary]:
	var spawn_plan: Array[Dictionary] = []

	if room_node == null or layer_platforms.size() == 0:
		return spawn_plan

	var enemy_data_class = load("res://scripts/data/enemy_data.gd")
	var enemy_ids = ["ash_beetle", "void_stalker", "crystal_construct"]
	if enemy_data_class and enemy_data_class.has_method("get_registry"):
		var reg = enemy_data_class.get_registry() as Dictionary
		if reg.size() > 0:
			enemy_ids = reg.keys()

	var placed_count = 0
	var layers = layer_platforms.keys()

	# 1. Place Ranged Snipers on Upper Layers (LAYER 4 / 5)
	for l_id in [4, 5]:
		if layer_platforms.has(l_id) and placed_count < enemy_budget:
			var platforms = layer_platforms[l_id] as Array
			for pos in platforms:
				if rng.randf() < 0.6 and placed_count < enemy_budget:
					var chosen_e = _pick_enemy_for_role(EnemyVerticalRole.UPPER_SNIPER, enemy_ids)
					spawn_plan.append({"enemy_id": chosen_e, "position": pos + Vector2(0, -14), "role": EnemyVerticalRole.UPPER_SNIPER})
					placed_count += 1

	# 2. Place Cave Ambushers in Lower Caves (LAYER 0 / 1)
	for l_id in [0, 1]:
		if layer_platforms.has(l_id) and placed_count < enemy_budget:
			var platforms = layer_platforms[l_id] as Array
			for pos in platforms:
				if rng.randf() < 0.5 and placed_count < enemy_budget:
					var chosen_e = _pick_enemy_for_role(EnemyVerticalRole.CAVE_AMBUSH, enemy_ids)
					spawn_plan.append({"enemy_id": chosen_e, "position": pos + Vector2(0, -14), "role": EnemyVerticalRole.CAVE_AMBUSH})
					placed_count += 1

	# 3. Place Ground Melee & Central Tanks on Main Layer (LAYER 2 / 3)
	for l_id in [2, 3]:
		if layer_platforms.has(l_id) and placed_count < enemy_budget:
			var platforms = layer_platforms[l_id] as Array
			for pos in platforms:
				if placed_count < enemy_budget:
					var role = EnemyVerticalRole.GROUND_MELEE if rng.randf() < 0.75 else EnemyVerticalRole.CENTRAL_TANK
					var chosen_e = _pick_enemy_for_role(role, enemy_ids)
					spawn_plan.append({"enemy_id": chosen_e, "position": pos + Vector2(0, -14), "role": role})
					placed_count += 1

	return spawn_plan

static func _pick_enemy_for_role(role: int, enemy_ids: Array) -> String:
	if enemy_ids.size() == 0:
		return "ash_beetle"

	match role:
		EnemyVerticalRole.UPPER_SNIPER:
			for e in enemy_ids:
				if "construct" in e or "stalker" in e or "sniper" in e: return e
		EnemyVerticalRole.CAVE_AMBUSH:
			for e in enemy_ids:
				if "stalker" in e or "beetle" in e: return e
		EnemyVerticalRole.CENTRAL_TANK:
			for e in enemy_ids:
				if "construct" in e or "golem" in e: return e

	return enemy_ids[0]
