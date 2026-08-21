# Changelog - Starfall Frontier

## [0.3.0] - 2026-08-21

### Added
- **Phase 3.0 (Persistent Hub World)**: Interactive Hub Base (`hub.tscn`), Hub level evolution (Levels 1-4: Outpost -> Workshop -> Station -> Base), and atomic upgrade transactions.
- **Phase 3.1 (Forge Crafting Station)**: Data-driven `RecipeData` and `CraftingManager` with material validation preventing resource loss on failure.
- **Phase 3.2 (Research Lab Tree)**: `ProgressionTree` with dependency chain prerequisite validation and Star-Shards unlocks.
- **Phase 3.3 (Companion Drone System)**: Autonomous `CompanionBase` drones (Miner, Combat, Support) with smooth player follow physics.
- **Phase 3.4 (Origin Archetypes)**: 5 Character Origins (`Vanguard`, `Scout`, `Engineer`, `Mystic`, `Nomad`) with dynamic stat modifier calculation.
- **Phase 3.5 (Persistence Integration)**: Save Manager schema v2 migration, atomic backup recovery, and resource security upon extraction.
- **Phase 3.6 (Integration & Regression Testing)**: Master test runner `test_phase3_runner.gd` with 0 regressions.

### Git Commits
- `phase-3.0-persistent-hub`
- `phase-3.1-forge-crafting`
- `phase-3.2-research-progression`
- `phase-3.3-companion-drones`
- `phase-3.4-origin-archetypes`
- `phase-3.5-persistence-integration`
- `phase-3.6-phase3-verification`
