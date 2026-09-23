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

# Backpack & Run Progress (Balo trong màn chơi)
var current_seed: int = 1337
var backpack_credits: int = 0
var backpack_shards: int = 0
var backpack_materials: Dictionary = {
	"ember_ore": 0,
	"cryo_crystal": 0,
	"bio_sample": 0,
	"star_shard": 0
}

const MAX_BACKPACK_SIZE = 12
var run_backpack: Array = [] # Array of Dictionary: {"id": String, "type": String, "amount": int}

# Compatibility aliases
var run_credits: int:
	get: return backpack_credits
	set(v): backpack_credits = v

var run_shards: int:
	get: return backpack_shards
	set(v): backpack_shards = v

var run_materials: Dictionary:
	get: return backpack_materials
	set(v): backpack_materials = v

var enemies_killed: int = 0
var run_time_seconds: float = 0.0
var current_biome_id: String = "emberwild"
var current_biome_name: String = "Emberwild Frontier"

# Player Persistent Stats Buffer for current run
var player_max_hp: int = 100
var player_current_hp: int = 100
var player_max_energy: float = 100.0
var player_current_energy: float = 100.0

# Player Leveling & XP Progression (Mục 2.6 trong GDD)
var player_level: int = 1
var player_xp: int = 0
var xp_to_next_level: int = 100

func add_xp(amount: int) -> void:
	player_xp += amount
	if player_xp >= xp_to_next_level:
		player_level += 1
		player_xp -= xp_to_next_level
		xp_to_next_level = int(xp_to_next_level * 1.35)
		
		# Stat increases on Level Up (Tăng HP & Hồi máu đầy)
		player_max_hp += 15
		player_current_hp = player_max_hp
		EventBus.player_hp_changed.emit(player_current_hp, player_max_hp)
		EventBus.player_leveled_up.emit(player_level)
		
	EventBus.xp_gained.emit(player_xp, xp_to_next_level, player_level)

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

var expedition_depth: int = 1

func clear_backpack() -> void:
	backpack_credits = 0
	backpack_shards = 0
	backpack_materials = {
		"ember_ore": 0,
		"cryo_crystal": 0,
		"bio_sample": 0,
		"star_shard": 0
	}
	run_backpack.clear()

func add_to_backpack(p_id: String, p_type: String, p_amount: int) -> bool:
	if p_type == "credit":
		backpack_credits += p_amount * 10
		return true
		
	if p_type == "material":
		if p_id == "star_shard":
			backpack_shards += p_amount
		if backpack_materials.has(p_id):
			backpack_materials[p_id] += p_amount
		else:
			backpack_materials[p_id] = p_amount

	# Check if stackable
	var max_stack = 999 if (p_type == "consumable" or p_type == "material") else 1
	var original_amount = p_amount
	
	for item in run_backpack:
		if item["id"] == p_id and item["amount"] < max_stack:
			var space = max_stack - item["amount"]
			if p_amount <= space:
				item["amount"] += p_amount
				p_amount = 0
				break
			else:
				item["amount"] = max_stack
				p_amount -= space
				
	# Need new slot(s) for remainder
	while p_amount > 0 and run_backpack.size() < MAX_BACKPACK_SIZE:
		var amount_to_add = min(p_amount, max_stack)
		run_backpack.append({"id": p_id, "type": p_type, "amount": amount_to_add})
		p_amount -= amount_to_add
		
	var added_amount = original_amount - p_amount
	if added_amount > 0:
		EventBus.loot_collected.emit(p_id, p_id, added_amount)
		var huds = get_tree().get_nodes_in_group("hud")
		for h in huds:
			if h.has_method("update_hud_display"): h.update_hud_display()
		return true
		
	return false

func start_new_expedition(p_seed: int = -1) -> void:
	if p_seed == -1:
		current_seed = randi() % 1000000
	else:
		current_seed = p_seed
	
	expedition_depth = 1
	var active_origin_id = SaveManager.profile_data.get("active_origin", "vanguard")
	var origin = OriginData.get_origin(active_origin_id)

	# BUG-008: Reset player progression (temporary per run)
	player_level = 1
	player_xp = 0
	xp_to_next_level = 100

	# BUG-007: Include armor HP bonuses in starting max_hp
	var add_hp = 0
	var equipped_armor: Dictionary = SaveManager.profile_data.get("equipped_armor", {})
	for slot_key in equipped_armor.keys():
		var eq_id = equipped_armor[slot_key]
		var eq = EquipmentData.get_equipment(eq_id)
		if eq:
			add_hp += eq.bonus_hp

	player_max_hp = int(100.0 * (1.0 + origin.hp_modifier)) + add_hp
	player_max_energy = 100.0 * (1.3 if active_origin_id == "mystic" else 1.0)

	# BUG-018: Re-apply any permanently unlocked research HP bonuses
	ProgressionTree.apply_saved_research_stats()

	var biomes = ["emberwild", "frostgrave", "verdant_abyss", "alien_void"]
	current_biome_id = biomes[current_seed % biomes.size()]

	# BUG-002: Bring stashed consumables into the run
	var profile = SaveManager.profile_data
	var cons_ids = ["health_potion", "energy_elixir", "iron_skin_potion", "berserker_brew"]
	for cid in cons_ids:
		var profile_key = cid + "s"
		var qty = profile.get(profile_key, 0)
		if qty > 0:
			add_to_backpack(cid, "consumable", qty)
			profile[profile_key] = 0

	# BUG-006: Reset contract rewards state for new run
	RewardManager.reset_contract()

	# DO NOT clear_backpack() here! The player might have bought consumables in the Hub!
	enemies_killed = 0
	run_time_seconds = 0.0
	player_current_hp = player_max_hp
	player_current_energy = player_max_energy
	
	change_state(GameState.WORLD_GENERATION)

func continue_expedition_next_stage() -> void:
	expedition_depth += 1
	current_seed = randi() % 1000000
	change_state(GameState.WORLD_GENERATION)

func restart_expedition() -> void:
	start_new_expedition(current_seed + 1)

func transfer_backpack_to_stash() -> void:
	var profile = SaveManager.profile_data

	var old_credits = profile.get("total_credits", 0)
	var old_shards = profile.get("total_shards", 0)
	var stash_mats = profile.get("persistent_materials", {})
	if not typeof(stash_mats) == TYPE_DICTIONARY:
		stash_mats = {}

	# Kho Mới = Kho Cũ + Balo Mới
	profile["total_credits"] = old_credits + backpack_credits
	profile["total_shards"] = old_shards + backpack_shards

	# Iterate over physical slots instead of abstract dict
	for item in run_backpack:
		if item["type"] == "material":
			stash_mats[item["id"]] = stash_mats.get(item["id"], 0) + item["amount"]
		elif item["type"] == "equipment":
			var eq_list = profile.get("stashed_equipment", [])
			eq_list.append(item["id"])
			profile["stashed_equipment"] = eq_list
		elif item["type"] == "consumable":
			# BUG-002: Persist consumables to stash on extraction
			var c_key = item["id"] + "s"
			profile[c_key] = profile.get(c_key, 0) + item["amount"]

	profile["persistent_materials"] = stash_mats
	profile["expeditions_completed"] = profile.get("expeditions_completed", 0) + 1

	SaveManager.save_game()

	# Clear backpack after transferring to stash
	clear_backpack()

func commit_run_rewards_to_save() -> void:
	transfer_backpack_to_stash()

func _on_player_died() -> void:
	# Persist collected materials and shards to Forge stash on death
	transfer_backpack_to_stash()
	clear_backpack()
	change_state(GameState.DEATH)

func _on_loot_collected(_item_id: String, _item_name: String, _amount: int) -> void:
	# Keep legacy signals working but routing to the real backpack if not using add_to_backpack directly
	pass

func _on_enemy_died(_pos: Vector2, _type: String) -> void:
	enemies_killed += 1
	add_xp(25)

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
