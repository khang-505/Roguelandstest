# Changelog - Starfall Frontier

## [0.3.1] - 2026-08-21

### Added
- **Phase 3.1 (Forge & Data-Driven Recipe Crafting Station)**:
  - Created `RecipeData` data class ([recipe_data.gd](file:///d:/DULIEU/lamgame/Roguelands/scripts/data/recipe_data.gd)) specifying material requirements, output item, required hub level, and research prerequisites.
  - Implemented `CraftingManager` ([crafting_manager.gd](file:///d:/DULIEU/lamgame/Roguelands/scripts/crafting/crafting_manager.gd)) with atomic validation logic preventing material consumption if requirements or prerequisites fail.
  - Created Forge Crafting UI dialog ([crafting_ui.tscn](file:///d:/DULIEU/lamgame/Roguelands/scenes/ui/crafting_ui.tscn)).
  - Added unit test suite [test_phase3_1.gd](file:///d:/DULIEU/lamgame/Roguelands/tests/test_phase3_1.gd).

### Git Commits
- `phase-3.1-forge-crafting`
