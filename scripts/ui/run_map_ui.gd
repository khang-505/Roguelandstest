# scripts/ui/run_map_ui.gd
class_name RunMapUI
extends Control

## UI Overlay presenting the procedural planet node map graph and node selection.

signal node_selected(node_id: int, node_type: int)

@onready var node_container: Control = $Panel/ScrollContainer/NodeContainer if has_node("Panel/ScrollContainer/NodeContainer") else null
@onready var title_label: Label = $Panel/TitleLabel if has_node("Panel/TitleLabel") else null

var map_mgr: RunMapManager

func setup_map(p_map_mgr: RunMapManager, biome_name: String) -> void:
	map_mgr = p_map_mgr
	if title_label:
		title_label.text = "PLANET EXPEDITION: " + biome_name.to_upper()
	_rebuild_map_display()

func _rebuild_map_display() -> void:
	if node_container == null or map_mgr == null:
		return
		
	for c in node_container.get_children():
		c.queue_free()

	# Render depth columns
	var depth_groups: Dictionary = {}
	for n_id in map_mgr.map_nodes.keys():
		var node = map_mgr.map_nodes[n_id] as RunMapManager.MapNode
		if not depth_groups.has(node.depth):
			depth_groups[node.depth] = []
		depth_groups[node.depth].append(node)

	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 48)
	node_container.add_child(hbox)

	var sorted_depths = depth_groups.keys()
	sorted_depths.sort()

	for d in sorted_depths:
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 24)
		hbox.add_child(vbox)

		for node in depth_groups[d]:
			var btn = Button.new()
			btn.custom_minimum_size = Vector2(140, 50)
			btn.text = node.title + "\n[" + _type_name(node.type) + "]"
			
			if node.is_completed:
				btn.disabled = true
				btn.modulate = Color(0.4, 0.4, 0.4, 1.0)
			elif node.is_accessible:
				btn.disabled = false
				btn.modulate = Color(0.2, 1.0, 0.4, 1.0) # Green accessible
			else:
				btn.disabled = true
				btn.modulate = Color(0.6, 0.6, 0.6, 0.6)

			var n_id = node.id
			var n_type = node.type
			btn.pressed.connect(func(): _on_node_btn_pressed(n_id, n_type))
			vbox.add_child(btn)

func _type_name(t: int) -> String:
	match t:
		RunMapManager.NodeType.START: return "START"
		RunMapManager.NodeType.COMBAT: return "COMBAT"
		RunMapManager.NodeType.ELITE: return "ELITE"
		RunMapManager.NodeType.TREASURE: return "TREASURE"
		RunMapManager.NodeType.EVENT: return "EVENT"
		RunMapManager.NodeType.SHOP: return "SHOP"
		RunMapManager.NodeType.REST: return "REST SITE"
		RunMapManager.NodeType.BOSS: return "BOSS"
	return "UNKNOWN"

func _on_node_btn_pressed(n_id: int, n_type: int) -> void:
	if map_mgr.select_node(n_id):
		var am = get_node_or_null("/root/AudioManager")
		if am and am.has_method("play_sfx"): am.play_sfx("pickup")
		node_selected.emit(n_id, n_type)
		_rebuild_map_display()
