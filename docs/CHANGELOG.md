# Changelog - Starfall Frontier

## [0.5.1] - 2026-08-21

### Added
- **Phase 5.1 (Co-op Multiplayer Architecture & Revive System)**:
  - Created `NetworkManager` ([network_manager.gd](file:///d:/DULIEU/lamgame/Roguelands/scripts/multiplayer/network_manager.gd)) establishing host/client server-authoritative state sync (1-4 players) while maintaining offline-capable single-player compatibility.
  - Implemented `ReviveSystem` ([revive_system.gd](file:///d:/DULIEU/lamgame/Roguelands/scripts/multiplayer/revive_system.gd)) managing Downed state (`ALIVE`, `DOWNED`, `BEING_REVIVED`, `REVIVED`, `DEAD`) and 5-second revive channeling.
  - Added unit test suite [test_phase5_1.gd](file:///d:/DULIEU/lamgame/Roguelands/tests/test_phase5_1.gd).

### Git Commits
- `phase-5.1-coop-architecture`
