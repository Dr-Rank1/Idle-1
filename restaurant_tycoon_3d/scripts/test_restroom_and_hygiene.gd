extends SceneTree

var _frame_count: int = 0
var _max_frames: int = 120

var gm: Node = null
var am: Node = null
var rest: Node = null
var hud_node: CanvasLayer = null
var cam: Node = null

var cust_scn: PackedScene = null
var test_customer: Node3D = null
var dummy_customers: Array[Node3D] = []

func _init() -> void:
	print(">>> [TEST] Starting test_restroom_and_hygiene.gd...")

func _process(_delta: float) -> bool:
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
		20:
			_step_frame_20()
			return true

	return false

func _step_frame_1() -> void:
	print("--- Frame 1: Setup and node instantiation ---")
	gm = root.get_node_or_null("GameManager")
	if gm == null:
		var gm_script = load("res://scripts/game_manager.gd")
		gm = gm_script.new()
		gm.name = "GameManager"
		root.add_child(gm)

	am = root.get_node_or_null("AudioManager")
	if am == null:
		var am_script = load("res://scripts/audio_manager.gd")
		am = am_script.new()
		am.name = "AudioManager"
		root.add_child(am)

	var rest_script = load("res://scripts/restaurant.gd")
	rest = rest_script.new()
	rest.name = "Restaurant"
	root.add_child(rest)
	gm.register_restaurant(rest)

	cust_scn = load("res://scenes/customer.tscn")
	if cust_scn != null:
		test_customer = cust_scn.instantiate()
		test_customer.name = "TestCustomer"
		root.add_child(test_customer)

	var hud_scn = load("res://scenes/ui/hud.tscn")
	if hud_scn != null:
		hud_node = hud_scn.instantiate()
		root.add_child(hud_node)

	print("✓ Frame 1 completed: Nodes instantiated.")

func _step_frame_5() -> void:
	print("--- Frame 5: Testing Restroom Stalls & Sinks Layout ---")
	assert(rest != null, "Restaurant node must exist")
	assert(rest.restroom_stalls.size() == 7, "Must have exactly 7 restroom stalls, got: %d" % rest.restroom_stalls.size())
	assert(rest.restroom_sinks.size() == 4, "Must have 4 ceramic sinks, got: %d" % rest.restroom_sinks.size())
	print("✓ 7 dark slate stalls and 4 north wall sinks verified.")

	# Test stall door open ratio and animation
	rest.set_stall_door_open_ratio(0, 1.0)
	assert(abs(rest.restroom_stalls[0]["door_ratio"] - 1.0) < 0.01, "Stall 0 door ratio should be 1.0")
	rest.set_stall_door_open_ratio(0, 0.0)
	assert(abs(rest.restroom_stalls[0]["door_ratio"] - 0.0) < 0.01, "Stall 0 door ratio should be 0.0")

	var tw = rest.animate_stall_door(1, true, 0.1)
	assert(tw != null, "animate_stall_door should return a Tween")
	print("✓ Stall door animation & hinge trigonometry verified.")

	# Test requesting stalls
	var dummy1 = Node3D.new()
	root.add_child(dummy1)
	dummy_customers.append(dummy1)
	var req1 = rest.request_restroom_stall(dummy1)
	assert(req1["stall_idx"] == 0, "First stall request should get stall 0")
	assert(req1["is_queued"] == false, "First request should not be queued")
	print("✓ Immediate stall reservation verified: " + str(req1))

	# Request remaining 6 stalls so all 7 are occupied
	for i in range(1, 7):
		var d = Node3D.new()
		root.add_child(d)
		dummy_customers.append(d)
		var req = rest.request_restroom_stall(d)
		assert(req["is_queued"] == false, "Stall %d should be unqueued" % i)

	# Request 8th stall -> should queue
	var dummy8 = Node3D.new()
	root.add_child(dummy8)
	dummy_customers.append(dummy8)
	var req8 = rest.request_restroom_stall(dummy8)
	assert(req8["is_queued"] == true, "8th request must queue outside occupied stalls")
	print("✓ Stall queueing verified: " + str(req8))

	# Release stall 0
	rest.finish_using_stall(0, dummy1)
	assert(rest.restroom_stalls[0]["occupant"] == dummy8, "Queued dummy8 should now occupy stall 0")
	print("✓ Queue pop upon finishing stall verified.")

	# Test Sinks
	var sink_pos = rest.get_available_sink_spot(dummy8)
	assert(sink_pos.z < -8.5, "Sink pos must be in front of North wall sinks (z < -8.5), got: " + str(sink_pos))
	rest.release_sink_spot(dummy8)
	print("✓ Ceramic sink allocation & release verified: " + str(sink_pos))

func _step_frame_10() -> void:
	print("--- Frame 10: Testing Cleanliness Metric & Rapid Sanitation ---")
	gm.cleanliness = 100.0
	assert(gm.get_cleanliness() == 100.0, "Initial cleanliness should be 100.0")

	gm.record_dirty_table()
	assert(gm.get_cleanliness() < 100.0, "Dirty table should reduce cleanliness")
	var cln_after_table = gm.get_cleanliness()

	gm.record_restroom_use()
	assert(gm.get_cleanliness() < cln_after_table, "Restroom use should reduce cleanliness")

	# Test Star rating drop when cleanliness < 75
	gm.cleanliness = 50.0
	gm._update_hygiene_star_rating()
	assert(gm.star_rating < 5.0, "Star rating should drop when cleanliness < 75%")
	print("✓ Cleanliness wear and star rating coupling verified: Cleanliness = %.1f, Stars = %.2f" % [gm.cleanliness, gm.star_rating])

	# Test Rapid Sanitation Upkeep Deduction
	gm.cash = 10000.0
	var pre_cash = gm.cash
	var cost = gm.get_cleaning_upkeep_cost()
	var triggered_signal_received = [false]
	gm.rapid_sanitation_triggered.connect(func(_cost):
		triggered_signal_received[0] = true
	, CONNECT_ONE_SHOT)

	var success = gm.trigger_rapid_sanitation()
	assert(success == true, "Rapid sanitation should succeed")
	assert(abs(gm.cash - (pre_cash - cost)) < 0.01, "Upkeep cost should be deducted from treasury")
	assert(gm.cleanliness == 100.0, "Cleanliness must be restored to 100.0")
	assert(gm.star_rating == 5.0, "Star rating must be restored to 5.0")
	assert(triggered_signal_received[0] == true, "rapid_sanitation_triggered signal must be emitted")
	print("✓ Rapid sanitation deduction & full restoration verified. Upkeep: $%.2f, Remaining Cash: $%.2f" % [cost, gm.cash])

func _step_frame_15() -> void:
	print("--- Frame 15: Testing Customer Restroom Navigation & Waypoints ---")
	if test_customer != null:
		# Test table to restroom waypoints
		var wps = test_customer._get_waypoints_from_table_to_restroom(Vector3(1.2, 0.0, 0.8))
		assert(wps.size() >= 3, "Must have waypoints through northern aisle to restroom")
		var has_entrance: bool = false
		for pt in wps:
			if pt.distance_to(Vector3(2.0, 0.0, -3.5)) < 0.5:
				has_entrance = true
				break
		assert(has_entrance, "Waypoints must route through south entrance Vector3(2.0, 0.0, -3.5)")
		print("✓ Restroom entrance waypoint path verified.")

		# Test starting restroom visit
		var started = test_customer._start_restroom_visit()
		assert(started == true, "Customer should successfully start restroom visit")
		assert(test_customer.current_state == test_customer.State.WALKING_TO_RESTROOM, "State should be WALKING_TO_RESTROOM")
		assert(test_customer.is_visiting_restroom == true, "is_visiting_restroom should be true")
		print("✓ Customer restroom state transition verified.")

func _step_frame_20() -> void:
	print("--- Frame 20: Test Completion & Cleanup ---")
	for d in dummy_customers:
		if is_instance_valid(d):
			d.queue_free()
	if is_instance_valid(test_customer):
		test_customer.queue_free()
	if is_instance_valid(hud_node):
		hud_node.queue_free()
	if is_instance_valid(rest):
		rest.queue_free()

	print("=======================================================")
	print(">>> ALL RESTROOM & HYGIENE SECTOR TESTS PASSED! (0 ERRORS) <<<")
	print("=======================================================")
	quit(0)
