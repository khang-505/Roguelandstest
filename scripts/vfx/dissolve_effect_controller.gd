# scripts/vfx/dissolve_effect_controller.gd
class_name DissolveEffectController
extends Node

## Dissolve Shader Parameter Animator for enemy deaths, boss phase transitions, and player teleportation.

signal dissolve_started(target: Node2D, duration: float)
signal dissolve_completed(target: Node2D)

var active_dissolves: Array[Dictionary] = []

func start_dissolve(target: Node2D, duration: float = 0.8, is_reverse: bool = false) -> Dictionary:
	if not target:
		return {"success": false, "reason": "invalid_target"}

	var info = {
		"target": target,
		"duration": duration,
		"elapsed": 0.0,
		"progress": 0.0 if not is_reverse else 1.0,
		"is_reverse": is_reverse,
		"is_completed": false
	}

	active_dissolves.append(info)
	dissolve_started.emit(target, duration)
	return {"success": true, "dissolve_info": info}

func process_dissolves(delta: float) -> void:
	for i in range(active_dissolves.size() - 1, -1, -1):
		var info = active_dissolves[i]
		if not is_instance_valid(info["target"]):
			active_dissolves.remove_at(i)
			continue

		info["elapsed"] += delta
		var t = clampf(info["elapsed"] / info["duration"], 0.0, 1.0)

		if not info["is_reverse"]:
			info["progress"] = t # 0 -> 1 (dissolving away)
		else:
			info["progress"] = 1.0 - t # 1 -> 0 (materializing)

		if t >= 1.0:
			info["is_completed"] = true
			dissolve_completed.emit(info["target"])
			active_dissolves.remove_at(i)
