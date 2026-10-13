extends SceneTree

func _init():
	var main_scn = load("res://scenes/main.tscn")
	var main_node = main_scn.instantiate()
	root.add_child(main_node)
	
	await process_frame
	
	var cam: Camera3D = main_node.get_node("Camera3D")
	cam.set_script(null)
	
	var tbl = main_node.get_node("Restaurant/Tables/Table2")
	
	# Spawn a customer and seat them at Table 2
	var cust_scn = load("res://scenes/customer.tscn")
	var cust = cust_scn.instantiate()
	main_node.get_node("Restaurant/Customers").add_child(cust)
	cust.assigned_table_id = "table_2"
	cust.table_ref = tbl
	cust.global_position = tbl.get_seat_position()
	cust.rotation.y = tbl.get_seat_rotation_y()
	cust.current_state = cust.State.SEATED_ORDERING
	cust._play_anim("sit")
	tbl.serve_food()
	
	# Position camera to look across the table showing BOTH chairs and the seated customer:
	cam.global_position = tbl.global_position + Vector3(0.0, 1.4, 2.2)
	cam.look_at(tbl.global_position + Vector3(0.0, 0.45, 0.0), Vector3.UP)
	cam.fov = 30.0
	
	for i in range(15):
		await process_frame
		
	var img = root.get_viewport().get_texture().get_image()
	img.save_png("/home/ian/Documents/Apps/idle game 1/verify_both_chairs.png")
	print("Saved verify_both_chairs.png")
	quit(0)
