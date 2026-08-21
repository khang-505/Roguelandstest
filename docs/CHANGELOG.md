# Changelog - Starfall Frontier

## [0.4.0] - 2026-08-21

### Added
- **Phase 4.0 (Biome Guardian Boss System & Multi-Phase FSM)**:
  - Created `BossBase` architecture ([boss_base.gd](file:///d:/DULIEU/lamgame/Roguelands/scripts/bosses/boss_base.gd)) separating behavioral states (`INTRO`, `IDLE`, `COMBAT`, `TRANSITION`, `STUNNED`, `DEAD`) from phase thresholds (`PHASE_1`, `PHASE_2`, `PHASE_3`).
  - Created Emberwild Biome Guardian *The Molten Warden* ([molten_warden.gd](file:///d:/DULIEU/lamgame/Roguelands/scripts/bosses/molten_warden.gd)):
    - Phase 1: Heavy melee slams (25 damage).
    - Phase 2 ($\le 66\%$ HP): Spawns lava pool hazards in arena.
    - Phase 3 ($\le 33\%$ HP): Enraged attack speed (+50%) and eruption burn burst.
  - Implemented boss death cleanup freeing hazards, stopping attack timers, and emitting `boss_defeated` event.
  - Added unit test suite [test_phase4_0.gd](file:///d:/DULIEU/lamgame/Roguelands/tests/test_phase4_0.gd).

### Git Commits
- `phase-4.0-boss-system`
