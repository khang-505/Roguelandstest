# scripts/procedural/interactive_object_data.gd
class_name InteractiveObjectData
extends Resource

## Data Resource defining interaction categories, required keys/abilities, prompts, and link targets.

enum InteractionType {
	DOOR,
	LEVER,
	SWITCH,
	BUTTON,
	TERMINAL,
	ELEVATOR,
	BRIDGE,
	MOVING_PLATFORM,
	CHEST,
	SHRINE,
	NPC,
	RESOURCE_NODE,
	POWER_NODE,
	TELEPORTER,
	TRAP,
	HAZARD,
	BREAKABLE_OBJECT,
	PUZZLE
}

@export var object_id: String = ""
@export var interaction_type: InteractionType = InteractionType.LEVER
@export var interaction_prompt: String = "[E] Pull Lever"
@export var required_item: String = ""
@export var required_ability: String = "NONE"

@export var one_time_use: bool = false
@export var cooldown: float = 0.5

@export var linked_object_ids: Array[String] = []

func _init(
	p_id: String = "",
	p_type: InteractionType = InteractionType.LEVER,
	p_prompt: String = "[E] Interact",
	p_item: String = ""
) -> void:
	object_id = p_id
	interaction_type = p_type
	interaction_prompt = p_prompt
	required_item = p_item

static func get_type_name(t: InteractionType) -> String:
	match t:
		InteractionType.DOOR: return "Security Gate Door"
		InteractionType.LEVER: return "Mechanical Toggle Lever"
		InteractionType.SWITCH: return "Floor Pressure Switch"
		InteractionType.TERMINAL: return "Sci-Fi Console Terminal"
		InteractionType.ELEVATOR: return "Subterranean Shaft Elevator"
		InteractionType.BRIDGE: return "Deployable Bridge"
		InteractionType.CHEST: return "Loot Container Chest"
		InteractionType.SHRINE: return "Ancient Artifact Shrine"
		InteractionType.POWER_NODE: return "Regional Power Core Relay"
		InteractionType.TRAP: return "Telegraphed Environmental Trap"
		InteractionType.PUZZLE: return "Interactive Logic Mechanism"
	return "Interactive Object"
