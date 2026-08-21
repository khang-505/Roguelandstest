# scripts/core/object_pool.gd
class_name ObjectPool
extends Node

## High-performance pre-allocated object memory pool to maintain a stable 60 FPS target.

static var pools: Dictionary = {} # scene_path -> Array[Node2D] (inactive)
static var active_objects: Dictionary = {} # instance_id -> scene_path
static var max_pool_size: int = 100

static func acquire(scene: PackedScene, parent: Node) -> Node2D:
	if scene == null or parent == null:
		return null

	var scene_path = scene.resource_path
	if not pools.has(scene_path):
		pools[scene_path] = []

	var inactive_list: Array = pools[scene_path]
	var obj: Node2D = null

	while inactive_list.size() > 0:
		var candidate = inactive_list.pop_back() as Node2D
		if is_instance_valid(candidate):
			obj = candidate
			break

	if obj == null:
		obj = scene.instantiate() as Node2D
		parent.add_child(obj)
	else:
		if obj.get_parent() != parent:
			if obj.get_parent():
				obj.get_parent().remove_child(obj)
			parent.add_child(obj)

	active_objects[obj.get_instance_id()] = scene_path
	obj.visible = true
	obj.set_process(true)
	obj.set_physics_process(true)
	return obj

static func release(obj: Node2D) -> bool:
	if obj == null or not is_instance_valid(obj):
		return false

	var inst_id = obj.get_instance_id()
	if not active_objects.has(inst_id):
		return false # Double-release guard

	var scene_path: String = active_objects[inst_id]
	active_objects.erase(inst_id)

	obj.visible = false
	obj.set_process(false)
	obj.set_physics_process(false)
	obj.position = Vector2(-9999, -9999) # Hide out of bounds

	if not pools.has(scene_path):
		pools[scene_path] = []

	var inactive_list: Array = pools[scene_path]
	if inactive_list.size() < max_pool_size:
		inactive_list.append(obj)
	else:
		obj.queue_free() # Exceeding max pool cap safely frees object

	return true

static func get_active_count() -> int:
	return active_objects.size()
