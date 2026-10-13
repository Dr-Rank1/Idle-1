extends SceneTree

func _init():
	var main_scn = load("res://scenes/main.tscn")
	var main_node = main_scn.instantiate()
	root.add_child(main_node)
	
	await process_frame
	
	var gm = root.get_node_or_null("GameManager")
	var restaurant = main_node.get_node("Restaurant")
	var hud_layer = main_node.get_node("HUD")
	var cam: Camera3D = main_node.get_node("Camera3D")
	cam.set_script(null)
	
	# 1. Upgrade stations to showcase tiers
	if gm != null:
		# Table 1 to Tier 2 Gourmet (Lv 6)
		gm.station_levels["table_1"] = 6
		gm.station_upgraded.emit("table_1", 6)
		
		# Table 2 to Tier 3 VIP (Lv 11)
		gm.station_levels["table_2"] = 11
		gm.station_upgraded.emit("table_2", 11)
		
		# Table 3 to Lv 4
		gm.station_levels["table_3"] = 4
		gm.station_upgraded.emit("table_3", 4)
		
		# Stove to Tier 2 Commercial Range (Lv 6)
		gm.station_levels["stove"] = 6
		gm.station_upgraded.emit("stove", 6)
		
		# Unlock Pasta and Pizza
		gm.menu_items["pasta"]["unlocked"] = true
		gm.menu_items["pizza"]["unlocked"] = true
		gm.menu_updated.emit()
		
		# Hire Waiter 2 (Sophia)
		gm.staff_roster["waiter_2"]["hired"] = true
		gm.staff_updated.emit("waiter_2")
	
	# 2. Spawn seated customers at tables with patience bars and food orders
	var table1 = restaurant.get_node("Tables/Table1")
	var table2 = restaurant.get_node("Tables/Table2")
	var cust_scn = load("res://scenes/customer.tscn")
	
	var cust1 = cust_scn.instantiate()
	restaurant.get_node("Customers").add_child(cust1)
	cust1.table_ref = table1
	cust1.assigned_table_id = "table_1"
	table1.occupy(cust1)
	cust1.global_position = table1.get_seat_position()
	cust1.rotation.y = table1.get_seat_rotation_y()
	cust1.current_state = cust1.State.SEATED_ORDERING
	cust1.ordered_dish = gm.menu_items["pasta"]
	cust1.set_bubble_text("🍝 Truffle Pasta")
	cust1.current_patience = 26.0
	cust1.is_waiting_for_food = true
	cust1._update_patience_bar()
	cust1._play_anim("sit")
	
	var cust2 = cust_scn.instantiate()
	restaurant.get_node("Customers").add_child(cust2)
	cust2.table_ref = table2
	cust2.assigned_table_id = "table_2"
	table2.occupy(cust2)
	cust2.global_position = table2.get_seat_position()
	cust2.rotation.y = table2.get_seat_rotation_y()
	cust2.current_state = cust2.State.SEATED_ORDERING
	cust2.ordered_dish = gm.menu_items["pizza"]
	cust2.set_bubble_text("🍕 Pizza")
	cust2.current_patience = 18.0 # Yellow patience bar!
	cust2.is_waiting_for_food = true
	cust2._update_patience_bar()
	cust2._play_anim("sit")
	
	# Waiter 1 walking to kitchen, Waiter 2 on floor
	var w1 = restaurant.get_node_or_null("Waiter")
	if w1 != null:
		w1.global_position = Vector3(-1.8, 0, -3.8)
		w1.rotation.y = -PI * 0.5
		w1._play_anim("walk")
		w1.get_node("ServingTray").visible = true
	
	var w2 = restaurant.get_node_or_null("Waiter2")
	if w2 != null:
		w2.global_position = Vector3(2.2, 0, -2.5)
		w2.rotation.y = PI * 0.2
		w2._play_anim("idle")
	
	# Frame settling for particles and animations
	for i in range(25):
		await process_frame
		
	# ─── SNAPSHOT 1: Restaurant Overview with Patience Bars, Waiters & Upgrades ────
	cam.global_position = Vector3(4.8, 13.8, 13.2)
	cam.look_at(Vector3(-0.2, 0.8, -0.6), Vector3.UP)
	cam.fov = 38.0
	
	for i in range(15):
		await process_frame
		
	var img1 = root.get_viewport().get_texture().get_image()
	img1.save_png("/home/ian/Documents/Apps/idle game 1/test_gameplay_overview.png")
	print("Saved test_gameplay_overview.png")
	
	# ─── SNAPSHOT 2: Seated Customer Close-up with Patience Bar & Pasta ────────────
	cam.global_position = table1.global_position + Vector3(0.1, 1.4, 2.1)
	cam.look_at(table1.global_position + Vector3(-0.35, 0.55, 0), Vector3.UP)
	cam.fov = 38.0
	
	for i in range(15):
		await process_frame
		
	var img2 = root.get_viewport().get_texture().get_image()
	img2.save_png("/home/ian/Documents/Apps/idle game 1/test_gameplay_patience_closeup.png")
	print("Saved test_gameplay_patience_closeup.png")
	
	# ─── SNAPSHOT 3: Menu UI Modal ─────────────────────────────────────────────────
	hud_layer._toggle_menu_panel()
	for i in range(15):
		await process_frame
		
	var img3 = root.get_viewport().get_texture().get_image()
	img3.save_png("/home/ian/Documents/Apps/idle game 1/test_gameplay_menu_ui.png")
	print("Saved test_gameplay_menu_ui.png")
	
	# ─── SNAPSHOT 4: Staff UI Modal ────────────────────────────────────────────────
	hud_layer._toggle_staff_panel()
	for i in range(15):
		await process_frame
		
	var img4 = root.get_viewport().get_texture().get_image()
	img4.save_png("/home/ian/Documents/Apps/idle game 1/test_gameplay_staff_ui.png")
	print("Saved test_gameplay_staff_ui.png")
	
	print("All gameplay test captures finished successfully!")
	quit(0)
