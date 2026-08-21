# Changelog - Starfall Frontier

## [0.2.0] - 2026-08-21

### Added
- **Phase 2.0 (Weapon Modifier Engine)**: `ModifierGenerator` with category compatibility filtering, seeded determinism, and dynamic stat resolution math.
- **Phase 2.1 (Item Rarity System)**: Data-driven `RarityData` table with weighted probabilities (Common 60% -> Mythic 0.1%), tier modifier bounds, and 10,000-roll statistical test.
- **Phase 2.2 (Weapon Categories & Special Effects)**: 4 original weapons (`plasma_cutter.tres`, `void_blade.tres`, `frost_rifle.tres`, `ember_staff.tres`), `projectile.tscn`, and `weapon_effect.gd` interface.
- **Phase 2.3 (Elemental Status Engine)**: `StatusEffectManager` supporting Burn DoT, Freeze slow, Shock chain lightning, Decay armor reduction, and Poison stacking.
- **Phase 2.4 (Extended Biomes)**: `BiomeData` registry (`Emberwild`, `Frostgrave`, `Verdant Abyss`) with hazard placement and 300-seed path validation.
- **Phase 2.5 (Integration & Regression Testing)**: Master test suite runner `test_phase2_runner.gd` with 0 regressions.

### Git Commits
- `phase-2.0-modifier-engine`
- `phase-2.1-rarity-system`
- `phase-2.2-weapon-categories`
- `phase-2.3-status-effects`
- `phase-2.4-extended-biomes`
- `phase-2.5-phase2-verification`
