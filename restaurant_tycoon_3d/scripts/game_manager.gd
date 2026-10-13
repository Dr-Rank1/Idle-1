extends Node

# ─── Signals ────────────────────────────────────────────────────────────────
signal cash_changed(new_amount: float)
signal reputation_changed(new_rep: int)
signal station_upgraded(station_id: String, new_level: int)
signal spawn_floating_cash(amount: float, world_pos: Vector3)
signal boost_toggled(active: bool)
signal menu_updated()
signal staff_updated(staff_id: String)
signal table_unlocked(table_id: String)
signal critic_review_awarded(stars: float, is_positive: bool)

# ─── Economy State ──────────────────────────────────────────────────────────
var cash: float = 650.0 # generous starting cash to experience upgrades & hiring immediately
var gems: int = 50
var total_earned: float = 0.0
var star_rating: float = 4.8
var restaurant_name: String = "Chef's Bistro Tycoon"
var is_boosted: bool = false
var boost_timer: float = 0.0

# ─── Table Unlock States ────────────────────────────────────────────────────
var unlocked_tables: Dictionary = {
	"table_1": true,
	"table_2": true,
	"table_3": true,
	"table_4": false,
	"table_5": false,
	"table_6": false,
	"table_7": false,
	"table_8": false,
}

var table_unlock_costs: Dictionary = {
	"table_1": 0.0,
	"table_2": 0.0,
	"table_3": 0.0,
	"table_4": 150.0,
	"table_5": 280.0,
	"table_6": 450.0,
	"table_7": 700.0,
	"table_8": 1100.0,
}

# ─── Station Levels ────────────────────────────────────────────────────────
var station_levels: Dictionary = {
	"stove": 1,
	"table_1": 1,
	"table_2": 1,
	"table_3": 1,
	"table_4": 1,
	"table_5": 1,
	"table_6": 1,
	"table_7": 1,
	"table_8": 1,
	"host_desk": 1,
}

var max_level: int = 25

# ─── Menu / Recipes ─────────────────────────────────────────────────────────
var menu_items: Dictionary = {
	"burger": {
		"id": "burger",
		"name": "Classic Bistro Burger",
		"icon": "🍔",
		"price": 45.0,
		"unlocked": true,
		"unlock_cost": 0.0,
		"desc": "Juicy grilled beef patty with aged cheddar & toasted brioche"
	},
	"pasta": {
		"id": "pasta",
		"name": "Truffle Tagliatelle",
		"icon": "🍝",
		"price": 115.0,
		"unlocked": false,
		"unlock_cost": 180.0,
		"desc": "Handmade ribbon pasta with shaved black winter truffles & parmesan"
	},
	"pizza": {
		"id": "pizza",
		"name": "Wood-Fired Margherita",
		"icon": "🍕",
		"price": 240.0,
		"unlocked": false,
		"unlock_cost": 420.0,
		"desc": "Crispy bubbly crust with San Marzano tomatoes, fresh mozzarella & basil"
	},
	"sushi": {
		"id": "sushi",
		"name": "Deluxe Dragon Roll",
		"icon": "🍣",
		"price": 480.0,
		"unlocked": false,
		"unlock_cost": 850.0,
		"desc": "Premium grilled eel, avocado, tobiko, and fresh Atlantic salmon"
	}
}

# ─── Staff Roster ───────────────────────────────────────────────────────────
var staff_roster: Dictionary = {
	"waiter_1": {
		"id": "waiter_1",
		"name": "Marco (Head Waiter)",
		"role": "waiter",
		"hired": true,
		"hire_cost": 0.0,
		"level": 1,
		"desc": "Faithful frontline server. Upgrading boosts sprint speed!"
	},
	"waiter_2": {
		"id": "waiter_2",
		"name": "Sophia (Speed Runner)",
		"role": "waiter",
		"hired": false,
		"hire_cost": 250.0,
		"level": 1,
		"desc": "Doubles floor service capacity for quicker table turns!"
	},
	"waiter_3": {
		"id": "waiter_3",
		"name": "Lucas (VIP Concierge)",
		"role": "waiter",
		"hired": false,
		"hire_cost": 600.0,
		"level": 1,
		"desc": "Triples floor service capacity & ensures zero customer walkouts!"
	},
	"chef_stove": {
		"id": "chef_stove",
		"name": "Gordon (Master Range)",
		"role": "chef",
		"hired": true,
		"hire_cost": 0.0,
		"level": 1,
		"desc": "Culinary virtuoso managing hot stove sautés & flame broiling."
	},
	"chef_prep": {
		"id": "chef_prep",
		"name": "Pierre (Prep Artisan)",
		"role": "chef",
		"hired": true,
		"hire_cost": 0.0,
		"level": 1,
		"desc": "Rapid knife skills plating starters and table sides."
	},
	"chef_sous": {
		"id": "chef_sous",
		"name": "Antoine (Sous Chef)",
		"role": "chef",
		"hired": false,
		"hire_cost": 350.0,
		"level": 1,
		"desc": "Expedites all kitchen station prep by +40%!"
	}
}

const SAVE_PATH: String = "user://restaurant_save.json"
var autosave_timer: float = 0.0

func _ready() -> void:
	load_game()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()

func save_game() -> void:
	var data = {
		"cash": cash,
		"gems": gems,
		"total_earned": total_earned,
		"star_rating": star_rating,
		"restaurant_name": restaurant_name,
		"unlocked_tables": unlocked_tables,
		"station_levels": station_levels,
		"menu_items": menu_items,
		"staff_roster": staff_roster
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var content = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(content)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	
	cash = parsed.get("cash", cash)
	gems = parsed.get("gems", gems)
	total_earned = parsed.get("total_earned", total_earned)
	star_rating = parsed.get("star_rating", star_rating)
	restaurant_name = parsed.get("restaurant_name", restaurant_name)
	
	if parsed.has("unlocked_tables") and typeof(parsed["unlocked_tables"]) == TYPE_DICTIONARY:
		for k in parsed["unlocked_tables"].keys():
			unlocked_tables[k] = parsed["unlocked_tables"][k]
			
	if parsed.has("station_levels") and typeof(parsed["station_levels"]) == TYPE_DICTIONARY:
		for k in parsed["station_levels"].keys():
			station_levels[k] = int(parsed["station_levels"][k])
			
	if parsed.has("menu_items") and typeof(parsed["menu_items"]) == TYPE_DICTIONARY:
		for k in parsed["menu_items"].keys():
			if menu_items.has(k) and typeof(parsed["menu_items"][k]) == TYPE_DICTIONARY:
				for prop in parsed["menu_items"][k].keys():
					menu_items[k][prop] = parsed["menu_items"][k][prop]
					
	if parsed.has("staff_roster") and typeof(parsed["staff_roster"]) == TYPE_DICTIONARY:
		for k in parsed["staff_roster"].keys():
			if staff_roster.has(k) and typeof(parsed["staff_roster"][k]) == TYPE_DICTIONARY:
				for prop in parsed["staff_roster"][k].keys():
					staff_roster[k][prop] = parsed["staff_roster"][k][prop]

func _process(delta: float) -> void:
	autosave_timer += delta
	if autosave_timer >= 20.0:
		autosave_timer = 0.0
		save_game()

	if is_boosted:
		boost_timer -= delta
		if boost_timer <= 0.0:
			is_boosted = false
			boost_toggled.emit(false)

func toggle_boost() -> void:
	is_boosted = not is_boosted
	if is_boosted:
		boost_timer = 60.0
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade", 0.1, 2.0)
	boost_toggled.emit(is_boosted)

func add_cash(amount: float, world_pos: Vector3 = Vector3.ZERO) -> void:
	var final_amount: float = amount * (2.0 if is_boosted else 1.0)
	cash += final_amount
	total_earned += final_amount
	cash_changed.emit(cash)
	if world_pos != Vector3.ZERO:
		spawn_floating_cash.emit(final_amount, world_pos)
	
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("coin", 0.08)

func spend_cash(amount: float) -> bool:
	if cash >= amount:
		cash -= amount
		cash_changed.emit(cash)
		return true
	return false

# ─── Stations ───────────────────────────────────────────────────────────────
func get_station_level(station_id: String) -> int:
	return station_levels.get(station_id, 1)

func get_upgrade_cost(station_id: String) -> float:
	var lvl: int = get_station_level(station_id)
	var base_cost: float = 75.0
	if station_id.begins_with("stove"):
		base_cost = 140.0
	elif station_id.begins_with("table"):
		base_cost = 90.0
	return round(base_cost * pow(1.20, lvl - 1))

func get_station_income(station_id: String) -> float:
	var lvl: int = get_station_level(station_id)
	var base_income: float = 30.0
	if station_id.begins_with("table"):
		base_income = 45.0 + (lvl * 14.0)
	elif station_id.begins_with("stove"):
		base_income = 35.0 + (lvl * 12.0)
	return base_income

func upgrade_station(station_id: String) -> bool:
	var cost: float = get_upgrade_cost(station_id)
	if spend_cash(cost):
		var current_lvl: int = get_station_level(station_id)
		station_levels[station_id] = current_lvl + 1
		station_upgraded.emit(station_id, station_levels[station_id])
		save_game()
		
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade")
		return true
	return false

func is_table_unlocked(table_id: String) -> bool:
	return unlocked_tables.get(table_id, true)

func get_table_unlock_cost(table_id: String) -> float:
	return table_unlock_costs.get(table_id, 200.0)

func unlock_table(table_id: String) -> bool:
	if is_table_unlocked(table_id):
		return true
	var cost = get_table_unlock_cost(table_id)
	if spend_cash(cost):
		unlocked_tables[table_id] = true
		table_unlocked.emit(table_id)
		save_game()
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade", 0.0, 3.0)
		return true
	return false

func award_critic_review(is_positive: bool, bounty: float = 0.0) -> void:
	if is_positive:
		star_rating = min(5.0, star_rating + 0.1)
		reputation_changed.emit(round(star_rating * 10))
		if bounty > 0.0:
			add_cash(bounty)
		critic_review_awarded.emit(star_rating, true)
	else:
		star_rating = max(3.5, star_rating - 0.1)
		reputation_changed.emit(round(star_rating * 10))
		critic_review_awarded.emit(star_rating, false)
	save_game()

func get_station_tier_title(station_id: String, lvl: int) -> String:
	if station_id.begins_with("table"):
		if lvl >= 10:
			return "👑 TIER 3 • ROYAL VIP SUITE"
		elif lvl >= 5:
			return "★ TIER 2 • GOURMET BISTRO"
		else:
			return "☕ TIER 1 • RUSTIC PINE TABLE"
	elif station_id.begins_with("stove"):
		if lvl >= 10:
			return "👑 TIER 3 • MASTER CHEF SUITE"
		elif lvl >= 5:
			return "★ TIER 2 • COMMERCIAL DOUBLE RANGE"
		else:
			return "🍳 TIER 1 • LINE COOK RANGE"
	return "STATION TIER 1"

func get_next_tier_desc(station_id: String, lvl: int) -> String:
	if station_id.begins_with("table"):
		if lvl < 5:
			return "Next: Lv. 5 unlocks Linen Cloth, Wine & Flowers (+45% rev)"
		elif lvl < 10:
			return "Next: Lv. 10 unlocks Royal VIP Candelabra (+85% rev)"
		else:
			return "MAX TIER UNLOCKED • Prestige VIP Status Active!"
	elif station_id.begins_with("stove"):
		if lvl < 5:
			return "Next: Lv. 5 unlocks Commercial Double Range & Stew Pots"
		elif lvl < 10:
			return "Next: Lv. 10 unlocks Master Chef Golden Range (+60% Speed)"
		else:
			return "MAX TIER UNLOCKED • Culinary Mastery Achieved!"
	return ""

# ─── Menu Methods ───────────────────────────────────────────────────────────
func get_unlocked_dishes() -> Array:
	var list: Array = []
	for k in menu_items.keys():
		if menu_items[k].get("unlocked", false):
			list.append(menu_items[k])
	if list.size() == 0:
		list.append(menu_items["burger"])
	return list

func pick_random_dish() -> Dictionary:
	var unlocked = get_unlocked_dishes()
	return unlocked.pick_random()

func unlock_dish(dish_id: String) -> bool:
	if not menu_items.has(dish_id):
		return false
	var item = menu_items[dish_id]
	if item.get("unlocked", false):
		return true
	var cost = item.get("unlock_cost", 100.0)
	if spend_cash(cost):
		item["unlocked"] = true
		menu_updated.emit()
		save_game()
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade", 0.0, 3.0)
		return true
	return false

# ─── Staff Methods ──────────────────────────────────────────────────────────
func is_staff_hired(staff_id: String) -> bool:
	return staff_roster.get(staff_id, {}).get("hired", false)

func get_staff_level(staff_id: String) -> int:
	return staff_roster.get(staff_id, {}).get("level", 1)

func get_staff_upgrade_cost(staff_id: String) -> float:
	var lvl = get_staff_level(staff_id)
	var base_cost = 95.0
	if staff_id.begins_with("chef"):
		base_cost = 130.0
	return round(base_cost * pow(1.25, lvl - 1))

func get_staff_speed_multiplier(staff_id: String) -> float:
	var lvl = get_staff_level(staff_id)
	return 1.0 + (lvl - 1) * 0.15

func hire_staff(staff_id: String) -> bool:
	if not staff_roster.has(staff_id):
		return false
	var st = staff_roster[staff_id]
	if st.get("hired", false):
		return true
	var cost = st.get("hire_cost", 200.0)
	if spend_cash(cost):
		st["hired"] = true
		staff_updated.emit(staff_id)
		save_game()
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade", 0.0, 2.0)
		return true
	return false

func upgrade_staff(staff_id: String) -> bool:
	if not staff_roster.has(staff_id):
		return false
	var st = staff_roster[staff_id]
	if not st.get("hired", false):
		return false
	var cost = get_staff_upgrade_cost(staff_id)
	if spend_cash(cost):
		st["level"] = st.get("level", 1) + 1
		staff_updated.emit(staff_id)
		save_game()
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade")
		return true
	return false
