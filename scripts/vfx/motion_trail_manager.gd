# scripts/vfx/motion_trail_manager.gd
class_name MotionTrailManager
extends Node2D

## Dynamic ribbon/trail manager for weapon swings, dash ghosts, and high-velocity projectiles.

signal trail_created(trail_id: String, target_path: NodePath)

@export var max_points: int = 12
@export var trail_lifetime: float = 0.3 # Fade duration in seconds
@export var trail_color: Color = Color(0.2, 0.8, 1.0, 0.8) # Electric Cyan

var active_trails: Dictionary = {}

func create_trail(trail_id: String, target_node: Node2D, color_override: Color = Color.WHITE) -> Dictionary:
	if not target_node:
		return {"success": false, "reason": "invalid_target"}

	var col = color_override if color_override != Color.WHITE else trail_color
	var trail_info = {
		"trail_id": trail_id,
		"target": target_node,
		"points": [target_node.global_position],
		"color": col,
		"max_points": max_points,
		"lifetime": trail_lifetime,
		"is_active": true
	}

	active_trails[trail_id] = trail_info
	trail_created.emit(trail_id, target_node.get_path())
	return {"success": true, "trail_info": trail_info}

func update_trail(trail_id: String, new_pos: Vector2) -> bool:
	if not active_trails.has(trail_id):
		return false

	var info = active_trails[trail_id]
	if not info["is_active"]:
		return false

	var points: Array = info["points"]
	points.append(new_pos)
	if points.size() > info["max_points"]:
		points.remove_at(0)

	info["points"] = points
	return true

func stop_trail(trail_id: String) -> bool:
	if not active_trails.has(trail_id):
		return false
	active_trails[trail_id]["is_active"] = false
	active_trails.erase(trail_id)
	return true
