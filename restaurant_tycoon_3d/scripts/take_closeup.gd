@tool
extends SceneTree

func _init():
	print("Starting close-up snapshot runner...")
	var main_scn = load("res://scenes/main.tscn")
	if not main_scn:
		print("FAILED to load main.tscn")
		quit(1)
		return
	
	var main_node = main_scn.instantiate()
	root.add_child(main_node)
	
	# Move camera to close-up of Table 1: Table 1 is at (2.5, 0, 4.2)
	var cam: Camera3D = main_node.get_node("Camera3D")
	cam.set_script(null) # disable script override
	cam.global_position = Vector3(2.5, 2.8, 7.2)
	cam.look_at(Vector3(2.5, 0.7, 4.2), Vector3.UP)
	cam.fov = 32.0
	
	# Spawn a customer and seat them at Table 1 immediately
	var rest = main_node.get_node("Restaurant")
	var tbl = main_node.get_node("Restaurant/Tables/Table1")
	var cust_scn = load("res://scenes/customer.tscn")
	var cust = cust_scn.instantiate()
	main_node.get_node("Restaurant/Customers").add_child(cust)
	cust.assigned_table_id = "table_1"
	cust.table_ref = tbl
	cust.global_position = tbl.get_seat_position()
	cust.current_state = cust.State.SEATED_ORDERING
	cust._play_anim("sit")
	if tbl != null:
		var to_tbl: Vector3 = tbl.global_position - cust.position
		cust.rotation.y = atan2(to_tbl.x, to_tbl.z)
	
	# Let frames run
	for i in range(120):
		await process_frame
	
	var img = root.get_viewport().get_texture().get_image()
	var out_path = "/home/ian/Documents/Apps/idle game 1/closeup_table.png"
	img.save_png(out_path)
	print("Saved close-up to ", out_path)
	quit(0)
