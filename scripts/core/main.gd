# scripts/core/main.gd
class_name MainController
extends Node2D

## Main scene controller connecting Main Menu, Hub Base, Procedural Level, HUD, and Game Over flow.

const MAIN_MENU_SCENE = preload("res://scenes/ui/main_menu.tscn")
const HUB_SCENE = preload("res://scenes/hub/hub.tscn")
const LEVEL_STAGE_SCENE = preload("res://scenes/world/level_stage.tscn")
const PLAYER_SCENE = preload("res://scenes/player/player.tscn")
const ASH_BEETLE_SCENE = preload("res://scenes/enemies/ash_beetle.tscn")
const LOOT_DROP_SCENE = preload("res://scenes/items/loot_drop.tscn")
const HUD_SCENE = preload("res://scenes/ui/hud.tscn")
const GAME_OVER_SCENE = preload("res://scenes/ui/game_over_screen.tscn")

var current_ui: Control = null
var current_level: Node2D = null
var current_player: CharacterBody2D = null

func _ready() -> void:
	EventBus.game_state_changed.connect(_on_game_state_changed)
	EventBus.enemy_died.connect(_on_enemy_died)
	_on_game_state_changed(GameManager.GameState.BOOT, GameManager.current_state)

func _on_game_state_changed(_old_state: int, new_state: int) -> void:
	match new_state:
		GameManager.GameState.MAIN_MENU:
			_show_main_menu()
		GameManager.GameState.HUB:
			_show_hub_world()
		GameManager.GameState.WORLD_GENERATION:
			_build_expedition_world()
		GameManager.GameState.DEATH:
			_show_game_over_screen()
		GameManager.GameState.RESULTS:
			_show_results_screen()

func _show_main_menu() -> void:
	_clear_world()
	RewardManager.reset_contract()
	if current_ui:
		current_ui.queue_free()
	current_ui = MAIN_MENU_SCENE.instantiate()
	add_child(current_ui)

func _show_hub_world() -> void:
	_clear_world()
	RewardManager.reset_contract()
	if current_ui:
		current_ui.queue_free()
		
	current_level = HUB_SCENE.instantiate()
	add_child(current_level)
	
	# Spawn player in Hub
	current_player = PLAYER_SCENE.instantiate() as CharacterBody2D
	current_player.global_position = Vector2(50, 230)
	current_level.add_child(current_player)

func _build_expedition_world() -> void:
	_clear_world()
	if current_ui:
		current_ui.queue_free()
		
	# 1. Instantiate level stage
	current_level = LEVEL_STAGE_SCENE.instantiate()
	add_child(current_level)
	
	var generator = current_level.get_node("RoomGenerator") as RoomGenerator
	var map_data = generator.generate_room(GameManager.current_seed)
	
	# 2. Instantiate Player at spawn point
	current_player = PLAYER_SCENE.instantiate() as CharacterBody2D
	current_player.global_position = map_data["player_spawn"]
	current_level.add_child(current_player)
	
	# 3. Instantiate Ash Beetle enemies
	var enemies_node = current_level.get_node("EnemiesContainer")
	for spawn_pos in map_data["enemy_spawns"]:
		var beetle = ASH_BEETLE_SCENE.instantiate() as EnemyBase
		beetle.global_position = spawn_pos
		enemies_node.add_child(beetle)
		
	# 4. Attach HUD overlay
	current_ui = HUD_SCENE.instantiate()
	add_child(current_ui)
	
	GameManager.change_state(GameManager.GameState.EXPLORATION)

func _on_enemy_died(pos: Vector2, _type: String) -> void:
	if current_level and is_instance_valid(current_level):
		var loot = LOOT_DROP_SCENE.instantiate() as Area2D
		loot.global_position = pos
		var loot_container = current_level.get_node_or_null("LootContainer")
		if loot_container:
			loot_container.add_child(loot)
		else:
			current_level.add_child(loot)

func _show_game_over_screen() -> void:
	if current_ui:
		current_ui.queue_free()
	current_ui = GAME_OVER_SCENE.instantiate()
	add_child(current_ui)

func _show_results_screen() -> void:
	# Calculate final rewards with contract multipliers exactly ONCE
	RewardManager.calculate_final_rewards(GameManager.run_credits, GameManager.run_shards)
	_show_game_over_screen()

func _clear_world() -> void:
	if current_level and is_instance_valid(current_level):
		current_level.queue_free()
		current_level = null
