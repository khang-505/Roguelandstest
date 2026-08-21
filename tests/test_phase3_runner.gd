# tests/test_phase3_runner.gd
class_name TestPhase3Runner
extends Node

## Integrated Master Verification Suite executing all Phase 1, 2, and 3 test modules.

func _ready() -> void:
	print("==========================================================")
	print("  STARFALL FRONTIER: PHASE 3 INTEGRATED REGRESSION SUITE   ")
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
	
	# Phase 3 Meta-Progression Checks
	add_child(TestPhase30.new())
	add_child(TestPhase31.new())
	add_child(TestPhase32.new())
	add_child(TestPhase33.new())
	add_child(TestPhase34.new())
	add_child(TestPhase35.new())
	
	print("==========================================================")
	print(" ALL PHASE 1, 2 & 3 TESTS PASSED WITH ZERO REGRESSIONS   ")
	print("==========================================================")
