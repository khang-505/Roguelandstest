# scripts/world/fake_wall.gd
class_name FakeWall
extends Area2D

## Illusionary wall fading out transparency when touched, revealing hidden paths.

signal wall_passed(pos: Vector2)

@export var secret_id: String = "fake_wall_01"
var is_revealed: bool = false
var visual_rect: ColorRect = null
var crack_label: Label = null

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player mask
	body_entered.connect(_on_body_entered)

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(24, 64)
	shape.shape = rect
	add_child(shape)

	visual_rect = ColorRect.new()
	visual_rect.size = Vector2(24, 64)
	visual_rect.position = Vector2(-12, -32)
	visual_rect.color = Color(0.35, 0.3, 0.28, 0.95)
	add_child(visual_rect)

	crack_label = Label.new()
	crack_label.text = "░"
	crack_label.position = Vector2(-4, -12)
	crack_label.modulate = Color(0.6, 0.5, 0.4, 0.6)
	add_child(crack_label)

func _on_body_entered(body: Node2D) -> void:
	if is_revealed: return
	if body != null and (body.is_in_group("player") or body.name == "PlayerController"):
		reveal()

func reveal() -> void:
	is_revealed = true
	var state_mgr = load("res://scripts/procedural/secret_state_manager.gd")
	if state_mgr: state_mgr.mark_opened(secret_id)

	var tween = create_tween()
	if tween and visual_rect:
		tween.tween_property(visual_rect, "color:a", 0.0, 0.4)

	wall_passed.emit(global_position)
