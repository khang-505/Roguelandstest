# scripts/combat/stat_aggregator.gd
class_name StatAggregator
extends Resource

## Central deterministic calculator summing base stats, equipment, affixes, artifacts, buffs, and perks.

static func calculate_stats(
	base_stats: Dictionary,
	equipped_armor: Array = [],
	equipped_weapon_data: Dictionary = {},
	equipped_artifacts: Array = [],
	active_buffs: Array = [],
	perk_modifiers: Dictionary = {}
) -> Dictionary:
	
	var base_atk = float(base_stats.get("attack", 10))
	var base_def = float(base_stats.get("defense", 0))
	var base_hp  = float(base_stats.get("hp", 100))
	var base_spd = float(base_stats.get("speed", 200.0))
	var base_crit = float(base_stats.get("crit_chance", 0.05))
	var base_crit_mult = float(base_stats.get("crit_multiplier", 1.5))
	var base_atk_spd = float(base_stats.get("attack_speed", 1.0))

	# 1. Equipment Stats
	var eq_atk: float = 0.0
	var eq_def: float = 0.0
	var eq_hp: float = 0.0
	var eq_spd: float = 0.0
	var eq_crit: float = 0.0

	for item in equipped_armor:
		if item and item is EquipmentData:
			var eq: EquipmentData = item as EquipmentData
			eq_atk += float(eq.bonus_attack)
			eq_def += float(eq.bonus_defense)
			eq_hp += float(eq.bonus_hp)
			eq_spd += float(eq.bonus_speed)
			eq_crit += float(eq.bonus_crit_chance)

	# Weapon base damage & affixes
	if equipped_weapon_data.size() > 0:
		eq_atk += float(equipped_weapon_data.get("base_damage", 0.0))
		var affixes = equipped_weapon_data.get("affixes", [])
		for affix in affixes:
			if affix is Dictionary:
				var stat = str(affix.get("stat", ""))
				var val = float(affix.get("value", 0.0))
				if stat == "attack" or stat == "bonus_attack": eq_atk += val
				elif stat == "defense" or stat == "bonus_defense": eq_def += val
				elif stat == "hp" or stat == "bonus_hp": eq_hp += val
				elif stat == "speed" or stat == "bonus_speed": eq_spd += val
				elif stat == "crit_chance": eq_crit += val

	# 2. Artifact Stats
	var engine_script = load("res://scripts/combat/artifact_proc_engine.gd")
	var art_stats: Dictionary = {}
	if engine_script:
		art_stats = engine_script.calculate_artifact_passive_stats(equipped_artifacts)

	var art_atk = float(art_stats.get("bonus_attack", 0))
	var art_def = float(art_stats.get("bonus_defense", 0))
	var art_hp  = float(art_stats.get("bonus_hp", 0))
	var art_spd = float(art_stats.get("bonus_speed", 0.0))
	var art_crit = float(art_stats.get("crit_chance", 0.0))

	# 3. Buff Stats
	var buff_atk: float = 0.0
	var buff_def: float = 0.0
	var buff_spd: float = 0.0
	var buff_crit: float = 0.0

	for buff in active_buffs:
		if buff is Dictionary:
			buff_atk += float(buff.get("bonus_attack", 0))
			buff_def += float(buff.get("bonus_defense", 0))
			buff_spd += float(buff.get("bonus_speed", 0.0))
			buff_crit += float(buff.get("bonus_crit_chance", 0.0))

	# 4. Perk Stats & Multipliers
	var perk_atk_mult = float(perk_modifiers.get("attack_mult", 1.0))
	var perk_def_mult = float(perk_modifiers.get("defense_mult", 1.0))
	var perk_hp_mult  = float(perk_modifiers.get("hp_mult", 1.0))
	var perk_crit_flat = float(perk_modifiers.get("crit_flat", 0.0))
	var perk_crit_mult = float(perk_modifiers.get("crit_multiplier_flat", 0.0))

	# Summation
	var raw_attack = (base_atk + eq_atk + art_atk + buff_atk) * perk_atk_mult
	var raw_defense = (base_def + eq_def + art_def + buff_def) * perk_def_mult
	var raw_hp = (base_hp + eq_hp + art_hp) * perk_hp_mult
	var raw_speed = base_spd + eq_spd + art_spd + buff_spd
	var raw_crit = base_crit + eq_crit + art_crit + buff_crit + perk_crit_flat
	var raw_crit_mult = base_crit_mult + perk_crit_mult

	# Caps & Clamps
	var final_attack = maxf(1.0, raw_attack)
	var final_defense = maxf(0.0, raw_defense)
	var final_hp = maxf(10.0, raw_hp)
	var final_speed = clampf(raw_speed, 50.0, 600.0) # min 50 spd, max 600 spd
	var final_crit = clampf(raw_crit, 0.0, 1.0)       # 0% to 100%
	var final_crit_mult = maxf(1.0, raw_crit_mult)   # min 1.0x

	# Damage reduction formula: armor / (armor + 100)
	var damage_reduction = final_defense / (final_defense + 100.0)

	return {
		"total_attack": final_attack,
		"total_defense": final_defense,
		"max_hp": final_hp,
		"move_speed": final_speed,
		"crit_chance": final_crit,
		"crit_multiplier": final_crit_mult,
		"damage_reduction": damage_reduction
	}
