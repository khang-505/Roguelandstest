# Changelog - Starfall Frontier

## [0.5.0] - 2026-08-21

### Added
- **Phase 5.0 (Relic Fusion System - Originality Mechanic 2)**:
  - Created `RelicFusionManager` ([relic_fusion_manager.gd](file:///d:/DULIEU/lamgame/Roguelands/scripts/combat/relic_fusion_manager.gd)) with data-driven recipes combining raw relic fragments into combat singularities.
  - Implemented Atomic Fragment Transactions: input fragments deducted, fused relic output granted, and profile saved atomically.
  - Added combat singularity burst execution:
    - `Molten Singularity` (Pulls hostiles inward and applies Burn status).
    - `Absolute Zero Pulse` (Freezes hostiles and chains static shock damage).
    - `Toxic Spore Cataclysm` (Applies 5 Poison stacks to all room hostiles).
  - Created Relic Fusion UI dialog ([relic_fusion_ui.tscn](file:///d:/DULIEU/lamgame/Roguelands/scenes/ui/relic_fusion_ui.tscn)).
  - Added unit test suite [test_phase5_0.gd](file:///d:/DULIEU/lamgame/Roguelands/tests/test_phase5_0.gd).

### Git Commits
- `phase-5.0-relic-fusion`
