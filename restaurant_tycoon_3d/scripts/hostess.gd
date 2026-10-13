extends Node3D

@onready var anim_player: AnimationPlayer = null
var time_passed: float = 0.0
var next_action_time: float = 3.0

func _ready() -> void:
	anim_player = find_child("AnimationPlayer", true, false)
	_play_anim("idle")

func _play_anim(anim_name: String) -> void:
	if anim_player != null and anim_player.has_animation(anim_name):
		anim_player.play(anim_name)

func _process(delta: float) -> void:
	time_passed += delta
	if time_passed >= next_action_time:
		time_passed = 0.0
		next_action_time = randf_range(3.5, 6.0)
		_perform_subtle_action()

func _perform_subtle_action() -> void:
	# Alternate between typing on laptop and friendly reception idle
	if anim_player != null:
		if randf() > 0.4 and anim_player.has_animation("interact-right"):
			anim_player.play("interact-right")
			await get_tree().create_timer(1.8).timeout
			if is_instance_valid(self):
				_play_anim("idle")
		elif anim_player.has_animation("emote-yes"):
			anim_player.play("emote-yes")
			await get_tree().create_timer(1.2).timeout
			if is_instance_valid(self):
				_play_anim("idle")

func greet_customer() -> void:
	if anim_player != null and anim_player.has_animation("emote-yes"):
		anim_player.play("emote-yes")
		await get_tree().create_timer(1.4).timeout
		if is_instance_valid(self):
			_play_anim("idle")
