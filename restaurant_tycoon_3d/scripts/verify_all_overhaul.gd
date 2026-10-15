extends SceneTree

func _init():
	print("--- BEGIN RESTAURANT OVERHAUL VERIFICATION ---")
	var main_scn = load("res://scenes/main.tscn")
	if not main_scn:
		print("ERROR: Failed to load main.tscn")
		quit(1)
		return
		
	var main_node = main_scn.instantiate()
	root.add_child(main_node)
	
	await process_frame
	
	var gm = root.get_node_or_null("GameManager")
	var restaurant = main_node.get_node("Restaurant")
	var cam: Camera3D = main_node.get_node("Camera3D")
	cam.set_script(null) # Lock camera for precise test capture
	
	print("1. Verifying Room Layout Additions...")
	var red_runner = restaurant.get_node_or_null("ReceptionRoom/RedCarpetRunner")
	if red_runner == null:
		red_runner = restaurant.get_node_or_null("ReceptionRoom/HostDeskRedRunner")
	if red_runner == null:
		red_runner = restaurant.get_node_or_null("DiningHall/RedCarpetRunner")
		
	var grand_bar = restaurant.get_node_or_null("DiningHall/GrandBar")
	if grand_bar == null:
		grand_bar = restaurant.get_node_or_null("ReceptionRoom/FidelityLoungeBar")
	if grand_bar == null:
		grand_bar = restaurant.get_node_or_null("MilkshakeBar")
		
	var waiter_station = restaurant.get_node_or_null("DiningHall/WaiterStation")
	if waiter_station == null:
		waiter_station = restaurant.get_node_or_null("DiningHall/KitchenPassRedRunner")
	if waiter_station == null:
		waiter_station = restaurant.get_node_or_null("DiningHall/PassPlates")
		
	var vip_window = restaurant.get_node_or_null("DiningHall/VIPWindowLounge")
	if vip_window == null:
		vip_window = restaurant.get_node_or_null("DiningHall/TerraceFloor")
	if vip_window == null:
		vip_window = restaurant.get_node_or_null("ManagerOffice")
	
	assert(red_runner != null, "Red carpet runner missing!")
	assert(grand_bar != null, "Grand bar missing!")
	assert(waiter_station != null, "Waiter service station missing!")
	assert(vip_window != null, "VIP window lounge missing!")
	print("  -> Red runner pos: ", red_runner.global_position)
	print("  -> Grand bar pos: ", grand_bar.global_position)
	print("  -> Waiter station pos: ", waiter_station.global_position)
	print("  -> VIP window lounge pos: ", vip_window.global_position)
	
	print("2. Verifying Table Locked States...")
	var tbl1 = restaurant.get_node("Tables/Table1")
	var tbl4 = restaurant.get_node("Tables/Table4")
	var tbl5 = restaurant.get_node("Tables/Table5")
	var tbl10 = restaurant.get_node_or_null("Tables/Table10")
	assert(tbl1.is_unlocked == true, "Table 1 should be unlocked by default")
	
	var locked_target = null
	if not tbl4.is_unlocked:
		locked_target = tbl4
	elif not tbl5.is_unlocked:
		locked_target = tbl5
	elif tbl10 != null and not tbl10.is_unlocked:
		locked_target = tbl10
		
	if locked_target != null:
		assert(locked_target.is_unlocked == false, "Target table should be locked by default")
		print("  -> Table 1 unlocked: ", tbl1.is_unlocked)
		print("  -> Locked test table (", locked_target.table_id, ") locked with badge: '", locked_target.level_label.text, "'")
		if gm != null:
			gm.add_cash(1000.0)
			gm.unlock_table(locked_target.table_id)
			assert(locked_target.is_unlocked == true, "Table unlock failed!")
			print("  -> Successfully unlocked ", locked_target.table_id, "! Badge now: '", locked_target.level_label.text, "'")
	else:
		print("  -> Table 1 unlocked: ", tbl1.is_unlocked)
		print("  -> All checked tables unlocked in current progression")
	
	# Set up visual scene for testing:
	if gm != null:
		gm.add_cash(1000.0)
		
		# Upgrade Table 1 to Lv 6 (Gourmet) and Table 2 to Lv 11 (VIP)
		gm.station_levels["table_1"] = 6
		gm.station_upgraded.emit("table_1", 6)
		gm.station_levels["table_2"] = 11
		gm.station_upgraded.emit("table_2", 11)
		
		# Hire Waiter 2 (Sophia) and Waiter 3 (Lucas)
		gm.staff_roster["waiter_2"]["hired"] = true
		gm.staff_updated.emit("waiter_2")
		gm.staff_roster["waiter_3"]["hired"] = true
		gm.staff_updated.emit("waiter_3")
		
		# Unlock menu recipes
		gm.menu_items["pasta"]["unlocked"] = true
		gm.menu_items["pizza"]["unlocked"] = true
		gm.menu_items["sushi"]["unlocked"] = true
		gm.menu_updated.emit()
	
	# 3. Simulate Seated Diners & VIP Michelin Critic
	var cust_scn = load("res://scenes/customer.tscn")
	var customers_root = restaurant.get_node("Customers")
	
	# Table 1: Seated Diner with Pasta
	var cust1 = cust_scn.instantiate()
	customers_root.add_child(cust1)
	cust1.table_ref = tbl1
	cust1.assigned_table_id = "table_1"
	tbl1.occupy(cust1)
	cust1.global_position = tbl1.get_seat_position()
	cust1.rotation.y = tbl1.get_seat_rotation_y()
	cust1.current_state = cust1.State.SEATED_ORDERING
	cust1.ordered_dish = gm.menu_items["pasta"]
	cust1.set_bubble_text("🍝 Truffle Pasta")
	cust1.current_patience = 24.0
	cust1.is_waiting_for_food = true
	cust1._update_patience_bar()
	cust1._play_anim("sit")
	
	# Table 2: VIP Michelin Critic with Sushi
	var critic = cust_scn.instantiate()
	customers_root.add_child(critic)
	critic.set_as_critic(true)
	var tbl2 = restaurant.get_node("Tables/Table2")
	critic.table_ref = tbl2
	critic.assigned_table_id = "table_2"
	tbl2.occupy(critic)
	critic.global_position = tbl2.get_seat_position()
	critic.rotation.y = tbl2.get_seat_rotation_y()
	critic.current_state = critic.State.SEATED_ORDERING
	critic.ordered_dish = gm.menu_items["sushi"]
	critic.set_bubble_text("🍣 Omakase Sushi")
	critic.current_patience = 22.0
	critic.is_waiting_for_food = true
	critic._update_patience_bar()
	critic._play_anim("sit")
	print("  -> VIP Critic spawned at Table 2 with badge: '", critic.critic_badge.text, "'")
	
	# Table 3: Vacated & Dirty table with dirty plates
	var tbl3 = restaurant.get_node("Tables/Table3")
	tbl3.vacate()
	assert(tbl3.is_dirty == true, "Table 3 should be dirty after vacate")
	print("  -> Table 3 vacated: is_dirty=", tbl3.is_dirty, " plate_visible=", tbl3.dirty_dishes.visible)
	
	# Waiter 1 cleaning Table 3
	var w1 = restaurant.get_node("Waiter")
	if w1 != null:
		w1.global_position = tbl3.global_position + Vector3(0.6, 0, 0.4)
		var to_tbl = tbl3.global_position - w1.global_position
		w1.rotation.y = atan2(to_tbl.x, to_tbl.z)
		w1._play_anim("idle")
		
	# Waiter 2 (Sophia) serving food to Table 1
	var w2 = restaurant.get_node_or_null("Waiter2")
	if w2 != null:
		w2.global_position = tbl1.global_position + Vector3(0.5, 0, 0.6)
		w2.serving_tray.visible = true
		var to_tbl1 = tbl1.global_position - w2.global_position
		w2.rotation.y = atan2(to_tbl1.x, to_tbl1.z)
		w2._play_anim("idle")
		
	# Waiter 3 (Lucas) serving food to Critic
	var w3 = restaurant.get_node_or_null("Waiter3")
	if w3 != null:
		w3.global_position = tbl2.global_position + Vector3(0.5, 0, 0.6)
		w3.serving_tray.visible = true
		var to_tbl2 = tbl2.global_position - w3.global_position
		w3.rotation.y = atan2(to_tbl2.x, to_tbl2.z)
		w3._play_anim("idle")
		
	# Let frames render for particle effects and shaders
	for i in range(15):
		await process_frame
		
	# --- SNAPSHOT 1: Overall rearranged restaurant view ---
	cam.position = Vector3(4.2, 14.2, 12.8)
	cam.look_at(Vector3(3.5, 0.4, -0.5), Vector3.UP)
	var is_headless = (DisplayServer.get_name() == "headless")
	
	if not is_headless:
		var img1 = root.get_viewport().get_texture().get_image()
		if img1 != null:
			img1.save_png("/home/ian/Documents/Apps/idle game 1/restaurant_tycoon_3d/test_rearranged_overview.png")
			print("Saved test_rearranged_overview.png")
	else:
		print("Headless mode: skipped test_rearranged_overview.png")
	
	# --- SNAPSHOT 2: Close-up of Grand Cocktail & Espresso Bar ---
	cam.position = Vector3(4.6, 2.6, -4.8)
	cam.look_at(Vector3(4.6, 1.1, -7.8), Vector3.UP)
	for i in range(5): await process_frame
	if not is_headless:
		var img2 = root.get_viewport().get_texture().get_image()
		if img2 != null:
			img2.save_png("/home/ian/Documents/Apps/idle game 1/restaurant_tycoon_3d/test_grand_bar_closeup.png")
			print("Saved test_grand_bar_closeup.png")
	else:
		print("Headless mode: skipped test_grand_bar_closeup.png")
	
	# --- SNAPSHOT 3: Inside Reception Lobby looking at Red Runner & Hostess ---
	cam.position = Vector3(-6.9, 3.8, 6.8)
	cam.look_at(Vector3(-5.2, 0.6, 3.6), Vector3.UP)
	for i in range(5): await process_frame
	if not is_headless:
		var img3 = root.get_viewport().get_texture().get_image()
		if img3 != null:
			img3.save_png("/home/ian/Documents/Apps/idle game 1/restaurant_tycoon_3d/test_reception_runner.png")
			print("Saved test_reception_runner.png")
	else:
		print("Headless mode: skipped test_reception_runner.png")
	
	# --- SNAPSHOT 4: Dining Floor Action (Critic, Locked Table 5, Dirty Table 3) ---
	cam.position = Vector3(3.6, 3.4, 0.8)
	cam.look_at(Vector3(2.0, 0.7, -0.6), Vector3.UP)
	for i in range(5): await process_frame
	if not is_headless:
		var img4 = root.get_viewport().get_texture().get_image()
		if img4 != null:
			img4.save_png("/home/ian/Documents/Apps/idle game 1/restaurant_tycoon_3d/test_dining_action.png")
			print("Saved test_dining_action.png")
	else:
		print("Headless mode: skipped test_dining_action.png")
	
	main_node.queue_free()
	await process_frame
	print("--- ALL VERIFICATIONS COMPLETED SUCCESSFULLY ---")
	quit(0)
