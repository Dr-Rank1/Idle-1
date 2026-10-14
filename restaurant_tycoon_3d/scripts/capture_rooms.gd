extends SceneTree

func _init():
	print("Capturing room inspection snapshots...")
	var main_scn = load("res://scenes/main.tscn")
	if not main_scn:
		print("FAILED to load main.tscn")
		quit(1)
		return
	
	var main_node = main_scn.instantiate()
	root.add_child(main_node)
	
	# Wait for scene initialization
	for i in range(20):
		await process_frame
		
	var welcome = root.find_child("WelcomeBackModal", true, false)
	if welcome != null:
		welcome.queue_free()
		
	for i in range(20):
		await process_frame
		
	var cam: Camera3D = main_node.get_node("Camera3D")
	cam.set_script(null) # freeze camera controller
	
	# 1. Close-up on Restroom (X in [-3.5, 2.5], Z in [-10.5, -3.5])
	cam.global_position = Vector3(4.5, 8.5, 2.0)
	cam.look_at(Vector3(-0.5, 0.8, -7.0), Vector3.UP)
	cam.fov = 38.0
	
	for i in range(10):
		await process_frame
	var img_restroom = root.get_viewport().get_texture().get_image()
	img_restroom.save_png("c:/Users/Ian/Documents/Apps/Idle-1/inspect_restroom.png")
	print("Saved inspect_restroom.png")
	
	# 2. Close-up on Manager's Office (X in [10.5, 18.5], Z in [-10.5, -3.5])
	cam.global_position = Vector3(19.5, 9.0, 2.0)
	cam.look_at(Vector3(14.5, 0.8, -7.0), Vector3.UP)
	cam.fov = 38.0
	
	for i in range(10):
		await process_frame
	var img_office = root.get_viewport().get_texture().get_image()
	img_office.save_png("c:/Users/Ian/Documents/Apps/Idle-1/inspect_office.png")
	print("Saved inspect_office.png")

	# 3. Close-up on Staff Breakroom (X in [10.5, 18.5], Z in [-3.5, -0.5])
	cam.global_position = Vector3(18.5, 7.5, 5.0)
	cam.look_at(Vector3(14.5, 0.8, -2.0), Vector3.UP)
	cam.fov = 38.0
	
	for i in range(10):
		await process_frame
	var img_breakroom = root.get_viewport().get_texture().get_image()
	img_breakroom.save_png("c:/Users/Ian/Documents/Apps/Idle-1/inspect_breakroom.png")
	print("Saved inspect_breakroom.png")

	quit(0)
