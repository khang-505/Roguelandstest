# scripts/items/resource_node.gd
class_name ResourceNode
extends StaticBody2D

## Mineable Resource Ore Node with finite HP and physical material drops.

@export var resource_pool: Array = ["ember_ore", "cryo_crystal", "bio_sample", "star_shard"]
@export var max_hp: int = 3

var current_hp: int = 3
var is_broken: bool = false

@onready var visual: Sprite2D = $Visual if has_node("Visual") else null

func _ready() -> void:
	current_hp = max_hp
	add_to_group("enemies") # Registered so player attacks/projectiles hit it

func take_damage(_amount: int, _knockback: Vector2 = Vector2.ZERO) -> void:
	if is_broken:
		return

	current_hp -= 1
	_hit_feedback()
	_drop_item()

	if current_hp <= 0:
		is_broken = true
		_drop_item() # Bonus drop on break
		_play_sfx("hit")
		DamageNumber.create(global_position, 0, true, "MINED!", get_parent())
		queue_free()

func _hit_feedback() -> void:
	_play_sfx("hit")
	if visual:
		visual.modulate = Color(2.0, 2.0, 1.5, 1.0)
		var t = get_tree().create_timer(0.12)
		if t:
			await t.timeout
			if is_instance_valid(visual):
				visual.modulate = Color.WHITE

func _drop_item() -> void:
	var drop_id = resource_pool[randi() % resource_pool.size()]
	
	var item_scene = load("res://scenes/items/item_drop.tscn")
	if item_scene:
		var item_inst = item_scene.instantiate() as Node2D
		item_inst.set("item_id", drop_id)
		item_inst.set("item_type", "material")
		item_inst.set("amount", randi_range(1, 2))
		item_inst.set("rarity_id", "uncommon" if drop_id == "star_shard" else "common")
		item_inst.global_position = global_position + Vector2(randf_range(-12, 12), -8)
		if get_parent():
			get_parent().call_deferred("add_child", item_inst)
		
	DamageNumber.create(global_position, 0, false, "GATHERED", get_parent())

func _play_sfx(sfx_name: String) -> void:
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_sfx"):
		am.play_sfx(sfx_name)
