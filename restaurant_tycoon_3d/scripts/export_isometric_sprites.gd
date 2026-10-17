extends SceneTree

func _init() -> void:
	print("Starting Isometric Sprite Export...")
	var out_dir = ProjectSettings.globalize_path("res://../assets/sprites/")
	var dir = DirAccess.open("res://../")
	if dir != null and not dir.dir_exists("assets/sprites"):
		dir.make_dir_recursive("assets/sprites")

	# Setup SubViewport for high quality rendering
	var vp = SubViewport.new()
	vp.transparent_bg = true
	vp.size = Vector2i(256, 256)
	vp.msaa_3d = Viewport.MSAA_4X
	vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var env = Environment.new()
	env.background_mode = Environment.BG_CLEAR_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.9, 0.9, 0.95)
	env.ambient_light_energy = 0.9
	
	var world = World3D.new()
	world.environment = env
	vp.world_3d = world

	# Directional key light
	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, -35, 0)
	sun.light_color = Color(1.0, 0.98, 0.92)
	sun.light_energy = 1.2
	sun.shadow_enabled = false
	vp.add_child(sun)

	# Directional fill light
	var fill = DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(30, 145, 0)
	fill.light_color = Color(0.85, 0.9, 1.0)
	fill.light_energy = 0.4
	vp.add_child(fill)

	# Isometric Camera
	var cam = Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.rotation_degrees = Vector3(-30.0, 45.0, 0.0)
	vp.add_child(cam)

	var models_to_render = [
		{
			"id": "booth",
			"path": "res://scenes/dining_table.tscn",
			"cam_size": 3.6,
			"offset": Vector3(0, 0.4, 0),
			"rot_y": 0.0
		},
		{
			"id": "stove",
			"path": "res://scenes/cooking_station.tscn",
			"cam_size": 2.8,
			"offset": Vector3(0, 0.4, 0),
			"rot_y": 0.0
		},
		{
			"id": "chef",
			"path": "res://scenes/chef.tscn",
			"cam_size": 2.2,
			"offset": Vector3(0, 0.6, 0),
			"rot_y": 0.0
		},
		{
			"id": "waiter",
			"path": "res://scenes/waiter.tscn",
			"cam_size": 2.2,
			"offset": Vector3(0, 0.6, 0),
			"rot_y": 0.0
		},
		{
			"id": "customer",
			"path": "res://assets/models/characters/character-female-b.glb",
			"cam_size": 2.2,
			"offset": Vector3(0, 0.55, 0),
			"rot_y": 0.0
		},
		{
			"id": "customer_vip",
			"path": "res://assets/models/characters/character-male-a.glb",
			"cam_size": 2.2,
			"offset": Vector3(0, 0.55, 0),
			"rot_y": 0.0
		},
		{
			"id": "car_taxi",
			"path": "res://assets/models/cars/taxi.glb",
			"cam_size": 4.5,
			"offset": Vector3(0, 0.5, 0),
			"rot_y": -90.0
		},
		{
			"id": "car_sedan",
			"path": "res://assets/models/cars/sedan.glb",
			"cam_size": 4.5,
			"offset": Vector3(0, 0.5, 0),
			"rot_y": -90.0
		},
		{
			"id": "car_suv",
			"path": "res://assets/models/cars/suv.glb",
			"cam_size": 4.5,
			"offset": Vector3(0, 0.5, 0),
			"rot_y": -90.0
		},
		{
			"id": "car_delivery",
			"path": "res://assets/models/cars/delivery.glb",
			"cam_size": 4.8,
			"offset": Vector3(0, 0.6, 0),
			"rot_y": -90.0
		},
		{
			"id": "car_sport",
			"path": "res://assets/models/cars/hatchback-sports.glb",
			"cam_size": 4.5,
			"offset": Vector3(0, 0.5, 0),
			"rot_y": -90.0
		}
	]

	for item in models_to_render:
		var scn = load(item["path"])
		if scn == null:
			print("Could not load scene: ", item["path"])
			continue
		
		var node = scn.instantiate()
		vp.add_child(node)
		if node is Node3D:
			node.rotation_degrees.y = item["rot_y"]

		cam.size = item["cam_size"]
		var target_pos = item["offset"]
		var cam_dist = 20.0
		cam.position = target_pos + cam.transform.basis.z * cam_dist

		# Wait for render frames
		for f in range(6):
			await process_frame

		var tex = vp.get_texture()
		if tex != null:
			var img = tex.get_image()
			if img != null:
				var file_name = item["id"] + ".png"
				var full_path = out_dir + file_name
				var err = img.save_png(full_path)
				print("Saved: ", full_path, " Result: ", err)

		node.queue_free()
		for f in range(2):
			await process_frame

	# Copy or export bubble sprites as well
	var bubbles = ["bubble_fork_knife.png", "bubble_hourglass.png", "bubble_cash_stack.png"]
	for b in bubbles:
		var src_path = ProjectSettings.globalize_path("res://assets/textures/" + b)
		var dst_path = out_dir + b
		var b_img = Image.load_from_file(src_path)
		if b_img != null:
			var err = b_img.save_png(dst_path)
			print("Copied bubble: ", dst_path, " Result: ", err)

	print("Export complete!")
	quit(0)
