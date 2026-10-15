extends SceneTree

func _init() -> void:
	print("--- BEGIN TEST: DECOR & ARCHITECTURAL BOUNDARIES AUDIT ---")
	var main_scene = load("res://scenes/main.tscn")
	if main_scene == null:
		print("FAILED to load main.tscn")
		quit(1)
		return

	var main = main_scene.instantiate()
	root.add_child(main)

	await create_timer(0.2).timeout

	var restaurant = main.find_child("Restaurant", true, false)
	assert(restaurant != null, "Restaurant missing!")

	var walls = restaurant.get_node_or_null("BuildingWalls")
	assert(walls != null, "BuildingWalls missing!")

	print("1. Auditing Floor-to-Ceiling Picture Windows along South Facade...")
	var win_lounge1 = walls.get_node_or_null("FrontWindowLounge1")
	var win_lounge2 = walls.get_node_or_null("FrontWindowLounge2")
	var win_lounge3 = walls.get_node_or_null("FrontWindowLounge3")
	var win_dining1 = walls.get_node_or_null("FrontWindowDining1")
	var win_dining2 = walls.get_node_or_null("FrontWindowDining2")
	var win_dining3 = walls.get_node_or_null("FrontWindowDining3")
	var win_exp1 = walls.get_node_or_null("FrontWindowExpansion1")
	var win_exp2 = walls.get_node_or_null("FrontWindowExpansion2")

	assert(win_lounge1 != null, "FrontWindowLounge1 missing!")
	assert(win_lounge2 != null, "FrontWindowLounge2 missing!")
	assert(win_lounge3 != null, "FrontWindowLounge3 missing!")
	assert(win_dining1 != null, "FrontWindowDining1 missing!")
	assert(win_dining2 != null, "FrontWindowDining2 missing!")
	assert(win_dining3 != null, "FrontWindowDining3 missing!")
	assert(win_exp1 != null, "FrontWindowExpansion1 missing!")
	assert(win_exp2 != null, "FrontWindowExpansion2 missing!")
	print("  -> Verified 8 floor-to-ceiling picture windows across entire South Facade (Lounge, Dining, Expansion)!")

	print("2. Auditing Indoor Window-Sill Ficus Plants & Lobby Plant...")
	var lobby_plant = walls.get_node_or_null("PlantEntranceLobby")
	assert(lobby_plant != null, "PlantEntranceLobby missing!")

	var plant_lounge1 = walls.get_node_or_null("IndoorWindowPlantLounge1")
	var plant_dining1 = walls.get_node_or_null("IndoorWindowPlantDining1")
	var plant_exp1 = walls.get_node_or_null("IndoorWindowPlantExpansion1")
	assert(plant_lounge1 != null, "IndoorWindowPlantLounge1 missing!")
	assert(plant_dining1 != null, "IndoorWindowPlantDining1 missing!")
	assert(plant_exp1 != null, "IndoorWindowPlantExpansion1 missing!")
	print("  -> Verified indoor ficus window-sill plants and entrance lobby plant!")

	print("3. Testing Front Sliding Glass Entrance Doors Animation...")
	var slide_left = walls.get_node_or_null("SlidingDoorLeft")
	var slide_right = walls.get_node_or_null("SlidingDoorRight")
	assert(slide_left != null, "SlidingDoorLeft missing!")
	assert(slide_right != null, "SlidingDoorRight missing!")

	# Closed state initially (no customers near door)
	assert(restaurant._door_open_ratio == 0.0, "Door open ratio should start at 0.0")
	assert(slide_left.position.x == 0.0, "Left sliding door should start closed")
	assert(slide_right.position.x == 0.0, "Right sliding door should start closed")

	# Spawn customer near DOOR_POS to test opening
	var cust_scn = load("res://scenes/customer.tscn")
	var cust = cust_scn.instantiate()
	restaurant.get_node("Customers").add_child(cust)
	cust.global_position = Vector3(-1.5, 0.0, 11.5) # Approaching garden pathway

	# Simulate process frames
	for f in range(25):
		restaurant._process_sliding_doors(0.016)

	assert(restaurant._door_open_ratio > 0.8, "Door open ratio should be open for approaching customer!")
	assert(slide_left.position.x < -0.6, "Left door should slide open to the left (-X)!")
	assert(slide_right.position.x > 0.6, "Right door should slide open to the right (+X)!")
	print("  -> Sliding doors successfully opened smoothly! Ratio: %.2f | Left X: %.2f | Right X: %.2f" % [restaurant._door_open_ratio, slide_left.position.x, slide_right.position.x])

	# Move customer far away to test closing
	cust.global_position = Vector3(10.0, 0.0, -5.0)
	for f in range(30):
		restaurant._process_sliding_doors(0.016)

	assert(restaurant._door_open_ratio < 0.1, "Door open ratio should return to closed!")
	print("  -> Sliding doors successfully closed smoothly! Ratio: %.2f" % [restaurant._door_open_ratio])

	print("4. Auditing Low Isometric Cutaway Wall Heights & Caps...")
	var cutaway_walls = [
		"SolidRightWallOffice", "SolidRightWallBreakroom",
		"SolidNorthWallLounge", "MilkshakeRestroomDivider",
		"RestroomKitchenDivider", "OfficeKitchenDivider",
		"DiningReceptionDividerNorth", "DiningReceptionDividerSouth",
		"HatchWallLeft", "HatchWallRight",
		"FrontWallLounge", "FrontWallDining", "ExpansionWallEast"
	]
	for w_name in cutaway_walls:
		var w = walls.get_node_or_null(w_name)
		assert(w != null, "Wall missing: " + w_name)
		assert(w.size.y <= 1.55, "Wall " + w_name + " height too tall for isometric cutaway: " + str(w.size.y))
	print("  -> All 13 checked divider and perimeter walls have low isometric cutaway height <= 1.5m!")

	var cap_nodes = [
		"RightWallOfficeCap", "RightWallBreakroomCap",
		"NorthWallLoungeCap", "MilkshakeRestroomDividerCap",
		"RestroomKitchenDividerCap", "OfficeKitchenDividerCap",
		"DiningReceptionDividerNorthCap", "DiningReceptionDividerSouthCap",
		"HatchWallLeftCap", "HatchWallRightCap",
		"FrontCapLounge", "FrontCapDining", "ExpansionCapEast"
	]
	for cap_name in cap_nodes:
		var cap = walls.get_node_or_null(cap_name)
		assert(cap != null, "Wall cap missing: " + cap_name)
	print("  -> All 13 wall top caps verified!")

	print("5. Auditing Hostess Reception Desk Props...")
	var reception = restaurant.get_node_or_null("ReceptionRoom")
	assert(reception != null, "ReceptionRoom missing!")
	var phone = reception.get_node_or_null("RetroPhone")
	var ledger = reception.get_node_or_null("ReservationBook")
	assert(phone != null, "RetroPhone missing on reception desk!")
	assert(ledger != null, "ReservationBook missing on reception desk!")
	assert(abs(phone.position.y - 0.90) < 0.05, "Phone should sit cleanly on counter top at Y = 0.90")
	assert(abs(ledger.position.y - 0.90) < 0.05, "Reservation book should sit cleanly on counter top at Y = 0.90")
	print("  -> Retro phone pos: %s | Reservation book pos: %s" % [phone.position, ledger.position])

	print("6. Auditing Front Lawn & South-East Courtyard Landscaping...")
	var lounge_tree1 = walls.get_node_or_null("LoungeTree1")
	var lounge_tree2 = walls.get_node_or_null("LoungeTree2")
	var cone_lounge1 = walls.get_node_or_null("TopiaryConeLounge1")
	var cone_entrance_w = walls.get_node_or_null("TopiaryConeEntranceW")
	var cone_entrance_e = walls.get_node_or_null("TopiaryConeEntranceE")
	assert(lounge_tree1 != null, "LoungeTree1 missing on front lawn!")
	assert(lounge_tree2 != null, "LoungeTree2 missing on front lawn!")
	assert(cone_lounge1 != null, "TopiaryConeLounge1 missing!")
	assert(cone_entrance_w != null, "TopiaryConeEntranceW missing!")
	assert(cone_entrance_e != null, "TopiaryConeEntranceE missing!")

	var courtyard = restaurant.get_node_or_null("EntranceCourtyard")
	assert(courtyard != null, "EntranceCourtyard missing!")
	var court_tree1 = courtyard.get_node_or_null("CourtyardTree")
	var court_tree2 = courtyard.get_node_or_null("CourtyardTreeEast")
	var court_cone1 = courtyard.get_node_or_null("CourtyardCone1")
	var court_cone_east = courtyard.get_node_or_null("CourtyardConeEast1")
	var court_lawn_east = courtyard.get_node_or_null("CourtyardLawnEast")
	assert(court_tree1 != null, "CourtyardTree missing!")
	assert(court_tree2 != null, "CourtyardTreeEast missing!")
	assert(court_cone1 != null, "CourtyardCone1 missing!")
	assert(court_cone_east != null, "CourtyardConeEast1 missing!")
	assert(court_lawn_east != null, "CourtyardLawnEast missing!")
	print("  -> Front lawn and South-East courtyard populated with trees, topiary cones, and hedges successfully!")

	print("\n--- ALL DECOR & ARCHITECTURE AUDITS PASSED SUCCESSFULLY! ---\n")
	quit(0)
