# scripts/ui/dialogue_validator.gd
class_name DialogueValidator
extends Resource

## Quality Score Engine evaluating Dialogue Trees, Choice Traversal, Action Triggers, and Lifecycle.

static func validate_dialogue_system() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var data_script = load("res://scripts/data/dialogue_data.gd")
	var engine_script = load("res://scripts/ui/dialogue_engine.gd")

	if not data_script or not engine_script:
		warnings.append("Dialogue data or engine script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	var dialogue = data_script.create_sample_commander_dialogue()
	var engine = engine_script.new()

	# 1. Dialogue Initialization & Start (30 Points)
	var started = engine.start_dialogue(dialogue, "root")
	if started and engine.is_active and engine.current_node_id == "root":
		total_score += 30.0
		details["start_score"] = 30.0
	else:
		warnings.append("Dialogue start initialization failed")

	# 2. Choice Selection Traversal (25 Points)
	# Choice 1 in root ("What are our objectives?") -> node "briefing"
	var choice_res = engine.select_choice(1)
	if choice_res and engine.current_node_id == "briefing":
		total_score += 25.0
		details["traversal_score"] = 25.0
	else:
		warnings.append("Choice selection traversal failed")

	# 3. Action Trigger Signal (25 Points)
	# Choice 0 in briefing ("Understood. Launching now.") -> action "start_expedition"
	var triggered_actions: Array[String] = []
	engine.dialogue_action_triggered.connect(func(act): triggered_actions.append(act))

	engine.select_choice(0)
	if triggered_actions.size() == 1 and triggered_actions[0] == "start_expedition":
		total_score += 25.0
		details["action_trigger_score"] = 25.0
	else:
		warnings.append("Action trigger signal failed")

	# 4. End Dialogue Lifecyle (20 Points)
	if not engine.is_active:
		total_score += 20.0
		details["end_lifecycle_score"] = 20.0
	else:
		warnings.append("End dialogue lifecycle failed")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
