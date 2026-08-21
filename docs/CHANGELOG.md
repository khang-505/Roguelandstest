# Changelog - Starfall Frontier

## [0.2.1] - 2026-08-21

### Added
- **Phase 2.1 (Item Rarity System)**:
  - Implemented `RarityData` ([rarity_data.gd](file:///d:/DULIEU/lamgame/Roguelands/scripts/data/rarity_data.gd)) with weighted probabilities:
    - Common: 60.0%
    - Uncommon: 25.0%
    - Rare: 10.0%
    - Epic: 4.0%
    - Legendary: 0.9%
    - Mythic: 0.1%
  - Configured modifier count bounds per tier (Common: 0-1, Uncommon: 1-2, Rare: 2, Epic: 2-3, Legendary: 3-4, Mythic: 4-5).
  - Added quality stat multipliers (`1.0x` -> `2.5x`) and visual hex color codes (`#A0A0A0` -> `#FF2050`).
  - Implemented automated 10,000-roll statistical distribution test suite ([test_phase2_1.gd](file:///d:/DULIEU/lamgame/Roguelands/tests/test_phase2_1.gd)).

### Git Commits
- `phase-2.1-rarity-system`
