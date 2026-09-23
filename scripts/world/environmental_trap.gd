# scripts/world/environmental_trap.gd
class_name EnvironmentalTrap
extends Area2D

## World node representing telegraphed environmental traps (spikes, lasers, flames).

signal trap_triggered(trap_id)

@export var trap_id: String = "trap_001"
@export var trap_type: String = "SPIKES" # SPIKES, LASER, FLAME, FALLING_ROCKS
@export var damage: float = 25.0
@export var is_disarmed: bool = false
@export var telegraph_time: float = 0.5

var visual_rect: ColorRect = null

func _ready() -> void:
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(32, 16)
	col.shape = shape
	add_child(col)

	visual_rect = ColorRect.new()
	visual_rect.size = Vector2(32, 16)
	visual_rect.position = Vector2(-16, -8)
	visual_rect.color = Color(0.8, 0.2, 0.2) # Hazard red
	add_child(visual_rect)

func disarm_trap() -> void:
	is_disarmed = true
	if visual_rect:
		visual_rect.color = Color(0.4, 0.4, 0.4)

	var state_class = load("res://scripts/procedural/interaction_state.gd")
	if state_class:
		state_class.set_state(trap_id, "DISABLED")

func trigger_trap(target: Node2D) -> void:
	if is_disarmed:
		return

	emit_signal("trap_triggered", trap_id)
	if target and target.has_method("take_damage"):
		target.take_damage(damage, "HAZARD")
