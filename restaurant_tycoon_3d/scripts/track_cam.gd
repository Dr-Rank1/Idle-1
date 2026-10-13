extends SceneTree

func _init():
	var main_scn = load("res://scenes/main.tscn")
	var main_node = main_scn.instantiate()
	root.add_child(main_node)
	
	var cam = main_node.get_node("Camera3D")
	print("Frame 0: pos=", cam.position, " target=", cam.target_position)
	
	for i in range(10):
		await process_frame
		print("Frame %d: pos=%s target=%s" % [i+1, cam.position, cam.target_position])
	quit(0)
