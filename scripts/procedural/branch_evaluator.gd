# scripts/procedural/branch_evaluator.gd
class_name BranchEvaluator
extends Node

## Calculates branch utility value based on Risk vs Reward equation and Player State.

static func calculate_branch_value(
	branch: Object,
	player_hp_percent: float = 1.0,
	player_credits: int = 100
) -> float:
	if branch == null:
		return 0.0

	var reward = branch.get("reward_rating") as float if "reward_rating" in branch else 0.5
	var risk = branch.get("risk_rating") as float if "risk_rating" in branch else 0.5
	var b_type = branch.get("branch_type") as String if "branch_type" in branch else ""

	var state_modifier = 0.0
	if player_hp_percent < 0.4 and b_type == "RESOURCE_SHOP":
		state_modifier += 0.4 # Higher value on Shop/Heal when HP is low
	elif player_hp_percent > 0.8 and b_type == "RISK_ELITE":
		state_modifier += 0.3 # Higher value on Elite when HP is high
	elif player_credits > 150 and b_type == "RESOURCE_SHOP":
		state_modifier += 0.2

	var final_value = (reward * 100.0) - (risk * 50.0) + (state_modifier * 30.0)
	return max(0.0, final_value)
