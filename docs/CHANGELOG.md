# Changelog - Starfall Frontier

## [0.2.0] - 2026-08-21

### Added
- **Phase 2.0 (Weapon Modifier Engine)**:
  - Implemented `ModifierGenerator` ([modifier_generator.gd](file:///d:/DULIEU/lamgame/Roguelands/scripts/combat/modifier_generator.gd)) supporting data-driven affix definitions (`damage_mult`, `damage_add`, `crit_chance`, `attack_speed`, `lifesteal`, `knockback`, `proj_speed`).
  - Added seeded RNG determinism for modifier selection and value rolling.
  - Implemented category compatibility filtering (preventing ranged-only affixes on melee weapons).
  - Updated `WeaponData` ([weapon_data.gd](file:///d:/DULIEU/lamgame/Roguelands/scripts/data/weapon_data.gd)) with dynamic stat resolution methods (`get_modified_damage()`, `get_modified_attack_speed()`, `get_modified_critical_chance()`, `get_modified_projectile_speed()`, `get_modified_knockback()`, `get_lifesteal_percent()`).
  - Added modifier stacking math rules in `docs/BALANCE.md`.
  - Added automated test suite [test_phase2_0.gd](file:///d:/DULIEU/lamgame/Roguelands/tests/test_phase2_0.gd).

### Git Commits
- `phase-2.0-modifier-engine`
