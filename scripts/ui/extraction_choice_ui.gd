# scripts/ui/extraction_choice_ui.gd
class_name ExtractionChoiceUIController
extends Control

## Popup dialog presented upon successful 5-second extraction channeling.

var beacon_ref: Node = null

func _ready() -> void:
	var return_btn = find_child("ReturnButton", true, false) as Button
	var continue_btn = find_child("ContinueButton", true, false) as Button

	if return_btn:
		return_btn.pressed.connect(_on_return_pressed)
	if continue_btn:
		continue_btn.pressed.connect(_on_continue_pressed)

func _on_return_pressed() -> void:
	GameManager.transfer_backpack_to_stash()
	queue_free()
	GameManager.change_state(GameManager.GameState.HUB)

func _on_continue_pressed() -> void:
	# 1. DO NOT commit rewards to save here! Items stay in the backpack.
	# If the player dies in the next zone, they lose them (True Risk vs Reward!)
	queue_free()
	
	# 2. Advance depth and generate NEW LARGER MAP!
	GameManager.continue_expedition_next_stage()
