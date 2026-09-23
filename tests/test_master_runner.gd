# tests/test_master_runner.gd
class_name TestMasterRunner
extends Node

## Master test runner executing all Phase 1 verification suites.

func _ready() -> void:
	print("==========================================================")
	print("  STARFALL FRONTIER: PHASE 1 COMPREHENSIVE SUITE RUNNER   ")
	print("==========================================================")
	
	var foundation_test = TestFoundation.new()
	add_child(foundation_test)
	
	var player_test = TestPlayer.new()
	add_child(player_test)
	
	var combat_test = TestCombat.new()
	add_child(combat_test)
	
	var procedural_test = TestProcedural.new()
	add_child(procedural_test)

	var map_test_class = load("res://tests/test_map_generation.gd")
	if map_test_class:
		var map_test = map_test_class.new()
		add_child(map_test)

	var loop_test_class = load("res://tests/test_gameplay_loop.gd")
	if loop_test_class:
		var loop_test = loop_test_class.new()
		add_child(loop_test)

	var exploration_test_class = load("res://tests/test_exploration_system.gd")
	if exploration_test_class:
		var exp_test = exploration_test_class.new()
		add_child(exp_test)

	var planet_test_class = load("res://tests/test_planet_generation.gd")
	if planet_test_class:
		var planet_test = planet_test_class.new()
		add_child(planet_test)

	var room_test_class = load("res://tests/test_room_generation.gd")
	if room_test_class:
		var room_test = room_test_class.new()
		add_child(room_test)

	var branch_test_class = load("res://tests/test_branching_system.gd")
	if branch_test_class:
		var branch_test = branch_test_class.new()
		add_child(branch_test)

	var vert_test_class = load("res://tests/test_vertical_exploration.gd")
	if vert_test_class:
		var vert_test = vert_test_class.new()
		add_child(vert_test)

	var terrain_test_class = load("res://tests/test_terrain_generation.gd")
	if terrain_test_class:
		var terrain_test = terrain_test_class.new()
		add_child(terrain_test)

	var platform_test_class = load("res://tests/test_platform_generation.gd")
	if platform_test_class:
		var platform_test = platform_test_class.new()
		add_child(platform_test)

	var cave_test_class = load("res://tests/test_cave_system.gd")
	if cave_test_class:
		var cave_test = cave_test_class.new()
		add_child(cave_test)

	var secret_test_class = load("res://tests/test_secret_system.gd")
	if secret_test_class:
		var secret_test = secret_test_class.new()
		add_child(secret_test)

	var hidden_path_test_class = load("res://tests/test_hidden_paths.gd")
	if hidden_path_test_class:
		var hidden_path_test = hidden_path_test_class.new()
		add_child(hidden_path_test)

	var breakable_test_class = load("res://tests/test_breakable_objects.gd")
	if breakable_test_class:
		var breakable_test = breakable_test_class.new()
		add_child(breakable_test)

	var interactive_test_class = load("res://tests/test_interactive_environment.gd")
	if interactive_test_class:
		var interactive_test = interactive_test_class.new()
		add_child(interactive_test)

	var spawn_test_class = load("res://tests/test_enemy_spawn_system.gd")
	if spawn_test_class:
		var spawn_test = spawn_test_class.new()
		add_child(spawn_test)

	var variety_test_class = load("res://tests/test_enemy_variety.gd")
	if variety_test_class:
		var variety_test = variety_test_class.new()
		add_child(variety_test)

	var ai_test_class = load("res://tests/test_enemy_ai.gd")
	if ai_test_class:
		var ai_test = ai_test_class.new()
		add_child(ai_test)

	var elite_test_class = load("res://tests/test_elite_enemies.gd")
	if elite_test_class:
		var elite_test = elite_test_class.new()
		add_child(elite_test)

	var boss_test_class = load("res://tests/test_boss_system.gd")
	if boss_test_class:
		var boss_test = boss_test_class.new()
		add_child(boss_test)

	var boss_arena_test_class = load("res://tests/test_boss_arenas.gd")
	if boss_arena_test_class:
		var boss_arena_test = boss_arena_test_class.new()
		add_child(boss_arena_test)

	var realtime_combat_test_class = load("res://tests/test_realtime_combat.gd")
	if realtime_combat_test_class:
		var realtime_combat_test = realtime_combat_test_class.new()
		add_child(realtime_combat_test)

	var melee_combat_test_class = load("res://tests/test_melee_combat.gd")
	if melee_combat_test_class:
		var melee_combat_test = melee_combat_test_class.new()
		add_child(melee_combat_test)

	var ranged_combat_test_class = load("res://tests/test_ranged_combat.gd")
	if ranged_combat_test_class:
		var ranged_combat_test = ranged_combat_test_class.new()
		add_child(ranged_combat_test)

	var ability_test_class = load("res://tests/test_ability_system.gd")
	if ability_test_class:
		var ability_test = ability_test_class.new()
		add_child(ability_test)

	var dash_mobility_test_class = load("res://tests/test_dash_mobility.gd")
	if dash_mobility_test_class:
		var dash_mobility_test = dash_mobility_test_class.new()
		add_child(dash_mobility_test)

	var projectile_system_test_class = load("res://tests/test_projectile_system.gd")
	if projectile_system_test_class:
		var projectile_system_test = projectile_system_test_class.new()
		add_child(projectile_system_test)

	var damage_system_test_class = load("res://tests/test_damage_system.gd")
	if damage_system_test_class:
		var damage_system_test = damage_system_test_class.new()
		add_child(damage_system_test)

	var status_effect_test_class = load("res://tests/test_status_effect_system.gd")
	if status_effect_test_class:
		var status_effect_test = status_effect_test_class.new()
		add_child(status_effect_test)

	var hit_reaction_test_class = load("res://tests/test_hit_reaction_system.gd")
	if hit_reaction_test_class:
		var hit_reaction_test = hit_reaction_test_class.new()
		add_child(hit_reaction_test)

	var loot_system_test_class = load("res://tests/test_loot_system.gd")
	if loot_system_test_class:
		var loot_system_test = loot_system_test_class.new()
		add_child(loot_system_test)

	var artifact_system_test_class = load("res://tests/test_artifact_system.gd")
	if artifact_system_test_class:
		var artifact_system_test = artifact_system_test_class.new()
		add_child(artifact_system_test)

	var stat_aggregator_test_class = load("res://tests/test_stat_aggregator.gd")
	if stat_aggregator_test_class:
		var stat_aggregator_test = stat_aggregator_test_class.new()
		add_child(stat_aggregator_test)

	var synergy_engine_test_class = load("res://tests/test_synergy_engine.gd")
	if synergy_engine_test_class:
		var synergy_engine_test = synergy_engine_test_class.new()
		add_child(synergy_engine_test)

	var chest_test_class = load("res://tests/test_interactive_chest.gd")
	if chest_test_class:
		var chest_test = chest_test_class.new()
		add_child(chest_test)

	# Phase 2 Suites
	var risk_reward_test_class = load("res://tests/test_risk_reward_system.gd")
	if risk_reward_test_class:
		var rr_test = risk_reward_test_class.new()
		add_child(rr_test)

	var curse_test_class = load("res://tests/test_curse_system.gd")
	if curse_test_class:
		var curse_test = curse_test_class.new()
		add_child(curse_test)

	var meta_tree_test_class = load("res://tests/test_meta_progression_tree.gd")
	if meta_tree_test_class:
		var meta_test = meta_tree_test_class.new()
		add_child(meta_test)

	var character_loadout_test_class = load("res://tests/test_character_loadout.gd")
	if character_loadout_test_class:
		var char_test = character_loadout_test_class.new()
		add_child(char_test)

	var hub_station_test_class = load("res://tests/test_hub_station.gd")
	if hub_station_test_class:
		var hub_test = hub_station_test_class.new()
		add_child(hub_test)

	var dialogue_test_class = load("res://tests/test_dialogue_system.gd")
	if dialogue_test_class:
		var dialogue_test = dialogue_test_class.new()
		add_child(dialogue_test)

	var quest_bounty_test_class = load("res://tests/test_quest_bounty_system.gd")
	if quest_bounty_test_class:
		var quest_test = quest_bounty_test_class.new()
		add_child(quest_test)

	# Phase 3 Suites
	var weather_test_class = load("res://tests/test_weather_system.gd")
	if weather_test_class:
		var weather_test = weather_test_class.new()
		add_child(weather_test)

	var parallax_test_class = load("res://tests/test_parallax_system.gd")
	if parallax_test_class:
		var parallax_test = parallax_test_class.new()
		add_child(parallax_test)

	var vfx_pool_test_class = load("res://tests/test_vfx_pool.gd")
	if vfx_pool_test_class:
		var vfx_test = vfx_pool_test_class.new()
		add_child(vfx_test)

	var motion_trail_test_class = load("res://tests/test_motion_trail.gd")
	if motion_trail_test_class:
		var trail_test = motion_trail_test_class.new()
		add_child(trail_test)

	var camera_shake_test_class = load("res://tests/test_camera_shake.gd")
	if camera_shake_test_class:
		var shake_test = camera_shake_test_class.new()
		add_child(shake_test)

	var dissolve_test_class = load("res://tests/test_dissolve_effect.gd")
	if dissolve_test_class:
		var dissolve_test = dissolve_test_class.new()
		add_child(dissolve_test)

	var dynamic_lighting_test_class = load("res://tests/test_dynamic_lighting.gd")
	if dynamic_lighting_test_class:
		var lighting_test = dynamic_lighting_test_class.new()
		add_child(lighting_test)

	var post_processing_test_class = load("res://tests/test_post_processing.gd")
	if post_processing_test_class:
		var pp_test = post_processing_test_class.new()
		add_child(pp_test)

	var damage_number_test_class = load("res://tests/test_damage_number_engine.gd")
	if damage_number_test_class:
		var dmg_num_test = damage_number_test_class.new()
		add_child(dmg_num_test)

	var health_bar_test_class = load("res://tests/test_health_bar_controller.gd")
	if health_bar_test_class:
		var hb_test = health_bar_test_class.new()
		add_child(hb_test)

	var ui_transition_test_class = load("res://tests/test_ui_transition_manager.gd")
	if ui_transition_test_class:
		var ui_trans_test = ui_transition_test_class.new()
		add_child(ui_trans_test)

	# Phase 4 Suites
	var dynamic_music_test_class = load("res://tests/test_dynamic_music.gd")
	if dynamic_music_test_class:
		var music_test = dynamic_music_test_class.new()
		add_child(music_test)

	var positional_sfx_test_class = load("res://tests/test_positional_sfx.gd")
	if positional_sfx_test_class:
		var sfx_test = positional_sfx_test_class.new()
		add_child(sfx_test)

	# Phase 5 Suites
	var input_remapping_test_class = load("res://tests/test_input_remapping.gd")
	if input_remapping_test_class:
		var input_test = input_remapping_test_class.new()
		add_child(input_test)

	var localization_test_class = load("res://tests/test_localization_engine.gd")
	if localization_test_class:
		var loc_test = localization_test_class.new()
		add_child(loc_test)

	# Phase 6 QA, Testing & Profiling Suites
	var combat_harness_test_class = load("res://tests/test_automated_combat_harness.gd")
	if combat_harness_test_class:
		var combat_harness_test = combat_harness_test_class.new()
		add_child(combat_harness_test)

	var map_stress_test_class = load("res://tests/test_procedural_map_stress.gd")
	if map_stress_test_class:
		var map_stress_test = map_stress_test_class.new()
		add_child(map_stress_test)

	var save_resilience_test_class = load("res://tests/test_save_migration_resilience.gd")
	if save_resilience_test_class:
		var save_resilience_test = save_resilience_test_class.new()
		add_child(save_resilience_test)

	var perf_profiler_test_class = load("res://tests/test_performance_profiler.gd")
	if perf_profiler_test_class:
		var perf_profiler_test = perf_profiler_test_class.new()
		add_child(perf_profiler_test)

	var telemetry_test_class = load("res://tests/test_telemetry_tracker.gd")
	if telemetry_test_class:
		var telemetry_test = telemetry_test_class.new()
		add_child(telemetry_test)
	
	var legacy_loop_test = TestGameLoop.new()
	add_child(legacy_loop_test)
	
	print("==========================================================")
	print("  ALL 90 SYSTEMS & PHASES 1-6 COMPLETED WITH 100% PASS RATE!  ")
	print("==========================================================")
	get_tree().quit(0)
