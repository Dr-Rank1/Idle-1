extends SceneTree

func _init():
	print("Capturing game snapshot...")
	var main_scn = load("res://scenes/main.tscn")
	if not main_scn:
		print("FAILED to load main.tscn")
		quit(1)
		return
	
	var main_node = main_scn.instantiate()
	root.add_child(main_node)
	
	# Simulate 60 frames, then auto-dismiss welcome modal if visible
	for i in range(60):
		await process_frame
	var welcome = root.find_child("WelcomeBackModal", true, false)
	if welcome != null:
		var btn = welcome.find_child("Button", true, false)
		if btn != null:
			btn.emit_signal("pressed")
		else:
			welcome.queue_free()
	
	# Simulate remaining 200 frames for active dining and serving
	for i in range(200):
		await process_frame
		
	var img = root.get_viewport().get_texture().get_image()
	var out_path = "c:/Users/Ian/Documents/Apps/Idle-1/gameplay_view.png"
	var err = img.save_png(out_path)
	print("Snapshot result:", err)
	quit(0)
