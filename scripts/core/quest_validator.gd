# scripts/core/quest_validator.gd
class_name QuestValidator
extends Resource

## Quality Score Engine evaluating Quest Presets, Objective Notifications, Completion Signals, and Reward Claiming.

static func validate_quest_system() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var data_script = load("res://scripts/data/quest_data.gd")
	var mgr_script = load("res://scripts/core/quest_bounty_manager.gd")

	if not data_script or not mgr_script:
		warnings.append("Quest data or manager script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	var mgr = mgr_script.new()
	var q1 = data_script.create_preset("bounty_beetles") # Needs 5 kills of ash_beetle

	# 1. Quest Acceptance & Presets (30 Points)
	var accepted = mgr.accept_quest(q1)
	if accepted and mgr.active_quests.size() == 1:
		total_score += 30.0
		details["acceptance_score"] = 30.0
	else:
		warnings.append("Quest acceptance check failed")

	# 2. Progress Notification & Completion (25 Points)
	var completed_signal_count = 0
	mgr.quest_completed.connect(func(_id, _rew): completed_signal_count += 1)

	mgr.notify_event(data_script.QuestType.KILL, "ash_beetle", 3)
	mgr.notify_event(data_script.QuestType.KILL, "ash_beetle", 2) # Total 5 -> Completed!

	if q1.is_completed and completed_signal_count == 1:
		total_score += 25.0
		details["progress_completion_score"] = 25.0
	else:
		warnings.append("Progress notification & completion signal check failed")

	# 3. Reward Claiming (25 Points)
	var claim_res = mgr.claim_reward("bounty_beetles")
	if claim_res.get("success", false) and q1.is_claimed:
		total_score += 25.0
		details["claim_reward_score"] = 25.0
	else:
		warnings.append("Reward claiming check failed")

	# 4. Double Claim Guard (20 Points)
	var claim_double = mgr.claim_reward("bounty_beetles")
	if not claim_double.get("success", true) and claim_double.get("reason") == "already_claimed":
		total_score += 20.0
		details["double_claim_score"] = 20.0
	else:
		warnings.append("Double claim guard failed")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
