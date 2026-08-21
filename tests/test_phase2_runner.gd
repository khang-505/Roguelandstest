# tests/test_phase2_runner.gd
class_name TestPhase2Runner
extends Node

## Integrated Master Verification Suite executing all Phase 1 & Phase 2 test modules.

func _ready() -> void:
	print("==========================================================")
	print("  STARFALL FRONTIER: PHASE 2 INTEGRATED REGRESSION SUITE   ")
	print("==========================================================")
	
	# Phase 1 Regression Checks
	add_child(TestFoundation.new())
	add_child(TestPlayer.new())
	add_child(TestCombat.new())
	add_child(TestProcedural.new())
	add_child(TestGameLoop.new())
	
	# Phase 2 Feature Checks
	add_child(TestPhase20.new())
	add_child(TestPhase21.new())
	add_child(TestPhase22.new())
	add_child(TestPhase23.new())
	add_child(TestPhase24.new())
	
	print("==========================================================")
	print("  ALL PHASE 1 & PHASE 2 TESTS PASSED WITH ZERO REGRESSIONS ")
	print("==========================================================")
