# scripts/audio/audio_manager.gd
extends Node

## Centralized Audio Architecture for BGM streams and dynamic combat SFX triggers.

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE = 8

var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 0.9

var sfx_cache: Dictionary = {}
var music_cache: Dictionary = {}

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	
	# Setup BGM player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	add_child(music_player)
	
	# Setup SFX pool
	for i in range(SFX_POOL_SIZE):
		var p = AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		sfx_players.append(p)

	_preload_audio()

	# Connect signals from EventBus
	EventBus.damage_dealt.connect(_on_damage_dealt)
	EventBus.loot_collected.connect(func(_id, _name, _amt): play_sfx("pickup"))
	EventBus.player_leveled_up.connect(func(_lvl): play_sfx("level_up"))

func _preload_audio() -> void:
	var sfx_list = ["attack_laser", "attack_slash", "hit", "crit", "jump", "dash", "pickup", "level_up", "explosion", "boss_roar"]
	for name in sfx_list:
		var path = "res://audio/sfx/" + name + ".wav"
		if ResourceLoader.exists(path):
			sfx_cache[name] = load(path)
			
	var bgm_list = ["ambient_hub", "planet_combat"]
	for name in bgm_list:
		var path = "res://audio/music/" + name + ".wav"
		if ResourceLoader.exists(path):
			music_cache[name] = load(path)

func play_sfx(sfx_name: String, pitch_scale: float = 1.0) -> void:
	if not sfx_cache.has(sfx_name):
		return
		
	for p in sfx_players:
		if not p.playing:
			p.stream = sfx_cache[sfx_name]
			p.volume_db = linear_to_db(sfx_volume * master_volume)
			p.pitch_scale = pitch_scale
			p.play()
			return

func play_music(track_name: String) -> void:
	if not music_cache.has(track_name):
		return
	if music_player.playing and music_player.stream == music_cache[track_name]:
		return
		
	music_player.stream = music_cache[track_name]
	music_player.volume_db = linear_to_db(music_volume * master_volume)
	music_player.play()

func set_volumes(master: float, music: float, sfx: float) -> void:
	master_volume = clampf(master, 0.0, 1.0)
	music_volume = clampf(music, 0.0, 1.0)
	sfx_volume = clampf(sfx, 0.0, 1.0)
	if music_player:
		music_player.volume_db = linear_to_db(music_volume * master_volume)

func _on_damage_dealt(_pos: Vector2, _dmg: int, is_crit: bool, _type: String) -> void:
	if is_crit:
		play_sfx("crit", randf_range(0.95, 1.05))
	else:
		play_sfx("hit", randf_range(0.9, 1.1))
