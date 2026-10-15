extends SceneTree

var _frame: int = 0
var _max_frames: int = 60
var gm: Node = null
var hud_instance: CanvasLayer = null

func _init() -> void:
	print("--- START TEST: Gacha Chests & Collectible Cards ---")

func _process(_delta: float) -> bool:
	_frame += 1

	if _frame == 1:
		_setup_test_environment()
		return false

	if _frame == 5:
		_test_cards_roster_definitions()
		return false

	if _frame == 10:
		_test_card_multipliers_and_discounts()
		return false

	if _frame == 15:
		_test_gacha_chests()
		return false

	if _frame == 20:
		_test_card_upgrades_and_duplicates()
		return false

	if _frame == 25:
		_test_hud_ui_integration()
		return false

	if _frame == 30:
		print("ALL GACHA CHESTS & COLLECTIBLE CARDS TESTS PASSED DETERMINISTICALLY! ✓")
		quit(0)
		return true

	if _frame >= _max_frames:
		printerr("TEST TIMEOUT: test_gacha_and_cards did not finish in %d frames" % _max_frames)
		quit(1)
		return true

	return false

func _setup_test_environment() -> void:
	print("[Frame 1] Setting up GameManager and mock nodes...")
	gm = root.get_node_or_null("GameManager")
	if gm == null:
		var gm_scn = load("res://scripts/game_manager.gd")
		gm = gm_scn.new()
		gm.name = "GameManager"
		root.add_child(gm)

	# Seed currencies for testing
	gm.cash = 50000.0
	gm.golden_coins = 2000
	gm.diamonds = 500
	gm.energy = 50
	gm.restaurant_level = 1
	gm.restaurant_xp = 0.0
	gm.xp_to_next_level = 1000000.0 # High threshold during test so add_cash does not trigger level-up

	# Reset all collectible cards to clean state
	for cid in gm.collectible_cards.keys():
		gm.collectible_cards[cid]["level"] = 0
		gm.collectible_cards[cid]["cards"] = 0

func _test_cards_roster_definitions() -> void:
	print("[Frame 5] Testing 12 Collectible Cards roster...")
	assert(gm.has_method("get_all_cards"), "GameManager missing get_all_cards method")
	var all_cards: Dictionary = gm.get_all_cards()
	assert(all_cards.size() >= 12, "Expected at least 12 collectible cards, found %d" % all_cards.size())

	var required_keys = [
		"head_chef", "head_waiter", "mixologist", "soda_pop_star",
		"valet_captain", "executive_tycoon", "sous_chef", "star_hostess",
		"maitre_d", "sommelier", "vip_chauffeur", "master_janitor"
	]
	for k in required_keys:
		assert(all_cards.has(k), "Collectible cards roster missing required card '%s'" % k)
		var c = all_cards[k]
		assert(c.has("id") and c.has("name") and c.has("sector") and c.has("rarity"), "Card '%s' missing basic metadata" % k)
		assert(c.has("level") and c.has("cards"), "Card '%s' missing level/cards count" % k)

	print("✓ 12 Collectible Cards verified successfully!")

func _test_card_multipliers_and_discounts() -> void:
	print("[Frame 10] Testing default card multipliers & Executive Tycoon discount...")
	# Base level 0 checks
	assert(is_equal_approx(gm.get_card_cook_speed_multiplier(), 1.0), "Base cook multiplier should be 1.0")
	assert(is_equal_approx(gm.get_card_waiter_speed_multiplier(), 1.0), "Base waiter multiplier should be 1.0")
	assert(is_equal_approx(gm.get_card_cocktail_revenue_multiplier(), 1.0), "Base cocktail multiplier should be 1.0")
	assert(is_equal_approx(gm.get_card_milkshake_revenue_multiplier(), 1.0), "Base milkshake multiplier should be 1.0")
	assert(is_equal_approx(gm.get_card_parking_rate_multiplier(), 1.0), "Base parking multiplier should be 1.0")
	assert(is_equal_approx(gm.get_card_upgrade_discount(), 0.0), "Base upgrade discount should be 0.0")

	# Test applying Executive Tycoon levels for discount
	gm.collectible_cards["executive_tycoon"]["level"] = 2
	var disc = gm.get_card_upgrade_discount()
	assert(is_equal_approx(disc, 0.10), "Executive Tycoon level 2 should give 10%% discount, got %f" % disc)

	var orig_cost = gm.get_station_config("kitchen_cook").base_cost
	var discounted_cost = gm.get_upgrade_cost("kitchen_cook")
	assert(discounted_cost < orig_cost, "Discounted cost %f should be lower than orig %f" % [discounted_cost, orig_cost])
	assert(is_equal_approx(discounted_cost, round(orig_cost * 0.90)), "Discount not matched")

	# Reset
	gm.collectible_cards["executive_tycoon"]["level"] = 0
	print("✓ Card multipliers and discount calculations verified!")

func _test_gacha_chests() -> void:
	print("[Frame 15] Testing Wooden, Silver, and Golden Epic Chest opening...")
	# 1. Wooden Chest Free Claim
	gm.wooden_chest_free_timestamp = 0.0
	assert(gm.can_claim_free_wooden_chest(), "Wooden chest should be claimable for free initially")

	var wooden_res = gm.open_chest("wooden")
	assert(wooden_res.get("success") == true, "Wooden chest free claim failed")
	assert(wooden_res.get("was_free") == true, "Wooden chest should be marked was_free")
	assert(wooden_res.cards.size() >= 2, "Wooden chest should give at least 2 card drops")
	assert(gm.wooden_chest_free_timestamp > Time.get_unix_time_from_system() + 10000.0, "Cooldown should be set ~4h in future")
	assert(not gm.can_claim_free_wooden_chest(), "Wooden chest should not be free immediately after claim")

	# 2. Wooden Chest Paid (100 Golden Coins)
	var coins_before = gm.golden_coins
	var wooden_paid = gm.open_chest("wooden")
	assert(wooden_paid.get("success") == true, "Wooden chest paid claim failed")
	assert(wooden_paid.get("was_free") == false, "Wooden chest should not be marked was_free")
	assert(gm.golden_coins == coins_before - 100 + wooden_paid.golden_coins, "Golden coins not adjusted properly")

	# 3. Silver Chest (35 Diamonds)
	var gems_before = gm.diamonds
	var silver_res = gm.open_chest("silver")
	assert(silver_res.get("success") == true, "Silver chest failed")
	assert(silver_res.cards.size() >= 3, "Silver chest should give at least 3 card drops")
	assert(gm.diamonds == gems_before - 35 + silver_res.diamonds, "Diamonds not adjusted properly for Silver chest")

	# 4. Golden Epic Chest (120 Diamonds)
	gems_before = gm.diamonds
	var epic_res = gm.open_chest("golden_epic")
	assert(epic_res.get("success") == true, "Golden Epic chest failed")
	assert(epic_res.cards.size() >= 5, "Golden Epic chest should give 5 card drops")
	assert(gm.diamonds == gems_before - 120 + epic_res.diamonds, "Diamonds not adjusted properly for Golden Epic chest")

	print("✓ All 3 Gacha chest tiers verified with reward drops!")

func _test_card_upgrades_and_duplicates() -> void:
	print("[Frame 20] Testing card duplicate progress and golden coin level up...")
	var test_card_id = "head_chef"
	# Reset test card
	gm.collectible_cards[test_card_id]["level"] = 0
	gm.collectible_cards[test_card_id]["cards"] = 0

	# Add 1st card -> unlocks card at Level 1 with 0 duplicates
	gm.add_card_duplicates(test_card_id, 1)
	assert(gm.get_card_level(test_card_id) == 1, "First card drop should unlock at level 1")
	assert(gm.get_card_count(test_card_id) == 0, "First drop should consume duplicate for unlock")

	# Add 2 more duplicates (Level 1 needs 2 duplicates according to CARD_DUPLICATES_TABLE)
	var needed = gm.get_card_cards_needed(test_card_id)
	assert(needed == 2, "Level 1 needs 2 cards to upgrade to Level 2")

	gm.add_card_duplicates(test_card_id, needed)
	assert(gm.get_card_count(test_card_id) == needed, "Card count should equal needed duplicates")
	assert(gm.can_upgrade_card(test_card_id), "Card should be eligible for upgrade")

	var gold_before = gm.golden_coins
	var cost = gm.get_card_gold_cost(test_card_id)
	var success = gm.upgrade_card(test_card_id)
	assert(success, "Card upgrade failed")
	assert(gm.get_card_level(test_card_id) == 2, "Card should now be Level 2")
	assert(gm.get_card_count(test_card_id) == 0, "Duplicate cards should be spent")
	assert(gm.golden_coins == gold_before - cost, "Golden coins not spent")

	# Check multiplier increase
	var cook_mult = gm.get_card_cook_speed_multiplier()
	assert(is_equal_approx(cook_mult, 1.0 + 2 * 0.15), "Head Chef Level 2 should give +30% cook speed (1.30)")

	print("✓ Card duplicate progress and level-up system verified!")

func _test_hud_ui_integration() -> void:
	print("[Frame 25] Testing HUD UI nodes, CardsPanel, and ChestRewardModal...")
	var hud_scene = load("res://scenes/ui/hud.tscn")
	assert(hud_scene != null, "Could not load res://scenes/ui/hud.tscn")

	hud_instance = hud_scene.instantiate()
	root.add_child(hud_instance)

	assert(hud_instance.get_node_or_null("CardsPanel") != null, "HUD missing CardsPanel")
	assert(hud_instance.get_node_or_null("ChestRewardModal") != null, "HUD missing ChestRewardModal")
	assert(hud_instance.get_node_or_null("HUD/BottomDock/HBox/CardsBtn") != null, "BottomDock missing CardsBtn")
	assert(hud_instance.get_node_or_null("HUD/RightDock/SideCardsBtn") != null, "RightDock missing SideCardsBtn")

	# Test opening CardsPanel
	var ui_ctrl = hud_instance
	assert(ui_ctrl.has_method("open_cards_panel"), "UIController missing open_cards_panel")
	ui_ctrl.open_cards_panel()

	var cards_panel = hud_instance.get_node_or_null("CardsPanel")
	assert(cards_panel.visible, "CardsPanel should be visible after open_cards_panel")

	var grid = hud_instance.get_node_or_null("CardsPanel/VBox/Scroll/CardsGrid")
	assert(grid != null and grid.get_child_count() >= 12, "CardsGrid should have at least 12 card roster tiles")

	# Test showing ChestRewardModal
	var reward_data = {
		"cash": 1500.0,
		"golden_coins": 50,
		"diamonds": 5,
		"cards": [
			{"id": "head_chef", "name": "Head Chef", "rarity": "rare", "icon": "👨‍🍳", "count": 2, "bonus_desc": "+15% Cook Speed"}
		]
	}
	ui_ctrl.show_chest_reward_popup("wooden", reward_data)
	var reward_modal = hud_instance.get_node_or_null("ChestRewardModal")
	assert(reward_modal.visible, "ChestRewardModal should be visible after show_chest_reward_popup")

	# Clean up
	hud_instance.queue_free()
	print("✓ HUD CardsPanel & ChestRewardModal UI verified!")
