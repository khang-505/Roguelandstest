# Technical Architecture - Starfall Frontier

## Overview
Starfall Frontier is built using Godot 4.x (GDScript) with a data-driven, component-oriented, state-machine based architecture.

## Engine Configuration
- **Resolution**: 480x270 Base Viewport (16:9 aspect ratio)
- **Display Scaling**: 2D stretch mode with `canvas_items` filter, integer scaling to fit 1080p / 4K displays seamlessly.
- **Frame Rate**: Fixed 60 FPS update rate for physics, variable rendering.

## System Architecture

```text
               +-----------------------+
               |     GameManager       | (Autoload Singleton)
               +-----------+-----------+
                           |
            +--------------+--------------+
            |                             |
 +----------v----------+       +----------v----------+
 |      EventBus       |       |     SaveManager     |
 +----------+----------+       +---------------------+
            |
  +---------+---------+-------------------+-------------------+
  |                   |                   |                   |
+-v----------+  +-----v------+      +-----v------+      +-----v------+
| Player Node|  | Enemy Node |      | Procedural |      |    HUD /   |
|Controller  |  | State FSM  |      | Generator  |      | UI Overlay |
+------------+  +------------+      +------------+      +------------+
```

## Key Subsystems

### 1. Game State Machine (`GameManager`)
States: `BOOT`, `MAIN_MENU`, `CHARACTER_CREATION`, `HUB`, `WORLD_SELECTION`, `WORLD_GENERATION`, `EXPLORATION`, `COMBAT`, `EXTRACTION`, `DEATH`, `PAUSE`.

### 2. Event Bus (`EventBus`)
Global signal hub facilitating loose coupling between combat components, UI, score updates, loot spawns, and state triggers.

### 3. Combat Subsystem (Hitbox / Hurtbox)
- **`Hitbox` (`Area2D`)**: Deals damage on overlap. Holds `damage`, `damage_type`, `crit_chance`, `knockback_vector`, and owner team (`PLAYER` vs `ENEMY`).
- **`Hurtbox` (`Area2D`)**: Receives damage from matching hitboxes. Controls invulnerability frames, armor mitigation, health deduction, and signals hit reactions.

### 4. Data-Driven Systems
Content items (`WeaponData`, `ItemData`, `EnemyData`) inherit from `Resource`. Gameplay parameters are loaded from data files (`.tres` / `.json`), allowing endless variation without editing script logic.

### 5. Deterministic Procedural World Generation
`RoomGenerator` initializes a `RandomNumberGenerator` with a standard integer seed. Given seed `S`, room layout, platforms, resource nodes, and enemy spawners generate identically across client machines.
