# scripts/data/artifact_data.gd
class_name ArtifactData
extends Resource

## Data class representing Artifact items with passive stats and dynamic proc triggers.

enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, MYTHIC }
enum ProcTrigger { NONE, ON_HIT, ON_CRIT, ON_DASH, ON_KILL, ON_LOW_HP, ON_ABILITY, ON_TAKE_DAMAGE }

@export var artifact_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var rarity: Rarity = Rarity.COMMON

## Dictionary of static passive stat bonuses (e.g. {"bonus_attack": 10, "crit_chance": 0.05})
@export var passive_stats: Dictionary = {}

## Dynamic Proc properties
@export var proc_trigger: ProcTrigger = ProcTrigger.NONE
@export var proc_chance: float = 1.0 # 0.0 to 1.0 (1.0 = 100%)
@export var proc_cooldown: float = 0.0 # Internal cooldown in seconds
@export var proc_effect_id: String = ""
@export var proc_value: float = 0.0 # Generic numeric parameter for proc

@export var tags: Array[String] = []

## Runtime proc tracking state
var last_proc_time: float = -999.0

func is_on_cooldown(current_time: float) -> bool:
	if proc_cooldown <= 0.0:
		return false
	return (current_time - last_proc_time) < proc_cooldown

func trigger_proc(current_time: float) -> bool:
	if is_on_cooldown(current_time):
		return false
	last_proc_time = current_time
	return true
