# scripts/combat/status_effect_manager.gd
class_name StatusEffectManager
extends Node

## Central Manager handling elemental status application, ticking, stacking, and node cleanup.

enum StatusType { BURN, FREEZE, SHOCK, DECAY, POISON }

class ActiveStatus:
	var type: StatusType
	var duration: float
	var tick_timer: float
	var tick_interval: float
	var damage_per_tick: int
	var stacks: int
	var max_stacks: int
	var param: float # e.g. slow ratio or armor reduction ratio

	func _init(p_type: StatusType, p_dur: float, p_dmg: int = 5, p_max_s: int = 1) -> void:
		type = p_type
		duration = p_dur
		tick_interval = 0.5
		tick_timer = 0.5
		damage_per_tick = p_dmg
		stacks = 1
		max_stacks = p_max_s
		param = 0.0

# Key: target Node2D instance_id -> Dictionary[StatusType, ActiveStatus]
static var active_statuses: Dictionary = {}

static func apply_status(target: Node2D, type: StatusType, duration: float, damage: int = 5, param: float = 0.0) -> void:
	if target == null or not is_instance_valid(target):
		return

	var target_id = target.get_instance_id()
	if not active_statuses.has(target_id):
		active_statuses[target_id] = {}
		# Connect tree exit signal for clean garbage collection
		if not target.tree_exiting.is_connected(_on_target_tree_exiting.bind(target_id)):
			target.tree_exiting.connect(_on_target_tree_exiting.bind(target_id))

	var target_dict: Dictionary = active_statuses[target_id]

	match type:
		StatusType.BURN:
			if target_dict.has(StatusType.BURN):
				var s = target_dict[StatusType.BURN] as ActiveStatus
				s.duration = maxf(s.duration, duration) # Refresh duration
			else:
				var s = ActiveStatus.new(StatusType.BURN, duration, damage, 1)
				target_dict[StatusType.BURN] = s

		StatusType.FREEZE:
			if target_dict.has(StatusType.FREEZE):
				var s = target_dict[StatusType.FREEZE] as ActiveStatus
				s.duration = maxf(s.duration, duration)
			else:
				var s = ActiveStatus.new(StatusType.FREEZE, duration, 0, 1)
				s.param = 0.40 # 40% slow
				target_dict[StatusType.FREEZE] = s
				_apply_freeze_speed(target, true, s.param)

		StatusType.SHOCK:
			_execute_shock_chain(target, damage, 3, 90.0)

		StatusType.DECAY:
			if target_dict.has(StatusType.DECAY):
				var s = target_dict[StatusType.DECAY] as ActiveStatus
				s.duration = maxf(s.duration, duration)
			else:
				var s = ActiveStatus.new(StatusType.DECAY, duration, 0, 1)
				s.param = 0.50 # 50% armor reduction
				target_dict[StatusType.DECAY] = s
				_apply_decay_armor(target, true, s.param)

		StatusType.POISON:
			if target_dict.has(StatusType.POISON):
				var s = target_dict[StatusType.POISON] as ActiveStatus
				s.stacks = min(s.max_stacks, s.stacks + 1)
				s.duration = duration # Refresh
			else:
				var s = ActiveStatus.new(StatusType.POISON, duration, damage, 5)
				target_dict[StatusType.POISON] = s

static func process_statuses(target: Node2D, delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return

	var target_id = target.get_instance_id()
	if not active_statuses.has(target_id):
		return

	var target_dict: Dictionary = active_statuses[target_id]
	var to_remove: Array[StatusType] = []

	for type in target_dict.keys():
		var status = target_dict[type] as ActiveStatus
		status.duration -= delta
		status.tick_timer -= delta

		if status.tick_timer <= 0.0:
			status.tick_timer = status.tick_interval
			_tick_status_damage(target, status)

		if status.duration <= 0.0:
			to_remove.append(type)

	for type in to_remove:
		var status = target_dict[type] as ActiveStatus
		if type == StatusType.FREEZE:
			_apply_freeze_speed(target, false, status.param)
		elif type == StatusType.DECAY:
			_apply_decay_armor(target, false, status.param)
		target_dict.erase(type)

	if target_dict.size() == 0:
		active_statuses.erase(target_id)

static func _tick_status_damage(target: Node2D, status: ActiveStatus) -> void:
	if target.has_method("_on_hit_received"):
		var total_damage = status.damage_per_tick * status.stacks
		if total_damage > 0:
			target._on_hit_received(total_damage, false, str(status.type), Vector2.ZERO)

static func _apply_freeze_speed(target: Node2D, enable: bool, slow_ratio: float) -> void:
	if target.get("enemy_data") != null and target.enemy_data:
		var base_s = target.enemy_data.move_speed
		if enable:
			target.set("move_speed", base_s * (1.0 - slow_ratio))
		else:
			target.set("move_speed", base_s)

static func _apply_decay_armor(target: Node2D, enable: bool, decay_ratio: float) -> void:
	var hurtbox = target.get_node_or_null("Hurtbox") as Hurtbox
	if hurtbox:
		if enable:
			hurtbox.armor = int(hurtbox.armor * (1.0 - decay_ratio))
		else:
			hurtbox.armor = int(hurtbox.armor / (1.0 - decay_ratio))

static func _execute_shock_chain(origin_target: Node2D, base_damage: int, max_chains: int, max_dist: float) -> void:
	var visited: Dictionary = {}
	visited[origin_target.get_instance_id()] = true
	var curr = origin_target
	var current_dmg = base_damage
	
	for chain in range(max_chains):
		var tree = origin_target.get_tree()
		if tree == null:
			break
		var enemies = tree.get_nodes_in_group("enemies")
		var closest: Node2D = null
		var min_d = max_dist
		
		for e in enemies:
			if not (e.get_instance_id() in visited) and is_instance_valid(e):
				var d = curr.global_position.distance_to(e.global_position)
				if d <= min_d:
					min_d = d
					closest = e
					
		if closest != null:
			visited[closest.get_instance_id()] = true
			if closest.has_method("_on_hit_received"):
				closest._on_hit_received(current_dmg, true, "ELECTRIC", Vector2.ZERO)
			curr = closest
			current_dmg = int(current_dmg * 0.70) # 30% falloff per jump
		else:
			break

static func _on_target_tree_exiting(target_id: int) -> void:
	if active_statuses.has(target_id):
		active_statuses.erase(target_id)
