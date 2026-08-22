# scripts/data/weapon_data.gd
class_name WeaponData
extends Resource

enum WeaponCategory { MELEE, RANGED, ENERGY, SPECIAL }
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, MYTHIC }
enum DamageType { PHYSICAL, ENERGY, FIRE, ICE, ELECTRIC, VOID, POISON, EXPLOSIVE }

@export var id: String = "plasma_cutter"
@export var display_name: String = "Plasma Cutter"
@export var category: WeaponCategory = WeaponCategory.MELEE
@export var rarity: Rarity = Rarity.COMMON
@export var damage_type: DamageType = DamageType.PHYSICAL
@export var base_damage: int = 18
@export var attack_speed: float = 1.5 # attacks per second
@export var attack_range: float = 32.0
@export var critical_chance: float = 0.10 # 10%
@export var critical_multiplier: float = 1.5
@export var knockback_force: float = 120.0
@export var energy_cost: float = 0.0
@export var projectile_speed: float = 350.0
@export var sprite_texture: Texture2D
@export var affixes: Array[Dictionary] = []

func get_modified_damage() -> int:
	var add_val: float = 0.0
	var mult_val: float = 0.0
	var override_val: float = -1.0
	
	for affix in affixes:
		if affix.get("stat") == "damage":
			var op = affix.get("operation")
			var v = float(affix.get("value", 0.0))
			if op == "ADD":
				add_val += v
			elif op == "MULTIPLY":
				mult_val += v
			elif op == "SET":
				override_val = v
				
	if override_val >= 0.0:
		return int(override_val)
		
	var base = float(base_damage) + add_val
	var final = base * (1.0 + mult_val)
	return max(1, int(final))

func get_modified_attack_speed() -> float:
	var add_val: float = 0.0
	var mult_val: float = 0.0
	
	for affix in affixes:
		if affix.get("stat") == "attack_speed":
			var op = affix.get("operation")
			var v = float(affix.get("value", 0.0))
			if op == "ADD":
				add_val += v
			elif op == "MULTIPLY":
				mult_val += v
				
	var base = attack_speed + add_val
	return maxf(0.1, base * (1.0 + mult_val))

func get_modified_critical_chance() -> float:
	var add_val: float = 0.0
	var mult_val: float = 0.0
	
	for affix in affixes:
		if affix.get("stat") == "critical_chance":
			var op = affix.get("operation")
			var v = float(affix.get("value", 0.0))
			if op == "ADD":
				add_val += v
			elif op == "MULTIPLY":
				mult_val += v
				
	var base = critical_chance + add_val
	return clampf(base * (1.0 + mult_val), 0.0, 1.0)

func get_modified_projectile_speed() -> float:
	var add_val: float = 0.0
	var mult_val: float = 0.0
	
	for affix in affixes:
		if affix.get("stat") == "projectile_speed":
			var op = affix.get("operation")
			var v = float(affix.get("value", 0.0))
			if op == "ADD":
				add_val += v
			elif op == "MULTIPLY":
				mult_val += v
				
	var base = projectile_speed + add_val
	return maxf(0.0, base * (1.0 + mult_val))

func get_modified_knockback() -> float:
	var add_val: float = 0.0
	var mult_val: float = 0.0
	
	for affix in affixes:
		if affix.get("stat") == "knockback_force":
			var op = affix.get("operation")
			var v = float(affix.get("value", 0.0))
			if op == "ADD":
				add_val += v
			elif op == "MULTIPLY":
				mult_val += v
				
	var base = knockback_force + add_val
	return maxf(0.0, base * (1.0 + mult_val))

func get_lifesteal_percent() -> float:
	var total: float = 0.0
	for affix in affixes:
		if affix.get("stat") == "lifesteal":
			total += float(affix.get("value", 0.0))
	return maxf(0.0, total)

static var _weapon_cache: Dictionary = {}

static func get_weapon(w_id: String) -> WeaponData:
	if _weapon_cache.has(w_id):
		return _weapon_cache[w_id]
	var path = "res://data/weapons/%s.tres" % w_id
	if ResourceLoader.exists(path):
		var w = load(path) as WeaponData
		if w != null:
			_weapon_cache[w_id] = w
			return w

	# Fallback weapon construction
	var fallback = WeaponData.new()
	fallback.id = w_id
	match w_id:
		"frost_rifle":
			fallback.display_name = "Frost Rifle"
			fallback.category = WeaponCategory.RANGED
			fallback.damage_type = DamageType.ICE
			fallback.base_damage = 15
			fallback.attack_speed = 2.2
		"ember_staff":
			fallback.display_name = "Ember Staff"
			fallback.category = WeaponCategory.ENERGY
			fallback.damage_type = DamageType.FIRE
			fallback.base_damage = 22
			fallback.attack_speed = 1.2
		"void_blade":
			fallback.display_name = "Void Blade"
			fallback.category = WeaponCategory.MELEE
			fallback.damage_type = DamageType.VOID
			fallback.base_damage = 28
			fallback.attack_speed = 1.8
		_:
			fallback.display_name = "Plasma Cutter"
			fallback.category = WeaponCategory.MELEE
			fallback.damage_type = DamageType.PHYSICAL
			fallback.base_damage = 18
			fallback.attack_speed = 1.5

	_weapon_cache[w_id] = fallback
	return fallback

