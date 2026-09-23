# scripts/procedural/secret_clue_data.gd
class_name SecretClueData
extends Resource

## Data Resource managing multi-modal environmental clues (visual, particle, audio, geometry, lighting).

enum ClueType {
	CRACKED_WALL,
	LIGHT_RAY,
	PARTICLE_DUST,
	AUDIO_HUM,
	UNUSUAL_TILE,
	GEOMETRY_GAP,
	SUSPICIOUS_SHADOW
}

@export var clue_type: ClueType = ClueType.CRACKED_WALL
@export var visibility: float = 0.6 # 0.0 = Invisible, 1.0 = Highly Visible
@export var sound_hint: bool = true
@export var particle_hint: bool = true
@export var lighting_hint: bool = true
@export var clue_radius: float = 48.0 # Interaction / observation radius in pixels

func _init(
	p_type: ClueType = ClueType.CRACKED_WALL,
	p_vis: float = 0.6,
	p_sound: bool = true,
	p_particle: bool = true,
	p_light: bool = true
) -> void:
	clue_type = p_type
	visibility = p_vis
	sound_hint = p_sound
	particle_hint = p_particle
	lighting_hint = p_light

static func get_clue_description(t: ClueType) -> String:
	match t:
		ClueType.CRACKED_WALL: return "Cracked Wall Fragment"
		ClueType.LIGHT_RAY: return "Faint Ambient Light Beam"
		ClueType.PARTICLE_DUST: return "Floating Energy Particles"
		ClueType.AUDIO_HUM: return "Subtle Resonance Sound"
		ClueType.UNUSUAL_TILE: return "Discolored Rock Tile"
		ClueType.GEOMETRY_GAP: return "Unusual Wall Gap"
		ClueType.SUSPICIOUS_SHADOW: return "Deep Wall Shadow"
	return "Environmental Clue"
