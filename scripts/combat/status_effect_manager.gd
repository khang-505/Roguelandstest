# scripts/combat/status_effect_manager.gd
class_name StatusEffectManager
extends Node

## Central Manager handling status application, data-driven presets across 5 categories, stacking rules, DoT pipeline using DamageCalculator, target resistance math, cleanses, status interactions, and boss status windows.

enum StatusType { BURN, FREEZE, SHOCK, DECAY, POISON, SLOW, STUN, BLEED, CORRUPTION }

class ActiveStatus:
	var type: StatusType
	var status_id: String
	var duration: float
	var tick_timer: float
	var tick_interval: float
	var damage_per_tick: int
	var stacks: int
	var max_stacks: int
	var param: float
	var data: Resource # StatusEffectData
	var source: Node

	func _init(p_type: StatusType, p_dur: float, p_dmg: int = 5, p_max_s: int = 1) -> void:
		type = p_type
		status_id = str(p_type).to_lower()
		duration = p_dur
		tick_interval = 0.5
		tick_timer = 0.5
		damage_per_tick = p_dmg
		stacks = 1
		max_stacks = p_max_s
		param = 0.0

# Key: target Node instance_id -> Dictionary[status_id/StatusType, ActiveStatus]
static var active_statuses: Dictionary = {}

signal status_applied(target: Node, status_id: String, stacks: int)
signal status_expired(target: Node, status_id: String)
signal status_cleansed(target: Node, count: int)

static func apply_status_data(target: Node, status_data: Resource, source_node: Node = null) -> Dictionary:
	if target == null or not is_instance_valid(target) or not status_data:
		return {"success": false, "reason": "Invalid target or status_data"}

	var target_id = target.get_instance_id()
	if not active_statuses.has(target_id):
		active_statuses[target_id] = {}
		if not target.tree_exiting.is_connected(_on_target_tree_exiting.bind(target_id)):
			target.tree_exiting.connect(_on_target_tree_exiting.bind(target_id))

	var target_dict: Dictionary = active_statuses[target_id]
	var s_id = status_data.id.to_lower()
	var eff_dur = status_data.duration
	var eff_tick_dmg = status_data.tick_damage

	# 1. Target Resistance Duration Math
	var res_type = status_data.resistance_type.to_lower() + "_resistance"
	var target_res = 0.0
	if res_type in target:
		target_res = float(target.get(res_type))
	elif "status_resistance" in target:
		target_res = float(target.get("status_resistance"))
		
	eff_dur *= (1.0 - clamp(target_res, 0.0, 0.75))

	# 2. Boss Status Handling (50% duration reduction, no complete immunity)
	if target.is_in_group("bosses") or (target.has_method("is_boss") and target.is_boss()):
		eff_dur *= 0.5

	if eff_dur <= 0.05:
		return {"success": false, "reason": "Resisted due to 100% resistance or duration cap"}

	# 3. Stacking Rules & Refresh Logic
	var active_entry: ActiveStatus = null
	if target_dict.has(s_id):
		active_entry = target_dict[s_id]
		match status_data.stack_behavior:
			StatusEffectData.StackBehavior.REFRESH:
				active_entry.duration = eff_dur
			StatusEffectData.StackBehavior.STACK:
				active_entry.stacks = min(status_data.max_stacks, active_entry.stacks + 1)
				active_entry.duration = eff_dur
			StatusEffectData.StackBehavior.EXTEND_DURATION:
				active_entry.duration += eff_dur
			StatusEffectData.StackBehavior.REPLACE:
				active_entry.duration = eff_dur
				active_entry.stacks = 1
	else:
		active_entry = ActiveStatus.new(StatusType.BURN, eff_dur, int(eff_tick_dmg), status_data.max_stacks)
		active_entry.status_id = s_id
		active_entry.data = status_data
		active_entry.source = source_node
		active_entry.tick_interval = status_data.tick_interval
		active_entry.tick_timer = status_data.tick_interval
		target_dict[s_id] = active_entry

	# 4. Status Interactions Check
	_check_status_interactions(target, s_id)

	return {
		"success": true,
		"status_id": s_id,
		"stacks": active_entry.stacks,
		"duration": active_entry.duration
	}

static func apply_status(target: Node, type_or_id, duration: float = 4.0, damage: int = 5, param: float = 0.0) -> void:
	if target == null or not is_instance_valid(target):
		return

	var data_script = load("res://scripts/combat/status_effect_data.gd")
	if typeof(type_or_id) == TYPE_STRING and data_script:
		var data = data_script.create_preset(type_or_id)
		if data:
			data.duration = duration
			data.tick_damage = damage
			apply_status_data(target, data, null)
			return

	# Legacy StatusType enum handling
	var target_id = target.get_instance_id()
	if not active_statuses.has(target_id):
		active_statuses[target_id] = {}
		if not target.tree_exiting.is_connected(_on_target_tree_exiting.bind(target_id)):
			target.tree_exiting.connect(_on_target_tree_exiting.bind(target_id))

	var target_dict: Dictionary = active_statuses[target_id]
	var enum_type = type_or_id as StatusType

	match enum_type:
		StatusType.BURN:
			if target_dict.has(StatusType.BURN):
				var s = target_dict[StatusType.BURN] as ActiveStatus
				s.duration = maxf(s.duration, duration)
			else:
				var s = ActiveStatus.new(StatusType.BURN, duration, damage, 1)
				target_dict[StatusType.BURN] = s

		StatusType.FREEZE, StatusType.SLOW:
			if target_dict.has(StatusType.FREEZE):
				var s = target_dict[StatusType.FREEZE] as ActiveStatus
				s.duration = maxf(s.duration, duration)
			else:
				var s = ActiveStatus.new(StatusType.FREEZE, duration, 0, 1)
				s.param = 0.40
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
				s.param = 0.50
				target_dict[StatusType.DECAY] = s
				_apply_decay_armor(target, true, s.param)

		StatusType.POISON, StatusType.BLEED, StatusType.CORRUPTION:
			if target_dict.has(StatusType.POISON):
				var s = target_dict[StatusType.POISON] as ActiveStatus
				s.stacks = min(s.max_stacks, s.stacks + 1)
				s.duration = duration
			else:
				var s = ActiveStatus.new(StatusType.POISON, duration, damage, 5)
				target_dict[StatusType.POISON] = s

static func process_statuses(target: Node, delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return

	var target_id = target.get_instance_id()
	if not active_statuses.has(target_id):
		return

	var target_dict: Dictionary = active_statuses[target_id]
	var to_remove: Array = []

	for key in target_dict.keys():
		var status = target_dict[key] as ActiveStatus
		status.duration -= delta
		status.tick_timer -= delta

		if status.tick_timer <= 0.0:
			status.tick_timer = status.tick_interval
			_tick_status_damage(target, status)

		if status.duration <= 0.0:
			to_remove.append(key)

	for key in to_remove:
		var status = target_dict[key] as ActiveStatus
		if key == StatusType.FREEZE or key == "freeze":
			_apply_freeze_speed(target, false, status.param)
		elif key == StatusType.DECAY or key == "decay":
			_apply_decay_armor(target, false, status.param)
		target_dict.erase(key)

	if target_dict.size() == 0:
		active_statuses.erase(target_id)

static func cleanse_all(target: Node) -> int:
	if target == null or not is_instance_valid(target):
		return 0
	var target_id = target.get_instance_id()
	if not active_statuses.has(target_id):
		return 0
	var count = active_statuses[target_id].size()
	active_statuses.erase(target_id)
	return count

static func cleanse_category(target: Node, category: int) -> int:
	if target == null or not is_instance_valid(target):
		return 0
	var target_id = target.get_instance_id()
	if not active_statuses.has(target_id):
		return 0
		
	var target_dict = active_statuses[target_id]
	var to_remove = []
	for key in target_dict.keys():
		var s = target_dict[key] as ActiveStatus
		if s.data and s.data.category == category:
			to_remove.append(key)
			
	for key in to_remove:
		target_dict.erase(key)
	return to_remove.size()

static func cleanse_status(target: Node, status_id: String) -> bool:
	if target == null or not is_instance_valid(target):
		return false
	var target_id = target.get_instance_id()
	if not active_statuses.has(target_id):
		return false
	var s_id = status_id.to_lower()
	if active_statuses[target_id].has(s_id):
		active_statuses[target_id].erase(s_id)
		return true
	return false

static func _tick_status_damage(target: Node, status: ActiveStatus) -> void:
	var total_dmg = status.damage_per_tick * status.stacks
	if total_dmg <= 0:
		return
		
	# Pipeline through DamageCalculator if available
	var calc_script = load("res://scripts/combat/damage_calculator.gd")
	var req_script = load("res://scripts/combat/damage_request.gd")
	
	if calc_script and req_script:
		var dmg_type = status.data.damage_type if (status.data and status.data.damage_type != "") else "FIRE"
		var req = req_script.new(float(total_dmg), dmg_type, "DOT", 0.0, 1.0)
		req.target = target
		var calc_res = calc_script.process_damage_request(req)
		total_dmg = calc_res.get("final_damage", total_dmg)

	if target.has_method("take_damage"):
		target.take_damage(total_dmg)
	elif target.has_method("_on_hit_received"):
		target._on_hit_received(total_dmg, false, "DOT", Vector2.ZERO)

static func _check_status_interactions(target: Node, new_status_id: String) -> void:
	var target_id = target.get_instance_id()
	if not active_statuses.has(target_id):
		return
	var dict = active_statuses[target_id]
	
	# ICE + SHOCK -> SHATTER_STUN
	if (new_status_id == "shock" and dict.has("freeze")) or (new_status_id == "freeze" and dict.has("shock")):
		dict.erase("freeze")
		dict.erase("shock")
		var stun_data = load("res://scripts/combat/status_effect_data.gd").create_preset("stun")
		apply_status_data(target, stun_data, null)
		if target.has_method("take_damage"):
			target.take_damage(50.0) # Shatter bonus damage

static func _apply_freeze_speed(target: Node, enable: bool, slow_ratio: float) -> void:
	if target.get("enemy_data") != null and target.enemy_data:
		var base_s = target.enemy_data.move_speed
		if enable:
			target.set("move_speed", base_s * (1.0 - slow_ratio))
		else:
			target.set("move_speed", base_s)

static func _apply_decay_armor(target: Node, enable: bool, decay_ratio: float) -> void:
	var hurtbox = target.get_node_or_null("Hurtbox") as Hurtbox
	if hurtbox:
		if enable:
			hurtbox.armor = int(hurtbox.armor * (1.0 - decay_ratio))
		else:
			hurtbox.armor = int(hurtbox.armor / (1.0 - decay_ratio))

static func _execute_shock_chain(origin_target: Node, base_damage: int, max_chains: int, max_dist: float) -> void:
	var visited: Dictionary = {}
	visited[origin_target.get_instance_id()] = true
	var curr = origin_target
	var current_dmg = base_damage
	
	for chain in range(max_chains):
		var tree = origin_target.get_tree()
		if tree == null:
			break
		var enemies = tree.get_nodes_in_group("enemies")
		var closest: Node = null
		var min_d = max_dist
		
		for e in enemies:
			if not (e.get_instance_id() in visited) and is_instance_valid(e):
				var e_pos = e.global_position if e.has_method("get_global_position") else e.position
				var c_pos = curr.global_position if curr.has_method("get_global_position") else curr.position
				var d = c_pos.distance_to(e_pos)
				if d <= min_d:
					min_d = d
					closest = e
					
		if closest != null:
			visited[closest.get_instance_id()] = true
			if closest.has_method("take_damage"):
				closest.take_damage(current_dmg)
			elif closest.has_method("_on_hit_received"):
				closest._on_hit_received(current_dmg, true, "ELECTRIC", Vector2.ZERO)
			curr = closest
			current_dmg = int(current_dmg * 0.70)
		else:
			break

static func _on_target_tree_exiting(target_id: int) -> void:
	if active_statuses.has(target_id):
		active_statuses.erase(target_id)
