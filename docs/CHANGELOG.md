# Changelog - Starfall Frontier

## [0.1.0] - 2026-08-21

### Added
- Created complete Phase 1 project foundation for **Starfall Frontier**.
- Configured Godot 4 `project.godot` with 480x270 pixel-art resolution settings and input mapping bindings (`move_left`, `move_right`, `jump`, `dash`, `attack`, `interact`, `ability`).
- Implemented core Autoload singletons:
  - `EventBus` (`scripts/core/event_bus.gd`) for decoupled game signals.
  - `GameManager` (`scripts/core/game_manager.gd`) for centralized state machine management.
- Built data resource architectures: `WeaponData`, `ItemData`, `EnemyData`.
- Implemented `CharacterBody2D` Player Controller featuring coyote time (0.15s), jump buffering (0.1s), invincible dash, and attack triggers.
- Implemented reusable `Hitbox` and `Hurtbox` combat components.
- Implemented "Ash Beetle" original biome enemy with state machine (`IDLE`, `PATROL`, `CHASE`, `ATTACK`, `DEAD`), damage flashing, floating combat text, and loot drop generation.
- Implemented deterministic seeded `RoomGenerator` with platform tile building, hazard placement, and portal creation.
- Implemented Loot Drop entity (`loot_drop.gd`) with magnet pickup logic and inventory integration.
- Implemented complete UI overlay suite: HUD (HP, Energy, Active Weapon, Loot counter), Main Menu, and Game Over / Restart dialog.
- Added context documentation suite: `AI_CONTEXT.md`, `PROGRESS.md`, `ROADMAP.md`, `ARCHITECTURE.md`, `GAME_DESIGN.md`, `BALANCE.md`, `CHANGELOG.md`.

### Tests
- Player Movement & Dash Physics: PASS
- Combat Hitbox/Hurtbox Damage & Knockback: PASS
- Enemy FSM & Loot Dropping: PASS
- Seeded Procedural Room Generation: PASS
- HUD Status Update & Game Over Loop: PASS
