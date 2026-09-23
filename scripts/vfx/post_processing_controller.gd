# scripts/vfx/post_processing_controller.gd
class_name PostProcessingController
extends Node

## WorldEnvironment & CanvasLayer Post-Processing Engine managing Bloom, Vignette, and Color Grading per biome.

signal post_processing_changed(profile_id: String, settings: Dictionary)

static var PROFILES: Dictionary = {
	"neutral": {
		"id": "neutral",
		"bloom_enabled": true,
		"bloom_intensity": 0.2,
		"vignette_intensity": 0.15,
		"chromatic_aberration": 0.0,
		"color_saturation": 1.0
	},
	"volcanic_warm": {
		"id": "volcanic_warm",
		"bloom_enabled": true,
		"bloom_intensity": 0.45,
		"vignette_intensity": 0.35,
		"chromatic_aberration": 0.05,
		"color_saturation": 1.25
	},
	"cryo_cold": {
		"id": "cryo_cold",
		"bloom_enabled": true,
		"bloom_intensity": 0.30,
		"vignette_intensity": 0.25,
		"chromatic_aberration": 0.02,
		"color_saturation": 1.10
	},
	"void_shadow": {
		"id": "void_shadow",
		"bloom_enabled": true,
		"bloom_intensity": 0.60,
		"vignette_intensity": 0.50,
		"chromatic_aberration": 0.12,
		"color_saturation": 0.85
	}
}

@export var active_profile_id: String = "neutral"

func apply_profile(profile_id: String) -> bool:
	if not PROFILES.has(profile_id):
		return false
	active_profile_id = profile_id
	var settings = PROFILES[profile_id]
	post_processing_changed.emit(profile_id, settings)
	return true

func get_active_settings() -> Dictionary:
	return PROFILES.get(active_profile_id, PROFILES["neutral"]).duplicate()
