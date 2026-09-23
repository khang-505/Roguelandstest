# scripts/world/dynamic_lighting_controller.gd
class_name DynamicLightingController
extends Node2D

## 2D PointLight2D / DirectionalLight2D manager supporting planetary ambient light profiles and localized light sources.

signal ambient_light_changed(profile_name: String, color: Color, energy: float)

static var AMBIENT_PROFILES: Dictionary = {
	"volcanic_red": {
		"color": Color(0.9, 0.4, 0.2, 1.0),
		"energy": 0.6,
		"shadow_color": Color(0.1, 0.0, 0.0, 0.8)
	},
	"cryo_blue": {
		"color": Color(0.3, 0.6, 0.95, 1.0),
		"energy": 0.5,
		"shadow_color": Color(0.0, 0.05, 0.15, 0.8)
	},
	"bio_green": {
		"color": Color(0.4, 0.85, 0.35, 1.0),
		"energy": 0.55,
		"shadow_color": Color(0.0, 0.1, 0.02, 0.8)
	},
	"void_purple": {
		"color": Color(0.7, 0.3, 0.9, 1.0),
		"energy": 0.4,
		"shadow_color": Color(0.1, 0.0, 0.15, 0.85)
	}
}

@export var active_profile: String = "volcanic_red"
var registered_lights: Array[Dictionary] = []

func set_ambient_profile(profile_name: String) -> bool:
	if not AMBIENT_PROFILES.has(profile_name):
		return false
	active_profile = profile_name
	var p = AMBIENT_PROFILES[profile_name]
	ambient_light_changed.emit(profile_name, p["color"], p["energy"])
	return true

func register_light_source(light_id: String, pos: Vector2, color: Color = Color.WHITE, energy: float = 1.0) -> Dictionary:
	var l_info = {
		"light_id": light_id,
		"position": pos,
		"color": color,
		"energy": energy,
		"is_active": true
	}
	registered_lights.append(l_info)
	return l_info

func get_active_profile_data() -> Dictionary:
	return AMBIENT_PROFILES.get(active_profile, AMBIENT_PROFILES["volcanic_red"]).duplicate()
