# scripts/procedural/landmark_manager.gd
class_name LandmarkManager
extends Node

## Spawns visual landmark anchors (Ancient Obelisks, Crashed Starships, Crystal Trees, Boss Gates).

static func spawn_landmark_for_room(
	parent_node: Node2D,
	width_tiles: int,
	height_tiles: int,
	tile_size: int,
	archetype: int,
	biome: Object,
	rng: RandomNumberGenerator
) -> Node2D:
	if parent_node == null or biome == null:
		return null

	var landmark_node = Node2D.new()
	landmark_node.name = "LandmarkAnchor"

	var label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	match archetype:
		11: # BOSS
			label.text = "❖ GUARDIAN CITADEL GATE ❖"
			label.modulate = Color(1.0, 0.3, 0.2, 0.9)
		0: # START
			label.text = "▲ STARFALL LANDING POD ▲"
			label.modulate = Color(0.2, 0.9, 0.4, 0.9)
		3: # TREASURE
			label.text = "★ ANCIENT STAR CACHE ★"
			label.modulate = Color(1.0, 0.85, 0.2, 0.9)
		_:
			var b_id = biome.get("id") if "id" in biome else "emberwild"
			match b_id:
				"frostgrave": label.text = "❄ FROST CRYOCRYSTAL MONOLITH ❄"
				"verdant_abyss": label.text = "🌿 GIANT BIOLUMINESCENT TREE 🌿"
				"alien_void": label.text = "🌌 VOID ANOMALY RIFT 🌌"
				_: label.text = "🔥 EMBERWILD VOLCANIC SPIRE 🔥"
			label.modulate = Color(0.6, 0.8, 1.0, 0.8)

	label.position = Vector2(-100, -20)
	landmark_node.add_child(label)

	var pos = Vector2((width_tiles * 0.5) * tile_size, (height_tiles - 4) * tile_size)
	landmark_node.position = pos
	parent_node.add_child(landmark_node)

	return landmark_node
