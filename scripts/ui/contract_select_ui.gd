# scripts/ui/contract_select_ui.gd
class_name ContractSelectUIController
extends Control

## UI Controller for selecting optional Expedition Contracts.

@onready var desc_label: Label = $VBoxContainer/DescLabel if has_node("VBoxContainer/DescLabel") else null

func _ready() -> void:
	update_display()

func update_display() -> void:
	if desc_label:
		var c_id = RewardManager.active_contract_id
		var contract = ContractData.get_contract(c_id)
		if contract:
			desc_label.text = "Selected Contract: %s\n%s" % [contract.display_name, contract.description]
		else:
			desc_label.text = "Selected Contract: Standard Expedition (No Multipliers)"

func _on_select_no_healing_pressed() -> void:
	RewardManager.select_contract("no_healing")
	update_display()

func _on_select_speed_run_pressed() -> void:
	RewardManager.select_contract("speed_run")
	update_display()

func _on_close_pressed() -> void:
	visible = false
