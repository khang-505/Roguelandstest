# scripts/world/weather_controller.gd
class_name WeatherController
extends Node2D

## Weather & Atmospheric Effects System managing 4 weather presets, wind vectors, density, and screen tint overlays.

enum WeatherType { CLEAR, ASH_STORM, CRYO_BLIZZARD, PLASMA_RAIN }

signal weather_changed(new_weather: WeatherType, preset_data: Dictionary)

static var PRESETS: Dictionary = {
	WeatherType.CLEAR: {
		"id": "clear",
		"name": "Clear Skies",
		"wind": Vector2(10.0, 0.0),
		"density": 0,
		"tint": Color(1.0, 1.0, 1.0, 1.0),
		"hazard_interval": 0.0
	},
	WeatherType.ASH_STORM: {
		"id": "ash_storm",
		"name": "Ember Ash Storm",
		"wind": Vector2(-150.0, 30.0),
		"density": 100,
		"tint": Color(1.1, 0.9, 0.75, 1.0),
		"hazard_interval": 8.0 # Falling embers
	},
	WeatherType.CRYO_BLIZZARD: {
		"id": "cryo_blizzard",
		"name": "Subzero Blizzard",
		"wind": Vector2(-220.0, 60.0),
		"density": 150,
		"tint": Color(0.8, 0.95, 1.1, 1.0),
		"hazard_interval": 6.0 # Frost wind gusts
	},
	WeatherType.PLASMA_RAIN: {
		"id": "plasma_rain",
		"name": "Plasma Rain",
		"wind": Vector2(30.0, 300.0),
		"density": 120,
		"tint": Color(0.9, 0.85, 1.15, 1.0),
		"hazard_interval": 5.0 # Lightning strikes
	}
}

@export var current_weather: WeatherType = WeatherType.CLEAR

func set_weather(weather: WeatherType) -> void:
	current_weather = weather
	var data = PRESETS.get(weather, PRESETS[WeatherType.CLEAR])
	weather_changed.emit(weather, data)

func get_active_preset() -> Dictionary:
	return PRESETS.get(current_weather, PRESETS[WeatherType.CLEAR]).duplicate()
