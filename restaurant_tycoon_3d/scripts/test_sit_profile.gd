extends SceneTree

func _init():
	var main_scn = load("res://scenes/main.tscn")
	var main_node = main_scn.instantiate()
	root.add_child(main_node)
	
	await process_frame
	
	var cam: Camera3D = main_node.get_node("Camera3D")
	cam.set_script(null)
	
	var tbl = main_node.get_node("Restaurant/Tables/Table2")
	var chair_l = tbl.get_node("ChairLeft")
	var chair_r = tbl.get_node("ChairRight")
	var table_mesh = tbl.get_node("TableMesh")
	
	# Tune table and chairs
	table_mesh.scale = Vector3(0.56, 0.56, 0.56)
	chair_l.scale = Vector3(0.55, 0.55, 0.55)
	chair_l.position = Vector3(-0.68, 0.0, 0.0)
	chair_l.rotation.y = PI * 0.5
	
	chair_r.scale = Vector3(0.55, 0.55, 0.55)
	chair_r.position = Vector3(0.68, 0.0, 0.0)
	chair_r.rotation.y = -PI * 0.5
	
	# Create seated customer
	var cust_scn = load("res://scenes/customer.tscn")
	var cust = cust_scn.instantiate()
	main_node.get_node("Restaurant/Customers").add_child(cust)
	cust._play_anim("sit")
	
	# Position customer on chair cushion:
	# Chair is at (-0.68, 0, 0), seat center is at local z~0, so global x = tbl.x - 0.68
	cust.global_position = tbl.global_position + Vector3(-0.68, 0.15, 0.0)
	cust.rotation.y = PI * 0.5
	
	# Camera profile view
	cam.global_position = tbl.global_position + Vector3(-0.35, 1.1, 1.9)
	cam.look_at(tbl.global_position + Vector3(-0.25, 0.45, 0.0), Vector3.UP)
	cam.fov = 28.0
	
	for i in range(15):
		await process_frame
		
	var img = root.get_viewport().get_texture().get_image()
	img.save_png("/home/ian/Documents/Apps/idle game 1/test_sit_profile2.png")
	print("Saved test_sit_profile2.png")
	quit(0)
