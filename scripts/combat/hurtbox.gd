# scripts/combat/hurtbox.gd
class_name Hurtbox
extends Area2D

## Reusable Hurtbox component that receives damage from matching Hitboxes.

signal hit_received(damage: int, is_crit: bool, damage_type: String, knockback_vector: Vector2)

@export var team: Hitbox.Team = Hitbox.Team.ENEMY
@export var invulnerability_time: float = 0.2
@export var armor: int = 0

var is_invulnerable: bool = false
var i_frame_timer: float = 0.0

func _ready() -> void:
	collision_layer = 32 if team == Hitbox.Team.ENEMY else 16
	collision_mask = 16 if team == Hitbox.Team.ENEMY else 32
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	if is_invulnerable:
		i_frame_timer -= delta
		if i_frame_timer <= 0.0:
			is_invulnerable = false

func _on_area_entered(area: Area2D) -> void:
	if is_invulnerable or not (area is Hitbox):
		return
		
	var hitbox = area as Hitbox
	if hitbox.team == team or not hitbox.is_active:
		return
		
	var damage_info = hitbox.get_calculated_damage()
	var raw_damage = damage_info["damage"]
	var effective_damage = max(1, raw_damage - armor)
	
	is_invulnerable = true
	i_frame_timer = invulnerability_time
	
	var knockback_dir = (global_position - hitbox.global_position).normalized()
	var knockback_vector = knockback_dir * damage_info["knockback"]
	
	hit_received.emit(effective_damage, damage_info["is_crit"], str(damage_info["damage_type"]), knockback_vector)
	EventBus.damage_dealt.emit(global_position, effective_damage, damage_info["is_crit"], str(damage_info["damage_type"]))
