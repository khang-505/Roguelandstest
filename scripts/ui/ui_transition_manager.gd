# scripts/ui/ui_transition_manager.gd
class_name UITransitionManager
extends Node

## Scene Transition & UI Popup Animation Engine supporting Fade, Slide, Scale-Bounce, and Backdrop Blur.

enum TransitionType { FADE, SLIDE_RIGHT, SCALE_BOUNCE, BLUR_BACKDROP }

signal transition_started(target: Control, type: TransitionType, duration: float)
signal transition_completed(target: Control)

var active_transitions: Array[Dictionary] = []

func transition_in(target: Control, type: TransitionType = TransitionType.FADE, duration: float = 0.3) -> Dictionary:
	if not target:
		return {"success": false, "reason": "invalid_target"}

	var info = {
		"target": target,
		"type": type,
		"duration": duration,
		"elapsed": 0.0,
		"progress": 0.0,
		"is_in": true,
		"is_completed": false
	}

	active_transitions.append(info)
	transition_started.emit(target, type, duration)
	return {"success": true, "transition_info": info}

func transition_out(target: Control, type: TransitionType = TransitionType.FADE, duration: float = 0.3) -> Dictionary:
	if not target:
		return {"success": false, "reason": "invalid_target"}

	var info = {
		"target": target,
		"type": type,
		"duration": duration,
		"elapsed": 0.0,
		"progress": 1.0,
		"is_in": false,
		"is_completed": false
	}

	active_transitions.append(info)
	transition_started.emit(target, type, duration)
	return {"success": true, "transition_info": info}

func process_transitions(delta: float) -> void:
	for i in range(active_transitions.size() - 1, -1, -1):
		var info = active_transitions[i]
		if not is_instance_valid(info["target"]):
			active_transitions.remove_at(i)
			continue

		info["elapsed"] += delta
		var t = clampf(info["elapsed"] / info["duration"], 0.0, 1.0)

		if info["is_in"]:
			info["progress"] = t # 0 -> 1
		else:
			info["progress"] = 1.0 - t # 1 -> 0

		# Update properties based on transition type
		var target: Control = info["target"] as Control
		var p = info["progress"]
		match info["type"]:
			TransitionType.FADE:
				target.modulate.a = p
			TransitionType.SCALE_BOUNCE:
				target.scale = Vector2.ONE * p
				target.modulate.a = p
			TransitionType.SLIDE_RIGHT:
				target.position.x = (1.0 - p) * -300.0
				target.modulate.a = p

		if t >= 1.0:
			info["is_completed"] = true
			transition_completed.emit(info["target"])
			active_transitions.remove_at(i)
