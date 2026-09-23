# scripts/world/explosive_barrel.gd
class_name ExplosiveBarrel
extends StaticBody2D

## Destructible explosive barrel dealing area damage, knockback, and bounded chain reactions.

signal barrel_exploded(barrel_id, pos, radius, damage)

@export var object_id: String = "barrel_001"
@export var blast_radius: float = 80.0
@export var blast_damage: float = 120.0
@export var max_health: float = 20.0
@export var current_health: float = 20.0

var is_exploded: bool = false
static var active_chain_depth: int = 0
const MAX_CHAIN_DEPTH: int = 5

func _ready() -> void:
	current_health = max_health

	if get_child_count() == 0 or not (get_child(0) is CollisionShape2D):
		var col = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(20, 28)
		col.shape = shape
		add_child(col)

		var rect = ColorRect.new()
		rect.size = Vector2(20, 28)
		rect.position = Vector2(-10, -14)
		rect.color = Color(0.9, 0.2, 0.1) # Bright red explosive barrel
		add_child(rect)

func take_damage(amount: float, _dmg_type: String = "PHYSICAL") -> void:
	if is_exploded:
		return

	current_health -= amount
	if current_health <= 0.0:
		explode()

func explode() -> void:
	if is_exploded or active_chain_depth >= MAX_CHAIN_DEPTH:
		return

	is_exploded = true
	active_chain_depth += 1

	var state_class = load("res://scripts/procedural/breakable_object_state.gd")
	if state_class:
		state_class.mark_destroyed(object_id)

	emit_signal("barrel_exploded", object_id, global_position, blast_radius, blast_damage)

	# Trigger blast Area2D query if parent exists
	if get_parent():
		var space = get_world_2d().direct_space_state
		if space:
			var query = PhysicsShapeQueryParameters2D.new()
			var sphere = CircleShape2D.new()
			sphere.radius = blast_radius
			query.shape = sphere
			query.transform = Transform2D(0.0, global_position)
			query.collide_with_bodies = true

			var hits = space.intersect_shape(query, 16)
			for hit in hits:
				var collider = hit.get("collider")
				if collider != null and collider != self and collider.has_method("take_damage"):
					collider.take_damage(blast_damage, "EXPLOSIVE")

	active_chain_depth = max(0, active_chain_depth - 1)
	queue_free()
