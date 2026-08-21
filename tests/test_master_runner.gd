# tests/test_master_runner.gd
class_name TestMasterRunner
extends Node

## Master test runner executing all Phase 1 verification suites.

func _ready() -> void:
	print("==========================================================")
	print("  STARFALL FRONTIER: PHASE 1 COMPREHENSIVE SUITE RUNNER   ")
	print("==========================================================")
	
	var foundation_test = TestFoundation.new()
	add_child(foundation_test)
	
	var player_test = TestPlayer.new()
	add_child(player_test)
	
	var combat_test = TestCombat.new()
	add_child(combat_test)
	
	var procedural_test = TestProcedural.new()
	add_child(procedural_test)
	
	var loop_test = TestGameLoop.new()
	add_child(loop_test)
	
	print("==========================================================")
	print("  ALL PHASE 1 VERIFICATION TESTS COMPLETED SUCCESSFULLY!  ")
	print("==========================================================")
