# scripts/world/breakable_wall.gd
class_name BreakableWall
extends StaticBody2D

## Breakable secret wall registering weapon hits and crumbling to reveal hidden paths.

signal wall_destroyed(pos: Vector2)

@export var secret_id: String = "breakable_wall_01"
@export var max_health: int = 3
var current_health: int = 3
var is_broken: bool = false

var visual_rect: ColorRect = null
var crack_label: Label = null

func _ready() -> void:
	collision_layer = 1
	collision_mask = 6

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(16, 48)
	shape.shape = rect
	add_child(shape)

	visual_rect = ColorRect.new()
	visual_rect.size = Vector2(16, 48)
	visual_rect.position = Vector2(-8, -24)
	visual_rect.color = Color(0.4, 0.35, 0.3, 0.95)
	add_child(visual_rect)

	crack_label = Label.new()
	crack_label.text = "░"
	crack_label.position = Vector2(-4, -12)
	crack_label.modulate = Color(0.9, 0.7, 0.3, 0.8)
	add_child(crack_label)

func take_damage(amount: int = 1) -> void:
	if is_broken: return
	current_health -= amount
	if crack_label: crack_label.text = "▓" if current_health == 2 else "█"
	if visual_rect: visual_rect.color = Color(0.6, 0.4, 0.3, 0.9)

	var tree = get_tree()
	if tree and tree.root and tree.root.has_node("AudioManager"):
		var am = tree.root.get_node("AudioManager")
		if am and am.has_method("play_sfx"): am.play_sfx("hit")

	if current_health <= 0:
		_crumble()

func _crumble() -> void:
	is_broken = true
	var state_mgr = load("res://scripts/procedural/secret_state_manager.gd")
	if state_mgr: state_mgr.mark_opened(secret_id)

	wall_destroyed.emit(global_position)

	# Spawn secret reward drop
	var item_scene = load("res://scenes/items/item_drop.tscn")
	if item_scene:
		var item_inst = item_scene.instantiate() as Node2D
		item_inst.set("item_id", "star_shard")
		item_inst.set("item_type", "material")
		item_inst.set("amount", 2)
		item_inst.set("rarity_id", "legendary")
		item_inst.global_position = global_position
		
		var parent = get_parent()
		if parent:
			parent.call_deferred("add_child", item_inst)

	queue_free()
