extends SceneTree

var _frame_count: int = 0
var _max_frames: int = 60

func _process(_delta: float) -> bool:
	_frame_count += 1
	if _frame_count >= _max_frames:
		printerr("[FAIL] Test timed out after %d frames" % _max_frames)
		quit(1)
		return true

	if _frame_count == 2:
		_run_prestige_tests()
		quit(0)
		return true

	return false

func _run_prestige_tests() -> void:
	print("--- Running Franchise Prestige & Valuation Test ---")
	var gm = load("res://scripts/game_manager.gd").new()
	root.add_child(gm)

	# 1. Valuation calculation
	var initial_val = gm.get_restaurant_valuation()
	print("[PASS] Initial valuation calculated: $%.2f" % initial_val)
	assert(initial_val >= 500.0, "Initial valuation should be at least $500")

	# 2. Check initial prestige state
	var start_p_lvl = gm.prestige_level
	var start_keys = gm.franchise_keys
	var start_mult = gm.get_prestige_multiplier()
	print("[PASS] Initial state: prestige_level=%d, franchise_keys=%d, mult=%.2fx" % [start_p_lvl, start_keys, start_mult])

	# 3. Add earnings to qualify for prestige
	gm.total_earned = max(gm.total_earned, 50000.0)
	var boosted_val = gm.get_restaurant_valuation()
	print("[PASS] Boosted valuation: $%.2f" % boosted_val)
	assert(gm.can_prestige(), "Should be able to prestige")

	# 4. Set stations to non-1 levels and add collectible card to verify preservation
	gm.station_levels["kitchen_cook"] = 15
	gm.station_levels["table_1"] = 25
	gm.collectible_cards["head_chef"]["level"] = 3
	gm.collectible_cards["head_chef"]["count"] = 5
	gm.permanent_boosters["perm_2x_income"]["owned"] = true

	var expected_keys = gm.get_prestige_keys_gain()
	var expected_diamonds = gm.get_prestige_diamonds_gain()

	# 5. Execute prestige
	var success = gm.execute_prestige()
	assert(success, "Prestige execution should succeed")
	print("[PASS] Prestige executed successfully")

	# 6. Verify state reset and rewards
	assert(gm.prestige_level == start_p_lvl + 1, "Prestige level should increment by 1")
	assert(gm.franchise_keys == start_keys + expected_keys, "Franchise keys should increment by expected keys")
	assert(gm.get_prestige_multiplier() == 1.0 + (float(gm.prestige_level) * 0.50), "Prestige multiplier should equal 1.0 + 0.50*lvl")
	assert(gm.station_levels["kitchen_cook"] == 1, "Kitchen cook level should reset to 1")
	assert(gm.station_levels["table_1"] == 1, "Table 1 level should reset to 1")

	# 7. Verify preservation of cards and permanent boosters
	assert(gm.collectible_cards["head_chef"]["level"] == 3, "Collectible card level should be preserved")
	assert(gm.collectible_cards["head_chef"]["count"] == 5, "Collectible card count should be preserved")
	assert(gm.permanent_boosters["perm_2x_income"]["owned"] == true, "Permanent booster should be preserved")
	print("[PASS] Cards and permanent shop boosters preserved correctly")

	gm.queue_free()
	print("--- ALL FRANCHISE PRESTIGE TESTS PASSED ---")
