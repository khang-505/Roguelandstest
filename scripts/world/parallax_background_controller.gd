# scripts/world/parallax_background_controller.gd
class_name ParallaxBackgroundController
extends Node2D

## Multi-layer 2D Parallax Background System supporting biome tinting and smooth camera scrolling.

enum ParallaxLayer { SKY, FAR_MOUNTAINS, MID_STRUCTURES, NEAR_RUINS }

static var LAYER_SCROLL_FACTORS: Dictionary = {
	ParallaxLayer.SKY: Vector2(0.0, 0.0),
	ParallaxLayer.FAR_MOUNTAINS: Vector2(0.15, 0.05),
	ParallaxLayer.MID_STRUCTURES: Vector2(0.45, 0.20),
	ParallaxLayer.NEAR_RUINS: Vector2(0.80, 0.50)
}

@export var current_biome: String = "volcanic"

static var BIOME_PALETTES: Dictionary = {
	"volcanic": {
		ParallaxLayer.SKY: Color(0.2, 0.05, 0.05),
		ParallaxLayer.FAR_MOUNTAINS: Color(0.4, 0.1, 0.1),
		ParallaxLayer.MID_STRUCTURES: Color(0.3, 0.15, 0.15),
		ParallaxLayer.NEAR_RUINS: Color(0.2, 0.1, 0.1)
	},
	"cryo": {
		ParallaxLayer.SKY: Color(0.05, 0.1, 0.25),
		ParallaxLayer.FAR_MOUNTAINS: Color(0.15, 0.25, 0.4),
		ParallaxLayer.MID_STRUCTURES: Color(0.2, 0.35, 0.5),
		ParallaxLayer.NEAR_RUINS: Color(0.1, 0.2, 0.3)
	},
	"bio_swamp": {
		ParallaxLayer.SKY: Color(0.05, 0.2, 0.1),
		ParallaxLayer.FAR_MOUNTAINS: Color(0.1, 0.3, 0.15),
		ParallaxLayer.MID_STRUCTURES: Color(0.15, 0.25, 0.15),
		ParallaxLayer.NEAR_RUINS: Color(0.1, 0.15, 0.1)
	}
}

func calculate_layer_offset(layer: ParallaxLayer, camera_position: Vector2) -> Vector2:
	var factor: Vector2 = LAYER_SCROLL_FACTORS.get(layer, Vector2.ZERO)
	return camera_position * factor

func get_layer_color(layer: ParallaxLayer, biome: String = "") -> Color:
	var b_key = biome if biome != "" else current_biome
	var palette = BIOME_PALETTES.get(b_key, BIOME_PALETTES["volcanic"])
	return palette.get(layer, Color.WHITE)
