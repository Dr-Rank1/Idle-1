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

	for i in range(max_sfx_channels):
		var p = AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)

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

func _on_ambience_finished() -> void:
	if ambience_player != null and is_instance_valid(ambience_player):
		ambience_player.play()

func stop_ambience() -> void:
	if ambience_player != null and is_instance_valid(ambience_player):
		ambience_player.stop()

func start_ambience() -> void:
	if ambience_player != null and is_instance_valid(ambience_player) and not ambience_player.playing:
		ambience_player.play()

func set_fever_pitch(active: bool) -> void:
	if ambience_player != null and is_instance_valid(ambience_player):
		ambience_player.pitch_scale = 1.08 if active else 1.0

func get_ambience_pitch() -> float:
	if ambience_player != null and is_instance_valid(ambience_player):
		return ambience_player.pitch_scale
	return 1.0

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

# ─── Pentatonic Pitch-Stepping on Rapid Upgrades ────────────────────────────
const PENTATONIC_PITCHES: Array[float] = [1.0, 1.06, 1.12, 1.20, 1.26, 1.33, 1.42, 1.50]
const RAPID_UPGRADE_WINDOW: float = 1.2
var upgrade_pitch_step: int = 0
var last_upgrade_time: float = -100.0

func play_upgrade_sfx(consecutive_step: int = -1) -> void:
	var now = Time.get_ticks_msec() / 1000.0
	if now - last_upgrade_time > RAPID_UPGRADE_WINDOW:
		upgrade_pitch_step = 0
	else:
		upgrade_pitch_step = min(upgrade_pitch_step + 1, PENTATONIC_PITCHES.size() - 1)
	last_upgrade_time = now

	var pitch: float = PENTATONIC_PITCHES[upgrade_pitch_step]
	if consecutive_step > 0:
		var step_idx = clamp(consecutive_step, 0, PENTATONIC_PITCHES.size() - 1)
		pitch = max(pitch, PENTATONIC_PITCHES[step_idx])
	play_sfx("upgrade", 0.012, 1.0, pitch)

func get_current_upgrade_pitch_scale() -> float:
	var now = Time.get_ticks_msec() / 1000.0
	if now - last_upgrade_time > RAPID_UPGRADE_WINDOW:
		return PENTATONIC_PITCHES[0]
	return PENTATONIC_PITCHES[clamp(upgrade_pitch_step, 0, PENTATONIC_PITCHES.size() - 1)]

func reset_upgrade_pitch() -> void:
	upgrade_pitch_step = 0
	last_upgrade_time = -100.0

func play_milestone_fanfare(milestone_level: int = 10) -> void:
	# Rich multi-layered major triad/7th chord fanfare
	# Level 10: C Major triad (Root, 3rd, 5th)
	# Level 25: Bright High Major (Root 1.12x, 3rd, 5th, Octave)
	# Level 50: Grand Full Fanfare with Diamond Chime harmonics
	var root_pitch: float = 1.0
	if milestone_level >= 50:
		root_pitch = 1.25
	elif milestone_level >= 25:
		root_pitch = 1.12

	# Layer 1: Root note
	play_sfx("upgrade", 0.0, 2.5, root_pitch)

	# Layer 2: Major Third (+25% frequency = 1.25 ratio)
	var t1 = get_tree().create_timer(0.04)
	t1.timeout.connect(func(): play_sfx("upgrade", 0.0, 2.0, root_pitch * 1.25))

	# Layer 3: Perfect Fifth (+50% frequency = 1.50 ratio)
	var t2 = get_tree().create_timer(0.08)
	t2.timeout.connect(func(): play_sfx("diamond", 0.0, 2.5, root_pitch * 1.50))

	# Layer 4: High Octave (+100% frequency = 2.0 ratio)
	var t3 = get_tree().create_timer(0.14)
	t3.timeout.connect(func(): play_sfx("diamond", 0.0, 3.0, root_pitch * 2.0))

func play_milestone_chime(milestone_level: int = 10) -> void:
	play_milestone_fanfare(milestone_level)

func play_studio_stinger() -> void:
	if sounds.get("stinger") != null:
		play_sfx("stinger", 0.0, 3.5, 1.0)
	elif sounds.get("diamond") != null:
		play_sfx("diamond", 0.0, 3.5, 1.2)
	else:
		play_milestone_fanfare(50)


