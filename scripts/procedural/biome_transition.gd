# scripts/procedural/biome_transition.gd
class_name BiomeTransition
extends Node

## Manages smooth visual, environmental, and enemy pool transitions between adjacent planet regions.

static func calculate_transition_state(
	from_biome: Object,
	to_biome: Object,
	progress_factor: float # 0.0 (from_biome) to 1.0 (to_biome)
) -> Dictionary:
	var blended_bg = Color(0.1, 0.1, 0.1, 1.0)
	var blended_theme = Color(0.5, 0.5, 0.5, 1.0)
	var blended_enemy_pool: Array[String] = []
	var blended_hazard_density = 0.3

	var bg_a = from_biome.background_color if from_biome and "background_color" in from_biome else Color.BLACK
	var bg_b = to_biome.background_color if to_biome and "background_color" in to_biome else Color.BLACK
	blended_bg = bg_a.lerp(bg_b, progress_factor)

	var tc_a = from_biome.theme_color if from_biome and "theme_color" in from_biome else Color.WHITE
	var tc_b = to_biome.theme_color if to_biome and "theme_color" in to_biome else Color.WHITE
	blended_theme = tc_a.lerp(tc_b, progress_factor)

	var pool_a = from_biome.enemy_pool if from_biome and "enemy_pool" in from_biome else []
	var pool_b = to_biome.enemy_pool if to_biome and "enemy_pool" in to_biome else []

	for e in pool_a:
		if not blended_enemy_pool.has(str(e)): blended_enemy_pool.append(str(e))
	if progress_factor > 0.4:
		for e in pool_b:
			if not blended_enemy_pool.has(str(e)): blended_enemy_pool.append(str(e))

	var hd_a = from_biome.hazard_density if from_biome and "hazard_density" in from_biome else 0.3
	var hd_b = to_biome.hazard_density if to_biome and "hazard_density" in to_biome else 0.3
	blended_hazard_density = lerpf(hd_a, hd_b, progress_factor)

	return {
		"background_color": blended_bg,
		"theme_color": blended_theme,
		"enemy_pool": blended_enemy_pool,
		"hazard_density": blended_hazard_density,
		"transition_progress": progress_factor
	}
