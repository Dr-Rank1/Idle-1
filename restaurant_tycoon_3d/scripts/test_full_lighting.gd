extends SceneTree

func _init():
	var main_scn = load("res://scenes/main.tscn")
	var main_node = main_scn.instantiate()
	root.add_child(main_node)
	
	await process_frame
	
	# 1. Adjust WorldEnvironment
	var env: WorldEnvironment = main_node.get_node("WorldEnvironment")
	if env and env.environment:
		env.environment.ambient_light_energy = 0.32
		env.environment.ambient_light_color = Color(0.82, 0.86, 0.92, 1.0)
		env.environment.tonemap_exposure = 0.98
		env.environment.adjustment_brightness = 0.98
		env.environment.adjustment_contrast = 1.06
		env.environment.adjustment_saturation = 1.15
	
	# 2. Adjust Sun Light (Isometric key lighting from North-West)
	var sun: DirectionalLight3D = main_node.get_node("DirectionalLight3D_Sun")
	if sun:
		# Angle from high-left casting soft diagonal shadows towards bottom-right
		sun.rotation_degrees = Vector3(-55.0, 35.0, 0.0)
		sun.light_energy = 0.85
		sun.light_color = Color(1.0, 0.96, 0.90, 1.0)
		sun.shadow_enabled = true
		sun.shadow_blur = 1.6
		
	var fill: DirectionalLight3D = main_node.get_node("DirectionalLight3D_Fill")
	if fill:
		fill.light_energy = 0.20
		fill.light_color = Color(0.70, 0.82, 0.95, 1.0)
		
	# 3. Adjust Dining Floor Material
	var dining_floor: MeshInstance3D = main_node.get_node("Restaurant/DiningHall/FloorWood")
	if dining_floor and dining_floor.mesh:
		var mat: StandardMaterial3D = dining_floor.mesh.material
		if mat:
			mat.roughness = 0.72
			mat.metallic = 0.0
			mat.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
			mat.albedo_color = Color(0.92, 0.86, 0.80, 1.0)
			
	# 4. Adjust Walls Material
	var back_wall: MeshInstance3D = main_node.get_node("Restaurant/BuildingWalls/SolidBackWall")
	if back_wall and back_wall.mesh:
		var w_mat: StandardMaterial3D = back_wall.mesh.material
		if w_mat:
			w_mat.albedo_color = Color(0.88, 0.85, 0.80, 1.0)
			w_mat.roughness = 0.85
			
	# 5. Tune all 8 Tables: chairs, mesh scale, and seat positions
	var tables_root = main_node.get_node("Restaurant/Tables")
	for tbl in tables_root.get_children():
		var t_mesh = tbl.get_node_or_null("TableMesh")
		if t_mesh:
			t_mesh.scale = Vector3(0.56, 0.56, 0.56)
		var cl = tbl.get_node_or_null("ChairLeft")
		if cl:
			cl.scale = Vector3(0.55, 0.55, 0.55)
			cl.position = Vector3(-0.68, 0.0, 0.0)
			cl.rotation.y = PI * 0.5
		var cr = tbl.get_node_or_null("ChairRight")
		if cr:
			cr.scale = Vector3(0.55, 0.55, 0.55)
			cr.position = Vector3(0.68, 0.0, 0.0)
			cr.rotation.y = -PI * 0.5
		var sm = tbl.get_node_or_null("SeatMarker")
		if sm:
			sm.position = Vector3(-0.68, 0.15, 0.0)
			sm.rotation.y = PI * 0.5
		# Table omni light tone down
		var t_light = tbl.get_node_or_null("TableOmniLight")
		if t_light:
			t_light.light_energy = 0.22
		# Table items lower to tabletop
		for item_name in ["TableMenu", "SaltShaker", "PepperShaker", "FoodDish"]:
			var item = tbl.get_node_or_null(item_name)
			if item:
				item.position.y = 0.56
				
	# 6. Spawn customers seated at Tables 1, 2, 5
	var cust_scn = load("res://scenes/customer.tscn")
	for tid in ["Table1", "Table2", "Table5"]:
		var target_tbl = tables_root.get_node(tid)
		var cust = cust_scn.instantiate()
		main_node.get_node("Restaurant/Customers").add_child(cust)
		cust.assigned_table_id = target_tbl.table_id
		cust.table_ref = target_tbl
		cust.global_position = target_tbl.get_seat_position()
		cust.rotation.y = target_tbl.get_seat_rotation_y()
		cust.current_state = cust.State.SEATED_ORDERING
		cust._play_anim("sit")
		if target_tbl.has_method("serve_food"):
			target_tbl.serve_food()
			
	# 7. Camera overview
	var cam: Camera3D = main_node.get_node("Camera3D")
	cam.set_script(null)
	# Center view on restaurant
	cam.global_position = Vector3(4.5, 14.5, 13.5)
	cam.look_at(Vector3(0.0, 0.8, -0.5), Vector3.UP)
	cam.fov = 34.0
	
	for i in range(20):
		await process_frame
		
	var img = root.get_viewport().get_texture().get_image()
	img.save_png("/home/ian/Documents/Apps/idle game 1/test_full_lighting.png")
	print("Saved test_full_lighting.png")
	quit(0)
