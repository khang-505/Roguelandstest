# scripts/combat/projectile.gd
class_name Projectile
extends Area2D

## Projectile entity for Ranged and Energy category weapons.

@export var speed: float = 400.0
@export var damage: int = 15
@export var is_crit: bool = false
@export var damage_type: WeaponData.DamageType = WeaponData.DamageType.ENERGY
@export var knockback_force: float = 80.0
@export var max_range: float = 400.0
@export var team: Hitbox.Team = Hitbox.Team.PLAYER

var direction: Vector2 = Vector2.RIGHT
var distance_traveled: float = 0.0

@onready var hitbox: Hitbox = $Hitbox if has_node("Hitbox") else null

func _ready() -> void:
	if hitbox:
		hitbox.team = team
		hitbox.damage = damage
		hitbox.knockback_force = knockback_force
		hitbox.damage_type = damage_type
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	var move_vec = direction * speed * delta
	global_position += move_vec
	distance_traveled += move_vec.length()
	
	if distance_traveled >= max_range:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		var hurtbox = area as Hurtbox
		if hurtbox.team != team:
			queue_free()

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		queue_free()
