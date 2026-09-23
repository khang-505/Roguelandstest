# scripts/ai/enemy_ai_states.gd
class_name EnemyAIStates
extends RefCounted

## Concrete state classes for the 11 modular enemy AI states.

class IdleState extends EnemyAIState:
	func _init() -> void:
		super._init(StateType.IDLE)

class PatrolState extends EnemyAIState:
	func _init() -> void:
		super._init(StateType.PATROL)

class InvestigateState extends EnemyAIState:
	func _init() -> void:
		super._init(StateType.INVESTIGATE)

class ChaseState extends EnemyAIState:
	func _init() -> void:
		super._init(StateType.CHASE)

class AttackState extends EnemyAIState:
	func _init() -> void:
		super._init(StateType.ATTACK)

class DefendState extends EnemyAIState:
	func _init() -> void:
		super._init(StateType.DEFEND)

class RetreatState extends EnemyAIState:
	func _init() -> void:
		super._init(StateType.RETREAT)

class StunnedState extends EnemyAIState:
	func _init() -> void:
		super._init(StateType.STUNNED)

class FleeState extends EnemyAIState:
	func _init() -> void:
		super._init(StateType.FLEE)

class SpecialState extends EnemyAIState:
	func _init() -> void:
		super._init(StateType.SPECIAL)

class DeadState extends EnemyAIState:
	func _init() -> void:
		super._init(StateType.DEAD)

static func create_state(type: int) -> EnemyAIState:
	match type:
		EnemyAIState.StateType.IDLE: return IdleState.new()
		EnemyAIState.StateType.PATROL: return PatrolState.new()
		EnemyAIState.StateType.INVESTIGATE: return InvestigateState.new()
		EnemyAIState.StateType.CHASE: return ChaseState.new()
		EnemyAIState.StateType.ATTACK: return AttackState.new()
		EnemyAIState.StateType.DEFEND: return DefendState.new()
		EnemyAIState.StateType.RETREAT: return RetreatState.new()
		EnemyAIState.StateType.STUNNED: return StunnedState.new()
		EnemyAIState.StateType.FLEE: return FleeState.new()
		EnemyAIState.StateType.SPECIAL: return SpecialState.new()
		EnemyAIState.StateType.DEAD: return DeadState.new()
	return IdleState.new()
