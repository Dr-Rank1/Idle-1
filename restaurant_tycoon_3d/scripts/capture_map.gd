extends SceneTree

func _init():
	print("Capturing world map snapshot...")
	var main_scn = load("res://scenes/main.tscn")
	if not main_scn:
		print("FAILED to load main.tscn")
		quit(1)
		return
	
	var main_node = main_scn.instantiate()
	root.add_child(main_node)
	
	for i in range(20):
		await process_frame
		
	var welcome = root.find_child("WelcomeBackModal", true, false)
	if welcome != null:
		welcome.queue_free()
		
	var ui = root.find_child("HUD", true, false)
	if ui != null:
		var map_btn = ui.find_child("MapBtn", true, false)
		if map_btn != null:
			map_btn.emit_signal("pressed")
		else:
			var wmp = ui.find_child("WorldMapPanel", true, false)
			if wmp != null:
				wmp.visible = true
				if ui.has_method("_refresh_world_map"):
					ui._refresh_world_map()
	
	for i in range(15):
		await process_frame
		
	var img = root.get_viewport().get_texture().get_image()
	var out_path = "c:/Users/Ian/Documents/Apps/Idle-1/map_view.png"
	var err = img.save_png(out_path)
	print("Map snapshot result:", err)
	quit(0)
