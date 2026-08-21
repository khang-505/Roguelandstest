# Changelog - Starfall Frontier

## [1.0.0] - 2026-08-21

### Added
- **Phase 5.0 (Relic Fusion System)**: Created `RelicFusionManager` and `RelicFusionUI` with atomic fragment transactions, Molten Singularity, Absolute Zero Pulse, and Toxic Spore Cataclysm.
- **Phase 5.1 (Co-op Multiplayer Architecture & Revive)**: Created `NetworkManager` for 1-4 players with server-authoritative state sync, offline single-player mode, and 5-second revive channeling (`revive_system.gd`).
- **Phase 5.2 (Object Pooling Engine)**: Implemented pre-allocated `ObjectPool` memory engine for 60 FPS performance and [PERFORMANCE.md](file:///d:/DULIEU/lamgame/Roguelands/docs/PERFORMANCE.md).
- **Phase 5.3 (Accessibility & UI Polish)**: Implemented persistent `SettingsMenu` supporting screen shake toggle, flash reduction, colorblind indicators, audio sliders, and aim assistance.
- **Phase 5.4 (Master Integration Suite)**: Master test runner `test_phase5_runner.gd` verifying 0 regressions across all 25 test modules.

### Git Commits
- `phase-5.0-relic-fusion`
- `phase-5.1-coop-architecture`
- `phase-5.2-object-pooling`
- `phase-5.3-accessibility`
- `phase-5.4-master-integration`
