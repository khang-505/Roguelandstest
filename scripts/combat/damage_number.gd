# scripts/combat/damage_number.gd
class_name DamageNumber
extends Node2D

## Floating Damage Indicator component displaying damage amount, critical hit styling, and damage types.

var velocity: Vector2 = Vector2(0, -50)
var lifetime: float = 0.6
var timer: float = 0.0

@onready var label: Label = $Label if has_node("Label") else null

static func create(pos: Vector2, amount: int, is_crit: bool, type_str: String, parent: Node) -> DamageNumber:
	var dn = DamageNumber.new()
	dn.global_position = pos + Vector2(randf_range(-8, 8), -10)
	
	var lbl = Label.new()
	lbl.name = "Label"
	lbl.text = str(amount)
	if is_crit:
		lbl.text += "!"
		lbl.modulate = Color(1.0, 0.9, 0.1, 1.0)
	else:
		match type_str:
			"FIRE": lbl.modulate = Color(1.0, 0.4, 0.1, 1.0)
			"ICE": lbl.modulate = Color(0.3, 0.9, 1.0, 1.0)
			"VOID": lbl.modulate = Color(0.7, 0.3, 1.0, 1.0)
			_: lbl.modulate = Color(1.0, 1.0, 1.0, 1.0)
	dn.add_child(lbl)
	parent.add_child(dn)
	return dn

func _physics_process(delta: float) -> void:
	timer += delta
	global_position += velocity * delta
	modulate.a = maxf(0.0, 1.0 - (timer / lifetime))
	if timer >= lifetime:
		queue_free()
