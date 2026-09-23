# scripts/combat/synergy_catalog.gd
class_name SynergyCatalog
extends Resource

## Catalog defining the 8 Build Synergy Archetypes and their Tier 1/2/3 bonuses.

static var _synergies: Dictionary = {}
static var _initialized: bool = false

static func _ensure_initialized() -> void:
	if _initialized:
		return
	_initialized = true

	# 1. FIRE (Pyromancer)
	_synergies["FIRE"] = {
		"tag": "FIRE",
		"name": "Pyromancer",
		"description": "Ignites foes with devastating burn explosions.",
		"tiers": {
			2: {"bonus_attack": 10, "fire_damage_mult": 0.15, "description": "Tier 1 (2): +10 ATK, +15% Fire Damage"},
			4: {"bonus_attack": 25, "fire_damage_mult": 0.35, "burn_spread": true, "description": "Tier 2 (4): +25 ATK, +35% Fire Damage, Burn spreads to nearby enemies"},
			6: {"bonus_attack": 50, "fire_damage_mult": 0.70, "burn_spread": true, "guaranteed_burn": true, "description": "Tier 3 (6): +50 ATK, +70% Fire Damage, All attacks inflict Burn"}
		}
	}

	# 2. ICE (Cryomancer)
	_synergies["ICE"] = {
		"tag": "ICE",
		"name": "Cryomancer",
		"description": "Freezes and slows enemies, turning defense into control.",
		"tiers": {
			2: {"bonus_defense": 10, "freeze_duration_mult": 0.20, "description": "Tier 1 (2): +10 DEF, +20% Freeze Duration"},
			4: {"bonus_defense": 25, "freeze_duration_mult": 0.50, "shatter_damage": 30.0, "description": "Tier 2 (4): +25 DEF, +50% Freeze Duration, Shattering frozen foes deals 30 AoE damage"},
			6: {"bonus_defense": 60, "freeze_duration_mult": 1.00, "shatter_damage": 75.0, "frost_aura": true, "description": "Tier 3 (6): +60 DEF, +100% Freeze Duration, Permanent Freezing Aura"}
		}
	}

	# 3. PLASMA (Energy Master)
	_synergies["PLASMA"] = {
		"tag": "PLASMA",
		"name": "Plasma Archon",
		"description": "Overcharges attacks with high-frequency shock energy.",
		"tiers": {
			2: {"attack_speed_mult": 0.15, "description": "Tier 1 (2): +15% Attack Speed"},
			4: {"attack_speed_mult": 0.35, "chain_targets": 2, "description": "Tier 2 (4): +35% Attack Speed, Attacks chain to 2 secondary targets"},
			6: {"attack_speed_mult": 0.75, "chain_targets": 5, "unlimited_energy": true, "description": "Tier 3 (6): +75% Attack Speed, Attacks chain to 5 targets, Unlimited Energy"}
		}
	}

	# 4. SHADOW (Void Assassin)
	_synergies["SHADOW"] = {
		"tag": "SHADOW",
		"name": "Void Assassin",
		"description": "Lurks in shadows, dealing high critical strike damage.",
		"tiers": {
			2: {"crit_chance": 0.10, "description": "Tier 1 (2): +10% Crit Chance"},
			4: {"crit_chance": 0.25, "crit_multiplier_bonus": 0.50, "description": "Tier 2 (4): +25% Crit Chance, +0.5x Crit Damage"},
			6: {"crit_chance": 0.50, "crit_multiplier_bonus": 1.20, "shadow_stealth": true, "description": "Tier 3 (6): +50% Crit Chance, +1.2x Crit Damage, Dashing grants 1.5s Stealth"}
		}
	}

	# 5. TANK (Juggernaut)
	_synergies["TANK"] = {
		"tag": "TANK",
		"name": "Juggernaut",
		"description": "Immovable defensive wall with extreme health and armor.",
		"tiers": {
			2: {"bonus_hp": 40, "bonus_defense": 8, "description": "Tier 1 (2): +40 HP, +8 DEF"},
			4: {"bonus_hp": 100, "bonus_defense": 20, "damage_reduction_flat": 0.15, "description": "Tier 2 (4): +100 HP, +20 DEF, 15% Flat Damage Reduction"},
			6: {"bonus_hp": 250, "bonus_defense": 50, "damage_reduction_flat": 0.35, "unyielding_shield": true, "description": "Tier 3 (6): +250 HP, +50 DEF, 35% Flat Damage Reduction, Cannot be knocked down"}
		}
	}

	# 6. SPEED (Storm Runner)
	_synergies["SPEED"] = {
		"tag": "SPEED",
		"name": "Storm Runner",
		"description": "Hyper-mobile skirmisher dashing through battle.",
		"tiers": {
			2: {"bonus_speed": 30.0, "description": "Tier 1 (2): +30 Move Speed"},
			4: {"bonus_speed": 75.0, "dash_cd_reduction": 0.30, "description": "Tier 2 (4): +75 Move Speed, 30% Dash Cooldown Reduction"},
			6: {"bonus_speed": 150.0, "dash_cd_reduction": 0.60, "infinite_dashes": true, "description": "Tier 3 (6): +150 Move Speed, 60% Dash Cooldown Reduction, Dash leaves shock trail"}
		}
	}

	# 7. VAMPIRE (Blood Lord)
	_synergies["VAMPIRE"] = {
		"tag": "VAMPIRE",
		"name": "Blood Lord",
		"description": "Sustains life through combat damage leeching.",
		"tiers": {
			2: {"lifesteal": 0.05, "description": "Tier 1 (2): 5% Life Steal"},
			4: {"lifesteal": 0.15, "overheal_shield": true, "description": "Tier 2 (4): 15% Life Steal, Overhealing grants Shield"},
			6: {"lifesteal": 0.35, "overheal_shield": true, "blood_frenzy": true, "description": "Tier 3 (6): 35% Life Steal, Overhealing grants Shield, Kills boost attack speed by +50%"}
		}
	}

	# 8. SUMMON (Master Sentinel)
	_synergies["SUMMON"] = {
		"tag": "SUMMON",
		"name": "Master Sentinel",
		"description": "Commands swarms of drones and turrets.",
		"tiers": {
			2: {"minion_damage": 0.20, "description": "Tier 1 (2): +20% Companion/Turret Damage"},
			4: {"minion_damage": 0.50, "extra_companion": 1, "description": "Tier 2 (4): +50% Companion Damage, +1 Extra Active Companion"},
			6: {"minion_damage": 1.20, "extra_companion": 2, "sentinel_overload": true, "description": "Tier 3 (6): +120% Companion Damage, +2 Extra Companions, Drones emit laser beams"}
		}
	}

static func get_synergy(tag: String) -> Dictionary:
	_ensure_initialized()
	if _synergies.has(tag):
		return _synergies[tag]
	return {}

static func get_all_synergy_tags() -> Array:
	_ensure_initialized()
	return _synergies.keys()
