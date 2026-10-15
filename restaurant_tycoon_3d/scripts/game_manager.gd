extends Node

# ─── Signals ────────────────────────────────────────────────────────────────
signal cash_changed(new_amount: float)
signal gems_changed(new_amount: int)
signal cash_rate_updated(rate: float)
signal level_updated(new_level: int, current_xp: float, target_xp: float)
signal reputation_changed(new_rep: int)
signal station_upgraded(station_id: String, new_level: int)
signal spawn_floating_cash(amount: float, world_pos: Vector3)
signal boost_toggled(active: bool)
signal menu_updated()
signal staff_updated(staff_id: String)
signal manager_inspection_changed(active: bool)
signal table_unlocked(table_id: String)
signal critic_review_awarded(stars: float, is_positive: bool)
signal quests_updated()
signal campaign_updated(campaign_id: String, active: bool, time_left: float)
signal terrace_unlocked_changed(unlocked: bool)
signal stall_unlocked(stall_idx: int)
signal offline_earnings_available(amount: float, elapsed_seconds: float)
signal world_restaurants_updated()

# ─── Developer Debug & Presets ──────────────────────────────────────────────
@export var preview_all_max_levels: bool = false:
	set(val):
		preview_all_max_levels = val
		if preview_all_max_levels and is_inside_tree():
			set_all_stations_max_level(true)

# ─── Economy State ──────────────────────────────────────────────────────────
var cash: float = 650.0
var gems: int = 50
var total_earned: float = 0.0
var pending_offline_earnings: float = 0.0
var star_rating: float = 4.8
var restaurant_name: String = "Idle Diner"
var is_boosted: bool = false
var boost_timer: float = 0.0
var is_manager_inspection_active: bool = false
var daily_gift_claimed: bool = false

# ─── World Map Restaurants ──────────────────────────────────────────────────
var active_restaurant_id: String = "idle_diner"
var world_restaurants: Dictionary = {
	"idle_diner": {
		"id": "idle_diner",
		"name": "Idle Diner",
		"icon": "🍔",
		"tagline": "Classic 1950s American Diner",
		"stars": 5,
		"multiplier": 1.0,
		"unlocked": true,
		"cost": 0.0,
		"color": Color(0.95, 0.45, 0.2, 1.0)
	},
	"idles_chain": {
		"id": "idles_chain",
		"name": "Idle's Chain",
		"icon": "🍟",
		"tagline": "Fast Food Drive-Thru Franchise",
		"stars": 3,
		"multiplier": 3.5,
		"unlocked": false,
		"cost": 5000.0,
		"color": Color(0.95, 0.75, 0.15, 1.0)
	},
	"snowy_peaks": {
		"id": "snowy_peaks",
		"name": "Snowy Peaks",
		"icon": "⛷️",
		"tagline": "Alpine Mountain Fondue Lodge",
		"stars": 2,
		"multiplier": 10.0,
		"unlocked": false,
		"cost": 25000.0,
		"color": Color(0.4, 0.8, 1.0, 1.0)
	},
	"taverna_athena": {
		"id": "taverna_athena",
		"name": "Taverna Athena",
		"icon": "🏛️",
		"tagline": "Aegean Seaside Seafood Taverna",
		"stars": 1,
		"multiplier": 35.0,
		"unlocked": false,
		"cost": 150000.0,
		"color": Color(0.2, 0.6, 0.95, 1.0)
	},
	"noodle_palace": {
		"id": "noodle_palace",
		"name": "Noodle Palace",
		"icon": "🍜",
		"tagline": "Imperial Dim Sum & Ramen Pagoda",
		"stars": 0,
		"multiplier": 120.0,
		"unlocked": false,
		"cost": 1000000.0,
		"color": Color(0.95, 0.25, 0.35, 1.0)
	},
	"sakura_springs": {
		"id": "sakura_springs",
		"name": "Sakura Springs",
		"icon": "🌸",
		"tagline": "Zen Hot Springs Sushi Garden",
		"stars": 0,
		"multiplier": 500.0,
		"unlocked": false,
		"cost": 10000000.0,
		"color": Color(0.95, 0.5, 0.75, 1.0)
	}
}

# ─── Sectors & Expansions ───────────────────────────────────────────────────
var unlocked_stalls: int = 2
var terrace_unlocked: bool = true
const TERRACE_UNLOCK_COST: float = 380.0

# ─── Tycoon Level & XP ──────────────────────────────────────────────────────
var restaurant_level: int = 1
var restaurant_xp: float = 0.0
var xp_to_next_level: float = 250.0

# ─── Live Income Tracking ───────────────────────────────────────────────────
var recent_earnings: Array = []
var cash_per_sec: float = 0.0
var rate_update_timer: float = 0.0

# ─── Table Unlock States ────────────────────────────────────────────────────
var unlocked_tables: Dictionary = {
	"table_1": true,
	"table_2": true,
	"table_3": true,
	"table_4": true,
	"table_5": true,
	"table_6": true,
	"table_7": true,
	"table_8": true,
	"table_9": true,
	"table_10": true,
	"table_11": true,
	"table_12": true,
}

var table_unlock_costs: Dictionary = {
	"table_1": 0.0,
	"table_2": 0.0,
	"table_3": 0.0,
	"table_4": 0.0,
	"table_5": 0.0,
	"table_6": 0.0,
	"table_7": 0.0,
	"table_8": 0.0,
	"table_9": 0.0,
	"table_10": 450.0,
	"table_11": 800.0,
	"table_12": 1200.0,
}

# ─── Station Configurations & Exponential Economy Formulas ───────────────────
# Formula: Cost = BaseCost * CostMultiplier^(L - 1)
# Formula: Revenue = BaseRevenue * RevenueMultiplier^(L - 1)
const STATION_CONFIGS: Dictionary = {
	"table_1": {"base_cost": 45.0, "cost_mult": 1.15, "base_rev": 12.0, "rev_mult": 1.10, "max_level": 50},
	"table_2": {"base_cost": 45.0, "cost_mult": 1.15, "base_rev": 12.0, "rev_mult": 1.10, "max_level": 50},
	"table_3": {"base_cost": 45.0, "cost_mult": 1.15, "base_rev": 12.0, "rev_mult": 1.10, "max_level": 50},
	"table_4": {"base_cost": 120.0, "cost_mult": 1.16, "base_rev": 28.0, "rev_mult": 1.11, "max_level": 50},
	"table_5": {"base_cost": 120.0, "cost_mult": 1.16, "base_rev": 28.0, "rev_mult": 1.11, "max_level": 50},
	"table_6": {"base_cost": 120.0, "cost_mult": 1.16, "base_rev": 28.0, "rev_mult": 1.11, "max_level": 50},
	"table_7": {"base_cost": 320.0, "cost_mult": 1.18, "base_rev": 65.0, "rev_mult": 1.12, "max_level": 50},
	"table_8": {"base_cost": 320.0, "cost_mult": 1.18, "base_rev": 65.0, "rev_mult": 1.12, "max_level": 50},
	"table_9": {"base_cost": 320.0, "cost_mult": 1.18, "base_rev": 65.0, "rev_mult": 1.12, "max_level": 50},
	"table_10": {"base_cost": 650.0, "cost_mult": 1.20, "base_rev": 140.0, "rev_mult": 1.13, "max_level": 50},
	"table_11": {"base_cost": 650.0, "cost_mult": 1.20, "base_rev": 140.0, "rev_mult": 1.13, "max_level": 50},
	"table_12": {"base_cost": 650.0, "cost_mult": 1.20, "base_rev": 140.0, "rev_mult": 1.13, "max_level": 50},
	"kitchen_cook": {"base_cost": 80.0, "cost_mult": 1.16, "base_rev": 15.0, "rev_mult": 1.12, "max_level": 50},
	"stove": {"base_cost": 80.0, "cost_mult": 1.16, "base_rev": 15.0, "rev_mult": 1.12, "max_level": 50},
	"milkshake_bar": {"base_cost": 250.0, "cost_mult": 1.17, "base_rev": 45.0, "rev_mult": 1.12, "max_level": 50},
	"parking_lot": {"base_cost": 180.0, "cost_mult": 1.19, "base_rev": 25.0, "rev_mult": 1.08, "spawn_rate_per_level": 0.15, "max_level": 25},
	"parking": {"base_cost": 180.0, "cost_mult": 1.19, "base_rev": 25.0, "rev_mult": 1.08, "spawn_rate_per_level": 0.15, "max_level": 25},
	"milkshake_blender": {"base_cost": 180.0, "cost_mult": 1.16, "base_rev": 30.0, "rev_mult": 1.11, "max_level": 50},
	"jukebox": {"base_cost": 150.0, "cost_mult": 1.15, "base_rev": 20.0, "rev_mult": 1.10, "max_level": 50},
	"host_desk": {"base_cost": 100.0, "cost_mult": 1.15, "base_rev": 15.0, "rev_mult": 1.10, "max_level": 50},
}

# ─── Station Levels ────────────────────────────────────────────────────────
var station_levels: Dictionary = {
	"kitchen_cook": 1,
	"stove": 1,
	"table_1": 1,
	"table_2": 1,
	"table_3": 1,
	"table_4": 1,
	"table_5": 1,
	"table_6": 1,
	"table_7": 1,
	"table_8": 1,
	"table_9": 1,
	"table_10": 1,
	"table_11": 1,
	"table_12": 1,
	"host_desk": 1,
	"milkshake_bar": 1,
	"milkshake_blender": 1,
	"jukebox": 1,
	"parking_lot": 1,
	"parking": 1,
}

var max_level: int = 50

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
		"category": "floor",
		"hired": true,
		"hire_cost": 0.0,
		"level": 1,
		"desc": "Frontline banquet server. Upgrading boosts floor run speed and carrying capacity."
	},
	"waiter_2": {
		"id": "waiter_2",
		"name": "Sophia (Speed Runner)",
		"role": "waiter",
		"category": "floor",
		"hired": true,
		"hire_cost": 250.0,
		"level": 1,
		"desc": "High-speed runner doubling dining room throughput and table turn speed."
	},
	"waiter_3": {
		"id": "waiter_3",
		"name": "Lucas (VIP Concierge)",
		"role": "waiter",
		"category": "floor",
		"hired": false,
		"hire_cost": 500.0,
		"level": 1,
		"desc": "Dedicated concierge expediting multi-dish orders for VIP critics and window booths."
	},
	"waiter_4": {
		"id": "waiter_4",
		"name": "Elena (Banquet Server)",
		"role": "waiter",
		"category": "floor",
		"hired": false,
		"hire_cost": 850.0,
		"level": 1,
		"desc": "Master server carrying up to 3 plates per run for rapid multi-table turnover."
	},
	"chef_stove": {
		"id": "chef_stove",
		"name": "Gordon (Master Range)",
		"role": "chef",
		"category": "kitchen",
		"hired": true,
		"hire_cost": 0.0,
		"level": 1,
		"desc": "Culinary virtuoso managing hot stove sautés & flame broiling at Stove 1."
	},
	"chef_prep": {
		"id": "chef_prep",
		"name": "Pierre (Prep Artisan)",
		"role": "chef",
		"category": "kitchen",
		"hired": true,
		"hire_cost": 0.0,
		"level": 1,
		"desc": "Knife master at the central prep table cutting fresh vegetables & starters."
	},
	"chef_sous": {
		"id": "chef_sous",
		"name": "Antoine (Sous Chef)",
		"role": "chef",
		"category": "kitchen",
		"hired": false,
		"hire_cost": 350.0,
		"level": 1,
		"desc": "Expedites hot pass dishes and coordinates kitchen line output by +40%."
	},
	"chef_pastry": {
		"id": "chef_pastry",
		"name": "Marcel (Pastry & Bakery)",
		"role": "chef",
		"category": "kitchen",
		"hired": false,
		"hire_cost": 550.0,
		"level": 1,
		"desc": "Bakes artisanal breads and desserts, boosting meal earnings by +25%."
	},
	"hostess": {
		"id": "hostess",
		"name": "Chloe (Reception Hostess)",
		"role": "hostess",
		"category": "service",
		"hired": true,
		"hire_cost": 0.0,
		"level": 1,
		"desc": "Welcomes arriving patrons at the podium, boosting guest patience by +35%."
	},
	"bartender": {
		"id": "bartender",
		"name": "Leo (Lounge Mixologist)",
		"role": "bartender",
		"category": "service",
		"hired": true,
		"hire_cost": 200.0,
		"level": 1,
		"desc": "Crafts shaken cocktails & pours vintage wines at the mahogany bar counter."
	},
	"barista": {
		"id": "barista",
		"name": "Penny (Diner Barista)",
		"role": "barista",
		"category": "service",
		"hired": true,
		"hire_cost": 250.0,
		"level": 1,
		"desc": "Blends malted shakes and dishes ice cream sundaes at the 50s Diner fountain."
	},
	"janitor": {
		"id": "janitor",
		"name": "Otis (Head Custodian)",
		"role": "janitor",
		"category": "facility",
		"hired": true,
		"hire_cost": 300.0,
		"level": 1,
		"desc": "Sweeps dining aisles, wipes down tables, and keeps the restaurant spotless."
	},
	"manager": {
		"id": "manager",
		"name": "Arthur (General Manager)",
		"role": "manager",
		"category": "management",
		"hired": false,
		"hire_cost": 750.0,
		"level": 1,
		"desc": "Stationed in executive office. Triggers inspection tours that boost all stations +25%!"
	}
}

# ─── Quests / Milestones ────────────────────────────────────────────────────
var active_quests: Array = [
	{
		"id": "serve_customers",
		"title": "Welcome Hungry Guests",
		"desc": "Serve delicious meals to patrons",
		"icon": "🍽️",
		"current": 0,
		"target": 5,
		"reward_cash": 200.0,
		"reward_gems": 5,
		"claimed": false
	},
	{
		"id": "upgrade_stations",
		"title": "Expand Dining Floor",
		"desc": "Upgrade dining tables or kitchen stove",
		"icon": "🔨",
		"current": 0,
		"target": 3,
		"reward_cash": 280.0,
		"reward_gems": 8,
		"claimed": false
	},
	{
		"id": "unlock_recipe",
		"title": "Culinary Innovation",
		"desc": "Unlock a new recipe in the Menu book",
		"icon": "📖",
		"current": 0,
		"target": 1,
		"reward_cash": 420.0,
		"reward_gems": 12,
		"claimed": false
	},
	{
		"id": "earn_cash",
		"title": "Tycoon Revenue Goal",
		"desc": "Earn cash through dining service",
		"icon": "💵",
		"current": 0,
		"target": 600,
		"reward_cash": 320.0,
		"reward_gems": 10,
		"claimed": false
	}
]

# ─── Marketing Campaigns ────────────────────────────────────────────────────
var campaigns: Dictionary = {
	"flyers": {
		"id": "flyers",
		"name": "Street Flyers",
		"desc": "+50% Faster customer walk-in frequency",
		"icon": "📜",
		"cost": 120.0,
		"duration": 60.0,
		"time_left": 0.0
	},
	"social_ad": {
		"id": "social_ad",
		"name": "Foodie Instagram Ad",
		"desc": "+35% Higher dish revenue on every order",
		"icon": "📱",
		"cost": 250.0,
		"duration": 60.0,
		"time_left": 0.0
	},
	"radio_spot": {
		"id": "radio_spot",
		"name": "Radio Food Spotlight",
		"desc": "+50% Customer patience & double critic visits",
		"icon": "📻",
		"cost": 450.0,
		"duration": 75.0,
		"time_left": 0.0
	}
}

const SAVE_PATH: String = "user://restaurant_save.json"
var autosave_timer: float = 0.0

func _ready() -> void:
	load_game()
	if preview_all_max_levels:
		set_all_stations_max_level(true)
	level_updated.emit(restaurant_level, restaurant_xp, xp_to_next_level)

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
		"restaurant_level": restaurant_level,
		"restaurant_xp": restaurant_xp,
		"unlocked_stalls": unlocked_stalls,
		"terrace_unlocked": terrace_unlocked,
		"unlocked_tables": unlocked_tables,
		"station_levels": station_levels,
		"menu_items": menu_items,
		"staff_roster": staff_roster,
		"active_quests": active_quests,
		"active_restaurant_id": active_restaurant_id,
		"cash_per_sec": cash_per_sec,
		"world_restaurants_unlocked": {
			"idle_diner": world_restaurants["idle_diner"].get("unlocked", true),
			"idles_chain": world_restaurants["idles_chain"].get("unlocked", false),
			"snowy_peaks": world_restaurants["snowy_peaks"].get("unlocked", false),
			"taverna_athena": world_restaurants["taverna_athena"].get("unlocked", false),
			"noodle_palace": world_restaurants["noodle_palace"].get("unlocked", false),
			"sakura_springs": world_restaurants["sakura_springs"].get("unlocked", false),
		},
		"saved_timestamp": Time.get_unix_time_from_system()
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
	restaurant_level = parsed.get("restaurant_level", restaurant_level)
	restaurant_xp = parsed.get("restaurant_xp", restaurant_xp)
	unlocked_stalls = int(parsed.get("unlocked_stalls", unlocked_stalls))
	terrace_unlocked = bool(parsed.get("terrace_unlocked", terrace_unlocked))
	xp_to_next_level = 250.0 * pow(1.35, restaurant_level - 1)
	cash_per_sec = float(parsed.get("cash_per_sec", cash_per_sec))
	
	active_restaurant_id = parsed.get("active_restaurant_id", active_restaurant_id)
	var unlocked_map = parsed.get("world_restaurants_unlocked", {})
	if typeof(unlocked_map) == TYPE_DICTIONARY:
		for k in unlocked_map:
			if world_restaurants.has(k):
				world_restaurants[k]["unlocked"] = bool(unlocked_map[k])

	var last_ts = float(parsed.get("saved_timestamp", 0.0))
	if last_ts > 0.0:
		var now = Time.get_unix_time_from_system()
		var elapsed = max(0.0, now - last_ts)
		if elapsed >= 30.0:
			var capped = min(elapsed, 28800.0) # Up to 8 hours (28,800s)
			var effective_rate = get_effective_cash_per_sec()
			var earned = round(capped * effective_rate * 0.85) # Reference formula
			if earned >= 10.0:
				pending_offline_earnings = earned
				call_deferred("_notify_offline_earnings", earned, capped)

	if parsed.has("unlocked_tables") and typeof(parsed["unlocked_tables"]) == TYPE_DICTIONARY:
		for k in parsed["unlocked_tables"].keys():
			unlocked_tables[k] = parsed["unlocked_tables"][k]

	if parsed.has("station_levels") and typeof(parsed["station_levels"]) == TYPE_DICTIONARY:
		for k in parsed["station_levels"].keys():
			station_levels[k] = int(parsed["station_levels"][k])

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
					
	if parsed.has("active_quests") and typeof(parsed["active_quests"]) == TYPE_ARRAY:
		for q in parsed["active_quests"]:
			for existing in active_quests:
				if existing.get("id") == q.get("id"):
					existing["current"] = q.get("current", existing["current"])
					existing["target"] = q.get("target", existing["target"])
					existing["reward_cash"] = q.get("reward_cash", existing["reward_cash"])
					existing["reward_gems"] = q.get("reward_gems", existing["reward_gems"])
					existing["claimed"] = q.get("claimed", existing["claimed"])

func _notify_offline_earnings(earned: float, elapsed: float) -> void:
	await get_tree().create_timer(0.6).timeout
	offline_earnings_available.emit(earned, elapsed)

func claim_offline_earnings(multiplier: float = 1.0) -> float:
	var payout = pending_offline_earnings * multiplier
	pending_offline_earnings = 0.0
	add_cash(payout)
	save_game()
	return payout

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

	# Update marketing campaigns
	for camp_id in campaigns.keys():
		var c = campaigns[camp_id]
		if c.time_left > 0.0:
			c.time_left -= delta
			if c.time_left <= 0.0:
				c.time_left = 0.0
				campaign_updated.emit(camp_id, false, 0.0)
			else:
				campaign_updated.emit(camp_id, true, c.time_left)

	# Calculate rolling cash per second
	var now = Time.get_ticks_msec()
	recent_earnings = recent_earnings.filter(func(item): return (now - item[0]) < 8000)
	var sum: float = 0.0
	for item in recent_earnings:
		sum += item[1]
	var target_rate: float = sum / 8.0
	cash_per_sec = lerp(cash_per_sec, target_rate, delta * 3.5)
	
	rate_update_timer += delta
	if rate_update_timer >= 0.35:
		rate_update_timer = 0.0
		cash_rate_updated.emit(cash_per_sec)

func toggle_boost() -> void:
	is_boosted = not is_boosted
	if is_boosted:
		boost_timer = 60.0
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade", 0.1, 2.0)
	boost_toggled.emit(is_boosted)

func add_cash(amount: float, world_pos: Vector3 = Vector3.ZERO) -> void:
	var rest_mult: float = get_active_revenue_multiplier()
	var final_amount: float = amount * (2.0 if is_boosted else 1.0) * rest_mult
	cash += final_amount
	total_earned += final_amount
	
	recent_earnings.append([Time.get_ticks_msec(), final_amount])
	add_xp(final_amount * 0.15)
	_progress_quest("earn_cash", int(final_amount))
	
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

func add_gems(amount: int) -> void:
	gems += amount
	gems_changed.emit(gems)
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("claim")

func spend_gems(amount: int) -> bool:
	if gems >= amount:
		gems -= amount
		gems_changed.emit(gems)
		return true
	return false

func add_boost_time(seconds: float) -> void:
	is_boosted = true
	boost_timer = max(boost_timer, 0.0) + seconds
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("upgrade", 0.1, 2.0)
	boost_toggled.emit(true)

func can_claim_daily_gift() -> bool:
	return not daily_gift_claimed

func claim_daily_gift() -> bool:
	if daily_gift_claimed:
		return false
	daily_gift_claimed = true
	add_cash(250.0)
	add_gems(5)
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("claim")
	return true

func buy_shop_item(item_id: String) -> bool:
	match item_id:
		"daily_gift":
			return claim_daily_gift()
		"cash_small":
			if spend_gems(10):
				add_cash(500.0)
				return true
		"cash_medium":
			if spend_gems(40):
				add_cash(2500.0)
				return true
		"cash_vault":
			if spend_gems(120):
				add_cash(10000.0)
				return true
		"boost_5m":
			if spend_gems(15):
				add_boost_time(300.0)
				return true
		"boost_15m":
			if spend_gems(35):
				add_boost_time(900.0)
				return true
		"buy_gems":
			if spend_cash(1000.0):
				add_gems(50)
				return true
	return false

func add_xp(amount: float) -> void:
	restaurant_xp += amount
	while restaurant_xp >= xp_to_next_level:
		restaurant_xp -= xp_to_next_level
		restaurant_level += 1
		xp_to_next_level = round(250.0 * pow(1.35, restaurant_level - 1))
		star_rating = min(5.0, star_rating + 0.05)
		reputation_changed.emit(round(star_rating * 10))
		add_gems(5)
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade", 0.0, 3.5)
	level_updated.emit(restaurant_level, restaurant_xp, xp_to_next_level)

# ─── Multiplier Station Upgrades ────────────────────────────────────────────
func get_station_config(station_id: String) -> Dictionary:
	var sid = station_id
	if sid == "kitchen_cook" or sid == "stove":
		return STATION_CONFIGS["kitchen_cook"]
	if sid == "parking" or sid == "parking_lot":
		return STATION_CONFIGS["parking_lot"]
	if STATION_CONFIGS.has(sid):
		return STATION_CONFIGS[sid]
	return {"base_cost": 50.0, "cost_mult": 1.15, "base_rev": 15.0, "rev_mult": 1.10, "max_level": 50}

func get_station_max_level(station_id: String) -> int:
	return int(get_station_config(station_id).get("max_level", 50))

func get_station_level(station_id: String) -> int:
	var sid = station_id
	if sid == "kitchen_cook" and not station_levels.has("kitchen_cook"):
		return station_levels.get("stove", 1)
	if sid == "stove" and not station_levels.has("stove"):
		return station_levels.get("kitchen_cook", 1)
	if sid == "parking" and not station_levels.has("parking"):
		return station_levels.get("parking_lot", 1)
	if sid == "parking_lot" and not station_levels.has("parking_lot"):
		return station_levels.get("parking", 1)
	return station_levels.get(sid, 1)

# Formula: Cost = BaseCost * CostMultiplier^(L - 1)
func get_upgrade_cost(station_id: String) -> float:
	var lvl: int = get_station_level(station_id)
	var cfg = get_station_config(station_id)
	var station_max = int(cfg.get("max_level", 50))
	if lvl >= station_max:
		return 0.0
	return round(cfg.base_cost * pow(cfg.cost_mult, lvl - 1))

# Formula: Revenue = BaseRevenue * RevenueMultiplier^(L - 1)
func get_station_income(station_id: String) -> float:
	var lvl: int = get_station_level(station_id)
	var cfg = get_station_config(station_id)
	var rev: float = round(cfg.base_rev * pow(cfg.rev_mult, lvl - 1))
	if has_method("get_manager_efficiency_multiplier"):
		rev *= get_manager_efficiency_multiplier()
	return round(rev)

func get_upgrade_multi_info(station_id: String, mode: String) -> Dictionary:
	var current_lvl: int = get_station_level(station_id)
	var station_max: int = get_station_max_level(station_id)
	var max_avail: int = station_max - current_lvl
	if max_avail <= 0:
		return {"cost": 0.0, "levels": 0, "can_afford": false}
	
	var target_levels: int = 1
	if mode == "10":
		target_levels = min(10, max_avail)
	elif mode == "MAX":
		target_levels = max_avail
		
	var cfg = get_station_config(station_id)
	var total_cost: float = 0.0
	var affordable_levels: int = 0
	var temp_lvl = current_lvl
	
	for i in range(target_levels):
		var c = round(cfg.base_cost * pow(cfg.cost_mult, temp_lvl - 1))
		if mode == "MAX":
			if cash >= total_cost + c:
				total_cost += c
				affordable_levels += 1
				temp_lvl += 1
			else:
				break
		else:
			total_cost += c
			affordable_levels += 1
			temp_lvl += 1
			
	if mode == "MAX" and affordable_levels == 0:
		total_cost = round(cfg.base_cost * pow(cfg.cost_mult, current_lvl - 1))
		return {"cost": total_cost, "levels": 1, "can_afford": cash >= total_cost}
		
	return {"cost": total_cost, "levels": affordable_levels, "can_afford": cash >= total_cost and affordable_levels > 0}

func upgrade_station_multi(station_id: String, mode: String) -> bool:
	var info = get_upgrade_multi_info(station_id, mode)
	if info.can_afford and spend_cash(info.cost):
		var current_lvl = get_station_level(station_id)
		var new_lvl = current_lvl + info.levels
		station_levels[station_id] = new_lvl
		if station_id == "stove":
			station_levels["kitchen_cook"] = new_lvl
		elif station_id == "kitchen_cook":
			station_levels["stove"] = new_lvl
		elif station_id == "parking":
			station_levels["parking_lot"] = new_lvl
		elif station_id == "parking_lot":
			station_levels["parking"] = new_lvl
		station_upgraded.emit(station_id, new_lvl)
		add_xp(info.cost * 0.25)
		_progress_quest("upgrade_stations", info.levels)
		save_game()
		
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade")
		return true
	return false

func upgrade_station(station_id: String) -> bool:
	return upgrade_station_multi(station_id, "1")

func get_effective_cash_per_sec() -> float:
	if cash_per_sec >= 1.0:
		return cash_per_sec
	var total_sec_rev: float = 0.0
	for i in range(1, 13):
		var tid = "table_%d" % i
		if is_table_unlocked(tid):
			var inc = get_station_income(tid)
			total_sec_rev += (inc / 12.0)
	total_sec_rev += get_station_income("kitchen_cook") / 6.0
	total_sec_rev += get_station_income("milkshake_bar") / 8.0
	return max(total_sec_rev, 14.0)

func set_all_stations_max_level(enable: bool = true) -> void:
	for sid in STATION_CONFIGS.keys():
		var max_lvl = get_station_max_level(sid)
		station_levels[sid] = max_lvl if enable else 1
		station_upgraded.emit(sid, station_levels[sid])
	if enable:
		terrace_unlocked = true
		unlocked_tables["table_10"] = true
		unlocked_tables["table_11"] = true
		unlocked_tables["table_12"] = true
		unlocked_stalls = 5
	save_game()

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
		add_xp(cost * 0.3)
		_progress_quest("upgrade_stations", 1)
		save_game()
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade", 0.0, 3.0)
		return true
	return false

func is_terrace_unlocked() -> bool:
	return terrace_unlocked

func unlock_terrace() -> bool:
	if terrace_unlocked:
		return true
	if spend_cash(TERRACE_UNLOCK_COST):
		terrace_unlocked = true
		unlocked_tables["table_10"] = true
		unlocked_tables["table_11"] = true
		unlocked_tables["table_12"] = true
		table_unlocked.emit("table_10")
		table_unlocked.emit("table_11")
		table_unlocked.emit("table_12")
		terrace_unlocked_changed.emit(true)
		add_xp(200.0)
		save_game()
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade", 0.0, 3.5)
		return true
	return false

func is_stall_unlocked(idx: int) -> bool:
	return idx <= unlocked_stalls

func get_stall_unlock_cost(idx: int) -> float:
	return 220.0 if idx == 3 else 480.0

func unlock_parking_stall(idx: int) -> bool:
	if is_stall_unlocked(idx):
		return true
	var cost = get_stall_unlock_cost(idx)
	if spend_cash(cost):
		unlocked_stalls = idx
		stall_unlocked.emit(idx)
		add_xp(120.0)
		save_game()
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade", 0.0, 2.5)
		return true
	return false

func award_critic_review(is_positive: bool, bounty: float = 0.0) -> void:
	if is_positive:
		star_rating = min(5.0, star_rating + 0.1)
		reputation_changed.emit(round(star_rating * 10))
		add_xp(120.0)
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
		var tnum = int(station_id.trim_prefix("table_"))
		if tnum >= 10:
			if lvl >= 10:
				return "👑 TIER 3 • SUNSET TERRACE CABANA"
			elif lvl >= 5:
				return "★ TIER 2 • SUNNY PATIO UMBRELLA"
			else:
				return "🌿 TIER 1 • OUTDOOR GARDEN TABLE"
		else:
			if lvl >= 10:
				return "👑 TIER 3 • LUXURY LEATHER QUAD-BOOTH"
			elif lvl >= 5:
				return "★ TIER 2 • RETRO DINER QUAD-BOOTH"
			else:
				return "🪑 TIER 1 • CLASSIC CRIMSON BOOTH"
	elif station_id.begins_with("stove"):
		if lvl >= 10:
			return "👑 TIER 3 • MASTER CHEF SUITE"
		elif lvl >= 5:
			return "★ TIER 2 • COMMERCIAL DOUBLE RANGE"
		else:
			return "🍳 TIER 1 • LINE COOK RANGE"
	elif station_id == "milkshake_bar":
		if lvl >= 10:
			return "👑 TIER 3 • NEON CHROME SODA FOUNTAIN"
		elif lvl >= 5:
			return "★ TIER 2 • RETRO DINER COUNTER"
		else:
			return "🥤 TIER 1 • CLASSIC MILKSHAKE BAR"
	elif station_id == "milkshake_blender":
		if lvl >= 10:
			return "👑 TIER 3 • TURBO FROZEN DESSERT SUITE"
		elif lvl >= 5:
			return "★ TIER 2 • COMMERCIAL TRIPLE BLENDER"
		else:
			return "🍨 TIER 1 • VINTAGE MILKSHAKE MIXER"
	elif station_id == "jukebox":
		if lvl >= 10:
			return "👑 TIER 3 • GOLD RECORD JUKEBOX"
		elif lvl >= 5:
			return "★ TIER 2 • ILLUMINATED VINYL JUKEBOX"
		else:
			return "🎵 TIER 1 • RETRO 1950s JUKEBOX"
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
	elif station_id == "milkshake_bar":
		if lvl < 5:
			return "Next: Lv. 5 unlocks Polished Chrome Stools & Frappe Glasses"
		elif lvl < 10:
			return "Next: Lv. 10 unlocks Gold Neon Glow & Luxury Shakes (+50% rev)"
		else:
			return "MAX TIER UNLOCKED • Peak Milkshake Bar Prestige!"
	elif station_id == "milkshake_blender":
		if lvl < 5:
			return "Next: Lv. 5 unlocks Triple Speed Whipped Cream & Cherries"
		elif lvl < 10:
			return "Next: Lv. 10 unlocks Gourmet Sundae Extravaganza (+75% speed)"
		else:
			return "MAX TIER UNLOCKED • Instant Dessert Preparation!"
	elif station_id == "jukebox":
		if lvl < 5:
			return "Next: Lv. 5 unlocks +15% Customer Patience & Rockabilly Hits"
		elif lvl < 10:
			return "Next: Lv. 10 unlocks +30% Tip Multiplier & Golden Glow"
		else:
			return "MAX TIER UNLOCKED • Legendary Soundtrack Prestige!"
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
		add_xp(cost * 0.35)
		_progress_quest("unlock_recipe", 1)
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
	elif staff_id == "manager":
		base_cost = 260.0
	elif staff_id in ["waiter_3", "waiter_4"]:
		base_cost = 150.0
	elif staff_id in ["bartender", "barista"]:
		base_cost = 120.0
	elif staff_id == "janitor":
		base_cost = 100.0
	return round(base_cost * pow(1.25, lvl - 1))

func get_staff_speed_multiplier(staff_id: String) -> float:
	var lvl = get_staff_level(staff_id)
	return 1.0 + (lvl - 1) * 0.15

func get_staff_cooking_multiplier(staff_id: String) -> float:
	var lvl = get_staff_level(staff_id)
	return 1.0 + (lvl - 1) * 0.20

func get_staff_serving_multiplier(staff_id: String) -> float:
	var lvl = get_staff_level(staff_id)
	return 1.0 + (lvl - 1) * 0.18

func get_staff_capacity(staff_id: String) -> int:
	var lvl = get_staff_level(staff_id)
	var cap = 1 + int(floor(float(lvl - 1) / 3.0))
	if staff_id == "waiter_4":
		cap += 1
	return clamp(cap, 1, 4)

func get_manager_efficiency_multiplier() -> float:
	if not is_staff_hired("manager"):
		return 1.0
	var lvl = get_staff_level("manager")
	var mult = 1.0 + (lvl - 1) * 0.08
	if is_manager_inspection_active:
		mult += 0.25
	return mult

func set_manager_inspection_active(active: bool) -> void:
	if is_manager_inspection_active != active:
		is_manager_inspection_active = active
		manager_inspection_changed.emit(active)

func hire_staff(staff_id: String) -> bool:
	if not staff_roster.has(staff_id):
		return false
	var st = staff_roster[staff_id]
	if st.get("hired", false):
		return true
	var cost = st.get("hire_cost", 200.0)
	if spend_cash(cost):
		st["hired"] = true
		add_xp(cost * 0.3)
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
		add_xp(cost * 0.25)
		staff_updated.emit(staff_id)
		save_game()
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade")
		return true
	return false

# ─── Quests & Milestones ────────────────────────────────────────────────────
func _progress_quest(quest_id: String, amount: int = 1) -> void:
	for q in active_quests:
		if q.get("id") == quest_id and not q.get("claimed", false):
			q["current"] = min(q.get("target", 1), q.get("current", 0) + amount)
			quests_updated.emit()

func record_customer_served() -> void:
	_progress_quest("serve_customers", 1)

func claim_quest(quest_id: String) -> bool:
	for q in active_quests:
		if q.get("id") == quest_id and q.get("current", 0) >= q.get("target", 1) and not q.get("claimed", false):
			var r_cash = q.get("reward_cash", 100.0)
			var r_gems = q.get("reward_gems", 5)
			add_cash(r_cash)
			add_gems(r_gems)
			
			# Scale up next milestone goal
			q["current"] = 0
			q["target"] = round(q.get("target", 1) * 1.8) + 2
			q["reward_cash"] = round(r_cash * 1.6)
			q["reward_gems"] = r_gems + 5
			quests_updated.emit()
			save_game()
			return true
	return false

# ─── Marketing Campaigns ────────────────────────────────────────────────────
func start_campaign(camp_id: String) -> bool:
	if not campaigns.has(camp_id):
		return false
	var c = campaigns[camp_id]
	if c.time_left > 0.0:
		return false # already active
	if spend_cash(c.cost):
		c.time_left = c.duration
		campaign_updated.emit(camp_id, true, c.time_left)
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade", 0.0, 2.5)
		return true
	return false

func is_campaign_active(camp_id: String) -> bool:
	return campaigns.get(camp_id, {}).get("time_left", 0.0) > 0.0

func get_spawn_rate_multiplier() -> float:
	var park_lvl = get_station_level("parking_lot")
	var park_bonus = 1.0 + (park_lvl - 1) * 0.15
	var flyer_bonus = 1.6 if is_campaign_active("flyers") else 1.0
	return park_bonus * flyer_bonus

func get_dish_price_multiplier() -> float:
	return 1.35 if is_campaign_active("social_ad") else 1.0

func get_patience_multiplier() -> float:
	return 1.5 if is_campaign_active("radio_spot") else 1.0

# ─── World Map Restaurants API ──────────────────────────────────────────────
func get_world_restaurants() -> Dictionary:
	return world_restaurants

func get_active_revenue_multiplier() -> float:
	return world_restaurants.get(active_restaurant_id, {}).get("multiplier", 1.0)

func unlock_world_restaurant(rest_id: String) -> bool:
	if not world_restaurants.has(rest_id):
		return false
	var info = world_restaurants[rest_id]
	if info.get("unlocked", false):
		return true
	var cost = float(info.get("cost", 0.0))
	if not spend_cash(cost):
		return false
	info["unlocked"] = true
	world_restaurants_updated.emit()
	save_game()
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("upgrade", 0.0, 3.5)
	return true

func switch_to_restaurant(rest_id: String) -> bool:
	if not world_restaurants.has(rest_id):
		return false
	var info = world_restaurants[rest_id]
	if not info.get("unlocked", false):
		return false
	active_restaurant_id = rest_id
	restaurant_name = info.get("name", "Idle Diner")
	world_restaurants_updated.emit()
	level_updated.emit(restaurant_level, restaurant_xp, xp_to_next_level)
	save_game()
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("coin", 0.05)
	return true
