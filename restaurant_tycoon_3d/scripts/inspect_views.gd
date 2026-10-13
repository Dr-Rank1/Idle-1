extends SceneTree

func _init():
	var main_scn = load("res://scenes/main.tscn")
	var main_node = main_scn.instantiate()
	root.add_child(main_node)
	
	# Wait 1 frame so scene tree transforms are ready
	await process_frame
	
	var cam: Camera3D = main_node.get_node("Camera3D")
	cam.set_script(null) # freeze camera controller
	
	# 1. Close-up on Kitchen
	cam.global_position = Vector3(-4.0, 6.5, -0.5)
	cam.look_at(Vector3(-6.5, 0.8, -5.5), Vector3.UP)
	cam.fov = 38.0
	
	for i in range(10):
		await process_frame
	
	var img_kitchen = root.get_viewport().get_texture().get_image()
	img_kitchen.save_png("/home/ian/Documents/Apps/idle game 1/inspect_kitchen.png")
	print("Kitchen inspect saved")
	
	# 2. Close-up on Dining Table with Seated Customer
	var tbl = main_node.get_node("Restaurant/Tables/Table2")
	var cust_scn = load("res://scenes/customer.tscn")
	var cust = cust_scn.instantiate()
	main_node.get_node("Restaurant/Customers").add_child(cust)
	cust.assigned_table_id = "table_2"
	cust.table_ref = tbl
	cust.global_position = tbl.get_seat_position()
	cust.current_state = cust.State.SEATED_ORDERING
	cust.rotation.y = tbl.get_seat_rotation_y()
	cust._play_anim("sit")
	
	cam.global_position = Vector3(3.6, 2.4, 3.2)
	cam.look_at(tbl.global_position + Vector3(0, 0.5, 0), Vector3.UP)
	cam.fov = 32.0
	
	for i in range(15):
		await process_frame
		
	var img_table = root.get_viewport().get_texture().get_image()
	img_table.save_png("/home/ian/Documents/Apps/idle game 1/inspect_seating.png")
	print("Seating inspect saved")
	
	quit(0)
