extends Node

var ambience_player: AudioStreamPlayer = null
var sfx_players: Array[AudioStreamPlayer] = []
var max_sfx_channels: int = 8

var sounds: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	sounds["coin"] = load("res://assets/audio/coin_payout.wav")
	sounds["bell"] = load("res://assets/audio/order_bell.wav")
	sounds["upgrade"] = load("res://assets/audio/upgrade_fanfare.wav")
	sounds["angry"] = load("res://assets/audio/angry_exit.wav")
	sounds["ambience"] = load("res://assets/audio/restaurant_ambience.wav")
	sounds["ambient"] = sounds.get("ambience")
	sounds["sizzle"] = load("res://assets/audio/cooking_sizzle.wav")
	sounds["click"] = load("res://assets/audio/button_click.wav")
	sounds["claim"] = load("res://assets/audio/quest_claim.wav")
	sounds["diamond"] = load("res://assets/audio/diamond_chime.wav")
	sounds["gem"] = sounds.get("diamond")
	sounds["gold_coin"] = load("res://assets/audio/gold_coin_chime.wav")
	sounds["energy"] = load("res://assets/audio/energy_spark.wav")
	# Milestone chime: reuse diamond_chime at a higher pitch for the level 10/25/50 burst
	sounds["milestone"] = sounds.get("diamond")
	
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

func _on_ambience_finished() -> void:
	if ambience_player != null and is_instance_valid(ambience_player):
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
