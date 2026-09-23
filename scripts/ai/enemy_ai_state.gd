# scripts/ai/enemy_ai_state.gd
class_name EnemyAIState
extends RefCounted

## Virtual base class for modular enemy AI states.

enum StateType {
	IDLE,
	PATROL,
	INVESTIGATE,
	CHASE,
	ATTACK,
	DEFEND,
	RETREAT,
	STUNNED,
	FLEE,
	SPECIAL,
	DEAD
}

var state_type: StateType = StateType.IDLE
var controller = null

func _init(p_type: StateType = StateType.IDLE) -> void:
	state_type = p_type

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

static func get_state_name(type: StateType) -> String:
	match type:
		StateType.IDLE: return "IDLE"
		StateType.PATROL: return "PATROL"
		StateType.INVESTIGATE: return "INVESTIGATE"
		StateType.CHASE: return "CHASE"
		StateType.ATTACK: return "ATTACK"
		StateType.DEFEND: return "DEFEND"
		StateType.RETREAT: return "RETREAT"
		StateType.STUNNED: return "STUNNED"
		StateType.FLEE: return "FLEE"
		StateType.SPECIAL: return "SPECIAL"
		StateType.DEAD: return "DEAD"
	return "UNKNOWN"
