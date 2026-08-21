# scripts/hub/station_base.gd
class_name StationBase
extends Area2D

## Reusable base class for Expedition Base Hub interactive stations.

signal player_interacted(station_type: String)

@export var station_id: String = "forge"
@export var display_name: String = "Forge Station"
@export var required_hub_level: int = 1

var is_player_in_range: bool = false

@onready var label: Label = $Label if has_node("Label") else null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if is_player_in_range and event.is_action_pressed("interact"):
		interact()

func interact() -> void:
	if SaveManager.profile_data.get("hub_level", 1) < required_hub_level:
		EventBus.damage_dealt.emit(global_position, 0, false, "STATION_LOCKED")
		return
	player_interacted.emit(station_id)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range = true
		if label:
			label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range = false
		if label:
			label.visible = false
