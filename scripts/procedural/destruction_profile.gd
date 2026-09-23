# scripts/procedural/destruction_profile.gd
class_name DestructionProfile
extends Resource

## Destruction feedback profile mapping materials to particles, sound, camera shake, and hit flash.

@export var material_name: String = "WOOD" # WOOD, ROCK, CRYSTAL, METAL, ICE
@export var particle_color: Color = Color(0.6, 0.4, 0.2)
@export var debris_count: int = 8
@export var camera_shake_strength: float = 4.0
@export var hit_flash_duration: float = 0.1
@export var sfx_break_event: String = "event:/sfx/break_wood"

func _init(
	p_mat: String = "WOOD",
	p_col: Color = Color(0.6, 0.4, 0.2),
	p_debris: int = 8,
	p_shake: float = 4.0
) -> void:
	material_name = p_mat
	particle_color = p_col
	debris_count = p_debris
	camera_shake_strength = p_shake

static func get_profile_for_material(mat: String) -> DestructionProfile:
	var profile_script = load("res://scripts/procedural/destruction_profile.gd")
	if not profile_script:
		return null

	match mat.to_upper():
		"ROCK":
			return profile_script.new("ROCK", Color(0.5, 0.5, 0.5), 12, 6.0)
		"CRYSTAL":
			return profile_script.new("CRYSTAL", Color(0.2, 0.8, 1.0), 10, 5.0)
		"METAL":
			return profile_script.new("METAL", Color(0.8, 0.8, 0.9), 14, 8.0)
		"ICE":
			return profile_script.new("ICE", Color(0.7, 0.9, 1.0), 10, 4.0)
		_: # WOOD
			return profile_script.new("WOOD", Color(0.6, 0.4, 0.2), 8, 4.0)
