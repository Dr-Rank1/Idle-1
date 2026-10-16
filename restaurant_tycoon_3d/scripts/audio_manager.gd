extends Node

var ambience_player: AudioStreamPlayer = null
var sfx_players: Array[AudioStreamPlayer] = []
var max_sfx_channels: int = 8

var sounds: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	sounds["coin"] = _safe_load_sound("res://assets/audio/coin_payout.wav")
	sounds["bell"] = _safe_load_sound("res://assets/audio/order_bell.wav")
	sounds["upgrade"] = _safe_load_sound("res://assets/audio/upgrade_fanfare.wav")
	sounds["angry"] = _safe_load_sound("res://assets/audio/angry_exit.wav")
	sounds["ambience"] = _safe_load_sound("res://assets/audio/restaurant_ambience.wav")
	sounds["ambient"] = sounds.get("ambience")
	sounds["sizzle"] = _safe_load_sound("res://assets/audio/cooking_sizzle.wav")
	sounds["click"] = _safe_load_sound("res://assets/audio/button_click.wav")
	sounds["claim"] = _safe_load_sound("res://assets/audio/quest_claim.wav")
	sounds["diamond"] = _safe_load_sound("res://assets/audio/diamond_chime.wav", "upgrade")
	sounds["gem"] = sounds.get("diamond")
	sounds["gold_coin"] = _safe_load_sound("res://assets/audio/gold_coin_chime.wav", "coin")
	sounds["energy"] = _safe_load_sound("res://assets/audio/energy_spark.wav", "upgrade")
	sounds["stinger"] = _safe_load_sound("res://assets/audio/studio_stinger.wav", "upgrade")
	sounds["studio_chime"] = sounds.get("stinger")
	# Milestone chime: reuse diamond_chime/upgrade at a higher pitch for the level 10/25/50 burst
	sounds["milestone"] = sounds.get("diamond") if sounds.get("diamond") != null else sounds.get("upgrade")
	
	ambience_player = AudioStreamPlayer.new()
	ambience_player.stream = sounds.get("ambience")
	ambience_player.volume_db = -12.0
	add_child(ambience_player)
	ambience_player.finished.connect(_on_ambience_finished)
	if ambience_player.stream != null:
		ambience_player.play()

func _safe_load_sound(path: String, fallback_key: String = "") -> AudioStream:
	# Check if imported sample exists on disk before attempting load to prevent C++ errors
	var import_path = path + ".import"
	if FileAccess.file_exists(import_path):
		var cfg = ConfigFile.new()
		if cfg.load(import_path) == OK:
			var sample_path = cfg.get_value("remap", "path", "")
			if sample_path != "" and not FileAccess.file_exists(sample_path):
				if fallback_key != "" and sounds.has(fallback_key):
					return sounds.get(fallback_key)
				return null
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is AudioStream:
			return res
	if fallback_key != "" and sounds.has(fallback_key):
		return sounds.get(fallback_key)
	return null

	for i in range(max_sfx_channels):
		var p = AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)

func _on_ambience_finished() -> void:
	if ambience_player != null and is_instance_valid(ambience_player):
		ambience_player.play()

func stop_ambience() -> void:
	if ambience_player != null and is_instance_valid(ambience_player):
		ambience_player.stop()

func start_ambience() -> void:
	if ambience_player != null and is_instance_valid(ambience_player) and not ambience_player.playing:
		ambience_player.play()

func play_sfx(sound_name: String, pitch_range: float = 0.05, volume_offset: float = 0.0, custom_pitch: float = 1.0) -> void:
	var stream = sounds.get(sound_name)
	if stream == null:
		return
	
	for p in sfx_players:
		if not p.playing:
			p.stream = stream
			p.pitch_scale = custom_pitch + randf_range(-pitch_range, pitch_range)
			p.volume_db = -4.0 + volume_offset
			p.play()
			return

func play_upgrade_sfx(consecutive_step: int = 0) -> void:
	# Pitch increases with each consecutive upgrade hold step up to +0.85
	var pitch: float = 1.0 + clamp(consecutive_step * 0.04, 0.0, 0.85)
	play_sfx("upgrade", 0.02, 1.0, pitch)

func play_milestone_chime(milestone_level: int = 10) -> void:
	# Three cascading chimes at rising pitch for levels 10 / 25 / 50
	var base_pitch: float = 1.0
	if milestone_level >= 50:
		base_pitch = 1.6
	elif milestone_level >= 25:
		base_pitch = 1.3
	play_sfx("milestone", 0.0, 2.0, base_pitch)
	# Schedule two more rising chimes with brief delays via a timer chain
	var t1 = get_tree().create_timer(0.18)
	t1.timeout.connect(func(): play_sfx("milestone", 0.0, 2.0, base_pitch + 0.15))
	var t2 = get_tree().create_timer(0.38)
	t2.timeout.connect(func(): play_sfx("milestone", 0.0, 3.0, base_pitch + 0.30))

func play_studio_stinger() -> void:
	if sounds.get("stinger") != null:
		play_sfx("stinger", 0.0, 3.5, 1.0)
	elif sounds.get("diamond") != null:
		play_sfx("diamond", 0.0, 3.5, 1.2)
	else:
		play_milestone_chime(50)

