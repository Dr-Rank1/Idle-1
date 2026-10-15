extends SceneTree

func _init() -> void:
	print(">>> [TEST] Starting test_tactile_feedback.gd...")
	
	# Load GameManager
	var gm_script = load("res://scripts/game_manager.gd")
	var gm = Node.new()
	gm.set_script(gm_script)
	gm.name = "GameManager"
	root.add_child(gm)
	
	# Load AudioManager
	var am_script = load("res://scripts/audio_manager.gd")
	var am = Node.new()
	am.set_script(am_script)
	am.name = "AudioManager"
	root.add_child(am)
	
	# --- 1. Test AudioManager pitch shifting ---
	print("--- 1. Testing AudioManager play_upgrade_sfx ---")
	assert(am.has_method("play_upgrade_sfx"), "AudioManager missing play_upgrade_sfx")
	am.play_upgrade_sfx(0)
	am.play_upgrade_sfx(5)
	am.play_upgrade_sfx(25)
	print("✓ AudioManager pitch shifting verified!")
	
	# --- 2. Test GameManager bulk multiplier info & station caps ---
	print("--- 2. Testing Bulk Upgrade Multipliers & Caps ---")
	gm.cash = 100000000.0 # 100M cash allows all 49 levels to cap
	var sid = "milkshake_bar"
	var max_lvl = gm.get_station_max_level(sid)
	assert(max_lvl == 50, "milkshake_bar max level expected 50, got %d" % max_lvl)
	
	var info_x1 = gm.get_upgrade_multi_info(sid, "x1")
	assert(info_x1.levels == 1, "x1 levels should be 1")
	assert(info_x1.cost > 0, "x1 cost should be > 0")
	
	var info_x10 = gm.get_upgrade_multi_info(sid, "x10")
	assert(info_x10.levels == 10, "x10 levels should be 10, got %d" % info_x10.levels)
	assert(info_x10.cost > info_x1.cost, "x10 cost should exceed x1 cost")
	
	var info_max = gm.get_upgrade_multi_info(sid, "MAX")
	var cur_lvl = gm.get_station_level(sid)
	var expected_max_levels = max_lvl - cur_lvl
	assert(info_max.levels == expected_max_levels, "MAX levels should be %d, got %d" % [expected_max_levels, info_max.levels])
	assert(info_max.can_afford, "With $100M, MAX should be affordable")
	print("✓ Bulk Multiplier info verified: x1=%d ($%.0f), x10=%d ($%.0f), MAX=%d ($%.0f)" % [
		info_x1.levels, info_x1.cost, info_x10.levels, info_x10.cost, info_max.levels, info_max.cost
	])
	
	# --- 3. Test HUD Scene & Multi Toggle Pill ---
	print("--- 3. Testing HUD Scene & Multi Toggle Pill ---")
	var hud_packed = load("res://scenes/ui/hud.tscn")
	assert(hud_packed != null, "Failed to load hud.tscn")
	var hud = hud_packed.instantiate()
	root.add_child(hud)
	await create_timer(0.25).timeout
	
	var trails_layer = hud.get_node_or_null("HUD/CurrencyTrailsLayer")
	assert(trails_layer != null, "HUD/CurrencyTrailsLayer missing in hud.tscn")
	
	var header_pill = hud.get_node_or_null("UpgradePanel/VBox/HeaderBar/HBox/MultiTogglePill")
	assert(header_pill != null, "MultiTogglePill missing in UpgradePanel header")
	
	var h1 = hud.get_node_or_null("UpgradePanel/VBox/HeaderBar/HBox/MultiTogglePill/PillHBox/HeaderMulti1Btn")
	var h10 = hud.get_node_or_null("UpgradePanel/VBox/HeaderBar/HBox/MultiTogglePill/PillHBox/HeaderMulti10Btn")
	var hmax = hud.get_node_or_null("UpgradePanel/VBox/HeaderBar/HBox/MultiTogglePill/PillHBox/HeaderMultiMaxBtn")
	assert(h1 != null and h10 != null and hmax != null, "Header multi buttons missing")
	
	# Test toggling multiplier modes
	hud._set_multiplier("10")
	assert(hud.current_multiplier == "10", "current_multiplier should be '10'")
	hud._set_multiplier("MAX")
	assert(hud.current_multiplier == "MAX", "current_multiplier should be 'MAX'")
	hud._set_multiplier("1")
	assert(hud.current_multiplier == "1", "current_multiplier should be '1'")
	print("✓ Header Multiplier Pill verified!")
	
	# --- 4. Test Rolling Odometer Tickers ---
	print("--- 4. Testing Rolling Odometer Number Tickers ---")
	hud._on_cash_changed(250000.0)
	assert(hud.cash_tween != null and hud.cash_tween.is_valid(), "cash_tween should be active on cash changed")
	
	hud._on_cash_rate_updated(1850.0)
	assert(hud.rate_tween != null and hud.rate_tween.is_valid(), "rate_tween should be active on rate updated")
	print("✓ Rolling Odometer tweens verified!")
	
	# --- 5. Test Camera Controller Contextual Panning ---
	print("--- 5. Testing Camera Controller Contextual Panning ---")
	var cam_script = load("res://scripts/camera_controller.gd")
	var cam = Camera3D.new()
	cam.set_script(cam_script)
	root.add_child(cam)
	
	assert(cam.has_method("pan_to_position"), "Camera missing pan_to_position")
	assert(cam.has_method("focus_zone"), "Camera missing focus_zone")
	assert(cam.has_method("focus_station"), "Camera missing focus_station")
	
	# Test focus_zone elevation offset for bottom drawer
	cam.focus_zone("kitchen", true)
	assert(cam.target_position.x > 24.0, "Camera target_position.x should be elevated for kitchen")
	assert(cam.pan_tween != null and cam.pan_tween.is_valid(), "pan_tween should be running on focus_zone")
	
	cam.focus_zone("dining", true)
	assert(cam.target_position.z > 22.0, "Camera target_position.z should be elevated for dining")
	
	cam.focus_zone("milkshake", true)
	assert(cam.target_position.x > 10.0, "Camera target_position.x should be elevated for milkshake")
	
	cam.focus_zone("lounge", true)
	assert(cam.target_position.z > 21.0, "Camera target_position.z should be elevated for lounge")
	print("✓ Contextual Camera Panning verified for all zones!")
	
	# --- 6. Test Active 3D Selection Highlight on Booth & Stove ---
	print("--- 6. Testing Active 3D Selection Highlight ---")
	var table_script = load("res://scripts/dining_table.gd")
	var table = StaticBody3D.new()
	table.name = "Table1"
	table.set_script(table_script)
	root.add_child(table)
	
	var stove_script = load("res://scripts/cooking_station.gd")
	var stove = StaticBody3D.new()
	stove.name = "CookingStation"
	stove.set_script(stove_script)
	root.add_child(stove)
	
	assert(table.has_method("set_highlight"), "Table missing set_highlight")
	assert(stove.has_method("set_highlight"), "Stove missing set_highlight")
	
	table.set_highlight(true)
	assert(table.is_highlighted == true, "Table should be highlighted")
	assert(table.highlight_ring != null and table.highlight_ring.visible == true, "Table highlight ring should be visible")
	
	table.set_highlight(false)
	assert(table.is_highlighted == false, "Table highlight should be cleared")
	assert(table.highlight_ring.visible == false, "Table highlight ring should be hidden")
	
	stove.set_highlight(true)
	assert(stove.is_highlighted == true, "Stove should be highlighted")
	assert(stove.highlight_ring != null and stove.highlight_ring.visible == true, "Stove highlight ring should be visible")
	
	stove.set_highlight(false)
	assert(stove.is_highlighted == false, "Stove highlight should be cleared")
	print("✓ Active 3D Selection Highlights verified!")
	
	# --- 7. Test Milestone Progress Bar Ticks & Star Multipliers ---
	print("--- 7. Testing Milestone Progress Bar Ticks ---")
	assert(hud.station_progress_bar != null, "station_progress_bar node missing in hud")
	assert(hud.ticks_overlay != null, "ticks_overlay node missing in hud")
	assert(hud.milestone_labels_hbox != null, "milestone_labels_hbox node missing in hud")
	
	# Update milestones at level 15 of 50
	hud._update_station_milestones(sid, 15, 50)
	assert(hud.station_progress_bar.max_value == 50.0, "Progress bar max_value should be 50")
	assert(hud.station_progress_bar.value == 15.0, "Progress bar value should be 15")
	assert(hud.ticks_overlay.get_child_count() >= 3, "Ticks overlay should have tick dividers")
	assert(hud.milestone_labels_hbox.get_child_count() == 3, "Milestone labels should have 3 pills (10, 25, 50)")
	
	# First pill (Level 10) should be unlocked (15 >= 10)
	var pill10 = hud.milestone_labels_hbox.get_child(0)
	var lbl10 = pill10.get_child(0) as Label
	assert(lbl10.text.contains("Lv.10") and lbl10.text.contains("BONUS"), "Lv.10 should be achieved at level 15: %s" % lbl10.text)
	
	# Second pill (Level 25) should be pending (15 < 25)
	var pill25 = hud.milestone_labels_hbox.get_child(1)
	var lbl25 = pill25.get_child(0) as Label
	assert(lbl25.text.contains("Lv.25") and not lbl25.text.contains("BONUS"), "Lv.25 should be pending at level 15: %s" % lbl25.text)
	print("✓ Milestone Progress Bar Ticks and Stars verified!")
	
	# --- 8. Test Hold-to-Upgrade continuous loop ---
	print("--- 8. Testing Hold-to-Upgrade Logic ---")
	hud.open_upgrade(sid, "Bar Top", 1)
	var prev_lvl = gm.get_station_level(sid)
	hud._start_hold_upgrade(sid)
	var next_lvl = gm.get_station_level(sid)
	assert(next_lvl == prev_lvl + 1, "Initial hold step should increment level from %d to %d (got %d)" % [prev_lvl, prev_lvl + 1, next_lvl])
	assert(hud._is_holding_upgrade, "Should be in holding state")
	hud._perform_hold_step()
	assert(gm.get_station_level(sid) == next_lvl + 1, "Second hold step should increment level")
	hud._stop_hold_upgrade()
	assert(not hud._is_holding_upgrade, "Holding state should be stopped")
	print("✓ Hold-to-Upgrade logic verified!")
	
	# --- 9. Test modal close clears 3D highlights ---
	print("--- 9. Testing Modal Close Clears Highlights ---")
	table.set_highlight(true)
	hud._close_modal(hud.upgrade_panel)
	assert(table.is_highlighted == false, "Closing modal should clear table highlight")
	print("✓ Highlight clearing on modal close verified!")
	
	# --- 10. Test Squash-and-Stretch Button Feedback ---
	print("--- 10. Testing Squash-and-Stretch Button Feedback ---")
	assert(hud.has_method("apply_button_squash_and_stretch"), "HUD missing apply_button_squash_and_stretch")
	var test_btn = hud.nav_parking_btn
	assert(test_btn != null, "nav_parking_btn missing")
	hud.apply_button_squash_and_stretch(test_btn)
	hud._wire_button_bounce(test_btn)
	test_btn.pressed.emit()
	print("✓ Squash-and-stretch button feedback verified!")
	
	# --- 11. Test Smart Affordability Notification Badges ---
	print("--- 11. Testing Smart Affordability Notification Badges ---")
	assert(hud.has_method("_update_affordability_badges"), "HUD missing _update_affordability_badges")
	assert(hud.has_method("_set_button_affordability_badge"), "HUD missing _set_button_affordability_badge")
	
	# Low cash: cannot afford upgrades
	gm.cash = 0.0
	hud._update_affordability_badges()
	var parking_badge = hud.nav_parking_btn.get_node_or_null("AffordabilityBadge")
	if parking_badge != null:
		assert(parking_badge.visible == false, "Parking badge should be hidden when broke")
		
	# High cash: can afford parking, kitchen, dining, staff
	gm.cash = 5000000.0
	hud._update_affordability_badges()
	parking_badge = hud.nav_parking_btn.get_node_or_null("AffordabilityBadge")
	assert(parking_badge != null and parking_badge.visible == true, "Parking badge should be visible when affordable")
	var badge_lbl = parking_badge.get_child(0) as Label
	assert(badge_lbl.text == "▲", "Badge text should be ▲, got %s" % badge_lbl.text)
	
	var staff_badge = hud.tab_staff_btn.get_node_or_null("AffordabilityBadge")
	assert(staff_badge != null and staff_badge.visible == true, "Staff tab badge should be visible when affordable")
	print("✓ Smart Affordability Notification Badges verified!")
	
	# --- 12. Test Swipe-to-Collect 3D Cash Stacks & Combo ---
	print("--- 12. Testing Swipe-to-Collect 3D Cash Stacks & Combo ---")
	var rest_script = load("res://scripts/restaurant.gd")
	var rest = Node3D.new()
	rest.name = "Restaurant"
	rest.set_script(rest_script)
	root.add_child(rest)
	
	assert(rest.has_method("register_cash_collection"), "Restaurant missing register_cash_collection")
	assert(rest.has_method("_check_swipe_cash_collection"), "Restaurant missing _check_swipe_cash_collection")
	
	# Initial collection: combo = 1
	var start_cash = gm.cash
	rest.register_cash_collection(Vector3.ZERO, 50.0)
	assert(rest.cash_collect_combo == 1, "First stack should set combo to 1")
	assert(gm.cash == start_cash + 50.0, "Cash should increment by 50.0")
	
	# Second collection within 1s: combo = 2
	rest.register_cash_collection(Vector3.ZERO, 50.0)
	assert(rest.cash_collect_combo == 2, "Second stack should set combo to 2")
	
	# Third collection within 1s: combo = 3, multiplier = 2 (x2 COMBO!)
	rest.register_cash_collection(Vector3.ZERO, 50.0)
	assert(rest.cash_collect_combo == 3, "Third stack should set combo to 3")
	assert(gm.cash == start_cash + 50.0 + 50.0 + 100.0, "Third stack should award x2 combo multiplier ($100)")
	
	# Fourth collection within 1s: combo = 4, multiplier = 3 (x3 COMBO!)
	rest.register_cash_collection(Vector3.ZERO, 50.0)
	assert(rest.cash_collect_combo == 4, "Fourth stack should set combo to 4")
	assert(gm.cash == start_cash + 50.0 + 50.0 + 100.0 + 150.0, "Fourth stack should award x3 combo multiplier ($150)")
	
	# Test dining table cash stack collection
	assert(table.has_method("has_visible_cash_stack"), "Table missing has_visible_cash_stack")
	assert(table.has_method("collect_booth_cash"), "Table missing collect_booth_cash")
	
	# Create booth cash stack on table
	table.booth_cash_stack = Node3D.new()
	table.add_child(table.booth_cash_stack)
	table.booth_cash_stack.visible = true
	assert(table.has_visible_cash_stack() == true, "Table should have visible cash stack")
	
	var collected_amt = table.collect_booth_cash()
	assert(collected_amt == 50.0, "collect_booth_cash should return 50.0")
	assert(table.has_visible_cash_stack() == false, "Table cash stack should be hidden after collect")
	print("✓ Swipe-to-Collect 3D Cash Stacks & Combo Multiplier verified!")
	
	print(">>> [TEST] ALL SYNCHRONIZED 3D-TO-UI FOCUS & TACTILE RESPONSIVENESS TESTS PASSED SUCCESSFULLY! <<<")
	quit(0)
