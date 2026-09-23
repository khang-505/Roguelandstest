# scripts/world/interactive_lever.gd
class_name InteractiveLever
extends Area2D

## World node representing mechanical toggle levers that activate linked doors, lifts, or power grids.

signal lever_pulled(lever_id, is_active)

@export var lever_id: String = "lever_001"
@export var is_active: bool = false
@export var linked_target_ids: Array[String] = []

var visual_rect: ColorRect = null

func _ready() -> void:
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 24.0
	col.shape = shape
	add_child(col)

	visual_rect = ColorRect.new()
	visual_rect.size = Vector2(12, 20)
	visual_rect.position = Vector2(-6, -10)
	visual_rect.color = Color(0.8, 0.7, 0.2)
	add_child(visual_rect)

func pull_lever() -> void:
	is_active = not is_active

	if visual_rect:
		visual_rect.color = Color(0.2, 0.9, 0.3) if is_active else Color(0.8, 0.7, 0.2)

	var state_class = load("res://scripts/procedural/interaction_state.gd")
	if state_class:
		state_class.set_state(lever_id, "ACTIVATED" if is_active else "AVAILABLE")

	emit_signal("lever_pulled", lever_id, is_active)

	# Trigger linked nodes in parent scene
	if get_parent():
		for child in get_parent().get_children():
			if child.get("door_id") in linked_target_ids or child.get("object_id") in linked_target_ids:
				if child.has_method("open_door") and is_active:
					child.open_door()
				elif child.has_method("close_door") and not is_active:
					child.close_door()
