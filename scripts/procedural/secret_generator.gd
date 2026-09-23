# scripts/procedural/secret_generator.gd
class_name SecretGenerator
extends Node

## Procedural Secret Generator executing 12-step pipeline, spawning clues, entrances, and secret rewards.

const GENERATOR_VERSION: int = 1

static func spawn_secret_walls_for_room(
	parent_node: Node2D,
	width_tiles: int,
	height_tiles: int,
	tile_size: int,
	archetype: int,
	rng: RandomNumberGenerator
) -> Array[Node2D]:
	var dummy_room = {
		"width_tiles": width_tiles,
		"height_tiles": height_tiles,
		"tile_size": tile_size,
		"archetype": archetype
	}
	var res = generate_secret_for_room(parent_node, dummy_room, "emberwild", rng.randi(), 0)
	var spawned: Array[Node2D] = []
	if res.get("entrance_node") != null:
		spawned.append(res.get("entrance_node") as Node2D)
	return spawned

static func generate_secret_for_room(
	parent_node: Node2D,
	room_data: Dictionary,
	biome_id: String = "emberwild",
	seed_val: int = 1337,
	secret_index: int = 0
) -> Dictionary:
	var secret_seed = int(abs(hash(str(seed_val) + "_" + str(secret_index))))
	var rng = RandomNumberGenerator.new()
	rng.seed = secret_seed

	var sec_data_class = load("res://scripts/procedural/secret_data.gd")
	var sec_clue_class = load("res://scripts/procedural/secret_clue_data.gd")
	var sec_loot_class = load("res://scripts/procedural/secret_loot_table.gd")
	var sec_pattern_class = load("res://scripts/procedural/secret_pattern.gd")
	var sec_state_class = load("res://scripts/procedural/secret_state_manager.gd")

	# Step 1-2: Eligibility & Category Selection
	var sec_type_int = rng.randi_range(0, 13)
	var sec_type_enum = sec_type_int
	var secret_id = "secret_%s_%d_%d" % [biome_id, seed_val, secret_index]

	# Step 3-4: Clue & Challenge Selection
	var clue_type_int = rng.randi_range(0, 6)
	var required_ability = "NONE"
	if sec_type_int == 6: # HIDDEN_CEILING
		required_ability = "DOUBLE_JUMP"
	elif sec_type_int == 2 or sec_type_int == 9: # HIDDEN_PLATFORM or MOVEMENT_SECRET
		required_ability = "DASH"

	# Step 5: Reward Selection
	var loot = sec_loot_class.roll_secret_reward(rng, 1.2) if sec_loot_class else {"id": "star_shard", "amount": 2}

	# Step 6-8: Spawn Entrance & Clues
	var w_tiles = room_data.get("width_tiles", 24)
	var h_tiles = room_data.get("height_tiles", 14)
	var t_size = room_data.get("tile_size", 16)

	var ent_x = (w_tiles - 3) * t_size
	var ent_y = (h_tiles - 3) * t_size
	var ent_pos = Vector2(ent_x, ent_y)

	var entrance_node: Node2D = null

	if parent_node != null:
		# Entrance Node Selection
		match sec_type_int:
			0, 4, 8: # HIDDEN_ROOM, HIDDEN_WALL, BREAKABLE_SECRET
				var wall_script = load("res://scripts/world/breakable_wall.gd")
				if wall_script:
					var w_inst = wall_script.new() as StaticBody2D
					w_inst.set("secret_id", secret_id)
					w_inst.position = ent_pos
					parent_node.add_child(w_inst)
					entrance_node = w_inst

			1, 3: # HIDDEN_CAVE, HIDDEN_TUNNEL
				var fake_script = load("res://scripts/world/fake_wall.gd")
				if fake_script:
					var f_inst = fake_script.new() as Area2D
					f_inst.set("secret_id", secret_id)
					f_inst.position = ent_pos
					parent_node.add_child(f_inst)
					entrance_node = f_inst

			12: # RISK_REWARD_SECRET
				var shrine_script = load("res://scripts/world/secret_shrine.gd")
				if shrine_script:
					var s_inst = shrine_script.new() as Area2D
					s_inst.set("shrine_id", secret_id)
					s_inst.position = ent_pos
					parent_node.add_child(s_inst)
					entrance_node = s_inst

			13: # SECRET_SHORTCUT
				var cut_script = load("res://scripts/world/secret_shortcut.gd")
				if cut_script:
					var c_inst = cut_script.new() as Area2D
					c_inst.set("shortcut_id", secret_id)
					c_inst.position = ent_pos
					c_inst.set("target_position", Vector2(100, 100))
					parent_node.add_child(c_inst)
					entrance_node = c_inst

			_: # Generic Fake Wall fallback
				var fake_script = load("res://scripts/world/fake_wall.gd")
				if fake_script:
					var f_inst = fake_script.new() as Area2D
					f_inst.set("secret_id", secret_id)
					f_inst.position = ent_pos
					parent_node.add_child(f_inst)
					entrance_node = f_inst

		# Spawn Visual Clue Node
		var clue_rect = ColorRect.new()
		clue_rect.size = Vector2(8, 8)
		clue_rect.position = ent_pos + Vector2(-4, -20)
		clue_rect.color = Color(0.9, 0.8, 0.2, 0.7) # Faint golden glow hint
		parent_node.add_child(clue_rect)

	# Register state
	if sec_state_class:
		sec_state_class.register_secret(secret_id, required_ability)

	return {
		"secret_id": secret_id,
		"secret_type": sec_type_int,
		"clue_type": clue_type_int,
		"required_ability": required_ability,
		"entrance_pos": ent_pos,
		"loot": loot,
		"entrance_node": entrance_node,
		"is_optional": true,
		"version": GENERATOR_VERSION
	}
