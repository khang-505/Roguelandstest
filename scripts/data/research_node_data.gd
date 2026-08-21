# scripts/data/research_node_data.gd
class_name ResearchNodeData
extends Resource

## Data-Driven Research Tree Node for Starfall Frontier Meta-Progression.

@export var node_id: String = "basic_combat"
@export var display_name: String = "Basic Physical Training"
@export var description: String = "Increases maximum player health by 15%."
@export var cost_shards: int = 10
@export var prerequisites: Array[String] = []
@export var required_hub_level: int = 2
@export var stat_target: String = "max_hp"
@export var operation: String = "MULTIPLY"
@export var value: float = 0.15
