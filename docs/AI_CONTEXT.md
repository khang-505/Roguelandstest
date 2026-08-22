# AI Context — Starfall Frontier

## Project Overview
Starfall Frontier is an original 2D side-scrolling action roguelite RPG built in Godot Engine 4.x using 100% GDScript.

## Core Architecture
- **Autoload Singletons**: `EventBus`, `GameManager`, `WorldManager`, `SaveManager`
- **Main Controller**: `scripts/core/main.gd` (Manages scene stack, UILayer CanvasLayer, WorldLayer)
- **Object Pool**: `scripts/core/object_pool.gd` (Static pre-allocated node pool)
- **Data Resources**: `WeaponData`, `OriginData`, `RarityData`, `EnemyData`, `ContractData`, `BiomeData`, `RecipeData`
- **Player**: `scripts/player/player_controller.gd` (Physics, dash i-frames, origin stats, weapon switching)
- **Enemies**: `EnemyBase` FSM with 5 concrete classes (`AshBeetle`, `FrostStalker`, `VoidLurker`, `IronGolem`, `SwarmDrone`)
- **UI System**: CanvasLayer overlays (`main_menu.tscn`, `hud.tscn`, `inventory_ui.tscn`, `game_over_screen.tscn`)

## Key Controls
- `A` / `D` or `Arrow Keys`: Move Left / Right
- `Space` or `W`: Jump / Double Jump
- `Shift` or `J`: Dash (invulnerable, costs energy)
- `K` / `Z` / `Left Mouse`: Weapon Attack
- `Q` / `Tab`: Switch Weapon
- `E`: Interact (Station / Beacon)
- `I`: Toggle Inventory & Profile
