# scripts/ui/dialogue_engine.gd
class_name DialogueEngine
extends Resource

## Manages dialogue tree traversal, choice selections, action triggers, and active NPC conversations.

signal dialogue_started(npc_name: String, node_id: String, text: String, choices: Array)
signal dialogue_node_changed(node_id: String, text: String, choices: Array)
signal dialogue_action_triggered(action: String)
signal dialogue_ended()

var current_dialogue: DialogueData = null
var current_node_id: String = ""
var is_active: bool = false

func start_dialogue(data: DialogueData, start_node: String = "root") -> bool:
	if not data or not data.nodes.has(start_node):
		return false

	current_dialogue = data
	current_node_id = start_node
	is_active = true

	var node = current_dialogue.nodes[current_node_id]
	dialogue_started.emit(data.npc_name, current_node_id, node["text"], node.get("choices", []))
	return true

func select_choice(choice_index: int) -> bool:
	if not is_active or not current_dialogue or not current_dialogue.nodes.has(current_node_id):
		return false

	var node = current_dialogue.nodes[current_node_id]
	var choices: Array = node.get("choices", [])

	if choice_index < 0 or choice_index >= choices.size():
		return false

	var choice = choices[choice_index]
	var next_node = str(choice.get("next_node_id", ""))
	var action = str(choice.get("action", ""))

	if action != "":
		dialogue_action_triggered.emit(action)

	if next_node != "" and current_dialogue.nodes.has(next_node):
		current_node_id = next_node
		var next = current_dialogue.nodes[current_node_id]
		dialogue_node_changed.emit(current_node_id, next["text"], next.get("choices", []))
		if next.get("choices", []).size() == 0:
			end_dialogue()
	else:
		end_dialogue()

	return true

func end_dialogue() -> void:
	is_active = false
	current_dialogue = null
	current_node_id = ""
	dialogue_ended.emit()
