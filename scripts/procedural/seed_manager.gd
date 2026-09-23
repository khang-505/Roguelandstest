# scripts/procedural/seed_manager.gd
class_name SeedManager
extends Node

## Deterministic RNG Seed Manager for procedural planet generation.

const GENERATOR_VERSION: int = 1

static var current_seed: int = 1337
static var rng: RandomNumberGenerator = RandomNumberGenerator.new()

static func initialize_seed(p_seed: int = -1) -> int:
	if p_seed == -1:
		current_seed = randi() % 1000000
	else:
		current_seed = p_seed
	rng.seed = current_seed
	print("[SeedManager] RUN SEED INITIALIZED: %d (v%d)" % [current_seed, GENERATOR_VERSION])
	return current_seed

static func get_region_seed(planet_seed: int, region_index: int) -> int:
	return abs((planet_seed * 31 + region_index * 997) % 1000000)

static func get_rng() -> RandomNumberGenerator:
	return rng

static func randf_range(from: float, to: float) -> float:
	return rng.randf_range(from, to)

static func randi_range(from: int, to: int) -> int:
	return rng.randi_range(from, to)

static func randf() -> float:
	return rng.randf()
