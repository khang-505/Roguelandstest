# scripts/world/extraction_beacon.gd
class_name ExtractionBeacon
extends Area2D

## 10-Second Extraction Channeling Beacon & Defensive Wave Controller.

enum ExtractionState { INACTIVE, CHANNELING, INTERRUPTED, COMPLETED }

signal extraction_started()
signal extraction_interrupted()
signal extraction_completed()

@export var extraction_duration: float = 10.0

var current_state: ExtractionState = ExtractionState.INACTIVE
var channel_timer: float = 0.0
var has_secured_rewards: bool = false
var target_player: CharacterBody2D = null

@onready var beacon_label: Label = $BeaconLabel if has_node("BeaconLabel") else null

func _ready() -> void:
	# Create collision shape if missing
	if get_child_count() == 0 or not _has_collision_shape():
		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.size = Vector2(24, 24)
		shape.shape = rect
		add_child(shape)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _has_collision_shape() -> bool:
	for child in get_children():
		if child is CollisionShape2D:
			return true
	return false

func _physics_process(delta: float) -> void:
	if current_state == ExtractionState.CHANNELING:
		channel_timer += delta

		if beacon_label:
			var remaining = max(0.0, extraction_duration - channel_timer)
			beacon_label.text = "EXIT %.1f" % remaining

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
	extraction_started.emit()
	return true

func interrupt_extraction() -> void:
	if current_state != ExtractionState.CHANNELING:
		return

	current_state = ExtractionState.INTERRUPTED
	channel_timer = 0.0
	if beacon_label:
		beacon_label.text = "EXIT"
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
		return # Idempotent check

	has_secured_rewards = true

	# Transfer run currency to persistent profile
	var persistent_credits = SaveManager.profile_data.get("total_credits", 0)
	var persistent_shards = SaveManager.profile_data.get("total_shards", 0)

	SaveManager.profile_data["total_credits"] = persistent_credits + GameManager.run_credits
	SaveManager.profile_data["total_shards"] = persistent_shards + GameManager.run_shards

	var total_exps = SaveManager.profile_data.get("expeditions_completed", 0)
	SaveManager.profile_data["expeditions_completed"] = total_exps + 1

	SaveManager.save_game()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target_player = body as CharacterBody2D
		start_extraction()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		interrupt_extraction()
		target_player = null
