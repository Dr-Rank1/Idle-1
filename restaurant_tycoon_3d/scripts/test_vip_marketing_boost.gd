extends SceneTree

func _init() -> void:
	print("--- BEGIN TEST: VIP, MARKETING & BOOST OVERHAUL ---")
	var main_scene = load("res://scenes/main.tscn")
	if main_scene == null:
		print("FAILED to load main.tscn")
		quit(1)
		return
		
	var main = main_scene.instantiate()
	root.add_child(main)
	
	# Settle frame
	await create_timer(0.25).timeout
	
	var gm = root.get_node_or_null("GameManager")
	assert(gm != null, "GameManager missing!")
	
	var rest = main.find_child("Restaurant", true, false)
	assert(rest != null, "Restaurant missing!")
	
	var parking = main.find_child("ParkingLot", true, false)
	assert(parking != null, "ParkingLot missing!")
	
	var ui = main.find_child("HUD", true, false)
	assert(ui != null, "HUD missing!")
	
	print("1. Testing GameManager Marketing System...")
	gm.marketing_level = 1
	assert(gm.get_marketing_level() == 1, "Initial marketing level should be 1")
	assert(abs(gm.get_marketing_traffic_multiplier() - 1.0) < 0.001, "Level 1 traffic mult should be 1.0")
	var cost_lv1 = gm.get_marketing_upgrade_cost()
	assert(cost_lv1 > 0.0, "Upgrade cost should be positive")
	
	gm.cash = 10000.0
	var upgraded = gm.upgrade_marketing()
	assert(upgraded == true, "Failed to upgrade marketing")
	assert(gm.get_marketing_level() == 2, "Marketing level should now be 2")
	assert(abs(gm.get_marketing_traffic_multiplier() - 1.15) < 0.001, "Level 2 traffic mult should be 1.15 (+15%)")
	
	var spawn_rate = gm.get_spawn_rate_multiplier()
	assert(spawn_rate >= 1.15, "Spawn rate multiplier should factor in marketing level")
	print("  -> Marketing Level: %d | Multiplier: %.2fx | Spawn Rate Mult: %.2fx" % [gm.get_marketing_level(), gm.get_marketing_traffic_multiplier(), spawn_rate])
	
	print("2. Testing Active 2X BOOST Multiplier & Golden Timer Bar...")
	var base_rev = gm.get_station_income("table_1")
	assert(base_rev > 0.0, "Base table income should be positive")
	
	gm.toggle_boost()
	assert(gm.is_boosted == true, "GameManager should be boosted")
	assert(gm.boost_timer == 60.0, "Boost timer should be 60s")
	
	var boosted_rev = gm.get_station_income("table_1")
	assert(boosted_rev >= base_rev * 2.0 - 0.5, "Boosted income should be StationRevenue * 2.0")
	print("  -> Boost Active: %s | Base Rev: $%.1f -> Boosted Rev: $%.1f" % [gm.is_boosted, base_rev, boosted_rev])
	
	assert(ui.boost_timer_bar != null, "Golden timer bar should be attached to FloatingBoostBanner")
	assert(ui.ribbon_marketing != null, "RibbonMarketing should be located")
	print("  -> Golden Timer Bar & Marketing Ribbon verified successfully!")
	
	print("3. Testing Helipad & Executive Helicopter...")
	assert(parking.has_method("force_spawn_vip_helicopter"), "Parking lot should have force_spawn_vip_helicopter")
	parking.force_spawn_vip_helicopter()
	assert(parking.helicopter_node != null, "Helicopter node should exist after spawn")
	assert(parking.get_helicopter_state() == "APPROACHING", "Helicopter state should be APPROACHING")
	print("  -> Executive Helicopter spawned at Approach position: %s | State: %s" % [parking.helicopter_node.position, parking.get_helicopter_state()])
	
	print("4. Testing VIP Investor Character & Windfall Reward...")
	var vip_cust = rest.spawn_vip_investor(Vector3(-14.2, 0.0, 16.0))
	assert(vip_cust != null, "VIP Investor customer should be spawned")
	assert(vip_cust.is_vip_investor == true, "Customer should be marked as VIP Investor")
	assert(vip_cust.investor_badge != null, "Investor badge label should exist")
	assert(vip_cust.briefcase_prop != null, "Golden briefcase prop should exist")
	
	var claimed_grant = vip_cust.claim_vip_investor_reward()
	assert(claimed_grant >= 3500.0, "Claimed grant should award high tier reward")
	assert(vip_cust.vip_reward_claimed == true, "VIP reward should be marked claimed")
	assert(gm.vip_revenue_multiplier_timer > 0.0, "VIP revenue multiplier timer should be active")
	print("  -> VIP Investor Grant Claimed: $%.1f | Revenue Multiplier Timer: %.1fs" % [claimed_grant, gm.vip_revenue_multiplier_timer])
	
	print("\n--- ALL VIP, MARKETING & BOOST OVERHAUL TESTS PASSED SUCCESSFULLY! ---\n")
	quit(0)
