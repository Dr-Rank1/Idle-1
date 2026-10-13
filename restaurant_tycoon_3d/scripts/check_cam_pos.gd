@tool
extends SceneTree

func _init():
	var scn = load("res://scenes/main.tscn")
	var inst = scn.instantiate()
	var cam = inst.get_node("Camera3D")
	print("Instantiated cam pos: ", cam.position)
	print("Instantiated cam transform: ", cam.transform)
	quit(0)
