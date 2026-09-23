# scripts/vfx/trail_validator.gd
class_name TrailValidator
extends Resource

## Quality Score Engine evaluating Motion Trail Creation, Point Sampling, Buffer Caps, and Trail Stop Lifecycles.

static func validate_trail_system() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var mgr_script = load("res://scripts/vfx/motion_trail_manager.gd")
	if not mgr_script:
		warnings.append("MotionTrailManager script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	var mgr = mgr_script.new()
	var dummy_target = Node2D.new()
	dummy_target.global_position = Vector2(100, 100)

	# 1. Trail Creation (30 Points)
	var create_res = mgr.create_trail("dash_trail_1", dummy_target, Color.CYAN)
	if create_res.get("success", false) and mgr.active_trails.size() == 1:
		total_score += 30.0
		details["create_score"] = 30.0
	else:
		warnings.append("Trail creation check failed")

	# 2. Point Sampling & Buffer Cap (25 Points)
	for i in range(20): # Exceed max_points (12)
		mgr.update_trail("dash_trail_1", Vector2(100 + i * 10, 100))

	var info = mgr.active_trails.get("dash_trail_1", {})
	var pts: Array = info.get("points", [])

	if pts.size() == 12: # Capped at max_points
		total_score += 25.0
		details["point_cap_score"] = 25.0
	else:
		warnings.append("Trail point sampling buffer cap failed (Size %d)" % pts.size())

	# 3. Stop Trail (25 Points)
	var stop_ok = mgr.stop_trail("dash_trail_1")
	if stop_ok and mgr.active_trails.size() == 0:
		total_score += 25.0
		details["stop_score"] = 25.0
	else:
		warnings.append("Stop trail lifecycle failed")

	# 4. Null Target Guard (20 Points)
	var null_res = mgr.create_trail("bad_trail", null)
	if not null_res.get("success", true) and null_res.get("reason") == "invalid_target":
		total_score += 20.0
		details["null_guard_score"] = 20.0
	else:
		warnings.append("Null target guard failed")

	dummy_target.free()
	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
