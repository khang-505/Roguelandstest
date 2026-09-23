# scripts/data/quest_data.gd
class_name QuestData
extends Resource

## Data class representing Bounties, Contracts, and Quests.

enum QuestType { KILL, COLLECT, SURVIVE, BOSS }

@export var quest_id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var type: QuestType = QuestType.KILL
@export var target_id: String = "" # e.g. "ash_beetle" or "ember_ore" or "boss_vanguard"
@export var required_amount: int = 5
@export var current_amount: int = 0
@export var rewards: Dictionary = {"credits": 500, "shards": 50}
@export var is_completed: bool = false
@export var is_claimed: bool = false

func add_progress(amount: int = 1) -> bool:
	if is_completed:
		return false
	current_amount = min(required_amount, current_amount + amount)
	if current_amount >= required_amount:
		is_completed = true
		return true # Newly completed
	return false

static var PRESETS: Dictionary = {
	"bounty_beetles": {
		"id": "bounty_beetles",
		"title": "Bug Hunt",
		"description": "Eliminate 5 Ash Beetles in Sector 1.",
		"type": QuestType.KILL,
		"target_id": "ash_beetle",
		"required_amount": 5,
		"rewards": {"credits": 300, "shards": 25}
	},
	"bounty_ore": {
		"id": "bounty_ore",
		"title": "Ember Mining",
		"description": "Collect 10 Ember Ore samples.",
		"type": QuestType.COLLECT,
		"target_id": "ember_ore",
		"required_amount": 10,
		"rewards": {"credits": 500, "shards": 40}
	},
	"boss_hunt": {
		"id": "boss_hunt",
		"title": "Sentinel Execution",
		"description": "Defeat the Sector 1 Boss Sentinel.",
		"type": QuestType.BOSS,
		"target_id": "boss_sentinel",
		"required_amount": 1,
		"rewards": {"credits": 1500, "shards": 150}
	}
}

static func create_preset(id: String) -> QuestData:
	if not PRESETS.has(id):
		return null
	var p = PRESETS[id]
	var q = QuestData.new()
	q.quest_id = p["id"]
	q.title = p["title"]
	q.description = p["description"]
	q.type = p["type"]
	q.target_id = p["target_id"]
	q.required_amount = p["required_amount"]
	q.rewards = p["rewards"]
	return q
