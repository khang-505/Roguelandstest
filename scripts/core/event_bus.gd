# scripts/core/event_bus.gd
class_name EventBusSingleton
extends Node

## Centralized Event Bus for decoupled signal handling across Starfall Frontier subsystems.

@warning_ignore("unused_signal")
signal player_hp_changed(current_hp: int, max_hp: int)
@warning_ignore("unused_signal")
signal player_energy_changed(current_energy: float, max_energy: float)
@warning_ignore("unused_signal")
signal player_died()
@warning_ignore("unused_signal")
signal player_respawned()
@warning_ignore("unused_signal")
signal xp_gained(current_xp: int, max_xp: int, level: int)
@warning_ignore("unused_signal")
signal player_leveled_up(new_level: int)

@warning_ignore("unused_signal")
signal enemy_spawned(enemy_node: Node2D)
@warning_ignore("unused_signal")
signal enemy_died(enemy_pos: Vector2, enemy_type: String)

@warning_ignore("unused_signal")
signal damage_dealt(target_pos: Vector2, damage_amount: int, is_crit: bool, damage_type: String)
@warning_ignore("unused_signal")
signal loot_collected(item_id: String, item_name: String, amount: int)
@warning_ignore("unused_signal")
signal secret_discovered(secret_id: String, secret_type: String, pos: Vector2)

@warning_ignore("unused_signal")
signal game_state_changed(old_state: int, new_state: int)
@warning_ignore("unused_signal")
signal world_generated(world_seed: int, world_name: String)
@warning_ignore("unused_signal")
signal request_restart()
@warning_ignore("unused_signal")
signal request_hub_return()
