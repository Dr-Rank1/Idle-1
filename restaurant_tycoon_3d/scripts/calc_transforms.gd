@tool
extends SceneTree

func _init():
	var cam = Camera3D.new()
	cam.look_at_from_position(Vector3(5.0, 14.5, 13.5), Vector3(-0.2, 0.8, -0.5), Vector3.UP)
	print("Cam Transform3D: ", cam.transform)
	quit(0)
