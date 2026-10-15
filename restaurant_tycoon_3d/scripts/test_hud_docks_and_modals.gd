extends SceneTree

func _init() -> void:
	print(">>> [TEST] Starting test_hud_docks_and_modals.gd...")
	
	# 1. Test Big-Number Currency Formatter
	print("--- 1. Testing Big-Number Currency Formatter ---")
	var gm_script = load("res://scripts/game_manager.gd")
	assert(gm_script != null, "GameManager script must load")
	
	var test_cases = [
		{"input": 100.0, "expected": "$100"},
		{"input": 1500.0, "expected": "$1.5K"},
		{"input": 24000000.0, "expected": "$24.0M"},
		{"input": 8200000000.0, "expected": "$8.2B"},
		{"input": 2800000000000.0, "expected": "$2.8T"},
		{"input": 172000000000000.0, "expected": "$172T"},
	]
	
	for tc in test_cases:
		var formatted = gm_script.format_currency(tc["input"])
		print("Format %f -> %s (expected %s)" % [tc["input"], formatted, tc["expected"]])
		assert(formatted == tc["expected"], "Formatted currency mismatch: got %s, expected %s" % [formatted, tc["expected"]])
	print("✓ Big-Number Currency Formatter passed!")

	# 2. Test GameManager Financial Breakdown & Perks
	print("--- 2. Testing GameManager Financials, Perks & Shop ---")
	var gm_node = Node.new()
	gm_node.set_script(gm_script)
	gm_node.name = "GameManager"
	root.add_child(gm_node)
	await create_timer(0.1).timeout
	
	var fin = gm_node.get_financial_breakdown()
	assert(fin.has("income") and fin.has("expenses") and fin.has("net_profit"), "Financial breakdown must contain income, expenses, net_profit")
	assert(fin["income"].has("dining"), "Must have dining income")
	assert(fin["income"].has("milkshake"), "Must have milkshake income")
	assert(fin["income"].has("cocktail"), "Must have cocktail income")
	assert(fin["income"].has("parking"), "Must have parking income")
	assert(fin["expenses"].has("marketing"), "Must have marketing expense")
	assert(fin["expenses"].has("cleaning"), "Must have cleaning expense")
	assert(fin["expenses"].has("staff"), "Must have staff expense")
	print("Live Income: +%s/s, Live Expenses: -%s/s, Net Profit: %s/s" % [
		gm_node.format_money(fin["income"]["total"]),
		gm_node.format_money(fin["expenses"]["total"]),
		gm_node.format_money(fin["net_profit"])
	])
	assert(fin["income"]["total"] > 0.0, "Total income should be positive")
	assert(fin["expenses"]["total"] > 0.0, "Total expenses should be positive")
	
	# Test Research Perks
	var perks = gm_node.get_research_perks()
	assert(perks.has("fast_turnover"), "Must have fast_turnover perk")
	assert(perks.has("high_roller_tips"), "Must have high_roller_tips perk")
	assert(perks.has("valet_expansion"), "Must have valet_expansion perk")
	assert(perks.has("master_chef"), "Must have master_chef perk")
	assert(perks.has("cocktail_infusion"), "Must have cocktail_infusion perk")
	assert(perks.has("spotless_hygiene"), "Must have spotless_hygiene perk")
	
	perks["fast_turnover"]["unlocked"] = false
	gm_node.cash = 10000.0
	assert(not gm_node.is_perk_unlocked("fast_turnover"), "fast_turnover should start locked")
	assert(gm_node.unlock_perk("fast_turnover"), "Should unlock fast_turnover")
	assert(gm_node.is_perk_unlocked("fast_turnover"), "fast_turnover should now be unlocked")
	
	# Test Permanent Boosters
	var boosters = gm_node.get_permanent_boosters()
	assert(boosters.has("golden_spatula"), "Must have golden_spatula booster")
	assert(boosters.has("golden_register"), "Must have golden_register booster")
	assert(boosters.has("roller_skates"), "Must have roller_skates booster")
	
	boosters["golden_register"]["owned"] = false
	gm_node.gems = 200
	assert(not gm_node.is_permanent_booster_owned("golden_register"), "golden_register should start unowned")
	assert(gm_node.buy_permanent_booster("golden_register"), "Should buy golden_register")
	assert(gm_node.is_permanent_booster_owned("golden_register"), "golden_register should now be owned")
	print("✓ GameManager Financials, Perks & Boosters passed!")

	# 3. Test HUD Scene and RightDock / Shop Buttons
	print("--- 3. Testing HUD Scene & Modals ---")
	var hud_scene = load("res://scenes/ui/hud.tscn")
	assert(hud_scene != null, "HUD scene must load successfully")
	var hud_instance = hud_scene.instantiate()
	root.add_child(hud_instance)
	await create_timer(0.2).timeout

	# Verify RightDock buttons
	var right_dock = hud_instance.get_node_or_null("HUD/RightDock")
	assert(right_dock != null, "HUD/RightDock must exist")
	
	var side_map_btn = right_dock.get_node_or_null("SideMapBtn")
	var side_ad_btn = right_dock.get_node_or_null("SideAdBtn")
	var side_settings_btn = right_dock.get_node_or_null("SideSettingsBtn")
	var side_lightbulb_btn = right_dock.get_node_or_null("SideLightbulbBtn")
	var side_stats_btn = right_dock.get_node_or_null("SideStatsBtn")
	var side_staff_btn = right_dock.get_node_or_null("SideStaffBtn")
	var shop_btn = hud_instance.get_node_or_null("HUD/ShopBtn")
	
	assert(side_map_btn != null, "SideMapBtn must exist")
	assert(side_ad_btn != null, "SideAdBtn must exist")
	assert(side_settings_btn != null, "SideSettingsBtn must exist")
	assert(side_lightbulb_btn != null, "SideLightbulbBtn must exist")
	assert(side_stats_btn != null, "SideStatsBtn must exist")
	assert(side_staff_btn != null, "SideStaffBtn must exist")
	assert(shop_btn != null, "HUD/ShopBtn must exist")
	
	# Verify Modal Panels
	var analytics_panel = hud_instance.get_node_or_null("AnalyticsPanel")
	var perks_panel = hud_instance.get_node_or_null("PerksPanel")
	var world_map_panel = hud_instance.get_node_or_null("WorldMapPanel")
	var shop_panel = hud_instance.get_node_or_null("ShopPanel")
	
	assert(analytics_panel != null, "AnalyticsPanel must exist in HUD")
	assert(perks_panel != null, "PerksPanel must exist in HUD")
	assert(world_map_panel != null, "WorldMapPanel must exist in HUD")
	assert(shop_panel != null, "ShopPanel must exist in HUD")
	
	# Test Opening Analytics Modal via SideStatsBtn
	print("Testing SideStatsBtn (📊) -> AnalyticsPanel...")
	assert(not analytics_panel.visible, "AnalyticsPanel should start closed")
	side_stats_btn.emit_signal("pressed")
	assert(analytics_panel.visible, "AnalyticsPanel should be visible after SideStatsBtn pressed")
	var a_vbox = analytics_panel.get_node("VBox/Scroll/VBox")
	assert(a_vbox.get_child_count() > 0, "AnalyticsPanel must have content rows populated")
	print("Analytics rows count: %d" % a_vbox.get_child_count())
	
	# Test Opening Perks Modal via SideLightbulbBtn
	print("Testing SideLightbulbBtn (💡) -> PerksPanel...")
	side_lightbulb_btn.emit_signal("pressed")
	assert(not analytics_panel.visible, "Previous modal should close when new one opens")
	assert(perks_panel.visible, "PerksPanel should be visible after SideLightbulbBtn pressed")
	var p_vbox = perks_panel.get_node("VBox/Scroll/VBox")
	assert(p_vbox.get_child_count() > 0, "PerksPanel must have perks and menu items populated")
	print("Perks & Menu rows count: %d" % p_vbox.get_child_count())
	
	# Test Opening World Map Modal via SideMapBtn
	print("Testing SideMapBtn (🌍) -> WorldMapPanel...")
	side_map_btn.emit_signal("pressed")
	assert(not perks_panel.visible, "PerksPanel should close when WorldMapPanel opens")
	assert(world_map_panel.visible, "WorldMapPanel should be visible after SideMapBtn pressed")
	var map_grid = world_map_panel.get_node("VBox/Scroll/CardsGrid")
	assert(map_grid.get_child_count() > 0, "WorldMapPanel must have restaurant cards")
	print("World map cards count: %d" % map_grid.get_child_count())
	
	# Test Opening Store Modal via ShopBtn
	print("Testing ShopBtn (🛒) -> ShopPanel...")
	shop_btn.emit_signal("pressed")
	assert(not world_map_panel.visible, "WorldMapPanel should close when ShopPanel opens")
	assert(shop_panel.visible, "ShopPanel should be visible after ShopBtn pressed")
	var s_vbox = shop_panel.get_node("VBox/Scroll/ItemsVBox")
	assert(s_vbox.get_child_count() >= 7, "ShopPanel must contain daily gift, cash packs, boosters, permanent items & exchange")
	print("Shop items count: %d" % s_vbox.get_child_count())
	
	# 4. Test Floating Cash Label
	print("--- 4. Testing Floating Cash Label ---")
	var float_script = load("res://scripts/floating_cash.gd")
	var float_lbl = Label3D.new()
	float_lbl.set_script(float_script)
	root.add_child(float_lbl)
	float_lbl.setup(24000000.0, Vector3.ZERO)
	print("Floating Cash 3D Text: %s" % float_lbl.text)
	assert(float_lbl.text == "💵 +$24.0M", "Floating cash text must use standard idle suffix: got %s" % float_lbl.text)
	float_lbl.queue_free()

	print(">>> [TEST] ALL HUD DOCKS AND MODALS TESTS PASSED SUCCESSFULLY! <<<")
	quit(0)
