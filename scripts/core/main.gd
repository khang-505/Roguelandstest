# scripts/core/main.gd
class_name MainController
extends Node2D

## Main scene controller connecting Main Menu, Hub Base, Procedural Level, HUD, and Game Over flow.

const MAIN_MENU_SCENE = preload("res://scenes/ui/main_menu.tscn")
const HUB_SCENE = preload("res://scenes/hub/hub.tscn")
const LEVEL_STAGE_SCENE = preload("res://scenes/world/level_stage.tscn")
const PLAYER_SCENE = preload("res://scenes/player/player.tscn")
const LOOT_DROP_SCENE = preload("res://scenes/items/loot_drop.tscn")
const HUD_SCENE = preload("res://scenes/ui/hud.tscn")
const GAME_OVER_SCENE = preload("res://scenes/ui/game_over_screen.tscn")
const INVENTORY_UI_SCENE = preload("res://scenes/ui/inventory_ui.tscn")

const ASH_BEETLE_SCENE = preload("res://scenes/enemies/ash_beetle.tscn")
const FROST_STALKER_SCENE = preload("res://scenes/enemies/frost_stalker.tscn")
const VOID_LURKER_SCENE = preload("res://scenes/enemies/void_lurker.tscn")
const IRON_GOLEM_SCENE = preload("res://scenes/enemies/iron_golem.tscn")
const SWARM_DRONE_SCENE = preload("res://scenes/enemies/swarm_drone.tscn")

const ENEMY_SCENES = [
	ASH_BEETLE_SCENE,
	FROST_STALKER_SCENE,
	VOID_LURKER_SCENE,
	IRON_GOLEM_SCENE,
	SWARM_DRONE_SCENE
]

var current_ui: Control = null
var current_level: Node2D = null
var current_player: CharacterBody2D = null
var instability_mgr: InstabilityManager = null
var active_inventory_ui: Control = null

@onready var world_layer: Node2D = $WorldLayer
@onready var ui_layer: CanvasLayer = $UILayer

func _ready() -> void:
	EventBus.game_state_changed.connect(_on_game_state_changed)
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.damage_dealt.connect(_on_damage_dealt)
	# Trigger initial state
	_on_game_state_changed(GameManager.GameState.BOOT, GameManager.current_state)

func _process(delta: float) -> void:
	if instability_mgr and is_instance_valid(instability_mgr):
		instability_mgr.process_instability(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_I:
			toggle_inventory_ui()

func toggle_inventory_ui() -> void:
	if active_inventory_ui and is_instance_valid(active_inventory_ui):
		active_inventory_ui.queue_free()
		active_inventory_ui = null
	else:
		active_inventory_ui = INVENTORY_UI_SCENE.instantiate()
		ui_layer.add_child(active_inventory_ui)

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
	_clear_ui()
	current_ui = MAIN_MENU_SCENE.instantiate()
	ui_layer.add_child(current_ui)

func _show_hub_world() -> void:
	_clear_world()
	_clear_ui()

	current_level = HUB_SCENE.instantiate()
	world_layer.add_child(current_level)

	# Spawn player in Hub
	current_player = PLAYER_SCENE.instantiate() as CharacterBody2D
	current_player.global_position = Vector2(50, 230)
	current_level.add_child(current_player)

	# Show HUD in hub too
	current_ui = HUD_SCENE.instantiate()
	ui_layer.add_child(current_ui)

func _build_expedition_world() -> void:
	_clear_world()
	_clear_ui()

	# 1. Instantiate level stage
	current_level = LEVEL_STAGE_SCENE.instantiate()
	world_layer.add_child(current_level)

	var generator = current_level.get_node("RoomGenerator") as RoomGenerator
	var map_data = generator.generate_room(GameManager.current_seed, GameManager.expedition_depth)

	# 2. Instantiate Player at spawn point
	current_player = PLAYER_SCENE.instantiate() as CharacterBody2D
	current_player.global_position = map_data["player_spawn"]
	current_level.add_child(current_player)

	# Set Camera limits according to new dynamic room size
	if current_player and current_player.has_node("Camera2D"):
		var cam = current_player.get_node("Camera2D") as Camera2D
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = map_data.get("room_width_px", 480)
		cam.limit_bottom = map_data.get("room_height_px", 270)

	# 3. Instantiate diverse enemies
	var enemies_node = current_level.get_node("EnemiesContainer")
	var rng = RandomNumberGenerator.new()
	rng.seed = GameManager.current_seed + 99
	for spawn_pos in map_data["enemy_spawns"]:
		var scene_idx = rng.randi() % ENEMY_SCENES.size()
		var enemy = ENEMY_SCENES[scene_idx].instantiate() as EnemyBase
		enemy.global_position = spawn_pos
		enemies_node.add_child(enemy)

	# 4. Attach InstabilityManager
	instability_mgr = InstabilityManager.new()
	add_child(instability_mgr)
	instability_mgr.reset_instability()

	# 5. Attach HUD overlay via UILayer
	current_ui = HUD_SCENE.instantiate()
	ui_layer.add_child(current_ui)

	var hud_ctrl = current_ui as HUDController
	if hud_ctrl:
		instability_mgr.instability_changed.connect(hud_ctrl.set_instability_display)

	GameManager.change_state(GameManager.GameState.EXPLORATION)

func _on_enemy_died(pos: Vector2, enemy_type: String) -> void:
	call_deferred("_spawn_enemy_loot_drop", pos, enemy_type)

func _spawn_enemy_loot_drop(pos: Vector2, enemy_type: String) -> void:
	if current_level and is_instance_valid(current_level):
		var loot_container = current_level.get_node_or_null("LootContainer")
		var target_parent = loot_container if loot_container else current_level
		var loot = ObjectPool.acquire(LOOT_DROP_SCENE, target_parent) as LootDrop
		if loot:
			loot.global_position = pos
			loot.configure_enemy_drop(enemy_type)

func _on_damage_dealt(pos: Vector2, damage: int, is_crit: bool, type_str: String) -> void:
	if current_level and is_instance_valid(current_level):
		DamageNumber.create(pos, damage, is_crit, type_str, current_level)

func _show_game_over_screen() -> void:
	_clear_ui()
	current_ui = GAME_OVER_SCENE.instantiate()
	ui_layer.add_child(current_ui)

func _show_results_screen() -> void:
	# Calculate final rewards with contract multipliers exactly ONCE
	RewardManager.calculate_final_rewards(GameManager.run_credits, GameManager.run_shards)
	_show_game_over_screen()

func _clear_world() -> void:
	ObjectPool.clear_all()
	if active_inventory_ui and is_instance_valid(active_inventory_ui):
		active_inventory_ui.queue_free()
		active_inventory_ui = null
	if instability_mgr and is_instance_valid(instability_mgr):
		instability_mgr.queue_free()
		instability_mgr = null
	if current_level and is_instance_valid(current_level):
		current_level.queue_free()
		current_level = null
	current_player = null

func _clear_ui() -> void:
	if active_inventory_ui and is_instance_valid(active_inventory_ui):
		active_inventory_ui.queue_free()
		active_inventory_ui = null
	if current_ui and is_instance_valid(current_ui):
		current_ui.queue_free()
		current_ui = null
