# Changelog - Starfall Frontier

## [0.4.2] - 2026-08-21

### Added
- **Phase 4.2 (World Instability Meter Mechanic)**:
  - Created `InstabilityManager` ([instability_manager.gd](file:///d:/DULIEU/lamgame/Roguelands/scripts/world/instability_manager.gd)) with rate escalation and strict [0.0%, 100.0%] clamping.
  - Implemented Elite Enemy Mutation applying +50% HP and +30% Touch Damage with `is_elite` one-shot guard preventing duplicate mutations.
  - Implemented Ancient Shard node spawning at $\ge 75\%$ instability.
  - Added unit test suite [test_phase4_2.gd](file:///d:/DULIEU/lamgame/Roguelands/tests/test_phase4_2.gd).

### Git Commits
- `phase-4.2-world-instability`
