# scripts/world/breakable_object.gd
class_name BreakableObject
extends StaticBody2D

## World node representing destructible objects, crates, rocks, crystals, and weak walls.

signal object_damaged(current_hp, max_hp)
signal object_destroyed(object_id)

@export var object_id: String = "break_001"
@export var max_health: float = 50.0
@export var current_health: float = 50.0
@export var armor: float = 0.0
@export var material_name: String = "WOOD"
@export var required_damage_type: String = "ANY"

var is_destroyed: bool = false
var visual_rect: ColorRect = null

func _ready() -> void:
	current_health = max_health

	# Create collision shape if not existing
	if get_child_count() == 0 or not (get_child(0) is CollisionShape2D):
		var col = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(24, 24)
		col.shape = shape
		add_child(col)

		visual_rect = ColorRect.new()
		visual_rect.size = Vector2(24, 24)
		visual_rect.position = Vector2(-12, -12)
		visual_rect.color = Color(0.6, 0.4, 0.2)
		add_child(visual_rect)

func take_damage(amount: float, damage_type: String = "PHYSICAL") -> void:
	if is_destroyed:
		return

	# Type weakness check
	if required_damage_type != "ANY" and required_damage_type != damage_type:
		amount *= 0.25 # Resistant if wrong damage type

	var net_dmg = max(1.0, amount - armor)
	current_health -= net_dmg
	emit_signal("object_damaged", current_health, max_health)

	# Update visual crack stage tint
	if visual_rect:
		var ratio = max(0.2, current_health / max_health)
		visual_rect.modulate = Color(ratio, ratio, ratio, 1.0)

	if current_health <= 0.0:
		destroy_object()

func destroy_object() -> void:
	if is_destroyed:
		return

	is_destroyed = true
	var state_class = load("res://scripts/procedural/breakable_object_state.gd")
	if state_class:
		state_class.mark_destroyed(object_id)

	# Emit destruction signal & drop loot if applicable
	emit_signal("object_destroyed", object_id)

	var bus = load("res://scripts/core/event_bus.gd")
	if bus and bus.has_signal("secret_discovered"):
		bus.emit_signal("secret_discovered", object_id, position)

	queue_free()
