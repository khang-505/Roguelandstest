# scripts/procedural/room_connector.gd
class_name RoomConnector
extends Area2D

## Physical door connector linking adjacent rooms with combat wave seal locks.

enum Direction { NORTH, SOUTH, EAST, WEST, SECRET }

@export var direction: Direction = Direction.EAST
@export var target_room_id: int = -1
@export var is_locked: bool = false
@export var is_secret: bool = false

var visual_door: ColorRect = null

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player layer
	body_entered.connect(_on_body_entered)

	visual_door = ColorRect.new()
	visual_door.size = Vector2(16, 48)
	visual_door.position = Vector2(-8, -24)
	visual_door.color = Color(0.2, 0.8, 1.0, 0.8) if not is_secret else Color(0.8, 0.2, 0.8, 0.4)
	add_child(visual_door)

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(24, 48)
	shape.shape = rect
	add_child(shape)

func set_locked(p_locked: bool) -> void:
	is_locked = p_locked
	if visual_door:
		visual_door.color = Color(1.0, 0.2, 0.2, 0.9) if is_locked else (Color(0.2, 0.8, 1.0, 0.8) if not is_secret else Color(0.8, 0.2, 0.8, 0.4))

func _on_body_entered(body: Node2D) -> void:
	if is_locked:
		return
	if body.is_in_group("player"):
		EventBus.room_transition_requested.emit(target_room_id, direction)
