extends SceneTree
func _init():
	print("=== Testing Camera Controller Mobile Diorama & Inertia ===")
	var cam_script = load("res://scripts/camera_controller.gd")
	var cam = cam_script.new()
	root.add_child(cam)
	
	# 1. Default size verification (11.5 - 13.0)
	assert(cam.size >= 11.5 and cam.size <= 13.0, "Camera default size should be between 11.5 and 13.0, got: " + str(cam.size))
	print("[PASS] Default size verified: ", cam.size)
	
	# 2. Clamped zoom limits (8.5 - 16.5)
	cam._zoom(-100.0) # Zoom in
	assert(cam.size == 8.5, "Min zoom should clamp to 8.5, got: " + str(cam.size))
	cam._zoom(100.0) # Zoom out
	assert(cam.size == 16.5, "Max zoom should clamp to 16.5, got: " + str(cam.size))
	cam._zoom(-2.0)
	assert(cam.size >= 8.5 and cam.size <= 16.5, "Zoom in range verified")
	print("[PASS] Clamped zoom limits (8.5 - 16.5) verified!")
	
	# 3. Drag Gesture & Inertia Damping
	var press_ev = InputEventMouseButton.new()
	press_ev.button_index = MOUSE_BUTTON_LEFT
	press_ev.pressed = true
	press_ev.position = Vector2(500, 300)
	cam._unhandled_input(press_ev)
	assert(cam.is_dragging == true, "Dragging should be active")
	
	var motion_ev = InputEventMouseMotion.new()
	motion_ev.position = Vector2(400, 200) # Swiped 100px left, 100px up
	cam._unhandled_input(motion_ev)
	assert(cam.drag_velocity.length() > 0.0, "Drag velocity should be registered")
	
	var release_ev = InputEventMouseButton.new()
	release_ev.button_index = MOUSE_BUTTON_LEFT
	release_ev.pressed = false
	release_ev.position = Vector2(400, 200)
	cam._unhandled_input(release_ev)
	assert(cam.is_dragging == false, "Dragging should be ended")
	assert(cam.pan_velocity.length() > 0.0, "Pan velocity should have momentum after release, got: " + str(cam.pan_velocity.length()))
	print("[PASS] Inertia launch velocity registered: ", cam.pan_velocity.length())
	
	# 4. Decay damping
	var initial_vel = cam.pan_velocity.length()
	cam._process(0.1) # 100ms
	assert(cam.pan_velocity.length() < initial_vel, "Velocity should decay through inertia damping")
	print("[PASS] Inertia decayed from " + str(initial_vel) + " to " + str(cam.pan_velocity.length()))
	
	for i in range(30):
		cam._process(0.1)
	assert(cam.pan_velocity == Vector3.ZERO, "Velocity should eventually reach zero")
	print("[PASS] Full inertia damping settled cleanly to zero!")
	
	cam.queue_free()
	print("=== ALL CAMERA TESTS PASSED ===")
	quit(0)
