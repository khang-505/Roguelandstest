# scripts/procedural/traversal_profile.gd
class_name TraversalProfile
extends Resource

## Centralized configuration resource measuring actual player movement physics and jump/dash limits.

@export var max_jump_horizontal: float = 160.0 # Maximum horizontal jump distance (px)
@export var max_jump_vertical: float = 140.0 # Maximum vertical jump height (px)
@export var max_dash_distance: float = 120.0 # Dash distance (px)
@export var max_safe_drop: float = 350.0 # Safe vertical fall height (px)
@export var min_platform_width: float = 32.0 # Minimum platform landing width (px)
@export var max_slope_angle: float = 45.0 # Max slope angle (degrees)

func init_default_profile() -> void:
	max_jump_horizontal = 160.0
	max_jump_vertical = 140.0
	max_dash_distance = 120.0
	max_safe_drop = 350.0
	min_platform_width = 32.0
	max_slope_angle = 45.0
