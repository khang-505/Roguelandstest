# Changelog - Starfall Frontier

## [0.3.3] - 2026-08-21

### Added
- **Phase 3.3 (Companion Drone System)**:
  - Created `CompanionData` ([companion_data.gd](file:///d:/DULIEU/lamgame/Roguelands/scripts/data/companion_data.gd)) specifying drone types (`MINER`, `COMBAT`, `SUPPORT`), follow distance, activation range, and cooldowns.
  - Implemented `CompanionBase` ([companion_base.gd](file:///d:/DULIEU/lamgame/Roguelands/scripts/companions/companion_base.gd)) featuring smooth follow physics, target detection, and autonomous drone behaviors.
  - Created Companion Drone scene ([companion_drone.tscn](file:///d:/DULIEU/lamgame/Roguelands/scenes/companions/companion_drone.tscn)).
  - Added unit test suite [test_phase3_3.gd](file:///d:/DULIEU/lamgame/Roguelands/tests/test_phase3_3.gd).

### Git Commits
- `phase-3.3-companion-drones`
