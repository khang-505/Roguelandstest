# scripts/combat/curse_manager.gd
class_name CurseManager
extends Resource

## Data-driven Curse Engine tracking Corruption level (0 to 100), thresholds, active debuffs, and cleansing mechanics.

signal corruption_changed(current_corruption: float, max_corruption: float)
signal threshold_reached(threshold_tier: int)

const MAX_CORRUPTION: float = 100.0

var corruption_points: float = 0.0
var active_curses: Array[CurseData] = []
var reached_thresholds: Array[int] = []

func add_corruption(amount: float) -> void:
	corruption_points = clampf(corruption_points + amount, 0.0, MAX_CORRUPTION)
	corruption_changed.emit(corruption_points, MAX_CORRUPTION)
	_check_thresholds()

func cleanse_corruption(amount: float) -> void:
	corruption_points = clampf(corruption_points - amount, 0.0, MAX_CORRUPTION)
	corruption_changed.emit(corruption_points, MAX_CORRUPTION)

func add_curse(curse: CurseData) -> bool:
	if not curse:
		return false
	active_curses.append(curse)
	add_corruption(curse.corruption_value)
	return true

func remove_curse(curse_id: String) -> bool:
	for i in range(active_curses.size()):
		if active_curses[i].curse_id == curse_id:
			var c = active_curses[i]
			cleanse_corruption(c.corruption_value)
			active_curses.remove_at(i)
			return true
	return false

func _check_thresholds() -> void:
	# Thresholds at 25%, 50%, 75%, 100%
	var current_pct = corruption_points / MAX_CORRUPTION
	var tiers = [1, 2, 3, 4]
	var pcts  = [0.25, 0.50, 0.75, 1.00]

	for idx in range(tiers.size()):
		var t = tiers[idx]
		var pct = pcts[idx]
		if current_pct >= pct and not reached_thresholds.has(t):
			reached_thresholds.append(t)
			threshold_reached.emit(t)

func get_aggregate_curse_debuffs() -> Dictionary:
	var aggregate = {
		"max_hp_mult": 0.0,
		"move_speed_flat": 0.0,
		"active_mutations": []
	}

	for curse in active_curses:
		for k in curse.stat_debuffs.keys():
			var val = curse.stat_debuffs[k]
			if aggregate.has(k):
				aggregate[k] += val
			else:
				aggregate[k] = val

		if curse.mutation_effect_id != "":
			aggregate["active_mutations"].append(curse.mutation_effect_id)

	return aggregate
