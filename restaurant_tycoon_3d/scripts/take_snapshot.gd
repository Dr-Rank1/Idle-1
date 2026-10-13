extends SceneTree

func _init():
	print("Starting snapshot runner...")
	var main_scn = load("res://scenes/main.tscn")
	if not main_scn:
		print("FAILED to load main.tscn")
		quit(1)
		return
	
	var main_node = main_scn.instantiate()
	root.add_child(main_node)
	
	await process_frame
	
	var cam: Camera3D = main_node.get_node_or_null("Camera3D")
	if cam:
		cam.set_process_unhandled_input(false)
		cam.position = Vector3(5.0, 14.5, 13.5)
		if "target_position" in cam:
			cam.target_position = Vector3(5.0, 14.5, 13.5)
		print("Init Cam: pos=", cam.global_position, " fov=", cam.fov)
	
	# Run for 7.5 seconds to let customers spawn, enter, seat, and eat
	var timer = 0.0
	while timer < 7.5:
		await process_frame
		timer += 1.0 / 60.0
		
	if cam:
		print("End Cam: pos=", cam.global_position, " fov=", cam.fov)
	
	var img = root.get_viewport().get_texture().get_image()
	var out_path = "/home/ian/Documents/Apps/idle game 1/restaurant_snapshot_mini.png"
	var err = img.save_png(out_path)
	if err == OK:
		print("Successfully saved screenshot to ", out_path)
	else:
		print("Failed saving screenshot: ", err)
	
	quit(0)
