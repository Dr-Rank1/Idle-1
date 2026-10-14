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
	
	# Simulate 260 frames for active dining and serving
	for i in range(260):
		await process_frame
		
	var img = root.get_viewport().get_texture().get_image()
	var out_path = "c:/Users/Ian/Documents/Apps/Idle-1/gameplay_view.png"
	var err = img.save_png(out_path)
	print("Snapshot result:", err)
	quit(0)
