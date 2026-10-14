extends Node3D

@export var anim_name: String = "idle"

func _ready() -> void:
	var ap: AnimationPlayer = _find_anim_player(self)
	if ap != null and ap.has_animation(anim_name):
		ap.play(anim_name)

func _find_anim_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found = _find_anim_player(child)
		if found != null:
			return found
	return null
