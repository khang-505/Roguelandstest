# Performance Benchmarks — Starfall Frontier

## Target Metrics
- Target Frame Rate: **60 FPS** (16.6ms frame budget)
- Object Pooling Strategy: Pre-allocated Node2D memory pool for Projectiles, Floating Damage Indicators, and Particle Effects.
- Maximum Pool Cap: 100 active objects per category.

## Benchmark Status
- **Baseline**: UNAVAILABLE (Live GPU/CPU frame profiling requires interactive Godot editor window execution).
- **Architecture**: `ObjectPool` engine (`scripts/core/object_pool.gd`) implemented with double-release protection and unit-tested in `tests/test_phase5_2.gd`.
