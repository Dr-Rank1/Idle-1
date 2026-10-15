extends SceneTree

func _init() -> void:
	print("==================================================")
	print("STARTING TEST: Shop & Multi-Currency System")
	print("==================================================")
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

	var hud_scn = load("res://scenes/ui/hud.tscn")
	var ui = hud_scn.instantiate()
	root.add_child(ui)
	await create_timer(0.2).timeout

	# ─────────────────────────────────────────────────────────
	# Test 1: Multi-Currency Tracking & Operations
	# ─────────────────────────────────────────────────────────
	print("\n--- Test 1: Currency State & Persistence ---")
	gm.cash = 1000.0
	gm.golden_coins = 200
	gm.diamonds = 100
	gm.energy = 30
	gm.max_energy = 50
	
	assert(gm.cash == 1000.0, "Cash should be 1000")
	assert(gm.golden_coins == 200, "Golden coins should be 200")
	assert(gm.diamonds == 100, "Diamonds should be 100")
	assert(gm.gems == 100, "Gems alias should be 100")
	assert(gm.energy == 30, "Energy should be 30")
	
	gm.add_golden_coins(50)
	assert(gm.golden_coins == 250, "Golden coins should be 250 after +50")
	var spent_gold = gm.spend_golden_coins(100)
	assert(spent_gold and gm.golden_coins == 150, "Should spend 100 gold coins and have 150 left")
	
	gm.add_diamonds(25)
	assert(gm.diamonds == 125, "Diamonds should be 125 after +25")
	var spent_diamonds = gm.spend_diamonds(50)
	assert(spent_diamonds and gm.diamonds == 75, "Should spend 50 diamonds and have 75 left")
	
	gm.add_energy(10)
	assert(gm.energy == 40, "Energy should be 40 after +10")
	var spent_energy = gm.spend_energy(15)
	assert(spent_energy and gm.energy == 25, "Should spend 15 energy and have 25 left")
	print("✓ Currency operations (add/spend) passed")
	
	# ─────────────────────────────────────────────────────────
	# Test 2: Energy Regeneration
	# ─────────────────────────────────────────────────────────
	print("\n--- Test 2: Energy Regeneration ---")
	gm.energy = 48
	gm.energy_regen_timer = 59.5
	gm._process(1.0) # passes 60s mark
	assert(gm.energy == 49, "Energy should regenerate +1 after 60s")
	gm.energy = 50
	gm._process(65.0)
	assert(gm.energy == 50, "Energy should not exceed max_energy (50)")
	print("✓ Energy regeneration capped at 50 passed")
	
	# ─────────────────────────────────────────────────────────
	# Test 3: Big-Number Formatter
	# ─────────────────────────────────────────────────────────
	print("\n--- Test 3: Big-Number Currency Formatter ---")
	assert(gm.format_currency(100.0) == "$100", "Format 100 should be $100")
	assert(gm.format_currency(1500.0) == "$1.5K", "Format 1500 should be $1.5K, got " + gm.format_currency(1500.0))
	assert(gm.format_currency(24000000.0) == "$24.0M", "Format 24M should be $24.0M, got " + gm.format_currency(24000000.0))
	assert(gm.format_currency(8200000000.0) == "$8.2B", "Format 8.2B should be $8.2B, got " + gm.format_currency(8200000000.0))
	assert(gm.format_currency(2800000000000.0) == "$2.8T", "Format 2.8T should be $2.8T, got " + gm.format_currency(2800000000000.0))
	print("✓ Big-number formatting passed")
	
	# ─────────────────────────────────────────────────────────
	# Test 4: Shop Purchases - Permanent Multipliers & Boosters
	# ─────────────────────────────────────────────────────────
	print("\n--- Test 4: Shop Purchases ---")
	gm.diamonds = 500
	gm.golden_coins = 1000
	gm.cash = 50000.0
	
	# Permanent x2 Income
	if gm.permanent_boosters.has("perm_2x_income"):
		gm.permanent_boosters["perm_2x_income"]["owned"] = false
	var base_price = gm.get_dish_price_multiplier()
	var buy_perm = gm.buy_shop_item("perm_2x_income")
	assert(buy_perm, "Should successfully buy perm_2x_income")
	assert(gm.is_permanent_booster_owned("perm_2x_income"), "Should own perm_2x_income")
	assert(gm.get_dish_price_multiplier() >= base_price * 2.0, "Dish price multiplier should be doubled")
	print("✓ Permanent x2 Income purchase & multiplier passed")
	
	# VIP Auto-Collector
	if gm.permanent_boosters.has("vip_auto_collector"):
		gm.permanent_boosters["vip_auto_collector"]["owned"] = false
	var buy_vip = gm.buy_shop_item("vip_auto_collector")
	assert(buy_vip, "Should successfully buy vip_auto_collector")
	assert(gm.is_vip_auto_collector_active(), "VIP auto-collector should now be active")
	print("✓ VIP Auto-Collector purchase passed")
	
	# Temporary Overdrive Boosts
	gm.buy_shop_item("boost_10x_5m")
	assert(gm.is_boosted, "Game should be boosted")
	assert(gm.boost_multiplier >= 10.0, "Boost multiplier should be 10x")
	assert(gm.boost_timer >= 290.0, "Boost timer should be ~300s")
	print("✓ 10X Overdrive Boost purchase passed")
	
	# Time Skips
	var pre_skip_cash = gm.cash
	var time_skip_res = gm.execute_time_skip(1, 0, 150)
	assert(time_skip_res > 0.0, "Time skip should calculate positive reward")
	assert(gm.cash > pre_skip_cash, "Cash should have increased after time skip")
	print("✓ Time skip execution passed")
	
	# Currency Exchange
	var pre_coins = gm.golden_coins
	gm.buy_shop_item("gold_pouch")
	assert(gm.golden_coins == pre_coins + 100, "Should add 100 golden coins from gold_pouch")
	
	gm.energy = 10
	gm.buy_shop_item("energy_full")
	assert(gm.energy == 50, "Should refill energy to 50 from energy_full")
	print("✓ Currency exchanges passed")
	
	# ─────────────────────────────────────────────────────────
	# Test 5: UIController Category Tabs & Shop Refresh
	# ─────────────────────────────────────────────────────────
	print("\n--- Test 5: UI Controller Shop Tabs ---")
	ui._select_shop_category("featured")
	assert(ui.current_shop_category == "featured", "Category should be featured")
	assert(ui.shop_vbox.get_child_count() > 0, "Featured tab should have items")
	
	ui._select_shop_category("boosts")
	assert(ui.current_shop_category == "boosts", "Category should be boosts")
	assert(ui.shop_vbox.get_child_count() > 0, "Boosts tab should have items")
	
	ui._select_shop_category("timeskips")
	assert(ui.current_shop_category == "timeskips", "Category should be timeskips")
	assert(ui.shop_vbox.get_child_count() > 0, "Time skips tab should have items")
	
	ui._select_shop_category("chests")
	assert(ui.current_shop_category == "chests", "Category should be chests")
	assert(ui.shop_vbox.get_child_count() > 0, "Chests tab should have items")
	
	ui._select_shop_category("currencies")
	assert(ui.current_shop_category == "currencies", "Category should be currencies")
	assert(ui.shop_vbox.get_child_count() > 0, "Currencies tab should have items")
	print("✓ All 5 Shop categories render items properly")
	
	# ─────────────────────────────────────────────────────────
	# Test 6: Flying Currency Trails & Time Skip Shower
	# ─────────────────────────────────────────────────────────
	print("\n--- Test 6: Currency Trails & Time Skip Shower ---")
	ui.spawn_flying_currency_trail(Vector3(0, 1, 0), 100.0, "cash")
	ui.spawn_flying_currency_trail(Vector3(0, 1, 0), 50.0, "gold")
	ui.spawn_flying_currency_trail(Vector3(0, 1, 0), 25.0, "diamond")
	ui.spawn_flying_currency_trail(Vector3(0, 1, 0), 10.0, "energy")
	
	ui.trigger_time_skip_shower(1, 5000.0)
	print("✓ Trails and time skip shower executed without error")
	
	print("\n==================================================")
	print("ALL TESTS PASSED SUCCESSFULLY!")
	print("==================================================")
	quit(0)
