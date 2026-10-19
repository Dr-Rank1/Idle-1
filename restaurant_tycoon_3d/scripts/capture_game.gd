extends SceneTree

func _init():
	print("Capturing game snapshot at 1080x1920 portrait resolution...")
	var base_dir = ProjectSettings.globalize_path("res://../")
	var gm = root.get_node_or_null("GameManager")

	# Dedicated SubViewport ensuring exact 1080x1920 render target in all display environments
	var vp = SubViewport.new()
	vp.name = "CaptureViewport"
	vp.size = Vector2i(1080, 1920)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	# 1. Capture Splash Screen
	if gm != null:
		gm.skip_boot_splash = false

	var splash_scn = load("res://scenes/ui/boot_splash.tscn")
	if splash_scn != null:
		var splash_node = splash_scn.instantiate()
		vp.add_child(splash_node)
		if splash_node is Control:
			splash_node.size = Vector2(1080, 1920)
		
		# Allow splash Stage 1 to animate into view with full radial glow and sheen
		for i in range(25):
			await process_frame
		
		var tex = vp.get_texture()
		if tex != null:
			var img_splash = tex.get_image()
			if img_splash != null:
				var err = img_splash.save_png(base_dir + "/splash_view.png")
				print("Splash snapshot result (1080x1920):", err)
		
		splash_node.queue_free()
		for i in range(2):
			await process_frame

	# 2. Skip boot splash and camera swoop for subsequent gameplay captures
	if gm != null:
		gm.skip_boot_splash = true
		gm.tutorial_completed = true

	var main_scn = load("res://scenes/main.tscn")
	if not main_scn:
		print("FAILED to load main.tscn")
		quit(1)
		return
	
	var main_node = main_scn.instantiate()
	vp.add_child(main_node)
	
	# Simulate 60 frames, then auto-dismiss welcome modal and complete tutorial for clean gameplay view
	for i in range(60):
		await process_frame
	var welcome = vp.find_child("WelcomeBackModal", true, false)
	if welcome != null:
		var btn = welcome.find_child("Button", true, false)
		if btn != null:
			btn.emit_signal("pressed")
		else:
			welcome.queue_free()

	var hud_node = vp.find_child("HUD", true, false)
	if hud_node != null:
		hud_node.tutorial_active = false
		if hud_node.has_method("dismiss_station_callout"):
			hud_node.dismiss_station_callout()
	
	# Lock default isometric camera parameters centered on 9-Booth Dining Hall and Kitchen Pass
	var cam = vp.find_child("Camera3D", true, false)
	if cam != null:
		cam.projection = Camera3D.PROJECTION_ORTHOGONAL
		cam.size = 12.5
		cam.position = Vector3(23.2, 15.0, 19.5)
		cam.rotation_degrees = Vector3(-30.0, 45.0, 0.0)
		cam.target_position = Vector3(23.2, 15.0, 19.5)

	# Simulate remaining 200 frames for active dining, cooking, and serving
	for i in range(200):
		await process_frame

	if hud_node != null and hud_node.has_method("_dismiss_vip_toast"):
		hud_node._dismiss_vip_toast()
	var toast = vp.find_child("VipArrivalToast", true, false)
	if toast != null:
		toast.visible = false
		toast.queue_free()
	var tut_toast = vp.find_child("TutorialCompleteToast", true, false)
	if tut_toast != null:
		tut_toast.visible = false
		tut_toast.queue_free()
	var tut_ring = vp.find_child("TargetRing", true, false)
	if tut_ring != null:
		tut_ring.visible = false
	var tut_ov = vp.find_child("TutorialOverlay", true, false)
	if tut_ov != null:
		tut_ov.visible = false
	await process_frame
		
	var img = vp.get_texture().get_image()
	if img != null:
		var err = img.save_png(base_dir + "/gameplay_view.png")
		print("Snapshot result (1080x1920):", err)

	# 3. Capture Upgrade Bottom Sheet View over highlighted Booth 1 (table_1)
	if gm != null:
		gm.set_all_stations_max_level(true)
	if hud_node != null and hud_node.has_method("open_upgrade"):
		hud_node.open_upgrade("table_1", "Booth Table 1", 1)
	for i in range(25):
		await process_frame
	var img_sheet = vp.get_texture().get_image()
	if img_sheet != null:
		var err_sheet = img_sheet.save_png(base_dir + "/upgrade_sheet_view.png")
		print("Upgrade sheet snapshot result (1080x1920):", err_sheet)
		img_sheet.save_png(base_dir + "/upgrade_modal_view.png")
	if hud_node != null and hud_node.has_method("_hide_all_modals"):
		hud_node._hide_all_modals()

	# Focus camera on terrace to capture expansion booths in full view
	if cam != null and cam.has_method("focus_zone"):
		cam.focus_zone("terrace")
	for i in range(30):
		await process_frame
	var img_exp = vp.get_texture().get_image()
	if img_exp != null:
		img_exp.save_png(base_dir + "/expansion_view.png")

	# Focus camera on parking lot to capture exterior, parking bays, courtyard, and helipad
	if cam != null and cam.has_method("focus_zone"):
		cam.focus_zone("parking")
	for i in range(30):
		await process_frame
	var img_park = vp.get_texture().get_image()
	if img_park != null:
		img_park.save_png(base_dir + "/parking_view.png")

	# Focus camera on lounge to capture details of Cocktail Lounge and Reception
	if cam != null and cam.has_method("focus_zone"):
		cam.focus_zone("lounge")
	for i in range(35):
		await process_frame
	var img_lounge = vp.get_texture().get_image()
	if img_lounge != null:
		img_lounge.save_png(base_dir + "/lounge_view.png")

	# Focus camera on milkshake bar to capture details of Milkshake & Soda Diner
	if cam != null:
		var orig_pos = cam.target_position
		var orig_size = cam.size
		cam.target_position = Vector3(7.7, 15.0, 9.8)
		cam.position = Vector3(7.7, 15.0, 9.8)
		cam.size = 10.5
		for i in range(30):
			await process_frame
		var img_shake = vp.get_texture().get_image()
		if img_shake != null:
			img_shake.save_png(base_dir + "/milkshake_view.png")
			
	# Focus camera on kitchen to capture details of Commercial Kitchen
	if cam != null:
		cam.target_position = Vector3(17.2, 14.5, 9.8)
		cam.position = Vector3(17.2, 14.5, 9.8)
		cam.size = 11.0
		for i in range(35):
			await process_frame
		var img_kitchen = vp.get_texture().get_image()
		if img_kitchen != null:
			img_kitchen.save_png(base_dir + "/kitchen_view.png")

	quit(0)
