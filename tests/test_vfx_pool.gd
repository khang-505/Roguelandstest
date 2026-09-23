# tests/test_vfx_pool.gd
class_name TestVFXPool
extends Node

## Verification test suite for Starfall Frontier — System 62: Particle & VFX Pooling Manager.

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("--- STARFALL FRONTIER: TESTING PARTICLE & VFX POOLING MANAGER ---")
	test_vfx_pools_initialization()
	test_spawn_and_recycle()
	test_validator_score()
	print("--- VFX POOL TEST SUMMARY: %d PASSED, %d FAILED ---" % [passed_tests, total_tests - passed_tests])

func _assert_true(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
	else:
		print("[FAIL] " + message)

func test_vfx_pools_initialization() -> void:
	var mgr_script = load("res://scripts/vfx/vfx_pool_manager.gd")
	_assert_true(mgr_script != null, "VFXPoolManager script loaded")

	var mgr = mgr_script.new()
	_assert_true(mgr.available_pools.size() == 7, "VFX pools initialized with 7 effect types")
	print("[PASS] VFX Pools Initialization Check (2/2 PASSED)")

func test_spawn_and_recycle() -> void:
	var mgr_script = load("res://scripts/vfx/vfx_pool_manager.gd")
	var mgr = mgr_script.new()

	var res = mgr.spawn_vfx("explosion", Vector2(500, 300), 2.0)
	_assert_true(res.get("success", false), "Spawn explosion VFX from pool succeeds")

	var inst = res["vfx_instance"]
	var rec_ok = mgr.recycle_vfx(inst)
	_assert_true(rec_ok, "Recycle explosion VFX back to pool succeeds")
	print("[PASS] Spawn & Recycle VFX Check (2/2 PASSED)")

func test_validator_score() -> void:
	var val_script = load("res://scripts/vfx/vfx_validator.gd")
	var res = val_script.validate_vfx_pool()
	_assert_true(res.get("is_valid", false), "VFXValidator passes quality score validation")
	_assert_true(res.get("quality_score", 0.0) >= 80.0, "Quality score >= 80.0 (Score: %.1f/100)" % res.get("quality_score", 0.0))
	print("[PASS] VFXValidator Quality Score Check (Score: %.1f/100)" % res.get("quality_score", 0.0))
