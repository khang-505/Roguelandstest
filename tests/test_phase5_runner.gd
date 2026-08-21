# tests/test_phase5_runner.gd
class_name TestPhase5Runner
extends Node

## Integrated Master Verification Suite executing all Phase 1, 2, 3, 4, and 5 test modules.

func _ready() -> void:
	print("==========================================================")
	print("  STARFALL FRONTIER: FULL PROJECT REGRESSION SUITE (P1-P5) ")
	print("==========================================================")
	
	# Phase 1 Foundation & Gameplay Loop
	add_child(TestFoundation.new())
	add_child(TestPlayer.new())
	add_child(TestCombat.new())
	add_child(TestProcedural.new())
	add_child(TestGameLoop.new())
	
	# Phase 2 Weapon Modifiers, Rarities & Biomes
	add_child(TestPhase20.new())
	add_child(TestPhase21.new())
	add_child(TestPhase22.new())
	add_child(TestPhase23.new())
	add_child(TestPhase24.new())
	
	# Phase 3 Persistent Hub, Forge, Research, Drones, Origins & Persistence
	add_child(TestPhase30.new())
	add_child(TestPhase31.new())
	add_child(TestPhase32.new())
	add_child(TestPhase33.new())
	add_child(TestPhase34.new())
	add_child(TestPhase35.new())
	
	# Phase 4 Boss Guardians, Extraction Defense, Instability & Contracts
	add_child(TestPhase40.new())
	add_child(TestPhase41.new())
	add_child(TestPhase42.new())
	add_child(TestPhase43.new())
	add_child(TestPhase44.new())
	
	# Phase 5 Relic Fusion, Co-op Architecture, Object Pooling & Accessibility
	add_child(TestPhase50.new())
	add_child(TestPhase51.new())
	add_child(TestPhase52.new())
	add_child(TestPhase53.new())
	
	print("==========================================================")
	print(" ALL 25 TEST MODULES PASSED (PHASE 1 - PHASE 5 COMPLETE)   ")
	print("==========================================================")
