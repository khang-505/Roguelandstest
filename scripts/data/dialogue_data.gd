# scripts/data/dialogue_data.gd
class_name DialogueData
extends Resource

## Data structure representing NPC dialogue nodes and choice trees.

@export var dialogue_id: String = ""
@export var npc_name: String = ""
@export var nodes: Dictionary = {}

static func create_sample_commander_dialogue() -> DialogueData:
	var d = DialogueData.new()
	d.dialogue_id = "commander_valkyrie"
	d.npc_name = "Commander Valkyrie"
	d.nodes = {
		"root": {
			"node_id": "root",
			"text": "Operative, Sector 7 has detected heavy Void energy fluctuations. Are you prepared to drop?",
			"choices": [
				{"text": "I'm ready for deployment.", "next_node_id": "deploy", "action": "start_expedition"},
				{"text": "What are our objectives?", "next_node_id": "briefing", "action": ""},
				{"text": "I need more supplies first.", "next_node_id": "exit", "action": "open_shop"}
			]
		},
		"briefing": {
			"node_id": "briefing",
			"text": "Eliminate the Void Sentinel in Sector 7 and secure any Star-Shards you recover.",
			"choices": [
				{"text": "Understood. Launching now.", "next_node_id": "deploy", "action": "start_expedition"},
				{"text": "Goodbye.", "next_node_id": "exit", "action": ""}
			]
		},
		"deploy": {
			"node_id": "deploy",
			"text": "Good luck out there, Operative. Valkyrie out.",
			"choices": []
		},
		"exit": {
			"node_id": "exit",
			"text": "Return when you're geared up.",
			"choices": []
		}
	}
	return d
