# scripts/combat/combo_manager.gd
class_name ComboManager
extends RefCounted

## Manager handling 3-Hit Combo Chains, Input Buffering, Reset Timers, and Air Combat Attacks.

var current_combo_step: int = 0
var combo_timer: float = 0.0
var max_combo_reset_time: float = 0.8

var input_buffer_queued: bool = false
var input_buffer_timer: float = 0.0
var max_buffer_time: float = 0.15

signal combo_step_executed(step: int, attack_info: Dictionary)
signal combo_reset()

func update(delta: float) -> void:
	if combo_step_executed:
		combo_timer += delta
		if combo_timer >= max_combo_reset_time:
			reset_combo()
			
	if input_buffer_queued:
		input_buffer_timer -= delta
		if input_buffer_timer <= 0.0:
			input_buffer_queued = false

func request_attack(is_airborne: bool = false) -> Dictionary:
	if is_airborne:
		return _get_air_attack()
		
	current_combo_step = (current_combo_step % 3) + 1
	combo_timer = 0.0
	
	var attack_info = {}
	match current_combo_step:
		1:
			attack_info = {
				"name": "Light Slash 1",
				"type": "LIGHT",
				"step": 1,
				"damage_multiplier": 1.0,
				"startup": 0.08,
				"active": 0.12,
				"recovery": 0.15,
				"knockback": 100.0
			}
		2:
			attack_info = {
				"name": "Light Slash 2",
				"type": "LIGHT",
				"step": 2,
				"damage_multiplier": 1.25,
				"startup": 0.07,
				"active": 0.12,
				"recovery": 0.15,
				"knockback": 140.0
			}
		3:
			attack_info = {
				"name": "Heavy Finisher Slam",
				"type": "HEAVY",
				"step": 3,
				"damage_multiplier": 1.8,
				"startup": 0.15,
				"active": 0.18,
				"recovery": 0.3,
				"knockback": 280.0
			}
			reset_combo()
			
	emit_signal("combo_step_executed", current_combo_step, attack_info)
	return attack_info

func buffer_input() -> void:
	input_buffer_queued = true
	input_buffer_timer = max_buffer_time

func consume_buffer() -> bool:
	if input_buffer_queued and input_buffer_timer > 0.0:
		input_buffer_queued = false
		return true
	return false

func _get_air_attack() -> Dictionary:
	return {
		"name": "Aerial Cleave",
		"type": "AIR",
		"step": 1,
		"damage_multiplier": 1.3,
		"startup": 0.06,
		"active": 0.15,
		"recovery": 0.12,
		"knockback": 160.0
	}

func reset_combo() -> void:
	current_combo_step = 0
	combo_timer = 0.0
	emit_signal("combo_reset")
