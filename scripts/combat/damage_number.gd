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
	
	var hit_fx = CPUParticles2D.new()
	hit_fx.emitting = false
	hit_fx.one_shot = true
	hit_fx.explosiveness = 0.9
	hit_fx.amount = 8 if not is_crit else 16
	hit_fx.spread = 180.0
	hit_fx.initial_velocity_min = 40.0
	hit_fx.initial_velocity_max = 100.0
	hit_fx.scale_amount_min = 2.0
	hit_fx.scale_amount_max = 4.0
	hit_fx.color = lbl.modulate
	hit_fx.global_position = pos
	
	var f_timer = Timer.new()
	f_timer.wait_time = 0.5
	f_timer.one_shot = true
	f_timer.autostart = true
	f_timer.timeout.connect(hit_fx.queue_free)
	hit_fx.add_child(f_timer)
	
	parent.add_child(hit_fx)
	hit_fx.emitting = true
	
	parent.add_child(dn)
	return dn

func _physics_process(delta: float) -> void:
	timer += delta
	global_position += velocity * delta
	modulate.a = maxf(0.0, 1.0 - (timer / lifetime))
	if timer >= lifetime:
		queue_free()
