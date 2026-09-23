# scripts/combat/hurtbox.gd
class_name Hurtbox
extends Area2D

## Reusable Hurtbox component that receives damage, knockback, and hit stop from matching Hitboxes.

signal hit_received(damage: int, is_crit: bool, damage_type: String, knockback_vector: Vector2)
signal hit_stop_applied(duration: float)

@export var team: Hitbox.Team = Hitbox.Team.ENEMY
@export var invulnerability_time: float = 0.2
@export var armor: float = 0.0
@export var element_type: String = "NONE"
@export var weight: float = 1.0

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
		
	var damage_info = hitbox.get_calculated_damage(armor, element_type, weight)
	var effective_damage = max(1, int(damage_info.get("damage", 1)))
	var hit_stop_dur = float(damage_info.get("hit_stop_duration", 0.04))
	
	is_invulnerable = true
	i_frame_timer = invulnerability_time
	
	var knockback_dir = (global_position - hitbox.global_position).normalized()
	if knockback_dir == Vector2.ZERO:
		knockback_dir = Vector2.RIGHT
	var knockback_force = float(damage_info.get("knockback_force", damage_info.get("knockback", 140.0)))
	var knockback_vector = knockback_dir * knockback_force
	
	emit_signal("hit_stop_applied", hit_stop_dur)
	hit_received.emit(effective_damage, damage_info["is_crit"], str(damage_info["damage_type"]), knockback_vector)
	EventBus.damage_dealt.emit(global_position, effective_damage, damage_info["is_crit"], str(damage_info["damage_type"]))
