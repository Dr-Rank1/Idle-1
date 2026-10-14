extends SceneTree

func _init():
	print("Capturing upgrade sheet and shop modal...")
	var main_scn = load("res://scenes/main.tscn")
	if not main_scn:
		quit(1)
		return
	
	var main_node = main_scn.instantiate()
	root.add_child(main_node)
	
	# Simulate 60 frames, auto-dismiss welcome modal if visible
	for i in range(60):
		await process_frame
	var welcome = root.find_child("WelcomeBackModal", true, false)
	if welcome != null:
		var btn = welcome.find_child("Button", true, false)
		if btn != null:
			btn.emit_signal("pressed")
		else:
			welcome.queue_free()
	
	for i in range(30):
		await process_frame
		
	var ui = root.find_child("HUD", true, false)
	if ui != null:
		# Test opening upgrade sheet for stove
		ui.open_upgrade("stove", "Master Range Stoves", 3)
		for i in range(30):
			await process_frame
		
		var img1 = root.get_viewport().get_texture().get_image()
		img1.save_png("c:/Users/Ian/Documents/Apps/Idle-1/upgrade_sheet_view.png")
		print("Saved upgrade_sheet_view.png")
		
		# Now test opening Shop panel
		var shop_btn = root.find_child("ShopBtn", true, false)
		if shop_btn != null:
			shop_btn.emit_signal("pressed")
		for i in range(30):
			await process_frame
			
		var img2 = root.get_viewport().get_texture().get_image()
		img2.save_png("c:/Users/Ian/Documents/Apps/Idle-1/shop_sheet_view.png")
		print("Saved shop_sheet_view.png")

	quit(0)
