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
	GameManager.commit_run_rewards_to_save()
	queue_free()
	GameManager.change_state(GameManager.GameState.RESULTS)

func _on_continue_pressed() -> void:
	# Save current materials secured so far
	GameManager.commit_run_rewards_to_save()

	if beacon_ref and is_instance_valid(beacon_ref):
		if beacon_ref.has_method("reset_beacon"):
			beacon_ref.reset_beacon()

	queue_free()
