# scripts/procedural/boss_arena_generator.gd
class_name BossArenaGenerator
extends Resource

## Generator creating authored Boss Arenas with phase-shifting terrain, telegraph hazard zones, camera framing, and procedural variants.

static func generate_arena(
	boss_id: String,
	biome_id: String = "mining",
	seed_val: int = 12345
) -> Resource:
	var data_script = load("res://scripts/procedural/boss_arena_data.gd")
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_val
	
	if biome_id == "mining" or boss_id == "titan_excavator":
		return _create_mining_arena(data_script, rng)
	elif biome_id == "forest" or boss_id == "apex_bio_horror":
		return _create_forest_arena(data_script, rng)
	else:
		return _create_cave_arena(data_script, rng)

static func _create_mining_arena(data_script: Resource, rng: RandomNumberGenerator) -> Resource:
	var arena = data_script.new(
		"arena_mining_excavator", "titan_excavator", "mining",
		1, # MULTI_LEVEL
		1200.0, 750.0
	)
	
	arena.player_spawn = Vector2(120.0, 620.0)
	arena.boss_spawn = Vector2(980.0, 480.0)
	arena.camera_bounds = Rect2(0.0, 0.0, 1200.0, 750.0)
	
	arena.platforms = [
		{"id": "floor_main", "pos": Vector2(600.0, 680.0), "size": Vector2(1200.0, 40.0), "phase_unlocked": 1},
		{"id": "mid_elevator_left", "pos": Vector2(350.0, 480.0), "size": Vector2(200.0, 20.0), "phase_unlocked": 2},
		{"id": "mid_elevator_right", "pos": Vector2(850.0, 480.0), "size": Vector2(200.0, 20.0), "phase_unlocked": 2},
		{"id": "high_crane_platform", "pos": Vector2(600.0, 280.0), "size": Vector2(300.0, 20.0), "phase_unlocked": 3}
	]
	
	arena.hazards = [
		{"id": "drill_track_left", "type": "HAZARD_ZONE", "rect": Rect2(200.0, 640.0, 300.0, 40.0), "damage": 25.0, "telegraph": "red_flashing"},
		{"id": "drill_track_right", "type": "HAZARD_ZONE", "rect": Rect2(700.0, 640.0, 300.0, 40.0), "damage": 25.0, "telegraph": "red_flashing"},
		{"id": "laser_gate_center", "type": "LASER_GRID", "rect": Rect2(550.0, 480.0, 100.0, 200.0), "damage": 20.0, "phase_active": 2}
	]
	
	arena.safe_zones = [
		Rect2(100.0, 400.0, 150.0, 100.0),
		Rect2(950.0, 400.0, 150.0, 100.0),
		Rect2(500.0, 200.0, 200.0, 80.0)
	]
	
	arena.phase_objects = [
		{"id": "power_core_alpha", "type": "BREAKABLE_SHIELD_NODE", "pos": Vector2(350.0, 450.0), "hp": 100.0},
		{"id": "power_core_beta", "type": "BREAKABLE_SHIELD_NODE", "pos": Vector2(850.0, 450.0), "hp": 100.0}
	]
	
	return arena

static func _create_forest_arena(data_script: Resource, rng: RandomNumberGenerator) -> Resource:
	var arena = data_script.new(
		"arena_forest_canopy", "apex_bio_horror", "forest",
		3, # PLATFORM
		1400.0, 850.0
	)
	
	arena.player_spawn = Vector2(150.0, 700.0)
	arena.boss_spawn = Vector2(1100.0, 520.0)
	arena.camera_bounds = Rect2(0.0, 0.0, 1400.0, 850.0)
	
	arena.platforms = [
		{"id": "root_ground", "pos": Vector2(700.0, 760.0), "size": Vector2(1400.0, 40.0), "phase_unlocked": 1},
		{"id": "canopy_left", "pos": Vector2(400.0, 520.0), "size": Vector2(250.0, 20.0), "phase_unlocked": 2},
		{"id": "canopy_right", "pos": Vector2(1000.0, 520.0), "size": Vector2(250.0, 20.0), "phase_unlocked": 2},
		{"id": "high_arch_center", "pos": Vector2(700.0, 320.0), "size": Vector2(350.0, 20.0), "phase_unlocked": 3}
	]
	
	arena.hazards = [
		{"id": "spore_pool_basin", "type": "POISON_POOL", "rect": Rect2(450.0, 720.0, 500.0, 40.0), "damage": 15.0, "telegraph": "green_bubble"},
		{"id": "vine_trap_zone", "type": "VINE_SWEEP", "rect": Rect2(200.0, 500.0, 1000.0, 60.0), "damage": 22.0, "phase_active": 3}
	]
	
	arena.safe_zones = [
		Rect2(100.0, 460.0, 180.0, 100.0),
		Rect2(1120.0, 460.0, 180.0, 100.0)
	]
	
	arena.phase_objects = [
		{"id": "spore_nest_1", "type": "MINION_SPAWNER_NODE", "pos": Vector2(400.0, 490.0), "hp": 80.0},
		{"id": "spore_nest_2", "type": "MINION_SPAWNER_NODE", "pos": Vector2(1000.0, 490.0), "hp": 80.0}
	]
	
	return arena

static func _create_cave_arena(data_script: Resource, rng: RandomNumberGenerator) -> Resource:
	var arena = data_script.new(
		"arena_cave_vault", "core_custodian", "cave",
		5, # MACHINE
		1300.0, 800.0
	)
	
	arena.player_spawn = Vector2(140.0, 660.0)
	arena.boss_spawn = Vector2(1050.0, 480.0)
	arena.camera_bounds = Rect2(0.0, 0.0, 1300.0, 800.0)
	
	arena.platforms = [
		{"id": "vault_floor", "pos": Vector2(650.0, 720.0), "size": Vector2(1300.0, 40.0), "phase_unlocked": 1},
		{"id": "plasma_platform_1", "pos": Vector2(380.0, 500.0), "size": Vector2(220.0, 20.0), "phase_unlocked": 2},
		{"id": "plasma_platform_2", "pos": Vector2(920.0, 500.0), "size": Vector2(220.0, 20.0), "phase_unlocked": 2},
		{"id": "apex_crystal_perch", "pos": Vector2(650.0, 300.0), "size": Vector2(280.0, 20.0), "phase_unlocked": 3}
	]
	
	arena.hazards = [
		{"id": "electric_floor_grid", "type": "ELECTRIC_GRID", "rect": Rect2(300.0, 680.0, 700.0, 40.0), "damage": 20.0, "telegraph": "yellow_sparks"},
		{"id": "orbital_beam_sweep", "type": "BEAM_SWEEP", "rect": Rect2(100.0, 250.0, 1100.0, 400.0), "damage": 50.0, "phase_active": 3}
	]
	
	arena.safe_zones = [
		Rect2(100.0, 440.0, 160.0, 100.0),
		Rect2(1040.0, 440.0, 160.0, 100.0),
		Rect2(550.0, 240.0, 200.0, 80.0)
	]
	
	arena.phase_objects = [
		{"id": "shield_node_north", "type": "SHIELD_GENERATOR_PILLAR", "pos": Vector2(650.0, 270.0), "hp": 120.0}
	]
	
	return arena

static func apply_phase_terrain_shift(arena_data: Resource, target_phase: int) -> void:
	arena_data.current_phase_terrain = target_phase
	for plat in arena_data.platforms:
		var unlock_phase = plat.get("phase_unlocked", 1)
		plat["is_active"] = target_phase >= unlock_phase
		
	for haz in arena_data.hazards:
		if haz.has("phase_active"):
			haz["is_active"] = target_phase >= haz.get("phase_active", 1)
		else:
			haz["is_active"] = true
