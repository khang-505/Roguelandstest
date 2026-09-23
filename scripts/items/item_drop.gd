# scripts/items/item_drop.gd
class_name ItemDrop
extends Area2D

## Physical dropped item entity with bouncing physics, magnetic pull, and pickup collection.

@export var item_id: String = "ember_ore"
@export var item_type: String = "material" # "material", "equipment", "credit", "consumable"
@export var amount: int = 1
@export var rarity_id: String = "common"

var velocity: Vector2 = Vector2.ZERO
var fall_gravity: float = 800.0
var bounce: float = 0.4
var floor_y: float = 0.0
var can_pickup: bool = false
var lifetime: float = 0.0
var magnet_radius: float = 64.0

@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null

func _ready() -> void:
	velocity = Vector2(randf_range(-120.0, 120.0), randf_range(-260.0, -120.0))
	
	# Raycast to find the ground
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(0, 800))
	query.collision_mask = 1 # Ground layer
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	
	if result:
		floor_y = result.position.y - 6.0
	else:
		floor_y = global_position.y + randf_range(10.0, 30.0)
	
	body_entered.connect(_on_body_entered)
	_update_visual_texture()

	# Read magnet bonus from profile
	var profile = SaveManager.profile_data
	var bonus_mag = profile.get("research_magnet_bonus", 0.0)
	magnet_radius += bonus_mag

func _update_visual_texture() -> void:
	if sprite == null:
		return

	var tex_path = ""
	match item_id:
		"credit": tex_path = "res://art/items/coin.png"
		"health_potion": tex_path = "res://art/items/health_potion.png"
		"ember_ore", "cryo_crystal", "bio_sample", "star_shard": tex_path = "res://art/resources/ember_crystal.png"
		_: tex_path = "res://art/items/coin.png"

	if ResourceLoader.exists(tex_path):
		sprite.texture = load(tex_path)

	match rarity_id:
		"common": sprite.modulate = Color.WHITE
		"uncommon": sprite.modulate = Color(0.4, 1.0, 0.4, 1.0)
		"rare": sprite.modulate = Color(0.3, 0.7, 1.0, 1.0)
		"epic": sprite.modulate = Color(0.8, 0.3, 1.0, 1.0)
		"legendary": sprite.modulate = Color(1.0, 0.8, 0.2, 1.0)

func _physics_process(delta: float) -> void:
	lifetime += delta
	if lifetime > 0.3:
		can_pickup = true
		
	# Check magnetic pull to player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p = players[0] as CharacterBody2D
		if is_instance_valid(p):
			var dist = global_position.distance_to(p.global_position)
			if dist <= magnet_radius and can_pickup:
				var dir = (p.global_position - global_position).normalized()
				var speed = 350.0 * (1.0 - dist / magnet_radius) + 100.0
				global_position += dir * speed * delta
				return # Magnet overrides bounce physics

	if global_position.y < floor_y:
		velocity.y += fall_gravity * delta
		global_position += velocity * delta
		if global_position.y >= floor_y:
			global_position.y = floor_y
			velocity.y = -velocity.y * bounce
			velocity.x *= 0.8
			if abs(velocity.y) < 40.0:
				velocity.y = 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, 200.0 * delta)
		global_position.x += velocity.x * delta

func _on_body_entered(body: Node2D) -> void:
	if not can_pickup: return
	if body.is_in_group("player"):
		if GameManager.add_to_backpack(item_id, item_type, amount):
			_play_sfx("pickup")
			var display_name = item_id.replace("_", " ").capitalize()
			EventBus.loot_collected.emit(item_id, display_name, amount)
			DamageNumber.create(global_position, 0, false, "NHẶT: +%d %s" % [amount, display_name], get_parent())
			queue_free()

func _play_sfx(sfx_name: String) -> void:
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_sfx"):
		am.play_sfx(sfx_name)
