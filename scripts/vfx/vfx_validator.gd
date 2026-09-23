# scripts/vfx/vfx_validator.gd
class_name VFXValidator
extends Resource

## Quality Score Engine evaluating VFX Object Pools, Spawning, Recycling, and Exhaustion Guards.

static func validate_vfx_pool() -> Dictionary:
	var total_score: float = 0.0
	var details: Dictionary = {}
	var warnings: Array[String] = []

	var mgr_script = load("res://scripts/vfx/vfx_pool_manager.gd")
	if not mgr_script:
		warnings.append("VFXPoolManager script missing")
		return {"is_valid": false, "quality_score": 0.0, "details": details, "warnings": warnings}

	var mgr = mgr_script.new()

	# 1. 7 VFX Types Pool Pre-allocation (30 Points)
	if mgr.available_pools.size() == 7:
		total_score += 30.0
		details["pool_types_score"] = 30.0
	else:
		warnings.append("Expected 7 VFX types pre-allocated in pool")

	# 2. Spawn VFX Instance (25 Points)
	var spawn_res = mgr.spawn_vfx("sparks", Vector2(100, 200), 1.5)
	if spawn_res.get("success", false) and mgr.active_vfx_count == 1:
		total_score += 25.0
		details["spawn_score"] = 25.0
	else:
		warnings.append("Spawn VFX instance check failed")

	# 3. Recycle VFX Instance (25 Points)
	var inst = spawn_res.get("vfx_instance", {})
	var recycle_res = mgr.recycle_vfx(inst)

	if recycle_res and mgr.active_vfx_count == 0 and not inst.get("is_active", true):
		total_score += 25.0
		details["recycle_score"] = 25.0
	else:
		warnings.append("Recycle VFX instance check failed")

	# 4. Unknown VFX Type Guard (20 Points)
	var spawn_bad = mgr.spawn_vfx("unknown_laser", Vector2.ZERO)
	if not spawn_bad.get("success", true) and spawn_bad.get("reason") == "vfx_type_not_found":
		total_score += 20.0
		details["type_guard_score"] = 20.0
	else:
		warnings.append("Unknown VFX type guard failed")

	var is_valid = total_score >= 80.0 and warnings.size() == 0

	return {
		"is_valid": is_valid,
		"quality_score": total_score,
		"details": details,
		"warnings": warnings
	}
