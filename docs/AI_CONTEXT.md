# AI Context - Starfall Frontier

## Project Overview
- **Project Name**: Starfall Frontier
- **Genre**: 2D Side-Scrolling Action Roguelite RPG
- **Target Engine**: Godot 4.x (GDScript)
- **Base Resolution**: 480x270 (Pixel Art 16:9), Integer Scaling supported
- **Target FPS**: 60 FPS
- **Core Loop**: Hub -> Loadout -> Procedural Planet Deployment -> Exploration & Resource Gathering -> Fast Action Combat -> Boss Guardian -> Extraction / Death -> Meta Progression -> Hub

## Current State
- **Current Phase**: Phase 1 — Foundation & First Playable Slice
- **Current Milestone**: Milestone 1.1 — Godot Project Architecture & Core Gameplay Prototype
- **Current Task**: Build complete functional prototype slice (Player, Combat, Enemy AI, Procedural Room, Loot, HUD, Game Loop)
- **Status**: Active Implementation

## Key Technical Decisions
- **Autoload Architecture**: `GameManager` (`res://scripts/core/game_manager.gd`) manages state machine transitions and run data. `EventBus` (`res://scripts/core/event_bus.gd`) handles decoupled signals across scenes.
- **Physics & Combat**: Uses `CharacterBody2D` with custom gravity, acceleration, coyote time (0.15s), jump buffering (0.1s), and invincible dash. Hitbox/Hurtbox component system for combat decoupling.
- **Data-Driven Content**: Weapon, Item, and Enemy stats are modeled using Godot `Resource` scripts in `scripts/data/` and saved as `.tres` files.
- **Procedural Generation**: Deterministic seed-based room topology generator using `RandomNumberGenerator` for reproducible worlds.

## Directory Map
- `docs/` — Project design, progress, context, architecture docs
- `scripts/core/` — GameManager, EventBus, state machines
- `scripts/player/` — Player physics controller & stats
- `scripts/combat/` — Hitbox, Hurtbox, weapon components
- `scripts/enemies/` — Enemy AI FSM & enemy behaviors
- `scripts/procedural/` — Seeded level & room generator
- `scripts/inventory/` — Item resources and loot drop entities
- `scripts/ui/` — HUD, main menu, pause, game over UI
- `scenes/` — Scene hierarchy (.tscn)
- `data/` — Data resources (.tres)
