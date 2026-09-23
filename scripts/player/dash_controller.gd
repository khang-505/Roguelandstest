# scripts/player/dash_controller.gd
class_name DashController
extends Node

## Player Dash Engine managing responsive directional execution, charges, i-frames, input buffering, and combat/environment interactions.

const INPUT_BUFFER_TIME: float = 0.15

var profile: Resource # MobilityProfile

var current_charges: int = 2
var charge_cooldown_timers: Array = [] # Array of floats per missing charge

var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.RIGHT

var iframe_timer: float = 0.0
var input_buffer_timer: float = 0.0
var buffered_direction: Vector2 = Vector2.ZERO

var is_grounded: bool = true
var air_dashes_used: int = 0

var is_dash_attacking: bool = false
var dash_attack_damage: float = 35.0

signal dash_started(direction: Vector2, is_air_dash: bool)
signal dash_ended()
signal charge_changed(current: int, max_charges: int)
signal iframe_state_changed(is_invulnerable: bool)
signal dash_attack_hit(target: Node, damage: float)
signal breakable_struck(breakable_node: Node, damage: float)

func _init(p_profile: Resource = null) -> void:
	if p_profile:
		init_profile(p_profile)
	else:
		var profile_script = load("res://scripts/player/mobility_profile.gd")
		if profile_script:
			init_profile(profile_script.new())

func init_profile(p_profile: Resource) -> void:
	profile = p_profile
	if profile:
		current_charges = profile.dash_count
		dash_attack_damage = profile.dash_damage
	charge_cooldown_timers.clear()

func set_grounded(p_grounded: bool) -> void:
	var was_grounded = is_grounded
	is_grounded = p_grounded
	if is_grounded and not was_grounded:
		air_dashes_used = 0
		# Check if we have a buffered input upon landing
		if input_buffer_timer > 0.0 and buffered_direction != Vector2.ZERO:
			attempt_dash(buffered_direction)

func buffer_dash_input(dir: Vector2) -> void:
	buffered_direction = dir.normalized() if dir != Vector2.ZERO else Vector2.RIGHT
	input_buffer_timer = INPUT_BUFFER_TIME

func attempt_dash(dir: Vector2 = Vector2.ZERO) -> Dictionary:
	if not profile:
		return {"success": false, "reason": "No MobilityProfile set"}
		
	var target_dir = dir.normalized()
	if target_dir == Vector2.ZERO:
		target_dir = buffered_direction if buffered_direction != Vector2.ZERO else Vector2.RIGHT
		
	# Check charge availability
	if current_charges <= 0:
		buffer_dash_input(target_dir)
		return {"success": false, "reason": "No charges available"}
		
	# Check Air Dash restriction
	var is_air = not is_grounded
	if is_air:
		if not profile.air_dash:
			return {"success": false, "reason": "Air dash unlocked = false"}
		if air_dashes_used >= 1 and profile.dash_count <= 1:
			return {"success": false, "reason": "Air dash limit reached"}
			
	# Trigger Dash
	current_charges -= 1
	if is_air:
		air_dashes_used += 1
		
	is_dashing = true
	dash_timer = profile.dash_duration
	dash_direction = target_dir
	iframe_timer = profile.iframe_duration
	
	# Start cooldown timer for this consumed charge
	charge_cooldown_timers.append(profile.dash_cooldown)
	
	# Clear input buffer
	input_buffer_timer = 0.0
	buffered_direction = Vector2.ZERO
	
	emit_signal("dash_started", dash_direction, is_air)
	emit_signal("charge_changed", current_charges, profile.dash_count)
	emit_signal("iframe_state_changed", true)
	
	return {
		"success": true,
		"direction": dash_direction,
		"is_air_dash": is_air,
		"remaining_charges": current_charges,
		"iframe_duration": profile.iframe_duration,
		"speed": profile.dash_speed
	}

func update(delta: float) -> Dictionary:
	# Tick input buffer
	if input_buffer_timer > 0.0:
		input_buffer_timer -= delta
		if input_buffer_timer <= 0.0:
			buffered_direction = Vector2.ZERO

	# Tick i-frames
	var was_iframe = is_invulnerable()
	if iframe_timer > 0.0:
		iframe_timer -= delta
		if iframe_timer <= 0.0 and was_iframe:
			emit_signal("iframe_state_changed", false)

	# Tick active dash state
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
			is_dash_attacking = false
			emit_signal("dash_ended")

	# Tick charge cooldown recovery (sequential recovery)
	if charge_cooldown_timers.size() > 0:
		charge_cooldown_timers[0] -= delta
		if charge_cooldown_timers[0] <= 0.0:
			charge_cooldown_timers.remove_at(0)
			if profile and current_charges < profile.dash_count:
				current_charges += 1
				emit_signal("charge_changed", current_charges, profile.dash_count)
				
				# Attempt buffered dash if ready
				if input_buffer_timer > 0.0 and buffered_direction != Vector2.ZERO:
					attempt_dash(buffered_direction)

	var current_vel = dash_direction * profile.dash_speed if (is_dashing and profile) else Vector2.ZERO
	
	return {
		"is_dashing": is_dashing,
		"velocity": current_vel,
		"is_invulnerable": is_invulnerable(),
		"current_charges": current_charges,
		"is_dash_attacking": is_dash_attacking
	}

func trigger_dash_attack() -> Dictionary:
	if not is_dashing:
		return {"success": false, "reason": "Not dashing"}
	is_dash_attacking = true
	return {
		"success": true,
		"damage": dash_attack_damage,
		"direction": dash_direction
	}

func check_breakable_collision(breakable_node: Node) -> bool:
	if not is_dashing or not profile:
		return false
	if profile.breaks_weak_barriers:
		emit_signal("breakable_struck", breakable_node, dash_attack_damage)
		return true
	return false

func is_invulnerable() -> bool:
	return iframe_timer > 0.0

func get_current_velocity() -> Vector2:
	if is_dashing and profile:
		return dash_direction * profile.dash_speed
	return Vector2.ZERO
