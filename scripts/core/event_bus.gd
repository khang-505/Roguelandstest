# scripts/core/event_bus.gd
class_name EventBusSingleton
extends Node

## Centralized Event Bus for decoupled signal handling across Starfall Frontier subsystems.

signal player_hp_changed(current_hp: int, max_hp: int)
signal player_energy_changed(current_energy: float, max_energy: float)
signal player_died()
signal player_respawned()

signal enemy_spawned(enemy_node: Node2D)
signal enemy_died(enemy_pos: Vector2, enemy_type: String)

signal damage_dealt(target_pos: Vector2, damage_amount: int, is_crit: bool, damage_type: String)
signal loot_collected(item_id: String, item_name: String, amount: int)

signal game_state_changed(old_state: int, new_state: int)
signal world_generated(world_seed: int, world_name: String)
signal request_restart()
signal request_hub_return()
