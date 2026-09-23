# scripts/combat/damage_event_bus.gd
class_name DamageEventBus
extends Node

## Global Event Bus emitting damage lifecycle signals across UI, Audio, VFX, Quests, and Combat Analytics.

signal damage_started(request: Resource)
signal damage_resolved(request: Resource, final_damage: int, is_crit: bool)
signal critical_hit(target: Node, damage: int, position: Vector2)
signal target_damaged(target: Node, damage: int, damage_type: String)
signal target_killed(target: Node, killer: Node)
signal damage_blocked(target: Node, amount: float)
signal shield_broken(target: Node)
signal armor_broken(target: Node)

static var _instance: DamageEventBus = null
static var _history: Array = []

func _enter_tree() -> void:
	_instance = self

static func dispatch_damage_started(request: Resource) -> void:
	if _instance:
		_instance.emit_signal("damage_started", request)

static func dispatch_damage_resolved(request: Resource, final_damage: int, is_crit: bool) -> void:
	_history.append({"request": request, "damage": final_damage, "is_crit": is_crit})
	if _history.size() > 500:
		_history.remove_at(0)
		
	if _instance:
		_instance.emit_signal("damage_resolved", request, final_damage, is_crit)
		if request and is_instance_valid(request.target):
			_instance.emit_signal("target_damaged", request.target, final_damage, request.damage_type)
			if is_crit:
				var t_pos = request.target.global_position if request.target.has_method("get_global_position") else Vector2.ZERO
				_instance.emit_signal("critical_hit", request.target, final_damage, t_pos)

static func dispatch_target_killed(target: Node, killer: Node) -> void:
	if _instance:
		_instance.emit_signal("target_killed", target, killer)

static func dispatch_shield_broken(target: Node) -> void:
	if _instance:
		_instance.emit_signal("shield_broken", target)

static func dispatch_armor_broken(target: Node) -> void:
	if _instance:
		_instance.emit_signal("armor_broken", target)

static func get_recent_history() -> Array:
	return _history

static func clear_history() -> void:
	_history.clear()
