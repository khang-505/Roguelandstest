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
var rarity: RarityData = null
var item_id: String = "ember_ore"

const MATERIAL_COLORS = {
	"ember_ore": Color(1.0, 0.4, 0.1, 1.0),
	"cryo_crystal": Color(0.2, 0.8, 1.0, 1.0),
	"bio_sample": Color(0.2, 0.9, 0.3, 1.0),
	"star_shard": Color(0.8, 0.2, 1.0, 1.0),
	"credit": Color(1.0, 0.85, 0.2, 1.0)
}

func _ready() -> void:
	if item_data == null:
		item_data = ItemData.new()
		item_data.id = "ember_ore"
		item_data.display_name = "Ember Ore"
	body_entered.connect(_on_body_entered)

func configure_enemy_drop(enemy_type: String) -> void:
	rarity = RarityData.roll_rarity()
	amount = max(1, int(ceil(1.0 * rarity.quality_multiplier)))
	
	var drop_pool = ["credit", "ember_ore"]
	match enemy_type:
		"frost_stalker":
			drop_pool = ["cryo_crystal", "credit", "star_shard"]
		"void_lurker":
			drop_pool = ["bio_sample", "star_shard", "credit"]
		"iron_golem":
			drop_pool = ["ember_ore", "star_shard", "cryo_crystal"]
		"swarm_drone":
			drop_pool = ["credit", "ember_ore"]
		_:
			drop_pool = ["ember_ore", "credit", "bio_sample"]

	item_id = drop_pool[randi() % drop_pool.size()]
	item_data.id = item_id
	item_data.display_name = item_id.replace("_", " ").capitalize()

	var gem = get_node_or_null("Gem") as ColorRect
	if gem:
		if MATERIAL_COLORS.has(item_id):
			gem.color = MATERIAL_COLORS[item_id]
		elif rarity:
			gem.color = Color.html(rarity.color_hex)

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
		var id_str = item_data.id if item_data else item_id
		var name_str = item_data.display_name if item_data else "Material"
		if rarity:
			name_str = "%s %s" % [rarity.display_name, name_str]
		EventBus.loot_collected.emit(id_str, name_str, amount)
		if not ObjectPool.release(self):
			queue_free()
