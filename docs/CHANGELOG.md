# Changelog - Starfall Frontier

## [0.5.2] - 2026-08-21

### Added
- **Phase 5.2 (Object Pooling Performance Engine)**:
  - Implemented `ObjectPool` ([object_pool.gd](file:///d:/DULIEU/lamgame/Roguelands/scripts/core/object_pool.gd)) with pre-allocation for high-frequency objects (projectiles, floating numbers, VFX particles).
  - Implemented double-release protection guarding against memory pool corruption.
  - Added performance benchmarks in [PERFORMANCE.md](file:///d:/DULIEU/lamgame/Roguelands/docs/PERFORMANCE.md) guaranteeing 60 FPS frame rate target.
  - Added unit test suite [test_phase5_2.gd](file:///d:/DULIEU/lamgame/Roguelands/tests/test_phase5_2.gd).

### Git Commits
- `phase-5.2-object-pooling`
