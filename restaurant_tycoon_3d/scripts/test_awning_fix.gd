extends SceneTree

func _init():
	var main_scn = load("res://scenes/main.tscn")
	var main_node = main_scn.instantiate()
	root.add_child(main_node)
	
	await process_frame
	
	var slope = main_node.get_node("Restaurant/ReceptionRoom/ExteriorFacade/BistroCanopy/AwningSlope")
	var mat = slope.material.duplicate()
	mat.uv1_rotation = Vector3(0, 0, deg_to_rad(90))
	slope.material = mat
	
	var cam: Camera3D = main_node.get_node("Camera3D")
	cam.set_script(null)
	cam.global_position = Vector3(-5.5, 2.6, 11.2)
	cam.look_at(Vector3(-5.5, 2.5, 7.0), Vector3.UP)
	cam.fov = 38.0
	
	for i in range(15):
		await process_frame
		
	var img = root.get_viewport().get_texture().get_image()
	img.save_png("/home/ian/Documents/Apps/idle game 1/test_awning_uv_result.png")
	print("Saved test_awning_uv_result.png")
	quit(0)
