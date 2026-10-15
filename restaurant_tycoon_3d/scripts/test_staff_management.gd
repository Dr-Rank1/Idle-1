extends SceneTree

func _init() -> void:
	print("\n--- BEGIN TEST STAFF MANAGEMENT OVERHAUL ---")
	var main_scene = load("res://scenes/main.tscn")
	if main_scene == null:
		print("FAILED to load main.tscn")
		quit(1)
		return
		
	var main = main_scene.instantiate()
	root.add_child(main)
	
	# Give scene a frame to settle
	await create_timer(0.2).timeout
	
	var gm = root.get_node_or_null("GameManager")
	assert(gm != null, "GameManager missing!")
	
	var rest = main.find_child("Restaurant", true, false)
	assert(rest != null, "Restaurant node missing!")
	
	print("1. Verifying Staff Roster in GameManager...")
	var expected_staff = [
		"waiter_1", "waiter_2", "waiter_3", "waiter_4",
		"chef_stove", "chef_prep", "chef_sous", "chef_pastry",
		"hostess", "bartender", "barista", "janitor", "manager"
	]
	
	for sid in expected_staff:
		assert(gm.staff_roster.has(sid), "Staff roster missing slot: " + sid)
		var st = gm.staff_roster[sid]
		print("  -> %s (%s) | Role: %s | Hired: %s | Lvl: %d" % [
			st.get("name"), sid, st.get("role"), str(st.get("hired")), st.get("level")
		])
	
	print("2. Verifying Staff Upgrades & Multipliers...")
	# Reset waiter_3 and manager for test repeatability
	gm.staff_roster["waiter_3"]["hired"] = false
	gm.staff_roster["waiter_3"]["level"] = 1
	gm.staff_roster["manager"]["hired"] = false
	gm.staff_roster["manager"]["level"] = 1

	gm.cash = 5000.0
	assert(gm.is_staff_hired("waiter_3") == false, "waiter_3 should start unhired")
	var hired_w3 = gm.hire_staff("waiter_3")
	assert(hired_w3 == true, "Failed to hire waiter_3")
	assert(gm.is_staff_hired("waiter_3") == true, "waiter_3 should now be hired")
	
	var initial_w3_spd = gm.get_staff_speed_multiplier("waiter_3")
	var initial_w3_cap = gm.get_staff_capacity("waiter_3")
	assert(initial_w3_cap == 1, "Lucas should have initial capacity of 1 plate")
	
	var up_w3 = gm.upgrade_staff("waiter_3")
	assert(up_w3 == true, "Failed to upgrade waiter_3")
	assert(gm.get_staff_level("waiter_3") == 2, "waiter_3 should be level 2")
	var up_w3_spd = gm.get_staff_speed_multiplier("waiter_3")
	assert(up_w3_spd > initial_w3_spd, "Upgraded speed should be higher")
	print("  -> Waiter 3 upgraded: Level %d | Speed mult: %.2f | Capacity: %d" % [
		gm.get_staff_level("waiter_3"), up_w3_spd, gm.get_staff_capacity("waiter_3")
	])
	
	# Also test waiter_4 capacity bonus
	gm.staff_roster["waiter_4"]["hired"] = true
	assert(gm.get_staff_capacity("waiter_4") == 2, "Elena should have initial capacity of 2 plates")
	
	# Test hiring & upgrading Floor Manager Arthur
	assert(gm.is_staff_hired("manager") == false, "manager should start unhired")
	var hired_mgr = gm.hire_staff("manager")
	assert(hired_mgr == true, "Failed to hire manager")
	assert(gm.is_staff_hired("manager") == true, "manager should now be hired")
	var base_eff = gm.get_manager_efficiency_multiplier()
	assert(base_eff >= 1.0, "Base manager efficiency should be >= 1.0")
	
	# Test inspection boost
	gm.set_manager_inspection_active(true)
	var active_eff = gm.get_manager_efficiency_multiplier()
	assert(active_eff >= base_eff + 0.25, "Active inspection should add +25% efficiency")
	gm.set_manager_inspection_active(false)
	print("  -> Floor Manager Arthur: Hired | Normal Eff: %.2f | Tour Eff: %.2f" % [base_eff, active_eff])
	
	# Test Chef Pastry Marcel
	var hired_pc = gm.hire_staff("chef_pastry")
	assert(hired_pc == true, "Failed to hire chef_pastry")
	var cook_mult = gm.get_staff_cooking_multiplier("chef_pastry")
	print("  -> Pastry Chef Marcel: Hired | Cooking mult: %.2f" % cook_mult)
	
	print("3. Verifying Spawning in Restaurant World...")
	# Trigger staff spawn check
	rest._check_spawn_hired_staff()
	await create_timer(0.2).timeout
	
	assert(rest._has_waiter("waiter_4") == true, "Waiter 4 Elena node missing in world!")
	assert(rest._has_floor_manager() == true, "Floor Manager Arthur node missing in world!")
	assert(rest._has_janitor() == true, "Janitor Otis node missing in world!")
	assert(rest._has_pastry_chef() == true, "Pastry Chef Marcel node missing in world!")
	print("  -> Waiter 4 Elena spawned at: ", rest.find_child("Waiter4", true, false).position)
	print("  -> Floor Manager Arthur spawned at: ", rest.floor_manager.position)
	print("  -> Janitor Otis spawned at: ", rest.janitor_character.position)
	print("  -> Pastry Chef Marcel spawned at: ", rest.find_child("ChefPastry", true, false).position)
	
	print("4. Verifying Breakroom Routine for Staff...")
	# Pick waiter 1 or 2 to take breakroom rest
	var w1 = rest.waiters[0]
	assert(w1.has_method("take_breakroom_rest"), "Waiter missing take_breakroom_rest method!")
	var sofa_spot = Vector3(14.6, 0.0, -2.2)
	w1.take_breakroom_rest(sofa_spot, true)
	assert(w1.current_state == 5, "Waiter should be in State.ON_BREAK (5)")
	assert(w1.waypoints.size() > 0, "Waiter should have waypoints to breakroom sofa")
	print("  -> Waiter dispatched to Breakroom Sofa: %d waypoints queued" % w1.waypoints.size())
	
	print("5. Verifying Manager Inspection Routine...")
	assert(rest.has_method("_start_manager_inspection_tour"), "Restaurant missing _start_manager_inspection_tour!")
	rest._start_manager_inspection_tour()
	assert(rest.manager_is_touring == true, "Manager should be touring!")
	assert(gm.is_manager_inspection_active == true, "GameManager inspection should be active!")
	assert(rest.manager_tour_waypoints.size() > 0, "Manager should have tour waypoints through kitchen and dining hall!")
	print("  -> Manager inspection tour active with %d waypoints through kitchen and dining hall" % rest.manager_tour_waypoints.size())
	
	print("6. Verifying UI Controller Staff Panel Refresh...")
	var ui = main.find_child("HUD", true, false)
	assert(ui != null, "HUD node missing!")
	if ui.has_method("_refresh_staff_panel"):
		ui._refresh_staff_panel()
		var vbox = ui.get_node_or_null("StaffPanel/VBox/StaffScroll/StaffVBox")
		if vbox != null:
			print("  -> Staff Panel VBox child count: %d (headers + staff cards)" % vbox.get_child_count())
			assert(vbox.get_child_count() >= 13, "Staff panel should have at least 13 cards/headers")
	
	print("\n--- ALL STAFF MANAGEMENT OVERHAUL TESTS PASSED SUCCESSFULLY! ---\n")
	quit(0)
