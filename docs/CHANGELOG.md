# Changelog - Starfall Frontier

## [0.4.0] - 2026-08-21

### Added
- **Phase 4.0 (Biome Guardian Boss System)**: Created `BossBase` architecture, Emberwild Guardian *The Molten Warden* (`molten_warden.gd`), multi-phase thresholds (Phases 1-3), enraged speed mode, lava hazards, and boss death cleanup.
- **Phase 4.1 (Extraction Defense Challenge)**: Implemented 10-second channeling `ExtractionBeacon`, defensive enemy wave spawner, and idempotent reward transfer.
- **Phase 4.2 (World Instability Meter)**: Implemented `InstabilityManager` with 0-100% rate escalation, Elite Enemy Mutations (+50% HP, +30% Damage), and Ancient Shard spawning.
- **Phase 4.3 (Expedition Contracts)**: Created `ContractData` and `ContractSelectUI` supporting `No Healing` (1.8x Credits), `Speed Run` (2.0x Shards), and `Melee Only` (2.5x Loot Quality) contracts.
- **Phase 4.4 (Reward Integration)**: Centralized `RewardManager` with idempotent multiplier calculation preventing double multiplication.
- **Phase 4.5 (Integration & Regression Testing)**: Master test runner `test_phase4_runner.gd` verifying 0 regressions across all 21 test modules.

### Git Commits
- `phase-4.0-boss-system`
- `phase-4.1-extraction-defense`
- `phase-4.2-world-instability`
- `phase-4.3-expedition-contracts`
- `phase-4.4-reward-integration`
- `phase-4.5-phase4-verification`
