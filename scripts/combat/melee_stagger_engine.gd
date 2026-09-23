# scripts/combat/melee_stagger_engine.gd
class_name MeleeStaggerEngine
extends Resource

## Engine managing Melee Armor Break, Stagger Vulnerability Windows, Target Weight Resistance, and Directional Attack Multipliers.

static func process_melee_impact(
	weapon_data: Resource,
	attack_type: String = "LIGHT", # LIGHT, HEAVY, CHARGED, AIR, DOWN, DASH_ATTACK
	target_armor: float = 20.0,
	target_weight: float = 1.0,
	is_staggered: bool = false
) -> Dictionary:
	var base_dmg = weapon_data.base_damage if weapon_data else 25.0
	var base_knockback = weapon_data.knockback_force if weapon_data else 140.0
	var base_armor_break = weapon_data.armor_break_power if weapon_data else 20.0
	var base_stagger = weapon_data.stagger_power if weapon_data else 30.0
	
	var dmg_mult = 1.0
	var armor_break_mult = 1.0
	var stagger_mult = 1.0
	var hit_stop_dur = 0.03
	var is_whiff = false
	
	match attack_type:
		"LIGHT":
			dmg_mult = 1.0
			armor_break_mult = 1.0
			stagger_mult = 1.0
			hit_stop_dur = 0.03
		"HEAVY":
			dmg_mult = 1.5
			armor_break_mult = 2.2
			stagger_mult = 2.0
			hit_stop_dur = 0.06
		"CHARGED":
			dmg_mult = 2.2
			armor_break_mult = 3.5
			stagger_mult = 3.0
			hit_stop_dur = 0.08
		"AIR":
			dmg_mult = 1.25
			armor_break_mult = 1.2
			stagger_mult = 1.2
			hit_stop_dur = 0.04
		"DOWN":
			dmg_mult = 1.6
			armor_break_mult = 2.0
			stagger_mult = 2.5
			hit_stop_dur = 0.07
		"DASH_ATTACK":
			dmg_mult = 1.3
			armor_break_mult = 1.5
			stagger_mult = 1.4
			hit_stop_dur = 0.05
		"WHIFF":
			is_whiff = true
			dmg_mult = 0.0
			hit_stop_dur = 0.0
			
	if is_whiff:
		return {
			"is_whiff": true,
			"damage": 0,
			"armor_broken": false,
			"stagger_triggered": false,
			"hit_stop_duration": 0.0,
			"final_knockback": 0.0,
			"audio_cue": weapon_data.whiff_sfx if weapon_data else "sfx_swing_sword"
		}
		
	# Stagger Window Damage Multiplier (1.5x if target is currently broken/staggered)
	var stagger_window_bonus = 1.5 if is_staggered else 1.0
	var armor_break_dealt = base_armor_break * armor_break_mult
	var new_armor = max(0.0, target_armor - armor_break_dealt)
	var armor_broken = (target_armor > 0.0 and new_armor == 0.0)
	
	var raw_damage = base_dmg * dmg_mult * stagger_window_bonus
	var effective_damage = max(1.0, raw_damage - (new_armor * 0.5))
	
	# Target Weight Knockback Scaling
	var final_knockback = max(15.0, (base_knockback * dmg_mult) / max(0.2, target_weight))
	var stagger_triggered = armor_broken or (base_stagger * stagger_mult >= 50.0)
	
	return {
		"is_whiff": false,
		"damage": int(effective_damage),
		"raw_damage": raw_damage,
		"armor_break_dealt": armor_break_dealt,
		"remaining_armor": new_armor,
		"armor_broken": armor_broken,
		"stagger_triggered": stagger_triggered,
		"hit_stop_duration": hit_stop_dur,
		"final_knockback": final_knockback,
		"audio_cue": weapon_data.hit_sfx if weapon_data else "sfx_hit_metal"
	}
