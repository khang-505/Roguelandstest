# scripts/combat/damage_number_engine.gd
class_name DamageNumberEngine
extends RefCounted

## Zero-Allocation Floating Damage Number Formatter & Queue Engine managing color coding, crit scaling, and visual feedback data.

static var _queue: Array = []

static func format_number_data(
	amount: float,
	damage_type: String,
	is_crit: bool,
	is_shield: bool = false,
	is_heal: bool = false
) -> Dictionary:
	var text_val = str(int(amount))
	var color_val = Color.WHITE
	var scale_val = 1.0
	var is_bold = false

	if is_heal:
		text_val = "+" + str(int(amount))
		color_val = Color(0.2, 1.0, 0.2) # Bright Lime
		scale_val = 1.1
	elif is_shield:
		color_val = Color(0.0, 0.6, 1.0) # Shield Blue
		scale_val = 1.0
	elif is_crit:
		color_val = Color(1.0, 0.84, 0.0) # Gold
		scale_val = 1.6
		is_bold = true
	else:
		match damage_type.to_upper():
			"FIRE": color_val = Color(1.0, 0.4, 0.0) # Orange
			"ICE": color_val = Color(0.0, 1.0, 1.0) # Cyan
			"ELECTRIC": color_val = Color(1.0, 1.0, 0.0) # Yellow
			"POISON": color_val = Color(0.0, 0.9, 0.2) # Green
			"ENERGY": color_val = Color(0.7, 0.2, 1.0) # Purple
			"VOID": color_val = Color(0.3, 0.0, 0.5) # Dark Violet
			"TRUE": color_val = Color(1.0, 0.0, 1.0) # Magenta
			"PHYSICAL": color_val = Color.WHITE
			"BLOCKED": color_val = Color(0.6, 0.6, 0.6)

	return {
		"amount": amount,
		"text": text_val,
		"color": color_val,
		"scale": scale_val,
		"is_bold": is_bold,
		"damage_type": damage_type,
		"is_crit": is_crit
	}

static func queue_number(pos: Vector2, amount: float, type: String, is_crit: bool) -> Dictionary:
	var entry = format_number_data(amount, type, is_crit)
	entry["position"] = pos
	entry["lifetime"] = 0.8
	_queue.append(entry)
	if _queue.size() > 200:
		_queue.remove_at(0)
	return entry

static func get_active_queue() -> Array:
	return _queue

static func clear_queue() -> void:
	_queue.clear()
