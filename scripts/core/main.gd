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
const MOLTEN_WARDEN_SCENE = preload("res://scenes/bosses/molten_warden.tscn")
const RESOURCE_NODE_SCENE = preload("res://scenes/items/resource_node.tscn")

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
	var map_data = generator.generate_room(GameManager.current_seed, GameManager.expedition_depth, GameManager.current_biome_id)

	# 2. Instantiate Player at spawn point
	current_player = PLAYER_SCENE.instantiate() as CharacterBody2D
	current_player.global_position = map_data["player_spawn"]
	current_level.add_child(current_player)

	# Set Camera limits & exploration framing according to dynamic room size
	if current_player and current_player.has_node("Camera2D"):
		var cam = current_player.get_node("Camera2D") as Camera2D
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = map_data.get("room_width_px", 512)
		cam.limit_bottom = map_data.get("room_height_px", 288)
		cam.position_smoothing_enabled = true
		cam.position_smoothing_speed = 8.0
		cam.drag_horizontal_enabled = true
		cam.drag_vertical_enabled = true
			# 3. Instantiate diverse enemies or Boss Guardian at Depth 3+
	var enemies_node = current_level.get_node("EnemiesContainer")
	if GameManager.expedition_depth >= 3:
		var boss = MOLTEN_WARDEN_SCENE.instantiate() as Node2D
		boss.global_position = Vector2(map_data.get("room_width_px", 480) * 0.5, 200)
		enemies_node.add_child(boss)
	else:
		var rng = RandomNumberGenerator.new()
		rng.seed = GameManager.current_seed + 99
		var biome = map_data.get("biome") as BiomeData
		
		# Spawn Enemies
		for spawn_pos in map_data["enemy_spawns"]:
			var enemy_id = biome.enemy_pool[rng.randi() % biome.enemy_pool.size()]
			var enemy_scene = load("res://scenes/enemies/" + enemy_id + ".tscn")
			if enemy_scene:
				var enemy = enemy_scene.instantiate() as EnemyBase
				enemy.global_position = spawn_pos
				
				# Elite Chance (Before add_child so _ready picks it up)
				if rng.randf() < 0.15:
					enemy.is_elite = true
					
				enemies_node.add_child(enemy)
				
				# Difficulty Scaling based on depth
				if enemy.enemy_data:
					var scale_mult = 1.0 + (GameManager.expedition_depth - 1) * 0.2 # +20% HP/Dmg per depth
					enemy.max_hp = int(enemy.max_hp * scale_mult) # Use the potentially already 3x multiplied max_hp
					enemy.current_hp = enemy.max_hp
					
		# Spawn Resource Nodes
		for res_pos in map_data.get("resource_spawns", []):
			var res_node = RESOURCE_NODE_SCENE.instantiate() as Node2D
			res_node.global_position = res_pos
			res_node.set("resource_pool", biome.resource_pool)
			# Add a visual tint based on biome color
			var sprite = res_node.get_node_or_null("Sprite2D")
			if sprite: sprite.modulate = biome.theme_color
			enemies_node.add_child(res_node)

	# 4. Attach InstabilityManager
	instability_mgr = InstabilityManager.new()
	add_child(instability_mgr)
	instability_mgr.ancient_shard_spawned.connect(_on_ancient_shard_spawned)
	instability_mgr.reset_instability()

	# 5. Check Room Archetype for Event / Shop modals
	var archetype = map_data.get("archetype", 0)
	if archetype == 4: # EVENT
		var evt_scene = load("res://scenes/ui/event_ui.tscn")
		if evt_scene:
			var evt_inst = evt_scene.instantiate()
			ui_layer.call_deferred("add_child", evt_inst)
			if evt_inst.has_method("setup_event"):
				evt_inst.setup_event({
					"title": "Ancient Shrine Anomaly",
					"description": "An ancient star-shrine pulses with cosmic power. Do you channel its energy or harvest its resources?",
					"options": [
						{"text": "Channel Power (+8 Atk, -15% Max HP)", "action": "shrine_power"},
						{"text": "Harvest Energy (+15 Credits)", "action": "shrine_credits"}
					]
				})
	elif archetype == 5: # SHOP
		var shop_scene = load("res://scenes/ui/shop_ui.tscn")
		if shop_scene:
			var shop_inst = shop_scene.instantiate()
			ui_layer.call_deferred("add_child", shop_inst)

	# 6. Attach HUD overlay via UILayer
	current_ui = HUD_SCENE.instantiate()
	ui_layer.add_child(current_ui)

	var hud_ctrl = current_ui as HUDController
	if hud_ctrl:
		instability_mgr.instability_changed.connect(hud_ctrl.set_instability_display)

	GameManager.change_state(GameManager.GameState.EXPLORATION)


func _on_ancient_shard_spawned(pos: Vector2) -> void:
	if current_level and is_instance_valid(current_level):
		var item_scene = load("res://scenes/items/item_drop.tscn")
		if item_scene:
			var item_inst = item_scene.instantiate() as Node2D
			item_inst.set("item_id", "star_shard")
			item_inst.set("item_type", "material")
			item_inst.set("amount", 1)
			item_inst.set("rarity_id", "legendary")
			item_inst.global_position = pos
			var loot_container = current_level.get_node_or_null("LootContainer")
			if loot_container:
				loot_container.add_child(item_inst)
			else:
				current_level.add_child(item_inst)

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
