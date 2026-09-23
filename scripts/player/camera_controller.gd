# scripts/player/camera_controller.gd
class_name CameraController
extends Camera2D

## Advanced Camera Controller with smooth target tracking, look-ahead, and multi-intensity screen shake.

@export var follow_speed: float = 8.0
@export var look_ahead_distance: float = 32.0

var target: Node2D = null
var shake_intensity: float = 0.0
var shake_decay: float = 12.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

enum ShakeLevel { SMALL, MEDIUM, STRONG, VERY_STRONG }

func _ready() -> void:
	rng.randomize()
	# Register with group or signal
	EventBus.damage_dealt.connect(_on_damage_dealt)

func set_target(p_target: Node2D) -> void:
	target = p_target

func trigger_shake(level: ShakeLevel) -> void:
	match level:
		ShakeLevel.SMALL:
			shake_intensity = maxf(shake_intensity, 3.0)
		ShakeLevel.MEDIUM:
			shake_intensity = maxf(shake_intensity, 7.0)
		ShakeLevel.STRONG:
			shake_intensity = maxf(shake_intensity, 12.0)
		ShakeLevel.VERY_STRONG:
			shake_intensity = maxf(shake_intensity, 20.0)

func _process(delta: float) -> void:
	if target and is_instance_valid(target):
		var target_pos = target.global_position
		if "facing_direction" in target:
			target_pos.x += target.get("facing_direction") * look_ahead_distance
		global_position = global_position.lerp(target_pos, follow_speed * delta)

	if shake_intensity > 0.0:
		offset = Vector2(
			rng.randf_range(-shake_intensity, shake_intensity),
			rng.randf_range(-shake_intensity, shake_intensity)
		)
		shake_intensity = maxf(0.0, shake_intensity - shake_decay * delta)
	else:
		offset = Vector2.ZERO

func _on_damage_dealt(_pos: Vector2, _damage: int, is_crit: bool, _type: String) -> void:
	if is_crit:
		trigger_shake(ShakeLevel.MEDIUM)
	else:
		trigger_shake(ShakeLevel.SMALL)
