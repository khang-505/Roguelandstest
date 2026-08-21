# scripts/companions/companion_base.gd
class_name CompanionBase
extends Node2D

## Base class for autonomous Companion Drones featuring smooth follow physics and target AI.

@export var companion_data: CompanionData

var target_player: CharacterBody2D = null
var cooldown_timer: float = 0.0
var hover_offset: Vector2 = Vector2(-24, -20)

@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null

func _ready() -> void:
	if companion_data == null:
		companion_data = CompanionData.new()
	tree_exiting.connect(_on_tree_exiting)

func _physics_process(delta: float) -> void:
	cooldown_timer = maxf(0.0, cooldown_timer - delta)
	
	if target_player == null or not is_instance_valid(target_player):
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target_player = players[0] as CharacterBody2D
			
	if target_player and is_instance_valid(target_player):
		_process_smooth_follow(delta)
		_process_companion_ai(delta)

func _process_smooth_follow(delta: float) -> void:
	var desired_pos = target_player.global_position + hover_offset
	var dist = global_position.distance_to(desired_pos)
	
	var follow_dist = companion_data.follow_distance if companion_data else 32.0
	var speed = companion_data.move_speed if companion_data else 180.0
	
	if dist > follow_dist:
		global_position = global_position.move_toward(desired_pos, speed * delta)
		
	if sprite and target_player.velocity.x != 0.0:
		sprite.flip_h = (target_player.velocity.x < 0)

func _process_companion_ai(_delta: float) -> void:
	if companion_data == null or cooldown_timer > 0.0:
		return
		
	match companion_data.type:
		CompanionData.Type.MINER:
			_process_miner_logic()
		CompanionData.Type.COMBAT:
			_process_combat_logic()
		CompanionData.Type.SUPPORT:
			_process_support_logic()

func _process_miner_logic() -> void:
	var loot_nodes = get_tree().get_nodes_in_group("loot")
	var range_val = companion_data.activation_range if companion_data else 140.0
	
	for loot in loot_nodes:
		if is_instance_valid(loot) and global_position.distance_to(loot.global_position) <= range_val:
			if loot.has_method("_on_body_entered") and target_player:
				loot._on_body_entered(target_player)
				cooldown_timer = companion_data.cooldown
				break

func _process_combat_logic() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var range_val = companion_data.activation_range if companion_data else 140.0
	
	for enemy in enemies:
		if is_instance_valid(enemy) and global_position.distance_to(enemy.global_position) <= range_val:
			if enemy.has_method("_on_hit_received"):
				enemy._on_hit_received(12, false, "ENERGY", Vector2.ZERO)
				cooldown_timer = companion_data.cooldown
				break

func _process_support_logic() -> void:
	if target_player and target_player.has_method("take_damage"):
		if target_player.current_hp < target_player.max_hp:
			target_player.current_hp = min(target_player.max_hp, target_player.current_hp + 10)
			GameManager.player_current_hp = target_player.current_hp
			EventBus.player_hp_changed.emit(target_player.current_hp, target_player.max_hp)
			cooldown_timer = companion_data.cooldown

func _on_tree_exiting() -> void:
	target_player = null
