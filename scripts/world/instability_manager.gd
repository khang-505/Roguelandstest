# scripts/world/instability_manager.gd
class_name InstabilityManager
extends Node

## Manages planetary World Instability escalation, elite enemy mutations, and rare resource spawning.

signal instability_changed(new_value: float)
signal elite_mutated(enemy: CharacterBody2D)
signal ancient_shard_spawned(position: Vector2)

@export var base_instability_rate: float = 0.5 # % per second

var current_instability: float = 0.0
var biome_multiplier: float = 1.0

var threshold_25_triggered: bool = false
var threshold_50_triggered: bool = false
var threshold_75_triggered: bool = false
var threshold_100_triggered: bool = false

func reset_instability() -> void:
	current_instability = 0.0
	threshold_25_triggered = false
	threshold_50_triggered = false
	threshold_75_triggered = false
	threshold_100_triggered = false
	instability_changed.emit(current_instability)

func process_instability(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.EXPLORATION and GameManager.current_state != GameManager.GameState.COMBAT:
		return

	var delta_instability = base_instability_rate * biome_multiplier * delta
	current_instability = clampf(current_instability + delta_instability, 0.0, 100.0)
	instability_changed.emit(current_instability)

	_check_instability_thresholds()

func _check_instability_thresholds() -> void:
	if current_instability >= 25.0 and not threshold_25_triggered:
		threshold_25_triggered = true
	elif current_instability >= 50.0 and not threshold_50_triggered:
		threshold_50_triggered = true
		_mutate_random_enemy()
	elif current_instability >= 75.0 and not threshold_75_triggered:
		threshold_75_triggered = true
		_spawn_ancient_shard()
	elif current_instability >= 100.0 and not threshold_100_triggered:
		threshold_100_triggered = true
		_mutate_random_enemy()

func mutate_enemy_to_elite(enemy: CharacterBody2D) -> bool:
	if enemy == null or not is_instance_valid(enemy):
		return false

	if enemy.get("is_elite") == true:
		return false # Idempotent check: prevent duplicate elite mutation

	enemy.set("is_elite", true)

	if enemy.get("max_hp") != null:
		var old_hp = enemy.get("max_hp")
		var new_hp = int(old_hp * 1.50) # +50% HP
		enemy.set("max_hp", new_hp)
		enemy.set("current_hp", new_hp)

	if enemy.get("enemy_data") != null and enemy.enemy_data:
		enemy.enemy_data.touch_damage = int(enemy.enemy_data.touch_damage * 1.30) # +30% Damage

	if enemy.has_node("Sprite2D"):
		var sprite = enemy.get_node("Sprite2D") as Sprite2D
		sprite.modulate = Color(1.0, 0.8, 0.1, 1.0) # Golden elite glow

	elite_mutated.emit(enemy)
	return true

func _mutate_random_enemy() -> void:
	var tree = get_tree()
	if tree == null:
		return
	var enemies = tree.get_nodes_in_group("enemies")
	for e in enemies:
		if e is CharacterBody2D and e.get("is_elite") != true:
			mutate_enemy_to_elite(e)
			break

func _spawn_ancient_shard() -> void:
	var pos = Vector2(randf_range(100, 380), 200)
	ancient_shard_spawned.emit(pos)
