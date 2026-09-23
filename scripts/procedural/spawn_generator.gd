# scripts/procedural/spawn_generator.gd
class_name SpawnGenerator
extends Node

## Spawns tactical enemy wave compositions based on room archetype and depth.

static func spawn_enemies_for_room(
	parent_node: Node2D,
	platform_spots: Array[Vector2],
	archetype: int,
	biome: Object,
	rng: RandomNumberGenerator
) -> Array[Node2D]:
	var spawned: Array[Node2D] = []
	if platform_spots.size() == 0 or biome == null:
		return spawned

	var enemy_count = 2
	match archetype:
		1: enemy_count = rng.randi_range(3, 5) # COMBAT
		7: enemy_count = rng.randi_range(4, 7) # ELITE
		10, 11: enemy_count = 1 # MINI_BOSS, BOSS
		_: enemy_count = rng.randi_range(1, 3)

	var enemy_pool: Array = biome.get("enemy_pool") if "enemy_pool" in biome else ["ash_beetle"]

	for i in range(min(enemy_count, platform_spots.size())):
		var spot = platform_spots[i]
		var e_id = enemy_pool[rng.randi() % enemy_pool.size()] as String
		var scn = _get_enemy_scene(e_id)
		
		if scn:
			var inst = scn.instantiate() as Node2D
			inst.global_position = spot
			if archetype == 7: # ELITE
				inst.set("is_elite", true)
			parent_node.add_child(inst)
			spawned.append(inst)

	return spawned

static func _get_enemy_scene(e_id: String) -> PackedScene:
	var path = "res://scenes/enemies/%s.tscn" % e_id
	if not ResourceLoader.exists(path):
		path = "res://scenes/enemies/ash_beetle.tscn"
	if ResourceLoader.exists(path):
		return load(path) as PackedScene
	return null
