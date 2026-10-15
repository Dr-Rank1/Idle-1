extends SceneTree

func _init():
	print("--- BEGIN TEST ACTIVE SERVICE SECTORS ---")
	var main_scn = load("res://scenes/main.tscn")
	if not main_scn:
		print("ERROR: Failed to load main.tscn")
		quit(1)
		return

	var main_node = main_scn.instantiate()
	root.add_child(main_node)

	for i in range(5):
		await process_frame

	var restaurant = main_node.get_node("Restaurant")
	var gm = root.get_node_or_null("GameManager")

	print("1. Checking Seat Counts...")
	print("  -> Lounge seats count: ", restaurant.lounge_seats.size())
	print("  -> Diner seats count: ", restaurant.diner_seats.size())
	assert(restaurant.lounge_seats.size() == 10, "Cocktail lounge must have 10 active seats (6 stools + 4 tables)!")
	assert(restaurant.diner_seats.size() == 10, "Milkshake diner must have 10 active seats (6 stools + 4 tables)!")

	print("2. Checking Staff References...")
	assert(restaurant.lounge_bartender != null, "Lounge bartender missing!")
	assert(restaurant.diner_barista != null, "Diner barista missing!")
	assert(restaurant.barista_radial_mesh != null, "Barista radial timer mesh missing!")
	assert(restaurant.bartender_shaker_prop != null, "Bartender cocktail shaker prop missing!")
	assert(restaurant.milkshake_badge_label != null, "Milkshake badge label missing!")
	print("  -> Bartender: ", restaurant.lounge_bartender.name, " at ", restaurant.lounge_bartender.position)
	print("  -> Barista: ", restaurant.diner_barista.name, " at ", restaurant.diner_barista.position)
	print("  -> Milkshake Badge text: '", restaurant.milkshake_badge_label.text, "'")

	print("3. Testing Cocktail Lounge Customer Flow...")
	var initial_cash = gm.cash if gm != null else 0.0
	var free_lounge_seat = restaurant.lounge_seats[0]
	restaurant._spawn_customer_flow_lounge(free_lounge_seat)
	assert(free_lounge_seat["is_occupied"] == true, "Lounge seat should be occupied")
	var lounge_cust = free_lounge_seat["customer"]
	assert(lounge_cust != null, "Lounge customer instance missing")
	print("  -> Spawned lounge customer: ", lounge_cust.name, " heading to ", free_lounge_seat["id"])

	# Teleport customer directly to seat to trigger seated ordering
	lounge_cust.global_position = free_lounge_seat["seat_pos"]
	lounge_cust.waypoints.clear()
	lounge_cust._on_all_waypoints_reached()
	assert(lounge_cust.current_state == lounge_cust.State.SEATED_ORDERING, "Customer should be seated ordering")
	print("  -> Customer ordered: ", lounge_cust.ordered_dish["name"], " (", lounge_cust.ordered_dish["icon"], ")")

	# Check pending lounge orders
	assert(restaurant.pending_lounge_orders.size() >= 1, "Order should be placed in pending_lounge_orders")
	print("  -> Pending lounge orders: ", restaurant.pending_lounge_orders.size())

	# Process bartender
	restaurant._process_lounge_bartender(0.1)
	assert(restaurant.bartender_state == restaurant.StaffState.PREPARING, "Bartender should be preparing drink")
	print("  -> Bartender state: PREPARING")

	# Wait for bartender prep and serving
	await create_timer(2.5).timeout
	assert(restaurant.bartender_state == restaurant.StaffState.IDLE, "Bartender should return to IDLE after serving")
	assert(free_lounge_seat["dish_instance"] != null, "Wine goblet or drink model should be spawned on counter")
	print("  -> Bartender served drink: ", free_lounge_seat["dish_instance"].name, " at ", free_lounge_seat["dish_instance"].position)
	print("  -> Cash added: $", (gm.cash - initial_cash if gm != null else 0.0))

	print("4. Testing 50s Milkshake Diner Customer Flow...")
	var pre_diner_cash = gm.cash if gm != null else 0.0
	var free_diner_seat = restaurant.diner_seats[0]
	restaurant._spawn_customer_flow_diner(free_diner_seat)
	assert(free_diner_seat["is_occupied"] == true, "Diner seat should be occupied")
	var diner_cust = free_diner_seat["customer"]
	assert(diner_cust != null, "Diner customer instance missing")
	print("  -> Spawned diner customer: ", diner_cust.name, " heading to ", free_diner_seat["id"])

	# Teleport customer directly to seat
	diner_cust.global_position = free_diner_seat["seat_pos"]
	diner_cust.waypoints.clear()
	diner_cust._on_all_waypoints_reached()
	assert(diner_cust.current_state == diner_cust.State.SEATED_ORDERING, "Customer should be seated ordering")
	print("  -> Customer ordered: ", diner_cust.ordered_dish["name"], " (", diner_cust.ordered_dish["icon"], ")")

	# Check pending diner orders
	assert(restaurant.pending_diner_orders.size() >= 1, "Order should be placed in pending_diner_orders")
	print("  -> Pending diner orders: ", restaurant.pending_diner_orders.size())

	# Process barista
	restaurant._process_diner_barista(0.1)
	assert(restaurant.barista_state == restaurant.StaffState.PREPARING, "Barista should be preparing treat")
	await create_timer(0.45).timeout
	assert(restaurant.barista_radial_mesh.visible == true, "Radial timer mesh should be visible during preparation")
	print("  -> Barista state: PREPARING with radial timer ring visible")

	# Wait for barista prep and serving
	await create_timer(3.8).timeout
	assert(restaurant.barista_state == restaurant.StaffState.IDLE, "Barista should return to IDLE after serving")
	assert(free_diner_seat["dish_instance"] != null, "Sundae or frappe model should be spawned on counter")
	print("  -> Barista served treat: ", free_diner_seat["dish_instance"].name, " at ", free_diner_seat["dish_instance"].position)
	print("  -> Cash added from diner treat & milkshake_bar station income: $", (gm.cash - pre_diner_cash if gm != null else 0.0))

	print("5. Testing Milkshake Bar Upgrades & Click Handling...")
	var tracker = {"ui_opened": false, "opened_station": ""}
	restaurant.open_upgrade_ui.connect(func(sid, sname, lvl):
		tracker["ui_opened"] = true
		tracker["opened_station"] = sid
	)
	var dummy_event = InputEventMouseButton.new()
	dummy_event.button_index = 1
	dummy_event.pressed = true
	restaurant._on_milkshake_bar_clicked(null, dummy_event, Vector3.ZERO, Vector3.UP, 0)
	assert(tracker["ui_opened"] == true, "Clicking milkshake bar should emit open_upgrade_ui")
	assert(tracker["opened_station"] == "milkshake_bar", "Opened station should be 'milkshake_bar'")
	print("  -> Successfully opened upgrade UI for station: ", tracker["opened_station"])

	# Upgrade milkshake bar to level 5
	if gm != null:
		gm.station_levels["milkshake_bar"] = 5
		gm.station_upgraded.emit("milkshake_bar", 5)
		await process_frame
		assert(restaurant.milkshake_badge_label.text.contains("Lv. 5"), "Badge should display upgraded level 5")
		print("  -> Upgraded milkshake_bar to Lv. 5! Badge text: '", restaurant.milkshake_badge_label.text, "'")

	print("--- ALL ACTIVE SERVICE SECTORS TESTS PASSED SUCCESSFULLY! ---")
	main_node.queue_free()
	await process_frame
	quit(0)
