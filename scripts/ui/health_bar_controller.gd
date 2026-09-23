# scripts/ui/health_bar_controller.gd
class_name HealthBarController
extends Control

## Dynamic world-space health bar controller supporting Shield overlays, Armor badges, Stagger bars, and hit-fill animations.

signal health_changed(current_hp: float, max_hp: float, shield: float)
signal stagger_changed(current_stagger: float, max_stagger: float)

@export var max_hp: float = 100.0
@export var current_hp: float = 100.0
@export var shield_hp: float = 0.0
@export var armor_rating: float = 0.0

@export var max_stagger: float = 100.0
@export var current_stagger: float = 0.0

@export var is_boss_bar: bool = false

func update_health(new_hp: float, new_shield: float = -1.0) -> Dictionary:
	current_hp = clampf(new_hp, 0.0, max_hp)
	if new_shield >= 0.0:
		shield_hp = new_shield

	var hp_pct = current_hp / max_hp if max_hp > 0.0 else 0.0
	var shield_pct = shield_hp / max_hp if max_hp > 0.0 else 0.0

	health_changed.emit(current_hp, max_hp, shield_hp)
	return {
		"current_hp": current_hp,
		"max_hp": max_hp,
		"shield_hp": shield_hp,
		"hp_pct": hp_pct,
		"shield_pct": shield_pct,
		"is_dead": current_hp <= 0.0
	}

func update_stagger(new_stagger: float) -> Dictionary:
	current_stagger = clampf(new_stagger, 0.0, max_stagger)
	var stagger_pct = current_stagger / max_stagger if max_stagger > 0.0 else 0.0
	stagger_changed.emit(current_stagger, max_stagger)
	return {
		"current_stagger": current_stagger,
		"max_stagger": max_stagger,
		"stagger_pct": stagger_pct,
		"is_staggered": current_stagger >= max_stagger
	}
