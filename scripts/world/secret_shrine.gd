# scripts/world/secret_shrine.gd
class_name SecretShrine
extends Area2D

## Interactive risk/reward shrine granting stat buffs or rare items in exchange for HP.

signal shrine_activated(shrine_id: String, reward_type: String)

@export var shrine_id: String = "shrine_01"
@export var is_used: bool = false
@export var hp_cost: int = 15

var visual_rect: ColorRect = null
var altar_label: Label = null

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player mask
	body_entered.connect(_on_body_entered)

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(40, 40)
	shape.shape = rect
	add_child(shape)

	visual_rect = ColorRect.new()
	visual_rect.size = Vector2(40, 40)
	visual_rect.position = Vector2(-20, -20)
	visual_rect.color = Color(0.8, 0.2, 0.4, 0.9) if not is_used else Color(0.4, 0.4, 0.4, 0.5)
	add_child(visual_rect)

	altar_label = Label.new()
	altar_label.text = "⛩"
	altar_label.position = Vector2(-8, -14)
	add_child(altar_label)

func _on_body_entered(body: Node2D) -> void:
	if is_used: return
	if body != null and (body.is_in_group("player") or body.name == "PlayerController"):
		activate_shrine(body)

func activate_shrine(player_node: Node2D) -> void:
	is_used = true
	var state_mgr = load("res://scripts/procedural/secret_state_manager.gd")
	if state_mgr: state_mgr.mark_completed(shrine_id)

	if player_node.has_method("take_damage"):
		player_node.call("take_damage", hp_cost)

	if visual_rect: visual_rect.color = Color(0.4, 0.4, 0.4, 0.5)
	shrine_activated.emit(shrine_id, "stat_buff")
