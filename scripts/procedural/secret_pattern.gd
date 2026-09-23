# scripts/procedural/secret_pattern.gd
class_name SecretPattern
extends Resource

## Authored secret geometry pattern templates for room generator placement.

@export var pattern_id: String = ""
@export var secret_type: int = 4 # SecretData.Category.HIDDEN_WALL
@export var relative_entrance_pos: Vector2 = Vector2(0.8, 0.8)
@export var relative_secret_pos: Vector2 = Vector2(0.9, 0.8)
@export var required_ability: String = "NONE"

func _init(
	p_id: String = "",
	p_type: int = 4,
	p_ent: Vector2 = Vector2(0.8, 0.8),
	p_sec: Vector2 = Vector2(0.9, 0.8),
	p_ability: String = "NONE"
) -> void:
	pattern_id = p_id
	secret_type = p_type
	relative_entrance_pos = p_ent
	relative_secret_pos = p_sec
	required_ability = p_ability

static func get_authored_patterns() -> Array:
	var list: Array = []
	var p_script = load("res://scripts/procedural/secret_pattern.gd")
	if not p_script:
		return list

	# 1. Breakable Wall Secret
	list.append(p_script.new("wall_crack_right", 4, Vector2(0.85, 0.85), Vector2(0.95, 0.85), "NONE"))
	# 2. Hidden Floor Drop
	list.append(p_script.new("floor_drop_chasm", 5, Vector2(0.5, 0.9), Vector2(0.5, 1.1), "NONE"))
	# 3. Hidden Ceiling Shaft
	list.append(p_script.new("ceiling_shaft_up", 6, Vector2(0.5, 0.15), Vector2(0.5, -0.15), "DOUBLE_JUMP"))
	# 4. Hidden Platform Alcove
	list.append(p_script.new("high_platform_alcove", 2, Vector2(0.15, 0.2), Vector2(0.05, 0.15), "DASH"))
	# 5. Hidden Cave Tunnel
	list.append(p_script.new("subterranean_cave_side", 1, Vector2(0.9, 0.7), Vector2(1.1, 0.7), "NONE"))
	# 6. Secret Shortcut Connection
	list.append(p_script.new("shortcut_portal_door", 13, Vector2(0.1, 0.85), Vector2(0.0, 0.85), "NONE"))
	# 7. Risk / Reward Shrine
	list.append(p_script.new("shrine_altar_room", 12, Vector2(0.7, 0.5), Vector2(0.8, 0.5), "NONE"))
	# 8. Secret Combat Arena
	list.append(p_script.new("secret_combat_arena", 11, Vector2(0.3, 0.3), Vector2(0.2, 0.2), "NONE"))

	return list
