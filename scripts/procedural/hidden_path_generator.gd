# scripts/procedural/hidden_path_generator.gd
class_name HiddenPathGenerator
extends Node

## 12-Step Procedural Generator for explorable hidden paths, shortcuts, loops, and cave routes.

const GENERATOR_VERSION: int = 1

static func generate_hidden_path_for_room(
	parent_node: Node2D,
	room_data: Dictionary,
	biome_id: String = "emberwild",
	seed_val: int = 1337,
	path_index: int = 0
) -> Dictionary:
	var path_seed = int(abs(hash(str(seed_val) + "_path_" + str(path_index))))
	var rng = RandomNumberGenerator.new()
	rng.seed = path_seed

	var data_class = load("res://scripts/procedural/hidden_path_data.gd")
	var state_class = load("res://scripts/procedural/hidden_path_state.gd")
	var loot_class = load("res://scripts/procedural/secret_loot_table.gd")

	# Step 1-2: Eligibility & Category Selection
	var p_type_int = rng.randi_range(0, 13)
	var path_id = "hpath_%s_%d_%d" % [biome_id, seed_val, path_index]

	# Step 3-4: Clue & Challenge Selection
	var clue_types = ["CRACKED_WALL", "LIGHT_RAY", "PARTICLE_DUST", "AUDIO_HUM", "UNUSUAL_TILE", "GEOMETRY_GAP", "SUSPICIOUS_SHADOW"]
	var clue_type = clue_types[rng.randi_range(0, clue_types.size() - 1)]

	var required_ability = "NONE"
	if p_type_int == 4: # HIDDEN_CEILING_PATH
		required_ability = "DOUBLE_JUMP"
	elif p_type_int == 6 or p_type_int == 11: # HIDDEN_PLATFORM_PATH or HIDDEN_ABILITY_PATH
		required_ability = "DASH"

	# Step 5: Reward & Destination Selection
	var dest_types = ["TREASURE", "CAVE", "SHORTCUT", "ALTERNATIVE_REGION", "SHOP", "ELITE", "EVENT", "REJOIN_MAIN"]
	var dest_type = dest_types[rng.randi_range(0, dest_types.size() - 1)]
	var loot = loot_class.roll_secret_reward(rng, 1.3) if loot_class else {"id": "quantum_core", "amount": 3}

	# Step 6-9: Entrance & Clue Instantiation
	var w_tiles = room_data.get("width_tiles", 24)
	var h_tiles = room_data.get("height_tiles", 14)
	var t_size = room_data.get("tile_size", 16)

	var ent_x = (w_tiles - 2) * t_size
	var ent_y = (h_tiles - 3) * t_size
	var ent_pos = Vector2(ent_x, ent_y)

	var entrance_node: Node2D = null

	if parent_node != null:
		match p_type_int:
			7: # HIDDEN_SHORTCUT
				var cut_script = load("res://scripts/world/secret_shortcut.gd")
				if cut_script:
					var c_inst = cut_script.new() as Area2D
					c_inst.set("shortcut_id", path_id)
					c_inst.position = ent_pos
					c_inst.set("target_position", Vector2(150, 150))
					parent_node.add_child(c_inst)
					entrance_node = c_inst

			12: # HIDDEN_BREAKABLE_PATH
				var wall_script = load("res://scripts/world/breakable_wall.gd")
				if wall_script:
					var w_inst = wall_script.new() as StaticBody2D
					w_inst.set("secret_id", path_id)
					w_inst.position = ent_pos
					parent_node.add_child(w_inst)
					entrance_node = w_inst

			_: # Generic Fake Wall or Tunnel
				var fake_script = load("res://scripts/world/fake_wall.gd")
				if fake_script:
					var f_inst = fake_script.new() as Area2D
					f_inst.set("secret_id", path_id)
					f_inst.position = ent_pos
					parent_node.add_child(f_inst)
					entrance_node = f_inst

		# Spawn Environmental Clue Node
		var clue_rect = ColorRect.new()
		clue_rect.size = Vector2(10, 10)
		clue_rect.position = ent_pos + Vector2(-5, -22)
		clue_rect.color = Color(0.3, 0.9, 0.7, 0.75) # Cyan/Green ambient clue particle
		parent_node.add_child(clue_rect)

	# Register State
	if state_class:
		state_class.register_path(path_id, required_ability)

	return {
		"path_id": path_id,
		"path_type": p_type_int,
		"clue_type": clue_type,
		"destination_type": dest_type,
		"required_ability": required_ability,
		"entrance_pos": ent_pos,
		"loot": loot,
		"entrance_node": entrance_node,
		"is_optional": true,
		"reconnects": true,
		"version": GENERATOR_VERSION
	}
