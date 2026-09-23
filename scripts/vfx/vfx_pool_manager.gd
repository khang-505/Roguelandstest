# scripts/vfx/vfx_pool_manager.gd
class_name VFXPoolManager
extends Resource

## Object pooling manager for GPUParticles2D and transient combat VFX instances preventing GC hitches.

signal vfx_spawned(vfx_type: String, position: Vector2)
signal vfx_recycled(vfx_type: String)

static var POOL_TYPES: Array[String] = [
	"sparks",
	"explosion",
	"blood_splatter",
	"dust_cloud",
	"beam_impact",
	"frost_burst",
	"plasma_flash"
]

const DEFAULT_POOL_SIZE_PER_TYPE: int = 20

var available_pools: Dictionary = {}
var active_vfx_count: int = 0

func _init() -> void:
	_initialize_pools()

func _initialize_pools() -> void:
	available_pools.clear()
	for v_type in POOL_TYPES:
		var pool_arr: Array = []
		for i in range(DEFAULT_POOL_SIZE_PER_TYPE):
			pool_arr.append({
				"id": "%s_%d" % [v_type, i],
				"type": v_type,
				"is_active": false,
				"position": Vector2.ZERO,
				"scale": 1.0
			})
		available_pools[v_type] = pool_arr

func spawn_vfx(vfx_type: String, pos: Vector2, scale_override: float = 1.0) -> Dictionary:
	if not available_pools.has(vfx_type):
		return {"success": false, "reason": "vfx_type_not_found"}

	var pool: Array = available_pools[vfx_type]
	for item in pool:
		if not item["is_active"]:
			item["is_active"] = true
			item["position"] = pos
			item["scale"] = scale_override
			active_vfx_count += 1
			vfx_spawned.emit(vfx_type, pos)
			return {"success": true, "vfx_instance": item}

	# If all pooled instances are in use, force recycle oldest or return pooled overflow
	return {"success": false, "reason": "pool_exhausted"}

func recycle_vfx(vfx_instance: Dictionary) -> bool:
	if not vfx_instance or not vfx_instance.has("type") or not vfx_instance.has("id"):
		return false

	var v_type = vfx_instance["type"]
	if not available_pools.has(v_type):
		return false

	var pool: Array = available_pools[v_type]
	for item in pool:
		if item["id"] == vfx_instance["id"] and item["is_active"]:
			item["is_active"] = false
			active_vfx_count = max(0, active_vfx_count - 1)
			vfx_recycled.emit(v_type)
			return true

	return false
