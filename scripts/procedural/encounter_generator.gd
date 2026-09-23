# scripts/procedural/encounter_generator.gd
class_name EncounterGenerator
extends Node

## 12-Step Procedural Generator for structured, data-driven encounters based on room purpose, biome, and difficulty.

const GENERATOR_VERSION: int = 1

static func generate_encounter_for_room(
	parent_node: Node2D,
	room_data: Dictionary,
	biome_id: String = "emberwild",
	seed_val: int = 1337,
	difficulty: float = 1.0
) -> Dictionary:
	var room_seed = int(abs(hash(str(seed_val) + "_enc_" + str(room_data.get("id", "rm")))))
	var rng = RandomNumberGenerator.new()
	rng.seed = room_seed

	var encounter_id = "enc_%s_%d" % [biome_id, room_seed]
	var w_tiles = room_data.get("width_tiles", 24)
	var h_tiles = room_data.get("height_tiles", 14)
	var t_size = room_data.get("tile_size", 16)

	# Step 1-2: Budget Calculation
	var area_factor = (w_tiles * h_tiles) / 300.0
	var enemy_budget = int(clamp(8.0 * area_factor * difficulty, 4.0, 30.0))

	# Step 3-4: Pattern & Role Selection
	var pattern_int = rng.randi_range(0, 11) # 0-11 SpawnPattern
	var wave_count = 1
	if pattern_int == 1: # WAVE
		wave_count = rng.randi_range(2, 3)

	# Step 5-8: Spawn Point Assignment & Safety Margin
	var spawn_points: Array = []
	var remaining_budget = enemy_budget
	var index = 0

	var marker_script = load("res://scripts/world/enemy_spawn_point.gd")

	while remaining_budget > 0 and index < 12:
		var role = rng.randi_range(0, 10) # 0-10 EnemyRole
		var data_class = load("res://scripts/procedural/encounter_data.gd")
		var role_cost = data_class.get_role_cost(role) if data_class else 2

		if role_cost > remaining_budget and spawn_points.size() > 0:
			break

		remaining_budget -= role_cost

		var gx = rng.randi_range(3, w_tiles - 4) * t_size
		var gy = rng.randi_range(3, h_tiles - 4) * t_size
		var pos = Vector2(gx, gy)

		var marker_node: Node2D = null
		if parent_node != null and marker_script != null:
			var m_inst = marker_script.new() as Node2D
			m_inst.set("marker_id", "%s_sp_%d" % [encounter_id, index])
			m_inst.position = pos
			parent_node.add_child(m_inst)
			marker_node = m_inst

		spawn_points.append({
			"marker_id": "%s_sp_%d" % [encounter_id, index],
			"role": role,
			"position": pos,
			"cost": role_cost,
			"node": marker_node
		})

		index += 1

	# Step 12: Register State
	var state_class = load("res://scripts/procedural/encounter_state.gd")
	if state_class:
		state_class.register_encounter(encounter_id, wave_count)

	return {
		"encounter_id": encounter_id,
		"biome": biome_id,
		"difficulty": difficulty,
		"total_budget": enemy_budget,
		"pattern": pattern_int,
		"wave_count": wave_count,
		"spawn_points": spawn_points,
		"version": GENERATOR_VERSION
	}
