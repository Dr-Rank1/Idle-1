extends SceneTree

var _frame: int = 0
var _max_frames: int = 70
var gm: Node = null
var hud_instance: CanvasLayer = null

func _init() -> void:
	print("--- START TEST: Objectives, Station Milestones, & Lucky Spin Wheel ---")

func _process(_delta: float) -> bool:
	_frame += 1

	if _frame == 1:
		_setup_test_environment()
		return false

	if _frame == 5:
		_test_active_objective_system()
		return false

	if _frame == 10:
		_test_station_milestone_rewards()
		return false

	if _frame == 15:
		_test_lucky_spin_wheel()
		return false

	if _frame == 20:
		_test_daily_login_rewards()
		return false

	if _frame == 25:
		_test_hud_ui_integration()
		return false

	if _frame == 30:
		print("ALL OBJECTIVES, STATION MILESTONES & SPIN WHEEL TESTS PASSED DETERMINISTICALLY! ✓")
		quit(0)
		return true

	if _frame >= _max_frames:
		printerr("TEST TIMEOUT: test_objectives_and_spin did not complete in %d frames" % _max_frames)
		quit(1)
		return true

	return false

func _setup_test_environment() -> void:
	print("[Frame 1] Initializing GameManager singleton & state...")
	gm = root.get_node_or_null("GameManager")
	if gm == null:
		var gm_scn = load("res://scripts/game_manager.gd")
		gm = gm_scn.new()
		gm.name = "GameManager"
		root.add_child(gm)

	# Seed test currencies and initial states
	gm.cash = 100000.0
	gm.diamonds = 50
	gm.golden_coins = 200
	gm.energy = 50
	gm.active_objective_index = 0
	gm.active_objective_current = 0
	gm.last_free_spin_timestamp = 0.0
	gm.login_streak_days = 0
	gm.last_login_claim_timestamp = 0.0

func _test_active_objective_system() -> void:
	print("[Frame 5] Testing Active Objective Tracker progression and rewards...")
	var initial_obj = gm.get_active_objective()
	assert(not initial_obj.is_empty(), "Active objective should not be empty")
	print("  Initial objective: %s (Target: %d, Type: %s)" % [initial_obj.title, initial_obj.target, initial_obj.type])

	# Advance table_1 station level to meet milestone or progress objective
	var initial_diamonds = gm.diamonds
	var initial_gold = gm.golden_coins

	# Objective 0 is 'Upgrade Booth 1 to Level 10'
	assert(initial_obj.type == "station_level", "First objective should be station_level")
	assert(initial_obj.station_id == "table_1", "Target station should be table_1")
	
	# Upgrade table_1 to level 10
	gm.station_levels["table_1"] = 10
	var completed_obj = gm.get_active_objective()
	assert(completed_obj.current >= completed_obj.target, "Objective should reach target")
	assert(completed_obj.is_completed == true, "Objective should be marked as completed")
	print("  Objective completed state verified: current=%d, target=%d, is_completed=%s" % [completed_obj.current, completed_obj.target, completed_obj.is_completed])

	# Claim objective reward
	var claimed = gm.claim_active_objective()
	assert(not claimed.is_empty(), "Claimed reward dictionary should not be empty")
	assert(gm.diamonds > initial_diamonds, "Diamonds should have increased from objective reward")
	assert(gm.golden_coins > initial_gold, "Golden coins should have increased from objective reward")
	assert(gm.active_objective_index == 1, "Active objective index should advance to 1")
	
	# Next objective rolled
	var next_obj = gm.get_active_objective()
	assert(next_obj.id != initial_obj.id, "Next milestone quest should roll after claiming")
	print("  Next objective successfully rolled: %s (ID: %s)" % [next_obj.title, next_obj.id])

func _test_station_milestone_rewards() -> void:
	print("[Frame 10] Testing Station Level Milestone Rewards (+5 Diamonds, +25 Golden Coins at Lv 10, 25, 50)...")
	var milestone_events: Array = []
	var on_milestone = func(sid, mlvl, b_dia, b_gold):
		milestone_events.append({"sid": sid, "lvl": mlvl, "dia": b_dia, "gold": b_gold})
	gm.station_milestone_reached.connect(on_milestone)

	# Set table_2 at level 9, then upgrade to level 10
	gm.xp_to_next_level = 10000000.0
	gm.restaurant_xp = 0.0
	gm.station_levels["table_2"] = 9
	var dia_before = gm.diamonds
	var gold_before = gm.golden_coins

	var upgraded = gm.upgrade_station_multi("table_2", "1")
	assert(upgraded == true, "Upgrade should succeed")
	assert(gm.get_station_level("table_2") == 10, "table_2 should now be level 10")
	assert(gm.diamonds == dia_before + 5, "Level 10 milestone should award +5 Diamonds")
	assert(gm.golden_coins == gold_before + 25, "Level 10 milestone should award +25 Golden Coins")
	assert(milestone_events.size() == 1, "station_milestone_reached should have fired once")
	assert(milestone_events[0].lvl == 10, "Milestone level should be 10")
	assert(milestone_events[0].dia == 5 and milestone_events[0].gold == 25, "Milestone event should carry 5 diamonds and 25 gold")
	print("  Level 10 milestone reward verified for table_2 (+5 Diamonds, +25 Coins) ✓")

	# Test Level 25 milestone on kitchen_cook
	gm.station_levels["kitchen_cook"] = 24
	dia_before = gm.diamonds
	gold_before = gm.golden_coins
	upgraded = gm.upgrade_station_multi("kitchen_cook", "1")
	assert(upgraded == true, "Upgrade kitchen_cook should succeed")
	assert(gm.get_station_level("kitchen_cook") == 25, "kitchen_cook should now be level 25")
	assert(gm.diamonds == dia_before + 5, "Level 25 milestone should award +5 Diamonds")
	assert(gm.golden_coins == gold_before + 25, "Level 25 milestone should award +25 Golden Coins")
	assert(milestone_events.back().lvl == 25, "Milestone level should be 25")
	assert(milestone_events.back().dia == 5 and milestone_events.back().gold == 25, "Milestone event should carry 5 diamonds and 25 gold")
	print("  Level 25 milestone reward verified for kitchen_cook (+5 Diamonds, +25 Coins) ✓")

	# Test Level 50 milestone on milkshake_bar
	gm.cash = 10000000.0
	gm.station_levels["milkshake_bar"] = 49
	dia_before = gm.diamonds
	gold_before = gm.golden_coins
	upgraded = gm.upgrade_station_multi("milkshake_bar", "1")
	assert(upgraded == true, "Upgrade milkshake_bar should succeed")
	assert(gm.get_station_level("milkshake_bar") == 50, "milkshake_bar should now be level 50")
	assert(gm.diamonds == dia_before + 5, "Level 50 milestone should award +5 Diamonds")
	assert(gm.golden_coins == gold_before + 25, "Level 50 milestone should award +25 Golden Coins")
	assert(milestone_events.back().lvl == 50, "Milestone level should be 50")
	assert(milestone_events.back().dia == 5 and milestone_events.back().gold == 25, "Milestone event should carry 5 diamonds and 25 gold")
	print("  Level 50 milestone reward verified for milkshake_bar (+5 Diamonds, +25 Coins) ✓")
	gm.station_milestone_reached.disconnect(on_milestone)

func _test_lucky_spin_wheel() -> void:
	print("[Frame 15] Testing Lucky Spin Wheel (8 slices, free daily spin, energy cost)...")
	assert(gm.WHEEL_SLICES.size() == 8, "Wheel must contain exactly 8 slices")
	
	# Verify slice prize types
	var slice_types = []
	for s in gm.WHEEL_SLICES:
		slice_types.append(s.type)
	assert("diamonds" in slice_types, "Wheel must contain Diamonds prize")
	assert("golden_coins" in slice_types, "Wheel must contain Golden Coins prize")
	assert("time_skip" in slice_types, "Wheel must contain 1-Hour Time Skip prize")
	assert("chest" in slice_types, "Wheel must contain Wooden Chest prize")
	assert("boost" in slice_types, "Wheel must contain x2 Profit Boost prize")
	print("  Wheel 8 slices contents verified: %s ✓" % [str(slice_types)])

	# Free daily spin test
	gm.last_free_spin_timestamp = 0.0
	assert(gm.can_claim_free_spin() == true, "First spin must be free")
	assert(gm.can_spin_wheel() == true, "Player should be able to spin")

	var spin_res = gm.spin_lucky_wheel()
	assert(not spin_res.is_empty(), "Spin result must not be empty")
	assert(spin_res.was_free == true, "First spin should have been free")
	assert(spin_res.slice_index >= 0 and spin_res.slice_index < 8, "Slice index must be 0-7")
	print("  Free daily spin successful! Won: %s (Slice %d)" % [spin_res.prize.title, spin_res.slice_index])

	# Subsequent spin on same day should cost 10 Energy
	assert(gm.can_claim_free_spin() == false, "Free spin should now be on cooldown")
	assert(gm.get_free_spin_cooldown_remaining() > 0.0, "Free spin cooldown should be > 0")
	gm.energy = 25
	var energy_before = gm.energy
	var energy_spin_res = gm.spin_lucky_wheel()
	assert(not energy_spin_res.is_empty(), "Energy spin should succeed")
	assert(energy_spin_res.was_free == false, "Spin should consume energy, not be free")
	assert(gm.energy == energy_before - 10, "Spin should consume exactly 10 Energy")
	print("  Energy spin successful! Consumed 10 Energy (remaining: %d ⚡) ✓" % gm.energy)

func _test_daily_login_rewards() -> void:
	print("[Frame 20] Testing 7-Day Login Modal rewards and streak progression...")
	assert(gm.DAILY_LOGIN_REWARDS.size() == 7, "Daily login calendar must feature 7 days")
	
	gm.login_streak_days = 0
	gm.last_login_claim_timestamp = 0.0
	assert(gm.can_claim_daily_login() == true, "Day 1 reward should be claimable")

	var dia_before = gm.diamonds
	var gold_before = gm.golden_coins
	var day_1_res = gm.claim_daily_login()
	assert(gm.login_streak_days == 1, "Login streak should advance to Day 1")
	assert(day_1_res.day == 1, "Claimed reward must correspond to Day 1")
	assert(gm.golden_coins == gold_before + 50, "Day 1 should grant +50 Golden Coins")
	print("  Day 1 claimed successfully: %s ✓" % day_1_res.desc)

	# Cooldown check
	assert(gm.can_claim_daily_login() == false, "Daily reward cannot be claimed twice immediately")

	# Advance streak to test Day 2 (Diamonds)
	gm.last_login_claim_timestamp = 0.0
	var day_2_res = gm.claim_daily_login()
	assert(gm.login_streak_days == 2, "Login streak should advance to Day 2")
	assert(day_2_res.day == 2, "Claimed reward must correspond to Day 2")
	assert(gm.diamonds == dia_before + 10, "Day 2 should grant +10 Diamonds")
	print("  Day 2 claimed successfully: %s ✓" % day_2_res.desc)

func _test_hud_ui_integration() -> void:
	print("[Frame 25] Testing HUD UI nodes & modal integration...")
	var hud_scn = load("res://scenes/ui/hud.tscn")
	assert(hud_scn != null, "hud.tscn must load successfully")
	hud_instance = hud_scn.instantiate()
	root.add_child(hud_instance)

	# Verify QuestBanner exists and is visible
	var quest_banner = hud_instance.get_node_or_null("HUD/QuestBanner")
	assert(quest_banner != null, "QuestBanner node must exist in hud.tscn")
	assert(quest_banner.visible == true, "QuestBanner must be visible by default")
	
	# Verify SideSpinBtn exists in RightDock
	var side_spin_btn = hud_instance.get_node_or_null("HUD/RightDock/SideSpinBtn")
	assert(side_spin_btn != null, "SideSpinBtn must exist in HUD/RightDock")
	assert(side_spin_btn.text == "🎡", "SideSpinBtn text must be 🎡")

	# Verify SpinWheelModal exists and has required components
	var spin_modal = hud_instance.get_node_or_null("SpinWheelModal")
	assert(spin_modal != null, "SpinWheelModal must exist in hud.tscn")
	var wheel_graphic = hud_instance.get_node_or_null("SpinWheelModal/VBox/SpinView/WheelCenterContainer/WheelGraphic")
	assert(wheel_graphic != null, "WheelGraphic control must exist in SpinWheelModal")
	var spin_btn = hud_instance.get_node_or_null("SpinWheelModal/VBox/SpinView/SpinActionBtn")
	assert(spin_btn != null, "SpinActionBtn must exist in SpinWheelModal")
	var daily_cards = hud_instance.get_node_or_null("SpinWheelModal/VBox/DailyView/DailyScroll/DailyCardsContainer")
	assert(daily_cards != null, "DailyCardsContainer must exist in SpinWheelModal")

	print("  HUD UI integration verified: QuestBanner visible, SideSpinBtn wired, SpinWheelModal ready ✓")
