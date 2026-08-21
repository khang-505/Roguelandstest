# scripts/combat/weapon_effect.gd
class_name WeaponEffect
extends Resource

## Reusable Weapon Special Effect resource triggered on hit or attack.

enum EffectTrigger { ON_HIT, ON_CRITICAL, ON_ATTACK, PASSIVE }

@export var effect_id: String = "burn_on_hit"
@export var trigger: EffectTrigger = EffectTrigger.ON_HIT
@export var proc_chance: float = 1.0 # 100% chance
@export var effect_param: float = 10.0 # Damage or duration

func execute_effect(attacker: Node2D, target: Node2D, hit_info: Dictionary) -> void:
	if randf() > proc_chance:
		return
		
	_apply_effect_logic(attacker, target, hit_info)

func _apply_effect_logic(_attacker: Node2D, _target: Node2D, _hit_info: Dictionary) -> void:
	# Overridden by specific effect implementations
	pass
