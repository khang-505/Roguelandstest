# Changelog - Starfall Frontier

## [0.1.0] - 2026-08-21

### Added
- **Phase 1.0 (Foundation)**: Project infrastructure, `project.godot`, documentation core, `GameManager`, `EventBus`, `WorldManager`, `SaveManager`, and data model resources (`WeaponData`, `ItemData`, `EnemyData`, `LootTableData`).
- **Phase 1.1 (Player Slice)**: `CharacterBody2D` platformer movement controller with acceleration, deceleration, variable jump, coyote time (0.15s), jump buffering (0.10s), invincible dash (0.2s duration, 0.8s cooldown), facing direction, and camera follow scene (`player.tscn`).
- **Phase 1.2 (Combat Slice)**: Component-based `Hitbox` and `Hurtbox` systems with armor mitigation, critical hit calculation, knockback vectors, and "Ash Beetle" enemy AI state machine (`IDLE`, `PATROL`, `CHASE`, `ATTACK`, `STUNNED`, `DEAD`).
- **Phase 1.3 (Procedural World Slice)**: Deterministic seeded `RoomGenerator` creating platforms, player spawn markers, extraction portal, enemy spawners, and loot positions with topological connectivity validation tested across 100 seeds.
- **Phase 1.4 (Game Loop Slice)**: `LootDrop` resource entity with magnet attraction logic, `HUDController` overlay showing real-time player stats, `MainMenu` dialog, `GameOverScreen` summary, and `main.gd` master orchestration.
- **Phase 1.5 (Verification & Documentation)**: Comprehensive test suite runner (`test_master_runner.gd`) executing unit tests across all Phase 1 modules.

### Git Commits
- `phase-1.0-foundation`
- `phase-1.1-player`
- `phase-1.2-combat`
- `phase-1.3-procedural-world`
- `phase-1.4-game-loop`
- `phase-1.5-verification`
