# scripts/world/ladder_system.gd
class_name LadderSystem
extends Area2D

## Climbable vertical ladder area enabling deterministic vertical ascension and shaft traversal.

@export var climb_speed: float = 140.0

var top_position: Vector2 = Vector2.ZERO
var bottom_position: Vector2 = Vector2.ZERO

var collision_shape: CollisionShape2D
var visual_container: Node2D

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player layer

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func setup_ladder(p_bottom: Vector2, p_top: Vector2, width_px: float = 24.0) -> void:
	bottom_position = p_bottom
	top_position = p_top
	
	var height = abs(p_bottom.y - p_top.y)
	var center = Vector2((p_bottom.x + p_top.x) * 0.5, (p_bottom.y + p_top.y) * 0.5)
	global_position = center

	if not has_node("CollisionShape2D"):
		collision_shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.size = Vector2(width_px, height)
		collision_shape.shape = rect
		add_child(collision_shape)

	_create_visuals(width_px, height)

func _create_visuals(w: float, h: float) -> void:
	var old_visual = get_node_or_null("LadderVisual")
	if old_visual: old_visual.queue_free()

	visual_container = Node2D.new()
	visual_container.name = "LadderVisual"
	add_child(visual_container)

	# Left/Right rails
	var rail_left = ColorRect.new()
	rail_left.color = Color(0.65, 0.50, 0.30, 0.9)
	rail_left.offset_left = -w * 0.5
	rail_left.offset_top = -h * 0.5
	rail_left.offset_right = -w * 0.5 + 4.0
	rail_left.offset_bottom = h * 0.5
	visual_container.add_child(rail_left)

	var rail_right = ColorRect.new()
	rail_right.color = Color(0.65, 0.50, 0.30, 0.9)
	rail_right.offset_left = w * 0.5 - 4.0
	rail_right.offset_top = -h * 0.5
	rail_right.offset_right = w * 0.5
	rail_right.offset_bottom = h * 0.5
	visual_container.add_child(rail_right)

	# Rungs spaced every 16px
	var rung_count = int(h / 16.0)
	for i in range(rung_count):
		var rung = ColorRect.new()
		rung.color = Color(0.75, 0.60, 0.38, 0.9)
		rung.offset_left = -w * 0.5 + 4.0
		rung.offset_top = (-h * 0.5) + (i * 16.0) + 6.0
		rung.offset_right = w * 0.5 - 4.0
		rung.offset_bottom = (-h * 0.5) + (i * 16.0) + 10.0
		visual_container.add_child(rung)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.set_meta("on_ladder", true)
		body.set_meta("ladder_ref", self)

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.set_meta("on_ladder", false)
		body.remove_meta("ladder_ref")
