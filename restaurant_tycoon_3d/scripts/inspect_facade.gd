extends SceneTree

func _init():
	var main_scn = load("res://scenes/main.tscn")
	var main_node = main_scn.instantiate()
	root.add_child(main_node)
	
	await process_frame
	
	var cam: Camera3D = main_node.get_node("Camera3D")
	cam.set_script(null)
	# Position in front of the entrance doors looking at canopy and neon sign
	cam.global_position = Vector3(-5.5, 2.6, 11.2)
	cam.look_at(Vector3(-5.5, 2.5, 7.0), Vector3.UP)
	cam.fov = 38.0
	
	for i in range(15):
		await process_frame
		
	var img = root.get_viewport().get_texture().get_image()
	img.save_png("/home/ian/Documents/Apps/idle game 1/test_facade_neon.png")
	print("Saved test_facade_neon.png")
	quit(0)
