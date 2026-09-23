# scripts/world/interactive_terminal.gd
class_name InteractiveTerminal
extends Area2D

## World node representing sci-fi console terminals revealing fog-of-war maps or disarming hazards.

signal terminal_activated(terminal_id)

@export var terminal_id: String = "term_001"
@export var is_activated: bool = false
@export var reveals_map: bool = true

var visual_rect: ColorRect = null

func _ready() -> void:
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(24, 24)
	col.shape = shape
	add_child(col)

	visual_rect = ColorRect.new()
	visual_rect.size = Vector2(24, 24)
	visual_rect.position = Vector2(-12, -12)
	visual_rect.color = Color(0.1, 0.7, 0.9)
	add_child(visual_rect)

func activate_terminal() -> void:
	if is_activated:
		return

	is_activated = true
	if visual_rect:
		visual_rect.color = Color(0.3, 1.0, 0.6)

	var state_class = load("res://scripts/procedural/interaction_state.gd")
	if state_class:
		state_class.set_state(terminal_id, "COMPLETED")

	emit_signal("terminal_activated", terminal_id)
