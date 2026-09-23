# scripts/vfx/camera_shake_controller.gd
class_name CameraShakeController
extends Node

## Trauma-based 2D Screen Shake & Impact Hit Freeze Frame Controller.

signal shake_applied(trauma_level: float, offset: Vector2)
signal freeze_frame_started(duration: float, time_scale: float)

@export var trauma_decay: float = 0.8 # Decay speed per second
@export var max_offset: Vector2 = Vector2(16.0, 12.0)
@export var max_roll: float = 0.1

var trauma: float = 0.0

func add_trauma(amount: float) -> void:
	trauma = clampf(trauma + amount, 0.0, 1.0)
	var current_offset = get_shake_offset()
	shake_applied.emit(trauma, current_offset)

func get_shake_offset(rng_override: float = -1.0) -> Vector2:
	if trauma <= 0.0:
		return Vector2.ZERO
	var amount = trauma * trauma # Exponential shake curve
	var roll_x = (rng_override if rng_override >= 0.0 else randf_range(-1.0, 1.0)) * max_offset.x * amount
	var roll_y = (rng_override if rng_override >= 0.0 else randf_range(-1.0, 1.0)) * max_offset.y * amount
	return Vector2(roll_x, roll_y)

func process_decay(delta: float) -> void:
	if trauma > 0.0:
		trauma = clampf(trauma - trauma_decay * delta, 0.0, 1.0)

func trigger_hit_freeze(duration: float = 0.05, time_scale: float = 0.1) -> void:
	Engine.time_scale = time_scale
	freeze_frame_started.emit(duration, time_scale)
	# In full game, a SceneTreeTimer resets Engine.time_scale to 1.0 after duration
