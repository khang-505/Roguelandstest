# scripts/core/game_manager.gd
class_name GameManagerSingleton
extends Node

## Central Manager for state flow, run telemetry, input registration, and global session data.

enum GameState {
	BOOT,
	MAIN_MENU,
	CHARACTER_CREATION,
	HUB,
	WORLD_SELECTION,
	WORLD_GENERATION,
	EXPLORATION,
	COMBAT,
	BOSS,
	EXTRACTION,
	DEATH,
	RESULTS,
	PAUSE
}

@export var current_state: GameState = GameState.BOOT

# Run Telemetry & Session Progress
var current_seed: int = 1337
var run_credits: int = 0
var run_shards: int = 0
var enemies_killed: int = 0
var run_time_seconds: float = 0.0
var current_biome_name: String = "Emberwild Frontier"

# Player Persistent Stats Buffer for current run
var player_max_hp: int = 100
var player_current_hp: int = 100
var player_max_energy: float = 100.0
var player_current_energy: float = 100.0

func _ready() -> void:
	_setup_fallback_input_map()
	change_state(GameState.MAIN_MENU)
	EventBus.player_died.connect(_on_player_died)
	EventBus.loot_collected.connect(_on_loot_collected)
	EventBus.enemy_died.connect(_on_enemy_died)

func _process(delta: float) -> void:
	if current_state == GameState.EXPLORATION or current_state == GameState.COMBAT:
		run_time_seconds += delta

func change_state(new_state: GameState) -> void:
	if current_state == new_state:
		return
	var old_state: GameState = current_state
	current_state = new_state
	EventBus.game_state_changed.emit(old_state, new_state)

func start_new_expedition(p_seed: int = -1) -> void:
	if p_seed == -1:
		current_seed = randi() % 1000000
	else:
		current_seed = p_seed
	
	run_credits = 0
	run_shards = 0
	enemies_killed = 0
	run_time_seconds = 0.0
	player_current_hp = player_max_hp
	player_current_energy = player_max_energy
	
	change_state(GameState.WORLD_GENERATION)

func restart_expedition() -> void:
	start_new_expedition(current_seed + 1)

func _on_player_died() -> void:
	change_state(GameState.DEATH)

func _on_loot_collected(_item_id: String, _item_name: String, amount: int) -> void:
	run_credits += amount * 10
	run_shards += amount

func _on_enemy_died(_pos: Vector2, _type: String) -> void:
	enemies_killed += 1

func _setup_fallback_input_map() -> void:
	var actions = {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"jump": [KEY_W, KEY_SPACE, KEY_UP],
		"dash": [KEY_SHIFT, KEY_J],
		"attack": [KEY_K, KEY_Z],
		"interact": [KEY_E],
		"ability": [KEY_Q, KEY_L]
	}
	
	for action in actions.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for keycode in actions[action]:
			var event = InputEventKey.new()
			event.physical_keycode = keycode
			var has_event = false
			for existing_ev in InputMap.action_get_events(action):
				if existing_ev is InputEventKey and existing_ev.physical_keycode == keycode:
					has_event = true
					break
			if not has_event:
				InputMap.action_add_event(action, event)
