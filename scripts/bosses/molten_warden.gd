# scripts/bosses/molten_warden.gd
class_name MoltenWarden
extends BossBase

## Original Biome Guardian Boss: The Molten Warden (Emberwild Guardian).

@export var lava_hazard_scene: PackedScene

var base_attack_cd: float = 2.0
var active_lava_hazards: Array[Node2D] = []

func _ready() -> void:
	boss_id = "molten_warden"
	display_name = "The Molten Warden"
	max_hp = 400
	current_hp = max_hp
	move_speed = 45.0
	super._ready()

func _on_phase_changed(_old_phase: BossPhase, new_phase: BossPhase) -> void:
	match new_phase:
		BossPhase.PHASE_2:
			base_attack_cd = 1.6
			_spawn_lava_hazards()
		BossPhase.PHASE_3:
			if not is_enraged:
				is_enraged = true
				base_attack_cd = 1.0 # Enraged +50% attack speed applied ONCE
				move_speed = 70.0
				_trigger_arena_eruption()

func _execute_boss_attack() -> void:
	attack_cooldown_timer = base_attack_cd
	if target_player and is_instance_valid(target_player):
		var dist = global_position.distance_to(target_player.global_position)
		if dist <= 40.0:
			if target_player.has_method("take_damage"):
				var dmg = 25 if not is_enraged else 35
				target_player.take_damage(dmg)

func _spawn_lava_hazards() -> void:
	# Spawns maximum 3 lava pool hazards in arena
	for i in range(3):
		var hazard = Node2D.new()
		hazard.position = global_position + Vector2((i - 1) * 60, 0)
		active_lava_hazards.append(hazard)

func _trigger_arena_eruption() -> void:
	# Enraged phase eruption burst
	if target_player and is_instance_valid(target_player):
		StatusEffectManager.apply_status(target_player, StatusEffectManager.StatusType.BURN, 3.0, 8)

func _die() -> void:
	# Cleanup spawned hazards
	for h in active_lava_hazards:
		if is_instance_valid(h):
			h.queue_free()
	active_lava_hazards.clear()
	super._die()
