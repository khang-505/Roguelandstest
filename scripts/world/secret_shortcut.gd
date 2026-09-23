# scripts/world/secret_shortcut.gd
class_name SecretShortcut
extends Area2D

## Interactive shortcut door/teleport connecting distant map or cave nodes once unlocked.

signal shortcut_activated(source_pos: Vector2, dest_pos: Vector2)

@export var shortcut_id: String = "shortcut_01"
@export var target_position: Vector2 = Vector2.ZERO
@export var is_unlocked: bool = false

var visual_rect: ColorRect = null
var label: Label = null

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player mask
	body_entered.connect(_on_body_entered)

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(32, 48)
	shape.shape = rect
	add_child(shape)

	visual_rect = ColorRect.new()
	visual_rect.size = Vector2(32, 48)
	visual_rect.position = Vector2(-16, -24)
	visual_rect.color = Color(0.2, 0.6, 0.9, 0.8) if is_unlocked else Color(0.3, 0.3, 0.35, 0.9)
	add_child(visual_rect)

	label = Label.new()
	label.text = "🌀" if is_unlocked else "🔒"
	label.position = Vector2(-8, -12)
	add_child(label)

func unlock_shortcut() -> void:
	is_unlocked = true
	var state_mgr = load("res://scripts/procedural/secret_state_manager.gd")
	if state_mgr: state_mgr.mark_opened(shortcut_id)
	if visual_rect: visual_rect.color = Color(0.2, 0.6, 0.9, 0.8)
	if label: label.text = "🌀"

func _on_body_entered(body: Node2D) -> void:
	if not is_unlocked:
		unlock_shortcut()

	if body != null and (body.is_in_group("player") or body.name == "PlayerController"):
		if target_position != Vector2.ZERO:
			body.global_position = target_position
			shortcut_activated.emit(global_position, target_position)
