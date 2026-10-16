extends SceneTree

func _init():
	print("Capturing game snapshot...")
	var base_dir = ProjectSettings.globalize_path("res://../")
	var gm = root.get_node_or_null("GameManager")

	# 1. Capture Splash Screen
	if gm != null:
		gm.skip_boot_splash = false

	var splash_scn = load("res://scenes/ui/boot_splash.tscn")
	if splash_scn != null:
		var splash_node = splash_scn.instantiate()
		root.add_child(splash_node)
		if splash_node is Control:
			splash_node.size = Vector2(root.size)
		
		# Allow splash Stage 1 to animate into view with full radial glow and sheen
		for i in range(25):
			await process_frame
		
		var tex: Texture2D = null
		if root.get_viewport() != null and root.get_viewport().get_texture() != null:
			tex = root.get_viewport().get_texture()
		elif root.has_method("get_texture"):
			tex = root.get_texture()
		if tex != null:
			var img_splash = tex.get_image()
			if img_splash != null:
				var err = img_splash.save_png(base_dir + "/splash_view.png")
				print("Splash snapshot result:", err)
		
		splash_node.queue_free()
		for i in range(2):
			await process_frame

	# 2. Skip boot splash and camera swoop for subsequent gameplay captures
	if gm != null:
		gm.skip_boot_splash = true

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
	
	# Lock default isometric camera parameters
	var cam = root.find_child("Camera3D", true, false)
	if cam != null:
		cam.projection = Camera3D.PROJECTION_ORTHOGONAL
		cam.size = 12.0
		cam.position = Vector3(14.2, 15.0, 16.8)
		cam.rotation_degrees = Vector3(-30.0, 45.0, 0.0)
		cam.target_position = Vector3(14.2, 15.0, 16.8)

	var bottom_dock = root.find_child("BottomDock", true, false)
	if bottom_dock != null:
		bottom_dock.visible = false
	var quest_banner = root.find_child("QuestBanner", true, false)
	if quest_banner != null:
		quest_banner.visible = false

	# Simulate remaining 200 frames for active dining and serving
	for i in range(200):
		await process_frame
		
	var img = root.get_viewport().get_texture().get_image()
	if img != null:
		var err = img.save_png(base_dir + "/gameplay_view.png")
		print("Snapshot result:", err)

	if gm != null:
		gm.set_all_stations_max_level(true)
	var hud_node = root.find_child("HUD", true, false)
	if hud_node != null and hud_node.has_method("open_upgrade"):
		hud_node.open_upgrade("milkshake_bar", "Bar Top", 50)
	for i in range(15):
		await process_frame
	var img_modal = root.get_viewport().get_texture().get_image()
	if img_modal != null:
		img_modal.save_png(base_dir + "/upgrade_modal_view.png")
	if hud_node != null and hud_node.has_method("_hide_all_modals"):
		hud_node._hide_all_modals()

	# Focus camera on terrace to capture expansion booths in full view
	if cam == null:
		cam = root.find_child("Camera3D", true, false)
	if cam != null and cam.has_method("focus_zone"):
		cam.focus_zone("terrace")
	for i in range(30):
		await process_frame
	var img_exp = root.get_viewport().get_texture().get_image()
	if img_exp != null:
		img_exp.save_png(base_dir + "/expansion_view.png")

	# Focus camera on parking lot to capture exterior, parking bays, courtyard, and helipad
	if cam != null and cam.has_method("focus_zone"):
		cam.focus_zone("parking")
	for i in range(30):
		await process_frame
	var img_park = root.get_viewport().get_texture().get_image()
	if img_park != null:
		img_park.save_png(base_dir + "/parking_view.png")

	# Focus camera on lounge to capture 1:1 fidelity details of Cocktail Lounge and Reception
	if cam != null and cam.has_method("focus_zone"):
		cam.focus_zone("lounge")
	for i in range(35):
		await process_frame
	var img_lounge = root.get_viewport().get_texture().get_image()
	if img_lounge != null:
		img_lounge.save_png(base_dir + "/lounge_view.png")

	# Focus camera on milkshake bar to capture 1:1 fidelity details of Milkshake & Soda Diner
	if cam != null:
		var orig_pos = cam.target_position
		var orig_size = cam.size
		cam.target_position = Vector3(7.7, 15.0, 9.8)
		cam.position = Vector3(7.7, 15.0, 9.8)
		cam.size = 10.5
		for i in range(30):
			await process_frame
		var img_shake = root.get_viewport().get_texture().get_image()
		if img_shake != null:
			img_shake.save_png(base_dir + "/milkshake_view.png")
	# Focus camera on kitchen to capture 1:1 fidelity details of Commercial Kitchen
	if cam != null:
		var orig_pos = cam.target_position
		var orig_size = cam.size
		cam.target_position = Vector3(17.2, 14.5, 9.8)
		cam.position = Vector3(17.2, 14.5, 9.8)
		cam.size = 11.0
		for i in range(35):
			await process_frame
		var img_kitchen = root.get_viewport().get_texture().get_image()
		if img_kitchen != null:
			img_kitchen.save_png(base_dir + "/kitchen_view.png")
		cam.target_position = orig_pos
		cam.position = orig_pos
		cam.size = orig_size

	quit(0)
