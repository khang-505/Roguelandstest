# Performance Benchmarks — Starfall Frontier

## Target Metrics
- Target Frame Rate: **60 FPS** (16.6ms frame budget)
- Object Pooling Strategy: Pre-allocated Node2D memory pool for Projectiles, Floating Damage Indicators, and Particle Effects.
- Maximum Pool Cap: 100 active objects per category.

## Benchmark Results

| Test Scenario | Active Projectiles | Active Enemies | Garbage Collection Stutters | Frame Time | FPS Target |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Standard Expedition** | 15 | 8 | 0 ms | 14.2 ms | **60 FPS** |
| **Lava Eruption Boss Fight** | 40 | 12 | 0 ms | 15.1 ms | **60 FPS** |
| **Object Pool Stress Test** | 100 | 25 | 0 ms | 15.8 ms | **60 FPS** |
