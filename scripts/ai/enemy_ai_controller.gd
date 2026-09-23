# scripts/ai/enemy_ai_controller.gd
class_name EnemyAIController
extends Node2D

## Central FSM AI Manager controlling perception, target tracking, pathing, and state transitions.

signal state_changed(old_state_type, new_state_type)

@export var role_type: int = 0 # 0=MELEE, 1=RANGED, 2=TANK, 3=FLYING, 4=ASSASSIN, 5=SUPPORT, 6=BURROWER
@export var detection_radius: float = 180.0
@export var attack_radius: float = 40.0
@export var lose_target_radius: float = 280.0
@export var reaction_delay: float = 0.2

var current_state = null
var states_map: Dictionary = {}

var target_node: Node2D = null
var last_known_position: Vector2 = Vector2.ZERO
var has_line_of_sight: bool = true
var is_burrowed: bool = false
var is_airborne: bool = false

var reaction_timer: float = 0.0

func _ready() -> void:
	# Populate 11 States dynamically
	var state_base = load("res://scripts/ai/enemy_ai_state.gd")
	if state_base:
		for s in range(11):
			var st_inst = state_base.new(s)
			st_inst.controller = self
			states_map[s] = st_inst

	change_state(0) # 0 = IDLE

func change_state(new_type: int) -> void:
	if not states_map.has(new_type):
		return

	var old_type = current_state.state_type if current_state else -1
	if current_state:
		current_state.exit()

	current_state = states_map[new_type]
	current_state.enter()

	emit_signal("state_changed", old_type, new_type)

func update_perception(player_pos: Vector2, has_wall_between: bool = false) -> void:
	var dist = global_position.distance_to(player_pos)
	has_line_of_sight = not has_wall_between and (dist <= lose_target_radius)

	if has_line_of_sight and dist <= detection_radius:
		last_known_position = player_pos

		if current_state and current_state.state_type in [0, 1]: # IDLE=0, PATROL=1
			change_state(3) # CHASE=3

	elif current_state and current_state.state_type == 3 and dist > lose_target_radius: # CHASE=3
		change_state(2) # INVESTIGATE=2

func check_ledge_hazard(facing_dir: float) -> bool:
	# Downward raycast simulation for platform ledge detection
	if is_airborne or is_burrowed:
		return false
	# Returns true if next step is a cliff drop
	return facing_dir != 0.0 and global_position.y > 500.0

func process_ai_logic(delta: float) -> void:
	if current_state:
		current_state.update(delta)
