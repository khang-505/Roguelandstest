# AI Context - Starfall Frontier

## Project Overview
- **Project Name**: Starfall Frontier
- **Genre**: 2D Side-Scrolling Action Roguelite RPG
- **Target Engine**: Godot 4.x (GDScript)
- **Base Resolution**: 480x270 (Pixel Art 16:9), Integer Scaling supported
- **Target FPS**: 60 FPS
- **Core Loop**: Hub Base -> Expedition Loadout & Contracts -> Procedural Biome Deployment -> Exploration & Resource Gathering -> Fast Action Combat & Status Effects -> Biome Guardian Boss -> Extraction Defense -> Persistent Meta Progression -> Hub Base

## Current State
- **Current Phase**: Phase 5 — Relic Fusion System, Co-op Multiplayer Architecture & Polish
- **Current Milestone**: Phase 5.4 — Final Master Integration & Verification Suite (100% COMPLETE)
- **Status**: Release v1.0.0 Complete & Pushed to GitHub (`https://github.com/khang-505/Roguelandstest.git`)

## Key Technical Decisions
- **Autoload Architecture**: `GameManager` (`res://scripts/core/game_manager.gd`) manages state machine transitions and run data. `EventBus` (`res://scripts/core/event_bus.gd`) handles decoupled signals across scenes. `SaveManager` handles atomic profile saving & schema v2 migration.
- **Physics & Combat**: Uses `CharacterBody2D` with custom gravity, acceleration, coyote time (0.15s), jump buffering (0.1s), invincible dash, weapon modifiers, and 5 elemental status effects (`status_effect_manager.gd`).
- **Data-Driven Content**: Weapon, Item, Recipe, Research, Companion, Origin, Boss, Contract, and Relic Fusion stats are modeled using Godot `Resource` scripts in `scripts/data/` and saved as `.tres` files.
- **Procedural Generation**: Deterministic seed-based room topology generator across 4 biomes (*Emberwild*, *Cryo Tundra*, *Toxic Bio-Dome*, *Void Spire*).
- **Meta-Progression & Base Evolution**: Persistent Hub Base (Levels 1-4), Forge Crafting Station, Research Lab Tree, Autonomous Companion Drones, 5 Origin Archetypes.
- **High-Stakes Systems**: Multi-phase Biome Guardian (*The Molten Warden*), 10s Extraction Beacon defense, World Instability escalation (0-100%) with Elite enemy mutations (+50% HP, +30% Damage), Expedition Contracts with reward multipliers.
- **Relic Fusion & Co-op**: Fusion matrix for combat singularities, server-authoritative 1-4 player co-op (`network_manager.gd`), 5s revive channeling (`revive_system.gd`), pre-allocated `ObjectPool` engine for 60 FPS performance, and persistent accessibility options (`settings_menu.gd`).

## Directory Map
- `docs/` — Project design, progress, context, balance, performance, changelog docs
- `scripts/core/` — GameManager, EventBus, SaveManager, MainController, ObjectPool, RewardManager
- `scripts/player/` — Player physics controller & stats
- `scripts/combat/` — Hitbox, Hurtbox, weapon components, status effect manager, relic fusion manager
- `scripts/enemies/` — Enemy AI FSM & enemy behaviors
- `scripts/bosses/` — BossBase FSM & MoltenWarden guardian implementation
- `scripts/procedural/` — Seeded level & room generator across 4 biomes
- `scripts/world/` — Level stage, extraction beacon, instability manager
- `scripts/hub/` — StationBase, HubController
- `scripts/crafting/` — CraftingManager & recipe processing
- `scripts/progression/` — ProgressionTree & research lab processing
- `scripts/companions/` — CompanionBase & drone behaviors
- `scripts/multiplayer/` — NetworkManager, ReviveSystem
- `scripts/ui/` — HUD, main menu, pause, game over, crafting UI, research UI, origin select UI, contract UI, relic fusion UI, settings menu
- `scenes/` — Scene hierarchy (.tscn)
- `data/` — Data resources (.tres)
- `tests/` — Automated unit test suites (25 test modules)
