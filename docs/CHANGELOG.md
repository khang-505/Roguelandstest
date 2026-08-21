# Changelog - Starfall Frontier

## [0.2.3] - 2026-08-21

### Added
- **Phase 2.3 (Elemental Status Engine)**:
  - Implemented `StatusEffectManager` ([status_effect_manager.gd](file:///d:/DULIEU/lamgame/Roguelands/scripts/combat/status_effect_manager.gd)):
    - `Burn`: 0.5s DoT tick rate, duration refresh on re-application.
    - `Freeze`: 40% movement speed reduction.
    - `Shock`: Static chain lightning up to 3 targets, max 90px jump distance, 30% falloff per jump.
    - `Decay`: 50% armor reduction.
    - `Poison`: Stackable DoT up to max 5 stacks cap.
  - Implemented memory leak protection and safe garbage collection on target `tree_exiting` signal.
  - Added automated test suite [test_phase2_3.gd](file:///d:/DULIEU/lamgame/Roguelands/tests/test_phase2_3.gd).

### Git Commits
- `phase-2.3-status-effects`
