# scripts/ui/minimap_ui.gd
class_name MinimapUIController
extends Control

## Realtime Exploration Minimap UI overlay displaying macro graph discovery state & Fog of War.

var graph: Object = null
var current_node_id: int = 0
@onready var grid_container: GridContainer = $MarginContainer/GridContainer if has_node("MarginContainer/GridContainer") else null

func _ready() -> void:
	add_to_group("minimap_ui")
	update_minimap()

func set_graph(p_graph: Object, p_current_id: int) -> void:
	graph = p_graph
	current_node_id = p_current_id
	update_minimap()

func update_minimap() -> void:
	if grid_container == null or graph == null or not "nodes" in graph:
		return

	for c in grid_container.get_children():
		c.queue_free()

	var nodes_dict = graph.nodes as Dictionary

	for node_id in nodes_dict.keys():
		var node = nodes_dict[node_id] as Object
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(36, 36)

		var is_visited = node.get("is_visited") as bool if "is_visited" in node else false
		var n_id = node.get("id") as int if "id" in node else -1
		var archetype = node.get("archetype") as int if "archetype" in node else 1

		if n_id == current_node_id:
			btn.text = "★"
			btn.modulate = Color(1.0, 0.9, 0.2, 1.0) # Current room gold
		elif is_visited:
			btn.text = _archetype_icon(archetype)
			btn.modulate = Color(0.4, 0.9, 0.4, 1.0) # Visited green
		elif archetype == 8: # SECRET
			btn.text = "░"
			btn.modulate = Color(0.8, 0.3, 0.9, 0.8) # Secret cyan/purple
		else:
			btn.text = _archetype_icon(archetype)
			btn.modulate = Color(0.7, 0.7, 0.7, 0.7) # Unvisited

		grid_container.add_child(btn)

func _archetype_icon(archetype: int) -> String:
	match archetype:
		0: return "S" # START
		1: return "C" # COMBAT
		2: return "X" # EXPLORATION
		3: return "$" # TREASURE
		4: return "!" # EVENT
		5: return "M" # SHOP
		6: return "H" # REST
		7: return "E" # ELITE
		8: return "?" # SECRET
		11: return "B" # BOSS
		_: return "●"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_M:
		visible = not visible
