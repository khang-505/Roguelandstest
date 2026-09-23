# scripts/procedural/hidden_path_pattern.gd
class_name HiddenPathPattern
extends Resource

## Authored layout pattern catalog for hidden path templates across 5 biomes.

@export var pattern_id: String = ""
@export var path_type: int = 0 # HiddenPathData.PathType.HIDDEN_TUNNEL
@export var biome_tag: String = "emberwild"
@export var entrance_relative_pos: Vector2 = Vector2(0.8, 0.8)
@export var exit_relative_pos: Vector2 = Vector2(0.95, 0.8)
@export var required_ability: String = "NONE"
@export var reconnects: bool = true

func _init(
	p_id: String = "",
	p_type: int = 0,
	p_biome: String = "emberwild",
	p_ent: Vector2 = Vector2(0.8, 0.8),
	p_exit: Vector2 = Vector2(0.95, 0.8),
	p_ability: String = "NONE",
	p_reconnect: bool = true
) -> void:
	pattern_id = p_id
	path_type = p_type
	biome_tag = p_biome
	entrance_relative_pos = p_ent
	exit_relative_pos = p_exit
	required_ability = p_ability
	reconnects = p_reconnect

static func get_authored_patterns() -> Array:
	var pattern_script = load("res://scripts/procedural/hidden_path_pattern.gd")
	var list: Array = []

	if pattern_script:
		# 1. Forest Root Tunnel
		list.append(pattern_script.new("forest_root_tunnel", 0, "verdant_abyss", Vector2(0.85, 0.85), Vector2(0.95, 0.85), "NONE", true))
		# 2. Mine Collapsed Shaft Shortcut
		list.append(pattern_script.new("mine_collapsed_shortcut", 7, "industrial_core", Vector2(0.1, 0.9), Vector2(0.0, 0.9), "NONE", true))
		# 3. Frostgrave Ice Wall Bypass
		list.append(pattern_script.new("ice_wall_bypass", 10, "frostgrave", Vector2(0.7, 0.8), Vector2(0.9, 0.8), "NONE", true))
		# 4. Machine Maintenance Vent Shaft
		list.append(pattern_script.new("machine_vent_shaft", 4, "industrial_core", Vector2(0.5, 0.15), Vector2(0.5, -0.15), "DOUBLE_JUMP", true))
		# 5. Cave Subterranean Loop
		list.append(pattern_script.new("subterranean_cave_loop", 8, "emberwild", Vector2(0.9, 0.7), Vector2(1.1, 0.7), "NONE", true))
		# 6. Alien Void High Platform Chain
		list.append(pattern_script.new("alien_high_platform_chain", 6, "alien_void", Vector2(0.2, 0.3), Vector2(0.1, 0.2), "DASH", true))

	return list
