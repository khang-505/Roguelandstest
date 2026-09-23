# scripts/combat/ranged_ammo_controller.gd
class_name RangedAmmoController
extends RefCounted

## Controller managing Magazine Ammo, Reload Cancel Windows, Energy Overheat heat accumulation, and Cooling Lockouts.

var weapon_data: Resource
var current_ammo: int = 12
var is_reloading: bool = false
var reload_timer: float = 0.0

var current_heat: float = 0.0
var is_overheated: bool = false
var overheat_cooldown_timer: float = 0.0

signal ammo_changed(current: int, max_capacity: int)
signal reload_started(duration: float)
signal reload_completed()
signal heat_changed(current_heat: float, is_overheated: bool)

func _init(data: Resource) -> void:
	weapon_data = data
	if weapon_data:
		if weapon_data.uses_energy:
			current_heat = 0.0
		else:
			current_ammo = weapon_data.magazine_capacity

func can_fire() -> bool:
	if not weapon_data:
		return false
		
	if weapon_data.uses_energy:
		return not is_overheated
	else:
		return current_ammo > 0 and not is_reloading

func consume_shot() -> bool:
	if not can_fire():
		return false
		
	if weapon_data.uses_energy:
		current_heat = min(100.0, current_heat + weapon_data.heat_per_shot)
		if current_heat >= 100.0:
			is_overheated = true
			overheat_cooldown_timer = 2.0 # 2s lockout on overheat
		emit_signal("heat_changed", current_heat, is_overheated)
		return true
	else:
		current_ammo = max(0, current_ammo - 1)
		emit_signal("ammo_changed", current_ammo, weapon_data.magazine_capacity)
		if current_ammo == 0:
			start_reload()
		return true

func start_reload() -> bool:
	if not weapon_data or weapon_data.uses_energy or is_reloading or current_ammo == weapon_data.magazine_capacity:
		return false
		
	is_reloading = true
	reload_timer = weapon_data.reload_duration
	emit_signal("reload_started", reload_timer)
	return true

func cancel_reload() -> void:
	if is_reloading:
		is_reloading = false
		reload_timer = 0.0

func update(delta: float) -> void:
	if not weapon_data:
		return
		
	if weapon_data.uses_energy:
		if is_overheated:
			overheat_cooldown_timer -= delta
			if overheat_cooldown_timer <= 0.0:
				is_overheated = false
		else:
			current_heat = max(0.0, current_heat - (weapon_data.cool_rate * delta))
		emit_signal("heat_changed", current_heat, is_overheated)
	else:
		if is_reloading:
			reload_timer -= delta
			if reload_timer <= 0.0:
				is_reloading = false
				current_ammo = weapon_data.magazine_capacity
				emit_signal("ammo_changed", current_ammo, weapon_data.magazine_capacity)
				emit_signal("reload_completed")
