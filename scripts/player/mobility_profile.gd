# scripts/player/mobility_profile.gd
class_name MobilityProfile
extends Resource

## Source of Truth for Player Traversal Capabilities & Procedural Platform Generation.
## Defines movement speed, jump metrics, dash distance/charges, air mobility, and traversal limits.

@export var move_speed: float = 220.0 # Standard movement speed in px/s
@export var jump_height: float = 96.0 # Max vertical jump height in px
@export var jump_distance: float = 160.0 # Base horizontal gap distance bridged by jump in px
@export var dash_distance: float = 140.0 # Total horizontal distance spanned per dash in px
@export var dash_speed: float = 700.0 # Dash execution velocity in px/s
@export var dash_duration: float = 0.2 # Active dash state duration in seconds
@export var dash_count: int = 2 # Maximum available dash charges (1, 2, or 3)
@export var dash_cooldown: float = 0.5 # Charge recovery duration in seconds per charge
@export var iframe_duration: float = 0.25 # Invulnerability window duration at dash start in seconds

@export var air_dash: bool = true # Whether air dash is enabled
@export var double_jump: bool = true # Whether double jump is enabled
@export var wall_jump: bool = true # Whether wall jump is enabled
@export var grapple: bool = false # Whether grapple hook is enabled

@export var dash_damage: float = 35.0 # Base damage dealt during a Dash Attack / Strike
@export var breaks_weak_barriers: bool = true # Whether dash can break weak objects/barriers

func _init(
	p_move_speed: float = 220.0,
	p_jump_height: float = 96.0,
	p_jump_distance: float = 160.0,
	p_dash_distance: float = 140.0,
	p_dash_count: int = 2,
	p_air_dash: bool = true
) -> void:
	move_speed = p_move_speed
	jump_height = p_jump_height
	jump_distance = p_jump_distance
	dash_distance = p_dash_distance
	dash_count = p_dash_count
	air_dash = p_air_dash

## Calculates maximum horizontal gap reach including jump and all available dash charges.
func get_max_horizontal_reach() -> float:
	var total_dash = dash_distance * float(dash_count)
	return jump_distance + total_dash

## Calculates maximum vertical platform height reach including double jump and air dash.
func get_max_vertical_reach() -> float:
	var vert = jump_height * (2.0 if double_jump else 1.0)
	if air_dash:
		vert += (dash_distance * 0.5) # Upward/angled air dash reach contribution
	return vert

## Evaluates whether a procedural horizontal gap of given width can be traversed.
func can_traverse_gap(gap_width: float) -> bool:
	return gap_width <= get_max_horizontal_reach()

## Evaluates whether a procedural vertical height difference can be traversed.
func can_traverse_height(height_diff: float) -> bool:
	return height_diff <= get_max_vertical_reach()

## Exports profile settings as dictionary for procedural level generation queries.
func to_dictionary() -> Dictionary:
	return {
		"move_speed": move_speed,
		"jump_height": jump_height,
		"jump_distance": jump_distance,
		"dash_distance": dash_distance,
		"dash_speed": dash_speed,
		"dash_duration": dash_duration,
		"dash_count": dash_count,
		"dash_cooldown": dash_cooldown,
		"iframe_duration": iframe_duration,
		"air_dash": air_dash,
		"double_jump": double_jump,
		"wall_jump": wall_jump,
		"grapple": grapple,
		"max_horizontal_reach": get_max_horizontal_reach(),
		"max_vertical_reach": get_max_vertical_reach()
	}
