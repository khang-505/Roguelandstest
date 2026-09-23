# scripts/world/elevator_system.gd
class_name ElevatorSystem
extends AnimatableBody2D

## Interactive and automated mechanical lift system for multi-layer vertical transitions.

signal elevator_arrived(target_layer: int)

@export var move_speed: float = 120.0
@export var is_automated: bool = true
@export var is_unlocked: bool = true

var start_position: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var move_direction: int = 1 # 1 = DOWN, -1 = UP

var collision_shape: CollisionShape2D
var visual_rect: ColorRect
var trigger_area: Area2D

func _ready() -> void:
	collision_layer = 1
	collision_mask = 6

	_setup_nodes()

func _setup_nodes() -> void:
	if not has_node("CollisionShape2D"):
		collision_shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.size = Vector2(80, 12)
		collision_shape.shape = rect
		add_child(collision_shape)

	if not has_node("VisualRect"):
		visual_rect = ColorRect.new()
		visual_rect.name = "VisualRect"
		visual_rect.color = Color(0.45, 0.55, 0.65, 0.95)
		visual_rect.offset_left = -40.0
		visual_rect.offset_top = -6.0
		visual_rect.offset_right = 40.0
		visual_rect.offset_bottom = 6.0
		add_child(visual_rect)

	if not has_node("TriggerArea"):
		trigger_area = Area2D.new()
		trigger_area.name = "TriggerArea"
		trigger_area.collision_layer = 0
		trigger_area.collision_mask = 2 # Player layer

		var t_shape = CollisionShape2D.new()
		var t_rect = RectangleShape2D.new()
		t_rect.size = Vector2(76, 24)
		t_shape.shape = t_rect
		t_shape.position = Vector2(0, -14)
		trigger_area.add_child(t_shape)

		trigger_area.body_entered.connect(_on_player_entered)
		add_child(trigger_area)

func setup_elevator(p_start: Vector2, p_end: Vector2, auto: bool = true) -> void:
	start_position = p_start
	target_position = p_end
	global_position = p_start
	is_automated = auto
	is_moving = false

func _physics_process(delta: float) -> void:
	if not is_moving:
		return

	var dest = target_position if move_direction > 0 else start_position
	var next_pos = global_position.move_toward(dest, move_speed * delta)
	global_position = next_pos

	if global_position.distance_squared_to(dest) < 1.0:
		global_position = dest
		is_moving = false
		move_direction *= -1 # Reverse direction for next trip
		elevator_arrived.emit(1 if move_direction > 0 else 0)

		if is_automated:
			await get_tree().create_timer(1.5).timeout
			if is_instance_valid(self):
				is_moving = true

func _on_player_entered(_body: Node2D) -> void:
	if is_unlocked and not is_moving:
		is_moving = true
