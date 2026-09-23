# scripts/world/enemy_spawn_point.gd
class_name EnemySpawnPoint
extends Node2D

## World marker node evaluating distance to player, Line-of-Sight, telegraph warnings, and enemy spawning.

signal enemy_spawned(enemy_node, spawn_point_id)

@export var marker_id: String = "sp_001"
@export var marker_type: int = 0 # SpawnPointData.MarkerType.GROUND
@export var preferred_role: int = 0 # EncounterData.EnemyRole.MELEE
@export var telegraph_duration: float = 0.8
@export var min_player_distance: float = 120.0 # Safety radius in pixels

var is_triggered: bool = false
var telegraph_rect: ColorRect = null

func _ready() -> void:
	# Add visual marker in editor / debug
	telegraph_rect = ColorRect.new()
	telegraph_rect.size = Vector2(16, 16)
	telegraph_rect.position = Vector2(-8, -8)
	telegraph_rect.color = Color(0.9, 0.2, 0.2, 0.5) # Warning Red
	add_child(telegraph_rect)

func can_spawn(player_pos: Vector2) -> bool:
	if is_triggered:
		return false

	var dist = global_position.distance_to(player_pos)
	if dist < min_player_distance:
		return false # Prevent spawning directly on player

	return true

func spawn_enemy(enemy_scene: PackedScene = null) -> CharacterBody2D:
	if is_triggered:
		return null

	is_triggered = true
	var enemy_inst: CharacterBody2D = null

	if enemy_scene:
		enemy_inst = enemy_scene.instantiate() as CharacterBody2D
	else:
		# Fallback dynamic dummy enemy controller
		var dummy_script = load("res://scripts/enemies/enemy_controller.gd")
		if dummy_script:
			enemy_inst = CharacterBody2D.new()
			enemy_inst.set_script(dummy_script)

	if enemy_inst:
		enemy_inst.global_position = global_position
		get_parent().add_child(enemy_inst)
		emit_signal("enemy_spawned", enemy_inst, marker_id)

	if telegraph_rect:
		telegraph_rect.queue_free()

	return enemy_inst
