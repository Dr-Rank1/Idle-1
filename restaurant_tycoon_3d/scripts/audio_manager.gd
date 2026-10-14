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
	sounds["click"] = load("res://assets/audio/button_click.wav")
	sounds["claim"] = load("res://assets/audio/quest_claim.wav")
	
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

func play_sfx(sound_name: String, pitch_range: float = 0.05, volume_offset: float = 0.0) -> void:
	var stream = sounds.get(sound_name)
	if stream == null:
		return
	
	for p in sfx_players:
		if not p.playing:
			p.stream = stream
			p.pitch_scale = 1.0 + randf_range(-pitch_range, pitch_range)
			p.volume_db = -4.0 + volume_offset
			p.play()
			return
