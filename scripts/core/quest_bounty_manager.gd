# scripts/core/quest_bounty_manager.gd
class_name QuestBountyManager
extends Resource

## Objective tracking engine for bounties, contracts, and quest completion rewards.

signal quest_updated(quest_id: String, current: int, required: int)
signal quest_completed(quest_id: String, rewards: Dictionary)
signal quest_claimed(quest_id: String, rewards: Dictionary)

var active_quests: Array[QuestData] = []

func accept_quest(quest: QuestData) -> bool:
	if not quest:
		return false
	for q in active_quests:
		if q.quest_id == quest.quest_id:
			return false # Already active
	active_quests.append(quest)
	return true

func notify_event(type: int, target_id: String, amount: int = 1) -> void:
	for quest in active_quests:
		if quest.is_completed:
			continue
		if quest.type == type and (quest.target_id == "" or quest.target_id == target_id):
			var newly_completed = quest.add_progress(amount)
			quest_updated.emit(quest.quest_id, quest.current_amount, quest.required_amount)
			if newly_completed:
				quest_completed.emit(quest.quest_id, quest.rewards)

func claim_reward(quest_id: String) -> Dictionary:
	for quest in active_quests:
		if quest.quest_id == quest_id:
			if not quest.is_completed:
				return {"success": false, "reason": "not_completed"}
			if quest.is_claimed:
				return {"success": false, "reason": "already_claimed"}

			quest.is_claimed = true
			quest_claimed.emit(quest_id, quest.rewards)
			return {"success": true, "rewards": quest.rewards}

	return {"success": false, "reason": "quest_not_found"}
