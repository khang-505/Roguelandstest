# scripts/combat/artifact_catalog.gd
class_name ArtifactCatalog
extends Resource

## Catalog containing all 15 unique Artifacts in Starfall Frontier.

static var _artifacts: Dictionary = {}
static var _initialized: bool = false

static func _ensure_initialized() -> void:
	if _initialized:
		return
	_initialized = true
	
	var data_script = load("res://scripts/data/artifact_data.gd")
	if not data_script:
		return
		
	# 1. Vampiric Fang (ON_KILL: Heal 5% max HP)
	var a1 = data_script.new()
	a1.artifact_id = "vampiric_fang"
	a1.display_name = "Vampiric Fang"
	a1.description = "On kill, restores 5% of maximum Health."
	a1.rarity = data_script.Rarity.UNCOMMON
	a1.passive_stats = {"bonus_attack": 5}
	a1.proc_trigger = data_script.ProcTrigger.ON_KILL
	a1.proc_chance = 1.0
	a1.proc_cooldown = 0.5
	a1.proc_effect_id = "vampiric_heal"
	a1.proc_value = 0.05
	a1.tags = ["vampire", "heal", "sustain"]
	_artifacts[a1.artifact_id] = a1

	# 2. Storm Pendant (ON_HIT 20% proc: Chain Lightning)
	var a2 = data_script.new()
	a2.artifact_id = "storm_pendant"
	a2.display_name = "Storm Pendant"
	a2.description = "On hit, 20% chance to unleash Chain Lightning."
	a2.rarity = data_script.Rarity.RARE
	a2.passive_stats = {"crit_chance": 0.05}
	a2.proc_trigger = data_script.ProcTrigger.ON_HIT
	a2.proc_chance = 0.20
	a2.proc_cooldown = 1.0
	a2.proc_effect_id = "chain_lightning"
	a2.proc_value = 30.0
	a2.tags = ["lightning", "aoe", "proc"]
	_artifacts[a2.artifact_id] = a2

	# 3. Pyro Core (ON_CRIT 30% proc: Burn Nova)
	var a3 = data_script.new()
	a3.artifact_id = "pyro_core"
	a3.display_name = "Pyro Core"
	a3.description = "On critical hit, 30% chance to ignite enemies in a Burn Nova."
	a3.rarity = data_script.Rarity.RARE
	a3.passive_stats = {"bonus_attack": 12, "crit_chance": 0.08}
	a3.proc_trigger = data_script.ProcTrigger.ON_CRIT
	a3.proc_chance = 0.30
	a3.proc_cooldown = 2.0
	a3.proc_effect_id = "burn_nova"
	a3.proc_value = 40.0
	a3.tags = ["fire", "crit", "burn"]
	_artifacts[a3.artifact_id] = a3

	# 4. Frost Clasp (ON_DASH: Frost Wave)
	var a4 = data_script.new()
	a4.artifact_id = "frost_clasp"
	a4.display_name = "Frost Clasp"
	a4.description = "Dashing emits a Frost Wave that slows and freezes nearby foes."
	a4.rarity = data_script.Rarity.UNCOMMON
	a4.passive_stats = {"bonus_speed": 15.0}
	a4.proc_trigger = data_script.ProcTrigger.ON_DASH
	a4.proc_chance = 1.0
	a4.proc_cooldown = 3.0
	a4.proc_effect_id = "frost_wave"
	a4.proc_value = 2.0 # Freeze duration
	a4.tags = ["ice", "dash", "cc"]
	_artifacts[a4.artifact_id] = a4

	# 5. Aegis Talisman (ON_LOW_HP <30%: Shield Burst)
	var a5 = data_script.new()
	a5.artifact_id = "aegis_talisman"
	a5.display_name = "Aegis Talisman"
	a5.description = "When HP drops below 30%, gain a temporary 50 HP Shield."
	a5.rarity = data_script.Rarity.EPIC
	a5.passive_stats = {"bonus_hp": 30, "bonus_defense": 8}
	a5.proc_trigger = data_script.ProcTrigger.ON_LOW_HP
	a5.proc_chance = 1.0
	a5.proc_cooldown = 20.0
	a5.proc_effect_id = "shield_burst"
	a5.proc_value = 50.0
	a5.tags = ["shield", "defense", "clutch"]
	_artifacts[a5.artifact_id] = a5

	# 6. Shadow Ring (ON_CRIT: Move Speed Buff)
	var a6 = data_script.new()
	a6.artifact_id = "shadow_ring"
	a6.display_name = "Shadow Ring"
	a6.description = "Critical hits grant +25% Movement Speed for 3s."
	a6.rarity = data_script.Rarity.UNCOMMON
	a6.passive_stats = {"crit_chance": 0.06}
	a6.proc_trigger = data_script.ProcTrigger.ON_CRIT
	a6.proc_chance = 1.0
	a6.proc_cooldown = 4.0
	a6.proc_effect_id = "shadow_speed"
	a6.proc_value = 0.25
	a6.tags = ["shadow", "speed", "crit"]
	_artifacts[a6.artifact_id] = a6

	# 7. Titan Girdle (ON_TAKE_DAMAGE 25%: Reflect Damage)
	var a7 = data_script.new()
	a7.artifact_id = "titan_girdle"
	a7.display_name = "Titan Girdle"
	a7.description = "Taking damage has a 25% chance to reflect 50% damage back to attackers."
	a7.rarity = data_script.Rarity.RARE
	a7.passive_stats = {"bonus_hp": 50, "bonus_defense": 10}
	a7.proc_trigger = data_script.ProcTrigger.ON_TAKE_DAMAGE
	a7.proc_chance = 0.25
	a7.proc_cooldown = 1.0
	a7.proc_effect_id = "reflect_damage"
	a7.proc_value = 0.50
	a7.tags = ["tank", "reflect", "defense"]
	_artifacts[a7.artifact_id] = a7

	# 8. Overcharge Battery (ON_ABILITY: Shock Damage Boost)
	var a8 = data_script.new()
	a8.artifact_id = "overcharge_battery"
	a8.display_name = "Overcharge Battery"
	a8.description = "Using an ability overcharges your next strike with +50% shock damage."
	a8.rarity = data_script.Rarity.RARE
	a8.passive_stats = {"bonus_attack": 8}
	a8.proc_trigger = data_script.ProcTrigger.ON_ABILITY
	a8.proc_chance = 1.0
	a8.proc_cooldown = 2.0
	a8.proc_effect_id = "overcharge_strike"
	a8.proc_value = 0.50
	a8.tags = ["plasma", "ability", "burst"]
	_artifacts[a8.artifact_id] = a8

	# 9. Blood Stone (ON_HIT 15%: Life Steal)
	var a9 = data_script.new()
	a9.artifact_id = "blood_stone"
	a9.display_name = "Blood Stone"
	a9.description = "Hits have a 15% chance to leech 15% of damage dealt as health."
	a9.rarity = data_script.Rarity.EPIC
	a9.passive_stats = {"bonus_attack": 10, "bonus_hp": 20}
	a9.proc_trigger = data_script.ProcTrigger.ON_HIT
	a9.proc_chance = 0.15
	a9.proc_cooldown = 0.5
	a9.proc_effect_id = "life_steal"
	a9.proc_value = 0.15
	a9.tags = ["vampire", "lifesteal", "sustain"]
	_artifacts[a9.artifact_id] = a9

	# 10. Wind Pendant (ON_DASH: Dash Cooldown Reduction)
	var a10 = data_script.new()
	a10.artifact_id = "wind_pendant"
	a10.display_name = "Wind Pendant"
	a10.description = "Dashing reduces skill cooldowns by 1 second."
	a10.rarity = data_script.Rarity.UNCOMMON
	a10.passive_stats = {"bonus_speed": 20.0}
	a10.proc_trigger = data_script.ProcTrigger.ON_DASH
	a10.proc_chance = 1.0
	a10.proc_cooldown = 2.0
	a10.proc_effect_id = "cooldown_reduction"
	a10.proc_value = 1.0
	a10.tags = ["wind", "dash", "utility"]
	_artifacts[a10.artifact_id] = a10

	# 11. Plasma Amplifier (ON_CRIT: Stacking Crit Multiplier)
	var a11 = data_script.new()
	a11.artifact_id = "plasma_amplifier"
	a11.display_name = "Plasma Amplifier"
	a11.description = "Critical hits stack +10% Crit Damage up to 5 times."
	a11.rarity = data_script.Rarity.EPIC
	a11.passive_stats = {"crit_chance": 0.10}
	a11.proc_trigger = data_script.ProcTrigger.ON_CRIT
	a11.proc_chance = 1.0
	a11.proc_cooldown = 0.2
	a11.proc_effect_id = "stacking_crit_damage"
	a11.proc_value = 0.10
	a11.tags = ["plasma", "crit", "stacking"]
	_artifacts[a11.artifact_id] = a11

	# 12. Void Pact (ON_KILL: Attack Scaling)
	var a12 = data_script.new()
	a12.artifact_id = "void_pact"
	a12.display_name = "Void Pact"
	a12.description = "Kills increase Attack by +2 (stacking), but cap Max HP by -1."
	a12.rarity = data_script.Rarity.LEGENDARY
	a12.passive_stats = {"bonus_attack": 20}
	a12.proc_trigger = data_script.ProcTrigger.ON_KILL
	a12.proc_chance = 1.0
	a12.proc_cooldown = 0.1
	a12.proc_effect_id = "void_growth"
	a12.proc_value = 2.0
	a12.tags = ["void", "tradeoff", "scaling"]
	_artifacts[a12.artifact_id] = a12

	# 13. Sentinel Core (ON_TAKE_DAMAGE: Deploy Shield Drone)
	var a13 = data_script.new()
	a13.artifact_id = "sentinel_core"
	a13.display_name = "Sentinel Core"
	a13.description = "Taking damage spawns a Sentinel Drone that blocks incoming projectiles."
	a13.rarity = data_script.Rarity.LEGENDARY
	a13.passive_stats = {"bonus_defense": 15, "bonus_hp": 40}
	a13.proc_trigger = data_script.ProcTrigger.ON_TAKE_DAMAGE
	a13.proc_chance = 0.40
	a13.proc_cooldown = 15.0
	a13.proc_effect_id = "spawn_sentinel"
	a13.proc_value = 5.0 # duration
	a13.tags = ["drone", "defense", "summon"]
	_artifacts[a13.artifact_id] = a13

	# 14. Blasphemer Tome (ON_ABILITY: Vulnerability Aura)
	var a14 = data_script.new()
	a14.artifact_id = "blasphemer_tome"
	a14.display_name = "Blasphemer Tome"
	a14.description = "Casting abilities inflicts 20% Vulnerability on surrounding enemies."
	a14.rarity = data_script.Rarity.EPIC
	a14.passive_stats = {"bonus_attack": 15}
	a14.proc_trigger = data_script.ProcTrigger.ON_ABILITY
	a14.proc_chance = 1.0
	a14.proc_cooldown = 5.0
	a14.proc_effect_id = "vulnerability_aura"
	a14.proc_value = 0.20
	a14.tags = ["shadow", "debuff", "ability"]
	_artifacts[a14.artifact_id] = a14

	# 15. Chronos Hourglass (ON_LOW_HP: Time Freeze & Cooldown Reset)
	var a15 = data_script.new()
	a15.artifact_id = "chronos_hourglass"
	a15.display_name = "Chronos Hourglass"
	a15.description = "Near death, slows time by 50% and resets all skill cooldowns."
	a15.rarity = data_script.Rarity.MYTHIC
	a15.passive_stats = {"bonus_hp": 50, "bonus_speed": 10.0, "crit_chance": 0.05}
	a15.proc_trigger = data_script.ProcTrigger.ON_LOW_HP
	a15.proc_chance = 1.0
	a15.proc_cooldown = 45.0
	a15.proc_effect_id = "chronos_reset"
	a15.proc_value = 3.0 # slow time duration
	a15.tags = ["mythic", "time", "clutch", "reset"]
	_artifacts[a15.artifact_id] = a15

static func get_artifact(id: String) -> ArtifactData:
	_ensure_initialized()
	if _artifacts.has(id):
		return _artifacts[id].duplicate()
	return null

static func get_all_artifact_ids() -> Array:
	_ensure_initialized()
	return _artifacts.keys()

static func get_catalog_size() -> int:
	_ensure_initialized()
	return _artifacts.size()
