# scripts/world/interactive_door.gd
class_name InteractiveDoor
extends StaticBody2D

## World node representing interactive security doors, keyed gates, and switch-operated barriers.

signal door_opened(door_id)
signal door_closed(door_id)

@export var door_id: String = "door_001"
@export var is_open: bool = false
@export var is_locked: bool = false
@export var required_key: String = ""

var visual_rect: ColorRect = null
var col_shape: CollisionShape2D = null

func _ready() -> void:
	col_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(16, 48)
	col_shape.shape = shape
	add_child(col_shape)

	visual_rect = ColorRect.new()
	visual_rect.size = Vector2(16, 48)
	visual_rect.position = Vector2(-8, -24)
	visual_rect.color = Color(0.2, 0.4, 0.8) # Blue security door
	add_child(visual_rect)

	update_door_state()

func interact(player_inventory: Array = []) -> bool:
	if is_locked:
		if required_key != "" and required_key in player_inventory:
			is_locked = false
		else:
			return false

	if is_open:
		close_door()
	else:
		open_door()
	return true

func open_door() -> void:
	is_open = true
	if col_shape:
		col_shape.disabled = true
	if visual_rect:
		visual_rect.color = Color(0.2, 0.8, 0.4, 0.3) # Faded open state
	emit_signal("door_opened", door_id)

	var state_class = load("res://scripts/procedural/interaction_state.gd")
	if state_class:
		state_class.set_state(door_id, "ACTIVATED")

func close_door() -> void:
	is_open = false
	if col_shape:
		col_shape.disabled = false
	if visual_rect:
		visual_rect.color = Color(0.2, 0.4, 0.8, 1.0)
	emit_signal("door_closed", door_id)

	var state_class = load("res://scripts/procedural/interaction_state.gd")
	if state_class:
		state_class.set_state(door_id, "AVAILABLE")

func update_door_state() -> void:
	if is_open:
		open_door()
	else:
		close_door()
