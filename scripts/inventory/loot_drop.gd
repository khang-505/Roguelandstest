# scripts/inventory/loot_drop.gd
class_name LootDrop
extends Area2D

## Collectible resource entity featuring magnetic attraction to the player.

@export var item_data: ItemData
@export var amount: int = 1
@export var magnet_radius: float = 48.0
@export var pickup_radius: float = 12.0

var velocity: Vector2 = Vector2.ZERO
var is_being_pulled: bool = false
var target_player: CharacterBody2D = null

@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null

func _ready() -> void:
	if item_data == null:
		item_data = ItemData.new()
		item_data.id = "ember_ore"
		item_data.display_name = "Ember Ore"
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if target_player == null:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target_player = players[0] as CharacterBody2D

	if target_player and is_instance_valid(target_player):
		var dist = global_position.distance_to(target_player.global_position)
		if dist <= magnet_radius:
			is_being_pulled = true
			var dir = (target_player.global_position - global_position).normalized()
			velocity = velocity.move_toward(dir * 240.0, 800.0 * delta)
			global_position += velocity * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var id_str = item_data.id if item_data else "ember_ore"
		var name_str = item_data.display_name if item_data else "Ember Ore"
		EventBus.loot_collected.emit(id_str, name_str, amount)
		queue_free()
