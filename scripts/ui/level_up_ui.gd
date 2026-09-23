# scripts/ui/level_up_ui.gd
class_name LevelUpUI
extends Control

## In-Run Level Up Choice UI modal presenting 3 randomized synergistic upgrade cards with reroll capabilities.

signal perk_selected(perk_data: Dictionary)

@onready var cards_container: HBoxContainer = $Panel/CardsContainer if has_node("Panel/CardsContainer") else null

var rerolls_remaining: int = 2

const PERK_POOL: Array = [
	# OFFENSIVE (6)
	{"id": "atk_up", "title": "+15% Damage", "description": "Increases all weapon and ability attack damage by 15%.", "category": "OFFENSIVE", "stat": "attack_percent", "value": 0.15},
	{"id": "crit_up", "title": "+10% Critical Chance", "description": "Increases critical hit chance across all attacks by 10%.", "category": "OFFENSIVE", "stat": "crit_chance", "value": 0.10},
	{"id": "crit_mult_up", "title": "+0.3x Critical Damage", "description": "Boosts critical hit damage multiplier by +0.3x.", "category": "OFFENSIVE", "stat": "crit_mult", "value": 0.30},
	{"id": "attack_speed_up", "title": "+20% Attack Speed", "description": "Reduces attack and ability cooldown delay by 20%.", "category": "OFFENSIVE", "stat": "attack_speed", "value": 0.20},
	{"id": "armor_pen", "title": "Armor Penetration", "description": "Attacks ignore 25% of target defense armor.", "category": "OFFENSIVE", "stat": "armor_pen", "value": 0.25},
	{"id": "execute_strike", "title": "Execute Protocol", "description": "Deals +50% damage against enemies below 30% Health.", "category": "OFFENSIVE", "stat": "execute", "value": 0.50},

	# DEFENSIVE (5)
	{"id": "hp_up", "title": "+30 Max HP", "description": "Increases maximum health capacity and restores 30 HP.", "category": "DEFENSIVE", "stat": "max_hp", "value": 30},
	{"id": "armor_up", "title": "+10 Armor Defense", "description": "Reduces all incoming damage by flat armor rating.", "category": "DEFENSIVE", "stat": "defense", "value": 10},
	{"id": "regen_up", "title": "Nano-Regen Core", "description": "Restores 1 HP every 3 seconds during combat.", "category": "DEFENSIVE", "stat": "hp_regen", "value": 1.0},
	{"id": "shield_up", "title": "+40 Energy Shield", "description": "Grants a rechargeable 40 HP protective shield.", "category": "DEFENSIVE", "stat": "shield", "value": 40},
	{"id": "damage_reduction", "title": "Reinforced Plating", "description": "Grants 10% damage reduction from all sources.", "category": "DEFENSIVE", "stat": "damage_reduction", "value": 0.10},

	# MOBILITY & UTILITY (5)
	{"id": "speed_up", "title": "+25 Movement Speed", "description": "Increases movement velocity and agility.", "category": "MOBILITY", "stat": "move_speed", "value": 25.0},
	{"id": "dash_charge", "title": "Extra Thruster", "description": "Grants +1 additional Dash charge.", "category": "MOBILITY", "stat": "extra_dash", "value": 1},
	{"id": "cooldown_reduction", "title": "Overclocked Cooldowns", "description": "Reduces all ability cooldowns by 15%.", "category": "UTILITY", "stat": "cd_reduction", "value": 0.15},
	{"id": "magnet_range", "title": "Magnetic Collector", "description": "Doubles credit and material pickup collection radius.", "category": "UTILITY", "stat": "magnet", "value": 2.0},
	{"id": "xp_boost", "title": "Scholar Augment", "description": "Increases XP gained from enemy kills by 25%.", "category": "UTILITY", "stat": "xp_rate", "value": 0.25},

	# ELEMENTAL & SYNERGY (6)
	{"id": "burn_blast", "title": "Ignition Burst", "description": "Burn status effects trigger an explosive AoE blast.", "category": "SYNERGY", "stat": "burn_synergy", "value": 1.0},
	{"id": "crit_chain", "title": "Storm Surge", "description": "Critical hits chain lightning to nearby hostile targets.", "category": "SYNERGY", "stat": "crit_synergy", "value": 1.0},
	{"id": "frost_nova_proc", "title": "Subzero Shatter", "description": "Defeating frozen foes triggers a freezing frost wave.", "category": "SYNERGY", "stat": "freeze_synergy", "value": 1.0},
	{"id": "poison_spore", "title": "Toxic Reaction", "description": "Poisoned enemies emit toxic clouds upon death.", "category": "SYNERGY", "stat": "poison_synergy", "value": 1.0},
	{"id": "vampire_leech", "title": "Vampiric Resonance", "description": "Grants 8% life steal on all physical weapon hits.", "category": "SYNERGY", "stat": "lifesteal", "value": 0.08},
	{"id": "shock_chain", "title": "Overcharge Conduits", "description": "Shock status effects bounce to 2 extra targets.", "category": "SYNERGY", "stat": "shock_synergy", "value": 2.0}
]

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	get_tree().paused = true
	_present_options()

func _present_options() -> void:
	if cards_container == null:
		return

	for c in cards_container.get_children():
		c.queue_free()

	var pool_copy = PERK_POOL.duplicate()
	pool_copy.shuffle()

	for i in range(min(3, pool_copy.size())):
		var perk = pool_copy[i] as Dictionary
		
		var panel = PanelContainer.new()
		panel.custom_minimum_size = Vector2(220, 260)

		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 12)
		panel.add_child(vbox)

		var cat_lbl = Label.new()
		cat_lbl.text = "[ %s ]" % perk.get("category", "GENERAL")
		cat_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(cat_lbl)

		var title = Label.new()
		title.text = perk["title"]
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(title)

		var desc = Label.new()
		desc.text = perk["description"]
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD
		desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(desc)

		var btn = Button.new()
		btn.text = "CHOOSE PERK"
		btn.pressed.connect(func(): _on_select_perk(perk))
		vbox.add_child(btn)

		cards_container.add_child(panel)

	# Add Reroll button if rerolls available
	if rerolls_remaining > 0:
		var reroll_btn = Button.new()
		reroll_btn.text = "🔄 REROLL CARDS (%d LEFT)" % rerolls_remaining
		reroll_btn.pressed.connect(_on_reroll)
		cards_container.add_child(reroll_btn)

func _on_reroll() -> void:
	if rerolls_remaining > 0:
		rerolls_remaining -= 1
		_present_options()

func _on_select_perk(perk: Dictionary) -> void:
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_sfx"): am.play_sfx("pickup")
	_apply_perk_effects(perk)
	get_tree().paused = false
	perk_selected.emit(perk)
	queue_free()

func _apply_perk_effects(perk: Dictionary) -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p = players[0]
		match perk["stat"]:
			"attack_percent":
				if "bonus_attack_stat" in p:
					p.bonus_attack_stat += int(10.0 * perk["value"])
			"crit_chance":
				if p.get("current_weapon") and p.current_weapon:
					p.current_weapon.critical_chance += perk["value"]
			"move_speed":
				if "move_speed" in p:
					p.move_speed += perk["value"]
			"max_hp":
				if "max_hp" in p:
					p.max_hp += perk["value"]
					p.current_hp = min(p.current_hp + perk["value"], p.max_hp)
					EventBus.player_hp_changed.emit(p.current_hp, p.max_hp)
			"defense":
				if "defense" in p:
					p.defense += perk["value"]
