# Changelog - Starfall Frontier

## [0.3.2] - 2026-08-21

### Added
- **Phase 3.2 (Research Lab & Meta-Progression Tree)**:
  - Created `ResearchNodeData` ([research_node_data.gd](file:///d:/DULIEU/lamgame/Roguelands/scripts/data/research_node_data.gd)) specifying research costs, prerequisites, hub levels, and stat targets (`max_hp`, `weapon_damage`, `magnet_radius`).
  - Implemented `ProgressionTree` ([progression_tree.gd](file:///d:/DULIEU/lamgame/Roguelands/scripts/progression/progression_tree.gd)) with prerequisite dependency chain validation and atomic Star-Shards unlocks.
  - Created Research UI dialog ([research_ui.tscn](file:///d:/DULIEU/lamgame/Roguelands/scenes/ui/research_ui.tscn)).
  - Added unit test suite [test_phase3_2.gd](file:///d:/DULIEU/lamgame/Roguelands/tests/test_phase3_2.gd).

### Git Commits
- `phase-3.2-research-progression`
