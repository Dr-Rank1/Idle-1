extends Node3D

@onready var anim_player: AnimationPlayer = null
var time_passed: float = 0.0
var next_action_time: float = 3.0
var is_greeting: bool = false

func _ready() -> void:
	anim_player = _find_anim_player(self)
	_play_anim("idle")

func _find_anim_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found = _find_anim_player(child)
		if found != null:
			return found
	return null

func _play_anim(anim_name: String) -> void:
	if anim_player != null and anim_player.has_animation(anim_name):
		var anim = anim_player.get_animation(anim_name)
		if anim != null and anim_name in ["idle", "sit", "walk"]:
			anim.loop_mode = Animation.LOOP_LINEAR
		anim_player.play(anim_name)

func _process(delta: float) -> void:
	if is_greeting:
		return
	time_passed += delta
	if time_passed >= next_action_time:
		time_passed = 0.0
		next_action_time = randf_range(3.5, 6.0)
		_perform_subtle_action()

func _perform_subtle_action() -> void:
	if anim_player == null or is_greeting:
		return
	if randf() > 0.4 and anim_player.has_animation("interact-right"):
		var a = anim_player.get_animation("interact-right")
		if a != null:
			a.loop_mode = Animation.LOOP_NONE
		anim_player.play("interact-right")
		await get_tree().create_timer(1.8).timeout
		if is_instance_valid(self) and not is_greeting:
			_play_anim("idle")
	elif anim_player.has_animation("emote-yes"):
		var a = anim_player.get_animation("emote-yes")
		if a != null:
			a.loop_mode = Animation.LOOP_NONE
		anim_player.play("emote-yes")
		await get_tree().create_timer(1.2).timeout
		if is_instance_valid(self) and not is_greeting:
			_play_anim("idle")

func greet_customer() -> void:
	if anim_player == null:
		return
	is_greeting = true
	time_passed = 0.0
	var greet_anim: String = "emote-yes" if anim_player.has_animation("emote-yes") else "idle"
	if anim_player.has_animation(greet_anim):
		var a = anim_player.get_animation(greet_anim)
		if a != null and greet_anim != "idle":
			a.loop_mode = Animation.LOOP_NONE
		anim_player.play(greet_anim)
	await get_tree().create_timer(1.4).timeout
	if is_instance_valid(self):
		is_greeting = false
		_play_anim("idle")
