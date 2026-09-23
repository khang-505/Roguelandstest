# scripts/procedural/risk_reward_manager.gd
class_name RiskRewardManager
extends Resource

## Dynamic Risk/Reward Pact Manager presenting trade-off modifiers at shrine nodes / room entrances.

signal pact_accepted(pact_id: String, risk_modifier: Dictionary, reward_modifier: Dictionary)

static var PACT_CATALOG: Array = [
	{
		"id": "blood_bargain",
		"display_name": "Blood Bargain",
		"description": "Enemies deal +40% damage, but drop +80% more Credits & Shards.",
		"risk": {"enemy_damage_mult": 0.40},
		"reward": {"loot_drop_mult": 0.80}
	},
	{
		"id": "glass_cannon_pact",
		"display_name": "Glass Cannon Pact",
		"description": "Player Max HP reduced by 30%, but weapon damage increased by +60%.",
		"risk": {"player_hp_mult": -0.30},
		"reward": {"player_attack_mult": 0.60}
	},
	{
		"id": "shieldless_greed",
		"display_name": "Shieldless Greed",
		"description": "Shields disabled, but guarantees 1 additional Item drop per Elite kill.",
		"risk": {"disable_shields": true},
		"reward": {"extra_elite_loot": 1}
	},
	{
		"id": "frenzy_swarm",
		"display_name": "Frenzy Swarm",
		"description": "Enemy movement & attack speed +30%, but item drop rarity upgraded.",
		"risk": {"enemy_speed_mult": 0.30},
		"reward": {"rarity_boost_tier": 1}
	},
	{
		"id": "shadow_curse_pact",
		"display_name": "Shadow Pact",
		"description": "Gain +15 Corruption Points instantly, but grant +25% Crit Chance.",
		"risk": {"corruption_add": 15},
		"reward": {"crit_chance_flat": 0.25}
	}
]

var active_pacts: Array[Dictionary] = []

func get_random_pact_choices(count: int = 3, rng_seed: int = 0) -> Array[Dictionary]:
	var catalog_copy = PACT_CATALOG.duplicate()
	if rng_seed != 0:
		var rng = RandomNumberGenerator.new()
		rng.seed = rng_seed
		# Simple shuffle
		for i in range(catalog_copy.size() - 1, 0, -1):
			var j = rng.randi_range(0, i)
			var tmp = catalog_copy[i]
			catalog_copy[i] = catalog_copy[j]
			catalog_copy[j] = tmp
	else:
		catalog_copy.shuffle()
		
	var choices: Array[Dictionary] = []
	for i in range(min(count, catalog_copy.size())):
		choices.append(catalog_copy[i])
	return choices

func accept_pact(pact: Dictionary) -> void:
	if not pact or not pact.has("id"):
		return
	active_pacts.append(pact)
	pact_accepted.emit(pact["id"], pact.get("risk", {}), pact.get("reward", {}))

func get_aggregate_modifiers() -> Dictionary:
	var total = {
		"enemy_damage_mult": 0.0,
		"player_hp_mult": 0.0,
		"player_attack_mult": 0.0,
		"enemy_speed_mult": 0.0,
		"loot_drop_mult": 0.0,
		"crit_chance_flat": 0.0,
		"disable_shields": false,
		"rarity_boost_tier": 0,
		"extra_elite_loot": 0
	}

	for pact in active_pacts:
		var risk = pact.get("risk", {})
		var reward = pact.get("reward", {})

		for k in risk.keys():
			var v = risk[k]
			if typeof(v) == TYPE_BOOL and v == true:
				total[k] = true
			elif total.has(k):
				total[k] += v

		for k in reward.keys():
			var v = reward[k]
			if typeof(v) == TYPE_BOOL and v == true:
				total[k] = true
			elif total.has(k):
				total[k] += v

	return total
