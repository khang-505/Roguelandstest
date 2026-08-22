# scripts/hub/hub_controller.gd
class_name HubController
extends Node2D

## Main Expedition Base Hub Controller managing base evolution, stations, and deployment.

const CRAFTING_UI_SCENE = preload("res://scenes/ui/crafting_ui.tscn")
const RESEARCH_UI_SCENE = preload("res://scenes/ui/research_ui.tscn")
const ORIGIN_SELECT_UI_SCENE = preload("res://scenes/ui/origin_select_ui.tscn")

const HUB_UPGRADE_COSTS = {
	2: {"credits": 100, "shards": 10},
	3: {"credits": 300, "shards": 25},
	4: {"credits": 1000, "shards": 75}
}

var current_hub_level: int = 1

@onready var station_forge: StationBase = $Stations/ForgeStation if has_node("Stations/ForgeStation") else null
@onready var station_research: StationBase = $Stations/ResearchStation if has_node("Stations/ResearchStation") else null
@onready var station_companion: StationBase = $Stations/CompanionStation if has_node("Stations/CompanionStation") else null
@onready var station_deploy: StationBase = $Stations/DeploymentStation if has_node("Stations/DeploymentStation") else null

func _ready() -> void:
	current_hub_level = SaveManager.profile_data.get("hub_level", 1)
	_update_station_locks()

	if station_deploy:
		station_deploy.player_interacted.connect(_on_deployment_interacted)
	if station_forge:
		station_forge.player_interacted.connect(_on_forge_interacted)
	if station_research:
		station_research.player_interacted.connect(_on_research_interacted)
	if station_companion:
		station_companion.player_interacted.connect(_on_companion_interacted)

func upgrade_hub() -> bool:
	if current_hub_level >= 4:
		return false # Max level reached

	var next_level = current_hub_level + 1
	var cost = HUB_UPGRADE_COSTS.get(next_level, {})
	var req_credits = cost.get("credits", 99999)
	var req_shards = cost.get("shards", 99999)

	var total_credits = SaveManager.profile_data.get("total_credits", 0)
	var total_shards = SaveManager.profile_data.get("total_shards", 0)

	if total_credits < req_credits or total_shards < req_shards:
		return false # Insufficient funds

	# Atomic transaction
	SaveManager.profile_data["total_credits"] = total_credits - req_credits
	SaveManager.profile_data["total_shards"] = total_shards - req_shards
	SaveManager.profile_data["hub_level"] = next_level
	current_hub_level = next_level

	SaveManager.save_game()
	_update_station_locks()
	return true

func _update_station_locks() -> void:
	if station_forge:
		station_forge.required_hub_level = 1
	if station_research:
		station_research.required_hub_level = 1
	if station_companion:
		station_companion.required_hub_level = 1
	if station_deploy:
		station_deploy.required_hub_level = 1

func _on_deployment_interacted(_station_id: String) -> void:
	GameManager.start_new_expedition()

func _on_forge_interacted(_station_id: String) -> void:
	_open_station_ui(CRAFTING_UI_SCENE)

func _on_research_interacted(_station_id: String) -> void:
	_open_station_ui(RESEARCH_UI_SCENE)

func _on_companion_interacted(_station_id: String) -> void:
	_open_station_ui(ORIGIN_SELECT_UI_SCENE)

func _open_station_ui(scene: PackedScene) -> void:
	var main_node = get_tree().current_scene
	if main_node and main_node.has_node("UILayer"):
		var ui_layer = main_node.get_node("UILayer") as CanvasLayer
		var ui = scene.instantiate()
		ui_layer.add_child(ui)
