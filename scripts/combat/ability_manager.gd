# scripts/combat/ability_manager.gd
class_name AbilityManager
extends RefCounted

## Controller managing Ability Activation Pipelines, Charge Regeneration, Cooldowns, Invulnerability i-Frames, and Roguelite Mutations.

var slots: Dictionary = {} # slot_name -> AbilityData
var cooldown_timers: Dictionary = {} # ability_id -> float
var charge_regen_timers: Dictionary = {} # ability_id -> float

signal ability_activated(ability_id: String, effect_info: Dictionary)
signal ability_cooldown_started(ability_id: String, duration: float)
signal charges_changed(ability_id: String, current: int, max_charges: int)

func equip_ability(slot_name: String, ability_data: Resource) -> void:
	if not ability_data:
		return
	slots[slot_name] = ability_data
	cooldown_timers[ability_data.ability_id] = 0.0
	charge_regen_timers[ability_data.ability_id] = 0.0

func activate_ability(
	ability_id: String,
	current_energy: float = 100.0,
	is_combat_disabled: bool = false
) -> Dictionary:
	var ability = _find_ability(ability_id)
	if not ability or is_combat_disabled:
		return {"success": false, "reason": "Disabled or null ability"}
		
	# 1. Check Energy Cost
	if current_energy < ability.energy_cost:
		return {"success": false, "reason": "Insufficient energy"}
		
	# 2. Check Charges & Cooldown
	var cd = cooldown_timers.get(ability_id, 0.0)
	if cd > 0.0 and ability.current_charges <= 0:
		return {"success": false, "reason": "On cooldown"}
		
	if ability.current_charges <= 0:
		return {"success": false, "reason": "No charges available"}
		
	# 3. Consume Charge & Energy
	ability.current_charges -= 1
	cooldown_timers[ability_id] = ability.cooldown
	charge_regen_timers[ability_id] = ability.cooldown
	
	emit_signal("charges_changed", ability_id, ability.current_charges, ability.max_charges)
	emit_signal("ability_cooldown_started", ability_id, ability.cooldown)
	
	# Apply Mutation modifiers if present
	var final_dmg = ability.damage
	if ability.mutation_modifiers.has("damage_multiplier"):
		final_dmg *= float(ability.mutation_modifiers["damage_multiplier"])
		
	var effect_info = {
		"success": true,
		"ability_id": ability_id,
		"ability_name": ability.ability_name,
		"category": ability.category,
		"targeting_type": ability.targeting_type,
		"damage": final_dmg,
		"energy_cost": ability.energy_cost,
		"range_radius": ability.range_radius,
		"duration": ability.duration,
		"i_frames_duration": ability.i_frames_duration,
		"element": ability.element,
		"status_effect": ability.status_effect,
		"remaining_charges": ability.current_charges
	}
	
	emit_signal("ability_activated", ability_id, effect_info)
	return effect_info

func apply_mutation(ability_id: String, mutation_info: Dictionary) -> bool:
	var ability = _find_ability(ability_id)
	if not ability:
		return false
		
	ability.active_mutation_id = mutation_info.get("id", "MUTATION")
	ability.mutation_modifiers = mutation_info
	
	if mutation_info.has("extra_charges"):
		ability.max_charges += int(mutation_info["extra_charges"])
		ability.current_charges += int(mutation_info["extra_charges"])
		
	if mutation_info.has("cooldown_reduction"):
		ability.cooldown = max(1.0, ability.cooldown * (1.0 - float(mutation_info["cooldown_reduction"])))
		
	return true

func on_enemy_killed(cooldown_reduction_bonus: float = 1.5) -> void:
	for a_id in cooldown_timers.keys():
		cooldown_timers[a_id] = max(0.0, cooldown_timers[a_id] - cooldown_reduction_bonus)

func update(delta: float) -> void:
	for a_id in cooldown_timers.keys():
		if cooldown_timers[a_id] > 0.0:
			cooldown_timers[a_id] = max(0.0, cooldown_timers[a_id] - delta)
			
	for slot_name in slots.keys():
		var ability = slots[slot_name]
		var a_id = ability.ability_id
		if ability.current_charges < ability.max_charges:
			var regen = charge_regen_timers.get(a_id, 0.0) - delta
			charge_regen_timers[a_id] = regen
			if regen <= 0.0:
				ability.current_charges += 1
				charge_regen_timers[a_id] = ability.cooldown
				emit_signal("charges_changed", a_id, ability.current_charges, ability.max_charges)

func _find_ability(ability_id: String) -> Resource:
	for slot_name in slots.keys():
		var ab = slots[slot_name]
		if ab and ab.ability_id == ability_id:
			return ab
	return null
