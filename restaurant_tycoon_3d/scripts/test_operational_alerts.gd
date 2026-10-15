extends SceneTree

func _init() -> void:
	print(">>> [TEST] Starting test_operational_alerts.gd...")
	call_deferred("_run_tests")

func _get_game_manager() -> Node:
	var gm = root.get_node_or_null("GameManager")
	if gm == null:
		var gm_script = load("res://scripts/game_manager.gd")
		gm = gm_script.new()
		gm.name = "GameManager"
		root.add_child(gm)
	return gm

func _get_audio_manager() -> Node:
	var am = root.get_node_or_null("AudioManager")
	if am == null:
		var am_script = load("res://scripts/audio_manager.gd")
		am = am_script.new()
		am.name = "AudioManager"
		root.add_child(am)
	return am

func _run_tests() -> void:
	var gm = _get_game_manager()
	var am = _get_audio_manager()
	await create_timer(0.2).timeout

	# ─── 1. Test Sector Bottleneck Status in Restaurant ─────────────────────────
	print("--- 1. Testing Sector Bottleneck Status in restaurant.gd ---")
	var rest_script = load("res://scripts/restaurant.gd")
	var rest = rest_script.new()
	rest.name = "TestRestaurant"
	root.add_child(rest)

	var cust_scn = load("res://scenes/customer.tscn")
	var waiter_scn = load("res://scenes/waiter.tscn")
	var table_scn = load("res://scenes/dining_table.tscn")

	# Default state: Optimal Flow
	var status = rest.get_sector_bottleneck_status()
	assert(status["text"] == "Optimal Flow", "Default should be Optimal Flow, got: " + status["text"])
	assert(status["code"] == "OPTIMAL", "Code should be OPTIMAL")
	print("✓ Default Optimal Flow verified: " + str(status["text"]))

	# Test Lobby Queue Full (3 waiting customers)
	var dummy_cust1 = Node3D.new()
	var dummy_cust2 = Node3D.new()
	var dummy_cust3 = Node3D.new()
	rest.add_child(dummy_cust1)
	rest.add_child(dummy_cust2)
	rest.add_child(dummy_cust3)
	var custs: Array[Node3D] = [dummy_cust1, dummy_cust2, dummy_cust3]
	rest.waiting_customers = custs
	status = rest.get_sector_bottleneck_status()
	assert(status["text"] == "Lobby Queue Full", "Should be Lobby Queue Full, got: " + status["text"])
	assert(status["code"] == "LOBBY_FULL", "Code should be LOBBY_FULL")
	print("✓ Lobby Queue Full verified: " + str(status["text"]))

	# Clear waiting customers
	rest.waiting_customers.clear()

	# Test Kitchen Backlogged (pending_orders >= 3)
	var dummy_order1 = Node3D.new()
	var dummy_order2 = Node3D.new()
	var dummy_order3 = Node3D.new()
	rest.add_child(dummy_order1)
	rest.add_child(dummy_order2)
	rest.add_child(dummy_order3)
	var orders: Array[Node3D] = [dummy_order1, dummy_order2, dummy_order3]
	rest.pending_orders = orders
	status = rest.get_sector_bottleneck_status()
	assert(status["text"] == "Kitchen Backlogged", "Should be Kitchen Backlogged, got: " + status["text"])
	assert(status["code"] == "KITCHEN_BACKLOGGED")
	print("✓ Kitchen Backlogged verified: " + str(status["text"]))

	# Test Waiters Busy (Waiters busy & active pending work)
	var single_order: Array[Node3D] = [dummy_order1]
	rest.pending_orders = single_order # 1 pending order
	var w = waiter_scn.instantiate()
	rest.add_child(w)
	var active_waiters: Array[Node3D] = [w]
	rest.waiters = active_waiters
	w.current_state = w.State.WALKING_TO_TABLE # Busy state
	status = rest.get_sector_bottleneck_status()
	assert(status["text"] == "Waiters Busy", "Should be Waiters Busy, got: " + status["text"])
	assert(status["code"] == "WAITERS_BUSY")
	print("✓ Waiters Busy verified: " + str(status["text"]))

	# Clean up restaurant
	rest.queue_free()
	await create_timer(0.1).timeout

	# ─── 2. Test Customer Critic and VIP Investor Arrival Signals ───────────────
	print("--- 2. Testing Customer Critic & VIP Investor Arrival Signals ---")
	var received_vip_alerts = []
	var on_vip = func(node, title, type, duration):
		received_vip_alerts.append({"node": node, "title": title, "type": type, "duration": duration})
	gm.vip_arrived.connect(on_vip)

	var critic_node = cust_scn.instantiate()
	root.add_child(critic_node)
	critic_node.set_as_critic(true)

	assert(received_vip_alerts.size() == 1, "Should have received 1 VIP arrival alert")
	assert(received_vip_alerts[0]["type"] == "critic", "Type should be critic")
	assert("Michelin Critic" in received_vip_alerts[0]["title"], "Title should contain Michelin Critic")
	assert(received_vip_alerts[0]["duration"] == 26.0, "Duration should match max_patience (26.0)")
	print("✓ Michelin Critic arrival alert verified: " + str(received_vip_alerts[0]["title"]))

	var investor_node = cust_scn.instantiate()
	root.add_child(investor_node)
	investor_node.set_as_vip_investor(true)

	assert(received_vip_alerts.size() == 2, "Should have received 2nd VIP arrival alert")
	assert(received_vip_alerts[1]["type"] == "investor", "Type should be investor")
	assert("VIP Investor" in received_vip_alerts[1]["title"], "Title should contain VIP Investor")
	assert(received_vip_alerts[1]["duration"] == 45.0, "Duration should match max_patience (45.0)")
	print("✓ VIP Investor arrival alert verified: " + str(received_vip_alerts[1]["title"]))

	gm.vip_arrived.disconnect(on_vip)
	critic_node.queue_free()
	investor_node.queue_free()
	await create_timer(0.1).timeout

	# ─── 3. Testing Camera Controller focus_target_node ─────────────────────────
	print("--- 3. Testing Camera Controller focus_target_node ---")
	var cam_script = load("res://scripts/camera_controller.gd")
	var cam = cam_script.new()
	cam.name = "TestCam"
	root.add_child(cam)
	await create_timer(0.05).timeout

	var target_prop = Node3D.new()
	target_prop.position = Vector3(10.0, 0.0, 5.0)
	root.add_child(target_prop)

	cam.focus_target_node(target_prop, 0.2)
	assert(is_equal_approx(cam.target_position.x, 10.0 + 18.37), "Camera target X should match target + offset")
	assert(is_equal_approx(cam.target_position.z, 5.0 + 18.37), "Camera target Z should match target + offset")
	print("✓ Camera focus_target_node verified at: " + str(cam.target_position))

	target_prop.queue_free()
	cam.queue_free()
	await create_timer(0.1).timeout

	# ─── 4. Testing UI Controller VIP Arrival Toast Banner ─────────────────────
	print("--- 4. Testing UI Controller VIP Arrival Toast Banner ---")
	var hud_scn = load("res://scenes/ui/hud.tscn")
	var hud_node = hud_scn.instantiate()
	root.add_child(hud_node)
	await create_timer(0.2).timeout

	var ui_ctrl = hud_node.get_script()
	var test_vip_target = Node3D.new()
	test_vip_target.position = Vector3(2.0, 0.0, 4.0)
	root.add_child(test_vip_target)

	# Trigger VIP arrival
	gm.notify_vip_arrival(test_vip_target, "👑 Michelin Critic Arrived!", "critic", 20.0)
	await create_timer(0.1).timeout

	var toast = hud_node.find_child("VipArrivalToast", true, false)
	assert(toast != null, "VipArrivalToast should be created in scene")
	var locate_btn = toast.find_child("LocateBtn", true, false)
	assert(locate_btn != null, "Locate button should exist in toast")
	var pbar = toast.find_child("ProgressBar", true, false)
	assert(pbar != null, "ProgressBar should exist in toast")
	assert(pbar.max_value == 20.0, "Progress bar max_value should match arrival duration")
	print("✓ VipArrivalToast banner & countdown progress bar verified!")

	# Simulate pressing Locate button
	locate_btn.emit_signal("pressed")
	print("✓ Locate button tap verified!")

	# ─── 5. Testing Upgrade Header Bottleneck Status Pill ───────────────────────
	print("--- 5. Testing Upgrade Header Bottleneck Status Pill ---")
	hud_node.open_upgrade("table_1", "Booth 1", 1)
	await create_timer(0.1).timeout

	var header_pill = hud_node.find_child("BottleneckStatusPill", true, false)
	assert(header_pill != null, "BottleneckStatusPill should exist in UpgradePanel header")
	var header_lbl = header_pill.find_child("BottleneckLabel", true, false)
	assert(header_lbl != null, "BottleneckLabel should exist in header pill")
	assert("Optimal Flow" in header_lbl.text, "Header pill should show Optimal Flow")
	print("✓ Upgrade Header Bottleneck Status Pill verified: " + header_lbl.text)

	# ─── 6. Testing Financial Analytics Bottleneck Diagnostic Card ──────────────
	print("--- 6. Testing Financial Analytics Bottleneck Diagnostic Card ---")
	hud_node.open_analytics_modal()
	await create_timer(0.1).timeout

	var analytics_vbox = hud_node.find_child("VBox", true, false)
	var found_diagnostic = false
	for child in hud_node.analytics_vbox.get_children():
		for lbl in child.find_children("*", "Label", true, false):
			if "BOTTLENECK" in lbl.text or "OPERATIONAL" in lbl.text:
				found_diagnostic = true
				break
		if found_diagnostic:
			break
	assert(found_diagnostic, "Sector Bottleneck Diagnostic card should be rendered in analytics modal")
	print("✓ Financial Analytics Bottleneck Diagnostic Card verified!")

	hud_node.queue_free()
	test_vip_target.queue_free()
	await create_timer(0.1).timeout

	print(">>> [TEST] ALL OPERATIONAL ALERT & BOTTLENECK DIAGNOSTIC TESTS PASSED SUCCESSFULLY! <<<")
	quit(0)
