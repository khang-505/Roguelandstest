# Changelog - Starfall Frontier

## [0.3.0] - 2026-08-21

### Added
- **Phase 3.0 (Persistent Hub World & Base Level Evolution)**:
  - Implemented `StationBase` ([station_base.gd](file:///d:/DULIEU/lamgame/Roguelands/scripts/hub/station_base.gd)) for reusable interactive station points (Forge, Research Lab, Companion Station, Deployment Console).
  - Implemented `HubController` ([hub_controller.gd](file:///d:/DULIEU/lamgame/Roguelands/scripts/hub/hub_controller.gd)) handling Hub levels 1–4 evolution:
    - Level 1: Outpost
    - Level 2: Workshop (100 Credits, 10 Shards)
    - Level 3: Station (300 Credits, 25 Shards)
    - Level 4: Base (1000 Credits, 75 Shards)
  - Implemented atomic transaction checks preventing currency deduction on failed upgrades.
  - Created playable 2D Hub scene ([hub.tscn](file:///d:/DULIEU/lamgame/Roguelands/scenes/hub/hub.tscn)).
  - Added unit test suite [test_phase3_0.gd](file:///d:/DULIEU/lamgame/Roguelands/tests/test_phase3_0.gd).

### Git Commits
- `phase-3.0-persistent-hub`
