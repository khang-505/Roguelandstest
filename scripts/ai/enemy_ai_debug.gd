# scripts/ai/enemy_ai_debug.gd
class_name EnemyAIDebug
extends Node2D

## Visual Debug Overlay rendering perception circles, target vectors, active state label, and last known position.

@export var controller_path: NodePath
var controller: EnemyAIController = null

func _ready() -> void:
	if not controller_path.is_empty():
		controller = get_node_or_null(controller_path) as EnemyAIController

func _draw() -> void:
	if not controller:
		return

	# Draw Detection Radius Circle (Yellow)
	draw_arc(Vector2.ZERO, controller.detection_radius, 0, TAU, 32, Color(1, 1, 0, 0.4), 1.5)

	# Draw Attack Radius Circle (Red)
	draw_arc(Vector2.ZERO, controller.attack_radius, 0, TAU, 32, Color(1, 0.2, 0.2, 0.6), 1.5)

	# Draw Line to Last Known Position (Cyan)
	if controller.last_known_position != Vector2.ZERO:
		var rel_pos = controller.last_known_position - controller.global_position
		draw_line(Vector2.ZERO, rel_pos, Color(0, 1, 1, 0.8), 2.0)
		draw_circle(rel_pos, 4.0, Color(0, 1, 1, 1.0))
