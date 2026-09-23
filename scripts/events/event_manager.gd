# scripts/events/event_manager.gd
class_name EventManager
extends Node

## Handles non-combat anomaly events and interactive choices with risk/reward mechanics.

const EVENT_DEFINITIONS: Array = [
	{
		"id": "ancient_shrine",
		"title": "Ancient Alien Shrine",
		"description": "An eerie glowing monument hums with temporal dark matter.",
		"options": [
			{
				"text": "Touch the Shrine (+20% Attack, -15% Max HP)",
				"action": "shrine_power"
			},
			{
				"text": "Siphon Energy (Gain 150 Credits)",
				"action": "shrine_credits"
			},
			{
				"text": "Leave in peace",
				"action": "leave"
			}
		]
	},
	{
		"id": "broken_robot",
		"title": "Dismantled Scout Unit",
		"description": "A rogue security automaton lies sparking on the cavern floor.",
		"options": [
			{
				"text": "Repair Power Core (Spend 50 Credits -> Gain Rare Weapon)",
				"action": "repair_bot"
			},
			{
				"text": "Scrap for Parts (Gain 3 Ember Ores)",
				"action": "scrap_bot"
			},
			{
				"text": "Ignore",
				"action": "leave"
			}
		]
	},
	{
		"id": "black_market",
		"title": "Smuggler's Haven",
		"description": "A shadowy merchant offers questionable high-grade technology.",
		"options": [
			{
				"text": "Buy Experimental Stim (+10% Crit Chance for 100 Credits)",
				"action": "buy_stim"
			},
			{
				"text": "Heal to Full (50 Credits)",
				"action": "heal_full"
			},
			{
				"text": "Decline",
				"action": "leave"
			}
		]
	}
]

static func get_random_event(seed_val: int) -> Dictionary:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_val
	var idx = rng.randi() % EVENT_DEFINITIONS.size()
	return EVENT_DEFINITIONS[idx]
