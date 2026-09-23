# scripts/audio/positional_sfx_engine.gd
class_name PositionalSFXEngine
extends Node2D

## Spatial audio emitter for 2D combat effects managing distance attenuation, pitch randomization, and surface footsteps.

signal sfx_played_at_position(sfx_name: String, position: Vector2, calculated_volume_db: float, pitch: float)

enum SurfaceType { STONE, METAL, DIRT, SNOW, MAGMA }

@export var max_audible_distance: float = 600.0
@export var default_pitch_variance: float = 0.08 # +/- 8% random pitch

static var SURFACE_FOOTSTEP_MAP: Dictionary = {
	SurfaceType.STONE: "footstep_stone",
	SurfaceType.METAL: "footstep_metal",
	SurfaceType.DIRT: "footstep_dirt",
	SurfaceType.SNOW: "footstep_snow",
	SurfaceType.MAGMA: "footstep_magma"
}

func calculate_spatial_audio(listener_pos: Vector2, emitter_pos: Vector2, base_volume_db: float = 0.0, pitch_variance: float = -1.0) -> Dictionary:
	var distance = listener_pos.distance_to(emitter_pos)
	if distance > max_audible_distance:
		return {"is_audible": false, "volume_db": -80.0, "pitch": 1.0}

	# Linear distance attenuation mapping: 0 dist = 0db, max_dist = -30db
	var atten_ratio = clampf(distance / max_audible_distance, 0.0, 1.0)
	var atten_db = -30.0 * atten_ratio
	var final_vol_db = base_volume_db + atten_db

	var var_val = pitch_variance if pitch_variance >= 0.0 else default_pitch_variance
	var randomized_pitch = randf_range(1.0 - var_val, 1.0 + var_val)

	return {
		"is_audible": true,
		"distance": distance,
		"volume_db": final_vol_db,
		"pitch": randomized_pitch
	}

func play_spatial_sfx(sfx_name: String, listener_pos: Vector2, emitter_pos: Vector2, base_volume_db: float = 0.0) -> Dictionary:
	var audio_data = calculate_spatial_audio(listener_pos, emitter_pos, base_volume_db)
	if audio_data["is_audible"]:
		sfx_played_at_position.emit(sfx_name, emitter_pos, audio_data["volume_db"], audio_data["pitch"])

	return audio_data

func get_footstep_sfx_name(surface: SurfaceType) -> String:
	return SURFACE_FOOTSTEP_MAP.get(surface, "footstep_stone")
