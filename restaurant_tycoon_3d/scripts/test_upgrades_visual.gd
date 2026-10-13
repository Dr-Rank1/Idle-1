extends SceneTree

func _init():
	var main_scn = load("res://scenes/main.tscn")
	var main_node = main_scn.instantiate()
	root.add_child(main_node)
	
	await process_frame
	
	var gm = main_node.get_node("/root/GameManager")
	var tbl1 = main_node.get_node("Restaurant/Tables/Table1")
	var tbl2 = main_node.get_node("Restaurant/Tables/Table2")
	var tbl3 = main_node.get_node("Restaurant/Tables/Table3")
	
	# Upgrade Table 2 to Level 5 (Tier 2 Gourmet)
	gm.station_levels["table_2"] = 5
	tbl2.update_level_display(5)
	
	# Upgrade Table 3 to Level 10 (Tier 3 Royal VIP)
	gm.station_levels["table_3"] = 10
	tbl3.update_level_display(10)
	
	# Seat a customer at Table 2 to verify proper seating with TableCloth and Wine Glasses!
	var cust_scn = load("res://scenes/customer.tscn")
	var cust = cust_scn.instantiate()
	main_node.get_node("Restaurant/Customers").add_child(cust)
	cust.assigned_table_id = "table_2"
	cust.table_ref = tbl2
	cust.global_position = tbl2.get_seat_position()
	cust.rotation.y = tbl2.get_seat_rotation_y()
	cust.current_state = cust.State.SEATED_ORDERING
	cust._play_anim("sit")
	tbl2.serve_food()
	
	# Open upgrade UI for Table 2
	var ui = main_node.get_node("HUD")
	if ui:
		ui.open_upgrade("table_2", "Garden Table 2", 5)
		
	var cam: Camera3D = main_node.get_node("Camera3D")
	cam.set_script(null)
	# Frame Table 1, 2, and 3 along with the upgrade panel
	cam.global_position = Vector3(3.2, 3.8, 4.2)
	cam.look_at(Vector3(1.8, 0.6, 0.0), Vector3.UP)
	cam.fov = 36.0
	
	for i in range(15):
		await process_frame
		
	var img = root.get_viewport().get_texture().get_image()
	img.save_png("/home/ian/Documents/Apps/idle game 1/test_upgrades_visual.png")
	print("Saved test_upgrades_visual.png")
	quit(0)
