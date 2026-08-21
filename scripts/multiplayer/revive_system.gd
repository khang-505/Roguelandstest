# scripts/multiplayer/revive_system.gd
class_name ReviveSystem
extends Node

## Handles Downed state transitions and 5-second revive channeling logic.

enum PlayerLifeState { ALIVE, DOWNED, BEING_REVIVED, REVIVED, DEAD }

signal life_state_changed(player: CharacterBody2D, new_state: PlayerLifeState)
signal revive_started(target: CharacterBody2D, reviver: CharacterBody2D)
signal revive_completed(target: CharacterBody2D)
signal revive_interrupted(target: CharacterBody2D)

@export var revive_duration: float = 5.0
@export var revive_radius: float = 48.0

var player_states: Dictionary = {} # player_instance_id -> PlayerLifeState
var revive_timers: Dictionary = {} # player_instance_id -> float
var active_revivers: Dictionary = {} # target_id -> reviver_id

func set_player_state(player: CharacterBody2D, state: PlayerLifeState) -> void:
	if player == null or not is_instance_valid(player):
		return
	var pid = player.get_instance_id()
	player_states[pid] = state
	life_state_changed.emit(player, state)

func get_player_state(player: CharacterBody2D) -> PlayerLifeState:
	if player == null or not is_instance_valid(player):
		return PlayerLifeState.DEAD
	var pid = player.get_instance_id()
	return player_states.get(pid, PlayerLifeState.ALIVE)

func process_player_downed(player: CharacterBody2D, is_coop: bool) -> void:
	if not is_coop:
		set_player_state(player, PlayerLifeState.DEAD)
	else:
		set_player_state(player, PlayerLifeState.DOWNED)

func start_revive(reviver: CharacterBody2D, target: CharacterBody2D) -> bool:
	if reviver == null or target == null:
		return false

	var target_id = target.get_instance_id()
	var state = get_player_state(target)

	if state != PlayerLifeState.DOWNED:
		return false

	if active_revivers.has(target_id):
		return false # Prevent duplicate revive channeling

	active_revivers[target_id] = reviver.get_instance_id()
	revive_timers[target_id] = 0.0
	set_player_state(target, PlayerLifeState.BEING_REVIVED)
	revive_started.emit(target, reviver)
	return true

func update_revive_process(target: CharacterBody2D, reviver: CharacterBody2D, delta: float) -> void:
	if target == null or reviver == null:
		return

	var target_id = target.get_instance_id()
	var dist = reviver.global_position.distance_to(target.global_position)

	if dist > revive_radius:
		interrupt_revive(target)
		return

	var curr_time = revive_timers.get(target_id, 0.0) + delta
	revive_timers[target_id] = curr_time

	if curr_time >= revive_duration:
		complete_revive(target)

func interrupt_revive(target: CharacterBody2D) -> void:
	if target == null:
		return
	var target_id = target.get_instance_id()
	active_revivers.erase(target_id)
	revive_timers.erase(target_id)
	set_player_state(target, PlayerLifeState.DOWNED)
	revive_interrupted.emit(target)

func complete_revive(target: CharacterBody2D) -> void:
	if target == null:
		return
	var target_id = target.get_instance_id()
	active_revivers.erase(target_id)
	revive_timers.erase(target_id)
	
	if target.has_method("take_damage"):
		target.set("current_hp", int(target.get("max_hp") * 0.50)) # Revive at 50% HP
		
	set_player_state(target, PlayerLifeState.REVIVED)
	revive_completed.emit(target)
