extends SceneTree

var _frame_count: int = 0
var _max_frames: int = 120

var gm: Node = null
var am: Node = null
var rest: Node = null
var hud_node: CanvasLayer = null
var cam: Node = null

var cust_scn: PackedScene = null
var waiter_scn: PackedScene = null

var received_vip_alerts: Array = []
var dummy_nodes: Array[Node] = []
var critic_node: Node = null
var investor_node: Node = null
var test_vip_target: Node3D = null

func _init() -> void:
	print(">>> [TEST] Starting test_operational_alerts.gd (Deterministic Frame-Stepped State Machine)...")

func _process(delta: float) -> bool:
	_frame_count += 1
	if _frame_count >= _max_frames:
		printerr("ERROR: Watchdog timeout exceeded (%d frames)" % _max_frames)
		quit(1)
		return true

	match _frame_count:
		1:
			_step_frame_1()
		5:
			_step_frame_5()
		10:
			_step_frame_10()
		15:
			_step_frame_15()
			return true

	return false

func _step_frame_1() -> void:
	print("--- Frame 1: Instantiating nodes and attaching to root ---")
	# 1. GameManager (Use Autoload or instantiate)
	gm = root.get_node_or_null("GameManager")
	if gm == null:
		var gm_script = load("res://scripts/game_manager.gd")
		gm = gm_script.new()
		gm.name = "GameManager"
		root.add_child(gm)

	# 2. AudioManager (Use Autoload or instantiate)
	am = root.get_node_or_null("AudioManager")
	if am == null:
		var am_script = load("res://scripts/audio_manager.gd")
		am = am_script.new()
		am.name = "AudioManager"
		root.add_child(am)

	# 3. Restaurant
	var rest_script = load("res://scripts/restaurant.gd")
	rest = rest_script.new()
	rest.name = "Restaurant"
	root.add_child(rest)
	gm.register_restaurant(rest)

	# 4. Scenes
	cust_scn = load("res://scenes/customer.tscn")
	waiter_scn = load("res://scenes/waiter.tscn")

	# 5. Camera Controller
	var cam_script = load("res://scripts/camera_controller.gd")
	cam = cam_script.new()
	cam.name = "Camera3D"
	root.add_child(cam)

	# 6. UI HUD
	var hud_scn = load("res://scenes/ui/hud.tscn")
	hud_node = hud_scn.instantiate()
	root.add_child(hud_node)

	# Connect VIP alert listener
	gm.vip_arrived.connect(func(node, title, type, duration):
		received_vip_alerts.append({"node": node, "title": title, "type": type, "duration": duration})
	)
	print("✓ Frame 1 completed: Nodes instantiated and attached to root.")

func _step_frame_5() -> void:
	print("--- Frame 5: Triggering bottleneck diagnostics & verifying synchronously ---")
	
	# 1. Default state: Optimal Flow
	var status = rest.get_sector_bottleneck_status()
	assert(status["text"] == "Optimal Flow", "Default should be Optimal Flow, got: " + status["text"])
	assert(status["code"] == "OPTIMAL", "Code should be OPTIMAL")
	print("✓ Default Optimal Flow verified: " + str(status["text"]))

	# 2. Lobby Queue Full (3 waiting customers)
	var dummy_cust1 = Node3D.new()
	var dummy_cust2 = Node3D.new()
	var dummy_cust3 = Node3D.new()
	rest.add_child(dummy_cust1)
	rest.add_child(dummy_cust2)
	rest.add_child(dummy_cust3)
	dummy_nodes.append_array([dummy_cust1, dummy_cust2, dummy_cust3])
	var custs: Array[Node3D] = [dummy_cust1, dummy_cust2, dummy_cust3]
	rest.waiting_customers = custs
	status = rest.get_sector_bottleneck_status()
	assert(status["text"] == "Lobby Queue Full", "Should be Lobby Queue Full, got: " + status["text"])
	assert(status["code"] == "LOBBY_FULL", "Code should be LOBBY_FULL")
	print("✓ Lobby Queue Full verified: " + str(status["text"]))

	# Clear waiting customers
	rest.waiting_customers.clear()

	# 3. Kitchen Backlogged (pending_orders >= 3)
	var dummy_order1 = Node3D.new()
	var dummy_order2 = Node3D.new()
	var dummy_order3 = Node3D.new()
	rest.add_child(dummy_order1)
	rest.add_child(dummy_order2)
	rest.add_child(dummy_order3)
	dummy_nodes.append_array([dummy_order1, dummy_order2, dummy_order3])
	var orders: Array[Node3D] = [dummy_order1, dummy_order2, dummy_order3]
	rest.pending_orders = orders
	status = rest.get_sector_bottleneck_status()
	assert(status["text"] == "Kitchen Backlogged", "Should be Kitchen Backlogged, got: " + status["text"])
	assert(status["code"] == "KITCHEN_BACKLOGGED")
	print("✓ Kitchen Backlogged verified: " + str(status["text"]))
	rest.pending_orders.clear()

	# 4. Waiters Busy (Waiters busy & active pending work)
	var single_order: Array[Node3D] = [dummy_order1]
	rest.pending_orders = single_order
	var w = waiter_scn.instantiate()
	rest.add_child(w)
	dummy_nodes.append(w)
	var active_waiters: Array[Node3D] = [w]
	rest.waiters = active_waiters
	w.current_state = w.State.WALKING_TO_TABLE # Busy state
	status = rest.get_sector_bottleneck_status()
	assert(status["text"] == "Waiters Busy", "Should be Waiters Busy, got: " + status["text"])
	assert(status["code"] == "WAITERS_BUSY")
	print("✓ Waiters Busy verified: " + str(status["text"]))

	# 5. UI Upgrade Header Bottleneck Status Pill
	hud_node.open_upgrade("table_1", "Booth 1", 1)
	var header_pill = hud_node.find_child("BottleneckStatusPill", true, false)
	assert(header_pill != null, "BottleneckStatusPill should exist in UpgradePanel header")
	var header_lbl = header_pill.find_child("BottleneckLabel", true, false)
	assert(header_lbl != null, "BottleneckLabel should exist in header pill")
	assert("Waiters Busy" in header_lbl.text, "Header pill should show Waiters Busy, got: " + header_lbl.text)
	print("✓ Upgrade Header Bottleneck Status Pill verified: " + header_lbl.text)
	hud_node._close_modal(hud_node.upgrade_panel)

	# 6. Financial Analytics Bottleneck Diagnostic Card
	hud_node.open_analytics_modal()
	var found_diagnostic = false
	if hud_node.analytics_vbox != null:
		for child in hud_node.analytics_vbox.get_children():
			for lbl in child.find_children("*", "Label", true, false):
				if "BOTTLENECK" in lbl.text or "OPERATIONAL" in lbl.text:
					found_diagnostic = true
					break
			if found_diagnostic:
				break
	assert(found_diagnostic, "Sector Bottleneck Diagnostic card should be rendered in analytics modal")
	print("✓ Financial Analytics Bottleneck Diagnostic Card verified!")
	hud_node._close_modal(hud_node.analytics_panel)

	# Reset restaurant state
	rest.pending_orders.clear()
	w.current_state = w.State.IDLE
	status = rest.get_sector_bottleneck_status()
	assert(status["code"] == "OPTIMAL")
	print("✓ Frame 5 completed: Bottleneck diagnostics verified.")

func _step_frame_10() -> void:
	print("--- Frame 10: Triggering Michelin Critic / VIP arrival toast banner & verifying synchronously ---")
	
	# 1. Customer Critic arrival
	critic_node = cust_scn.instantiate()
	root.add_child(critic_node)
	dummy_nodes.append(critic_node)
	critic_node.set_as_critic(true)

	assert(received_vip_alerts.size() >= 1, "Should have received 1 VIP arrival alert")
	assert(received_vip_alerts[0]["type"] == "critic", "Type should be critic")
	assert("Michelin Critic" in received_vip_alerts[0]["title"], "Title should contain Michelin Critic")
	assert(received_vip_alerts[0]["duration"] == 26.0, "Duration should match max_patience (26.0)")
	print("✓ Michelin Critic arrival alert verified: " + str(received_vip_alerts[0]["title"]))

	# 2. VIP Investor arrival
	investor_node = cust_scn.instantiate()
	root.add_child(investor_node)
	dummy_nodes.append(investor_node)
	investor_node.set_as_vip_investor(true)

	assert(received_vip_alerts.size() >= 2, "Should have received 2nd VIP arrival alert")
	assert(received_vip_alerts[1]["type"] == "investor", "Type should be investor")
	assert("VIP Investor" in received_vip_alerts[1]["title"], "Title should contain VIP Investor")
	assert(received_vip_alerts[1]["duration"] == 45.0, "Duration should match max_patience (45.0)")
	print("✓ VIP Investor arrival alert verified: " + str(received_vip_alerts[1]["title"]))

	# 3. Camera Controller focus_target_node
	var target_prop = Node3D.new()
	target_prop.position = Vector3(10.0, 0.0, 5.0)
	root.add_child(target_prop)
	dummy_nodes.append(target_prop)

	cam.focus_target_node(target_prop, 0.2)
	assert(is_equal_approx(cam.target_position.x, 10.0 + 18.37), "Camera target X should match target + offset")
	assert(is_equal_approx(cam.target_position.z, 5.0 + 18.37), "Camera target Z should match target + offset")
	print("✓ Camera focus_target_node verified at: " + str(cam.target_position))

	# 4. VIP Arrival Toast Banner in UI
	test_vip_target = Node3D.new()
	test_vip_target.position = Vector3(2.0, 0.0, 4.0)
	root.add_child(test_vip_target)
	dummy_nodes.append(test_vip_target)

	gm.notify_vip_arrival(test_vip_target, "👑 Michelin Critic Arrived!", "critic", 20.0)

	var toast = hud_node.active_vip_toast
	assert(toast != null and is_instance_valid(toast), "VipArrivalToast should be created in scene")
	assert(toast.visible, "VipArrivalToast should be visible")
	var locate_btn = toast.find_child("LocateBtn", true, false)
	assert(locate_btn != null, "Locate button should exist in toast")
	var pbar = hud_node.active_vip_progress_bar
	assert(pbar != null and is_instance_valid(pbar), "ProgressBar should exist in toast")
	assert(pbar.max_value == 20.0, "Progress bar max_value should match arrival duration")
	print("✓ VipArrivalToast banner & countdown progress bar verified!")

	# Simulate pressing Locate button
	locate_btn.emit_signal("pressed")
	print("✓ Locate button tap verified!")
	print("✓ Frame 10 completed: VIP arrival toast banner verified.")

func _step_frame_15() -> void:
	print("--- Frame 15: Cleaning up instantiated nodes & exiting ---")
	for node in dummy_nodes:
		if is_instance_valid(node):
			node.free()
	dummy_nodes.clear()

	if is_instance_valid(hud_node):
		hud_node.free()
	if is_instance_valid(rest):
		rest.free()
	if is_instance_valid(cam):
		cam.free()

	print(">>> [TEST] ALL OPERATIONAL ALERT & BOTTLENECK DIAGNOSTIC TESTS PASSED DETERMINISTICALLY! <<<")
	quit(0)
