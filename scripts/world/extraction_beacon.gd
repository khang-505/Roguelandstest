# scripts/world/extraction_beacon.gd
class_name ExtractionBeacon
extends Area2D

## 10-Second Extraction Channeling Beacon & Defensive Wave Controller.

enum ExtractionState { INACTIVE, STARTING, CHANNELING, INTERRUPTED, COMPLETED }

signal extraction_started()
signal extraction_interrupted()
signal extraction_completed()

@export var extraction_duration: float = 10.0
@export var beacon_radius: float = 48.0

var current_state: ExtractionState = ExtractionState.INACTIVE
var channel_timer: float = 0.0
var wave_spawn_timer: float = 0.0
var has_secured_rewards: bool = false

var target_player: CharacterBody2D = null

@onready var label: Label = $Label if has_node("Label") else null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	if current_state == ExtractionState.CHANNELING:
		channel_timer += delta
		wave_spawn_timer += delta

		if wave_spawn_timer >= 3.0:
			wave_spawn_timer = 0.0
			_spawn_defensive_enemy()

		if channel_timer >= extraction_duration:
			_complete_extraction()

func start_extraction() -> bool:
	if current_state == ExtractionState.COMPLETED or current_state == ExtractionState.CHANNELING:
		return false

	if target_player == null:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target_player = players[0] as CharacterBody2D

	if target_player == null:
		return false

	current_state = ExtractionState.CHANNELING
	channel_timer = 0.0
	wave_spawn_timer = 0.0
	extraction_started.emit()
	return true

func interrupt_extraction() -> void:
	if current_state != ExtractionState.CHANNELING:
		return

	current_state = ExtractionState.INTERRUPTED
	channel_timer = 0.0
	extraction_interrupted.emit()

func _complete_extraction() -> void:
	if current_state == ExtractionState.COMPLETED:
		return

	current_state = ExtractionState.COMPLETED
	extraction_completed.emit()
	_secure_run_rewards()
	GameManager.change_state(GameManager.GameState.RESULTS)

func _secure_run_rewards() -> void:
	if has_secured_rewards:
		return # Idempotent check: prevent duplicate reward transfers
		
	has_secured_rewards = true
	
	# Transfer run currency to persistent profile
	var persistent_credits = SaveManager.profile_data.get("total_credits", 0)
	var persistent_shards = SaveManager.profile_data.get("total_shards", 0)
	
	SaveManager.profile_data["total_credits"] = persistent_credits + GameManager.run_credits
	SaveManager.profile_data["total_shards"] = persistent_shards + GameManager.run_shards
	
	var total_exps = SaveManager.profile_data.get("expeditions_completed", 0)
	SaveManager.profile_data["expeditions_completed"] = total_exps + 1
	
	SaveManager.save_game()

func _spawn_defensive_enemy() -> void:
	# Spawns defensive wave enemy near beacon
	var enemy = AshBeetle.new()
	enemy.global_position = global_position + Vector2(randf_range(-80, 80), -20)
	var stage = get_tree().current_scene
	if stage:
		stage.add_child(enemy)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target_player = body as CharacterBody2D
		start_extraction()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		interrupt_extraction()
		target_player = null
