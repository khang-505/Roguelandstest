# scripts/world/power_node.gd
class_name PowerNode
extends Area2D

## World node representing regional power grid relays energizing connected terminals and lifts.

signal power_state_changed(node_id, is_online)

@export var node_id: String = "pnode_001"
@export var is_online: bool = true

var visual_rect: ColorRect = null

func _ready() -> void:
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 18.0
	col.shape = shape
	add_child(col)

	visual_rect = ColorRect.new()
	visual_rect.size = Vector2(24, 24)
	visual_rect.position = Vector2(-12, -12)
	visual_rect.color = Color(0.2, 0.9, 0.9)
	add_child(visual_rect)

func toggle_power() -> void:
	is_online = not is_online
	if visual_rect:
		visual_rect.color = Color(0.2, 0.9, 0.9) if is_online else Color(0.3, 0.3, 0.3)

	var state_class = load("res://scripts/procedural/interaction_state.gd")
	if state_class:
		state_class.set_state(node_id, "ACTIVATED" if is_online else "DISABLED")

	emit_signal("power_state_changed", node_id, is_online)
