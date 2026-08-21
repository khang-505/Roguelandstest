# Changelog - Starfall Frontier

## [0.4.1] - 2026-08-21

### Added
- **Phase 4.1 (Extraction Defense Challenge & Channel Timer)**:
  - Created `ExtractionBeacon` controller ([extraction_beacon.gd](file:///d:/DULIEU/lamgame/Roguelands/scripts/world/extraction_beacon.gd)) featuring explicit states (`INACTIVE`, `STARTING`, `CHANNELING`, `INTERRUPTED`, `COMPLETED`).
  - Configured 10-second channeling timer using delta-based elapsed timing.
  - Implemented defensive wave spawner triggering wave pressure during extraction.
  - Implemented idempotent reward transfer securing all run loot and currency to the persistent profile upon completion.
  - Added unit test suite [test_phase4_1.gd](file:///d:/DULIEU/lamgame/Roguelands/tests/test_phase4_1.gd).

### Git Commits
- `phase-4.1-extraction-defense`
