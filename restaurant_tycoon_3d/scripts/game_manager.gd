extends Node

# ─── Signals ────────────────────────────────────────────────────────────────
signal cash_changed(new_amount: float)
signal gems_changed(new_amount: int)
signal diamonds_changed(new_amount: int)
signal golden_coins_changed(new_amount: int)
signal energy_changed(new_amount: int)
signal currencies_updated(cash: float, golden_coins: int, diamonds: int, energy: int)
signal cash_rate_updated(rate: float)
signal level_updated(new_level: int, current_xp: float, target_xp: float)
signal reputation_changed(new_rep: int)
signal station_upgraded(station_id: String, new_level: int)
signal spawn_floating_cash(amount: float, world_pos: Vector3)
signal spawn_flying_currency_trail(world_pos: Vector3, amount: float, currency_type: String)
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
signal marketing_upgraded(new_level: int)
signal marketing_changed()
signal vip_investor_awarded(amount: float)
signal perks_updated()
signal shop_updated()
signal vip_arrived(vip_node: Node3D, title: String, type: String, duration: float)
signal time_skip_activated(hours: int, cash_amount: float)
signal overdrive_boost_activated(multiplier: float, duration: float)
signal chest_opened(chest_type: String, rewards: Dictionary)
signal card_updated(card_id: String, level: int, count: int)
signal cards_updated()
signal station_milestone_reached(station_id: String, milestone_lvl: int, bonus_diamonds: int, bonus_golden_coins: int)
signal objective_updated(objective: Dictionary)
signal objective_claimed(rewards: Dictionary)
signal spin_wheel_completed(slice_index: int, prize: Dictionary)
signal daily_login_claimed(day: int, reward: Dictionary)
signal cleanliness_updated(new_cleanliness: float)
signal rapid_sanitation_triggered(cost_deducted: float)
signal rush_hour_changed(active: bool, time_left: float)
signal franchise_prestiged(prestige_level: int, keys_earned: int, diamonds_earned: int)
signal franchise_keys_changed(new_amount: int)
signal prestige_updated(prestige_level: int, franchise_keys: int, multiplier: float)
signal valuation_updated(new_valuation: float)
signal manager_skill_activated(sector_id: String)
signal manager_skill_ended(sector_id: String)
signal manager_skill_ready(sector_id: String)
signal manager_assigned(sector_id: String, tier: String)
signal star_dish_unlocked(star_tier: int, dish_info: Dictionary)
signal piggy_bank_updated(current: int, max_cap: int)
signal investor_offer_requested(investor_node: Node3D, cash_amount: float, diamond_amount: int)
signal fever_meter_updated(current: float, max_val: float, is_active: bool)
signal fever_mode_changed(active: bool, time_left: float)

var restaurant_node: Node3D = null

# ─── Kolibri Games Sector Manager Active Skills ─────────────────────────────
var sector_managers: Dictionary = {
	"kitchen": {
		"sector_id": "kitchen",
		"sector_name": "Commercial Kitchen",
		"assigned": true,
		"tier": "senior",
		"manager_name": "Chef Marcus",
		"skill_id": "cooking_speed_2x",
		"skill_name": "2x Cooking Speed",
		"skill_desc": "All kitchen chefs prepare orders twice as fast.",
		"skill_icon": "🍳",
		"is_active": false,
		"active_timer": 0.0,
		"cooldown_timer": 0.0,
		"active_duration": 60.0,
		"cooldown_duration": 300.0,
	},
	"dining": {
		"sector_id": "dining",
		"sector_name": "Main Dining Hall",
		"assigned": true,
		"tier": "executive",
		"manager_name": "Maître Valerie",
		"skill_id": "instant_table_clean",
		"skill_name": "Instant Table Clean",
		"skill_desc": "Immediately wipes all dirty tables and accelerates bussing.",
		"skill_icon": "🧽",
		"is_active": false,
		"active_timer": 0.0,
		"cooldown_timer": 0.0,
		"active_duration": 60.0,
		"cooldown_duration": 300.0,
	},
	"milkshake": {
		"sector_id": "milkshake",
		"sector_name": "50s Milkshake Cafe",
		"assigned": true,
		"tier": "junior",
		"manager_name": "Supervisor Dex",
		"skill_id": "upgrade_cost_discount",
		"skill_name": "-30% Upgrade Cost",
		"skill_desc": "Grants a 30% discount across all station and furniture upgrades.",
		"skill_icon": "🏷️",
		"is_active": false,
		"active_timer": 0.0,
		"cooldown_timer": 0.0,
		"active_duration": 60.0,
		"cooldown_duration": 300.0,
	},
	"lounge": {
		"sector_id": "lounge",
		"sector_name": "Cocktail Lounge",
		"assigned": true,
		"tier": "senior",
		"manager_name": "Director Evelyn",
		"skill_id": "walk_speed_boost",
		"skill_name": "+100% Walk Speed",
		"skill_desc": "Waiters and servers sprint at +100% walk speed.",
		"skill_icon": "👟",
		"is_active": false,
		"active_timer": 0.0,
		"cooldown_timer": 0.0,
		"active_duration": 60.0,
		"cooldown_duration": 300.0,
	}
}

# ─── Developer Debug & Presets ──────────────────────────────────────────────
@export var preview_all_max_levels: bool = false:
	set(val):
		preview_all_max_levels = val
		if preview_all_max_levels and is_inside_tree():
			set_all_stations_max_level(true)

var skip_boot_splash: bool = false

# ─── Economy State ──────────────────────────────────────────────────────────
var cash: float = 650.0
var golden_coins: int = 150
var diamonds: int = 50
var gems: int:
	get:
		return diamonds
	set(val):
		diamonds = val
var energy: int = 50
var max_energy: int = 50
var energy_regen_timer: float = 0.0
var total_earned: float = 0.0
var pending_offline_earnings: float = 0.0
var star_rating: float = 5.0
var cleanliness: float = 100.0
var restaurant_name: String = "Idle Diner"
var is_boosted: bool = false
var boost_timer: float = 0.0
var boost_multiplier: float = 2.0
var is_manager_inspection_active: bool = false
var daily_gift_claimed: bool = false
var unlocked_star_tiers: Array = [1]
var claimed_star_rewards: Array = []
const PIGGY_BANK_CAP: int = 250
var piggy_bank_diamonds: int = 0

# ─── Diner Fever Combo State ────────────────────────────────────────────────
var fever_charge: float = 0.0
var fever_max_charge: float = 100.0
var is_fever_active: bool = false
var fever_timer: float = 0.0
const FEVER_DURATION: float = 20.0

# ─── Play Store Star Rating Signature Dishes ────────────────────────────────
const STAR_DISH_TIERS: Dictionary = {
	1: {
		"id": "burger",
		"star": 1,
		"name": "Classic Diner Burger & Fries",
		"icon": "🍔",
		"price": 45.0,
		"multiplier": 1.0,
		"models": ["res://assets/models/food/burger.glb", "res://assets/models/food/fries.glb"],
		"primary_model": "res://assets/models/food/burger-cheese.glb",
		"desc": "Crispy golden french fries paired with a fire-grilled beef patty on toasted brioche."
	},
	2: {
		"id": "sundae",
		"star": 2,
		"name": "Retro Strawberry Sundae & Frappe",
		"icon": "🍨",
		"price": 120.0,
		"multiplier": 2.5,
		"models": ["res://assets/models/food/sundae.glb", "res://assets/models/food/frappe.glb"],
		"primary_model": "res://assets/models/food/sundae.glb",
		"desc": "Double strawberry sundae with whipped cream, cherry, and an icy retro diner frappe."
	},
	3: {
		"id": "steak_platter",
		"star": 3,
		"name": "Double Cheese Steak Platter",
		"icon": "🥩",
		"price": 280.0,
		"multiplier": 4.0,
		"models": ["res://assets/models/food/meat-cooked.glb", "res://assets/models/food/cheese.glb"],
		"primary_model": "res://assets/models/food/meat-cooked.glb",
		"desc": "Thick sizzling seared ribeye platter smothered in melted double Wisconsin cheddar."
	},
	4: {
		"id": "cocktail_tapas",
		"star": 4,
		"name": "Artisan Cocktail & Tapas Combo",
		"icon": "🍸",
		"price": 650.0,
		"multiplier": 6.5,
		"models": ["res://assets/models/food/cocktail.glb", "res://assets/models/food/taco.glb"],
		"primary_model": "res://assets/models/food/cocktail.glb",
		"desc": "Handcrafted botanical cocktail paired with crunchy artisan tapas bites."
	},
	5: {
		"id": "michelin_feast",
		"star": 5,
		"name": "Golden Michelin Lobster & Ribeye Feast",
		"icon": "🦞",
		"price": 1500.0,
		"multiplier": 10.0,
		"models": ["res://assets/models/food/fish.glb", "res://assets/models/food/meat-ribs.glb"],
		"primary_model": "res://assets/models/food/fish.glb",
		"desc": "Supreme 5-star Michelin feast: butter-poached lobster and 24k gold ribeye."
	}
}

const STAR_THRESHOLDS: Dictionary = {
	1: 1,
	2: 3,
	3: 6,
	4: 10,
	5: 15
}

var marketing_level: int = 1
const MARKETING_MAX_LEVEL: int = 25
var vip_revenue_multiplier_timer: float = 0.0
var rush_hour_timer: float = 0.0
var rush_hour_auto_timer: float = 600.0
const RUSH_HOUR_DURATION: float = 60.0
const RUSH_HOUR_ENERGY_COST: int = 15
const RUSH_HOUR_AUTO_INTERVAL: float = 600.0

# ─── Franchise Prestige & Valuation ─────────────────────────────────────────
var prestige_level: int = 0
var franchise_keys: int = 0
const PRESTIGE_VALUATION_THRESHOLD: float = 25000.0

# ─── Idle Objectives & Quests ───────────────────────────────────────────────
var active_objective_index: int = 0
var active_objective_current: int = 0

const OBJECTIVES_ROSTER: Array = [
	{
		"id": "upgrade_booth_1_lvl_10",
		"type": "station_level",
		"station_id": "table_1",
		"title": "Upgrade Booth 1 to Level 10",
		"desc": "Boost Table 1 seating capacity and profits",
		"icon": "🍽️",
		"target": 10,
		"reward_diamonds": 10,
		"reward_golden_coins": 50
	},
	{
		"id": "serve_25_customers",
		"type": "serve_customers",
		"title": "Serve 25 Customers",
		"desc": "Keep tables turning and guests fed",
		"icon": "😋",
		"target": 25,
		"reward_diamonds": 5,
		"reward_golden_coins": 75
	},
	{
		"id": "collect_speedy_tips",
		"type": "speedy_tips",
		"title": "Collect 3 Speedy Tips",
		"desc": "Tap floating tip bubbles above happy diners",
		"icon": "💸",
		"target": 3,
		"reward_diamonds": 15,
		"reward_golden_coins": 60
	},
	{
		"id": "upgrade_kitchen_lvl_10",
		"type": "station_level",
		"station_id": "kitchen_cook",
		"title": "Upgrade Kitchen to Level 10",
		"desc": "Speed up grill times for hungry patrons",
		"icon": "🍳",
		"target": 10,
		"reward_diamonds": 8,
		"reward_golden_coins": 100
	},
	{
		"id": "collect_cash_stacks",
		"type": "collect_cash",
		"title": "Collect 5 Cash Stacks",
		"desc": "Swipe or tap cash piles left on tables",
		"icon": "💵",
		"target": 5,
		"reward_diamonds": 10,
		"reward_golden_coins": 80
	},
	{
		"id": "spin_wheel_once",
		"type": "spin_wheel",
		"title": "Spin Lucky Wheel",
		"desc": "Try your luck on the Spin Wheel",
		"icon": "🎡",
		"target": 1,
		"reward_diamonds": 5,
		"reward_golden_coins": 120
	},
	{
		"id": "open_chest_once",
		"type": "open_chest",
		"title": "Open 1 Gacha Chest",
		"desc": "Unlock a Chest from the Shop",
		"icon": "📦",
		"target": 1,
		"reward_diamonds": 20,
		"reward_golden_coins": 100
	},
	{
		"id": "upgrade_bar_lvl_10",
		"type": "station_level",
		"station_id": "milkshake_bar",
		"title": "Upgrade Milkshake Bar to Level 10",
		"desc": "Whip up sweet shakes for visitors",
		"icon": "🥤",
		"target": 10,
		"reward_diamonds": 12,
		"reward_golden_coins": 150
	},
	{
		"id": "serve_50_customers",
		"type": "serve_customers",
		"title": "Serve 50 Customers",
		"desc": "Master lunchtime rush hours",
		"icon": "🍽️",
		"target": 50,
		"reward_diamonds": 25,
		"reward_golden_coins": 150
	},
	{
		"id": "upgrade_booths_lvl_25",
		"type": "station_level",
		"station_id": "table_1",
		"title": "Upgrade Booth 1 to Level 25",
		"desc": "Reach a major diner milestone",
		"icon": "⭐",
		"target": 25,
		"reward_diamonds": 30,
		"reward_golden_coins": 200
	}
]

# ─── Lucky Spin Wheel & 7-Day Login ─────────────────────────────────────────
var last_free_spin_timestamp: float = 0.0
const FREE_SPIN_COOLDOWN: float = 86400.0 # 24 Hours
var login_streak_days: int = 0
var last_login_claim_timestamp: float = 0.0
const LOGIN_CLAIM_COOLDOWN: float = 86400.0 # 24 Hours

const WHEEL_SLICES: Array = [
	{
		"index": 0,
		"type": "diamonds",
		"amount": 10,
		"title": "10 Diamonds",
		"label": "10 💎",
		"color": Color(0.18, 0.52, 0.95, 1.0)
	},
	{
		"index": 1,
		"type": "golden_coins",
		"amount": 50,
		"title": "50 Golden Coins",
		"label": "50 🪙",
		"color": Color(0.95, 0.72, 0.15, 1.0)
	},
	{
		"index": 2,
		"type": "time_skip",
		"hours": 1,
		"title": "1-Hour Time Skip",
		"label": "1h Skip ⏩",
		"color": Color(0.2, 0.75, 0.45, 1.0)
	},
	{
		"index": 3,
		"type": "diamonds",
		"amount": 25,
		"title": "25 Diamonds",
		"label": "25 💎",
		"color": Color(0.55, 0.25, 0.92, 1.0)
	},
	{
		"index": 4,
		"type": "chest",
		"chest_type": "wooden",
		"title": "Wooden Chest",
		"label": "Chest 📦",
		"color": Color(0.85, 0.45, 0.15, 1.0)
	},
	{
		"index": 5,
		"type": "golden_coins",
		"amount": 100,
		"title": "100 Golden Coins",
		"label": "100 🪙",
		"color": Color(0.95, 0.60, 0.1, 1.0)
	},
	{
		"index": 6,
		"type": "boost",
		"multiplier": 2.0,
		"duration": 900.0,
		"title": "x2 Profit Boost (15m)",
		"label": "x2 Boost ⚡",
		"color": Color(0.95, 0.25, 0.35, 1.0)
	},
	{
		"index": 7,
		"type": "diamonds",
		"amount": 5,
		"title": "5 Diamonds",
		"label": "5 💎",
		"color": Color(0.25, 0.82, 0.88, 1.0)
	}
]

const DAILY_LOGIN_REWARDS: Array = [
	{
		"day": 1,
		"title": "Day 1 Welcome",
		"icon": "🪙",
		"type": "golden_coins",
		"amount": 50,
		"desc": "+50 Golden Coins"
	},
	{
		"day": 2,
		"title": "Day 2 Sparkle",
		"icon": "💎",
		"type": "diamonds",
		"amount": 10,
		"desc": "+10 Diamonds"
	},
	{
		"day": 3,
		"title": "Day 3 Stash",
		"icon": "🪙",
		"type": "golden_coins",
		"amount": 100,
		"desc": "+100 Golden Coins"
	},
	{
		"day": 4,
		"title": "Day 4 Fast Forward",
		"icon": "⏩",
		"type": "time_skip",
		"hours": 1,
		"desc": "1-Hour Time Skip"
	},
	{
		"day": 5,
		"title": "Day 5 Fortune",
		"icon": "💎",
		"type": "diamonds",
		"amount": 25,
		"desc": "+25 Diamonds"
	},
	{
		"day": 6,
		"title": "Day 6 Loot Box",
		"icon": "📦",
		"type": "chest",
		"chest_type": "wooden",
		"desc": "Wooden Gacha Chest"
	},
	{
		"day": 7,
		"title": "Day 7 Grand Jackpot",
		"icon": "👑",
		"type": "grand_jackpot",
		"diamonds": 50,
		"chest_type": "golden",
		"desc": "+50 💎 & Golden Epic Chest!"
	}
]


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
	"cocktail_lounge": {"base_cost": 350.0, "cost_mult": 1.18, "base_rev": 60.0, "rev_mult": 1.12, "max_level": 50},
	"cocktail_bar": {"base_cost": 350.0, "cost_mult": 1.18, "base_rev": 60.0, "rev_mult": 1.12, "max_level": 50},
	"restroom": {"base_cost": 200.0, "cost_mult": 1.16, "base_rev": 20.0, "rev_mult": 1.10, "max_level": 50},
	"manager_office": {"base_cost": 500.0, "cost_mult": 1.20, "base_rev": 75.0, "rev_mult": 1.12, "max_level": 50},
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
	"cocktail_lounge": 1,
	"cocktail_bar": 1,
	"restroom": 1,
	"manager_office": 1,
}

var max_level: int = 50

# ─── Menu / Recipes ─────────────────────────────────────────────────────────
var menu_items: Dictionary = {
	"burger": {
		"id": "burger",
		"star": 1,
		"name": "Classic Diner Burger & Fries",
		"icon": "🍔",
		"price": 45.0,
		"multiplier": 1.0,
		"unlocked": true,
		"unlock_cost": 0.0,
		"desc": "Crispy seasoned golden fries paired with a fire-grilled beef patty on toasted brioche."
	},
	"sundae": {
		"id": "sundae",
		"star": 2,
		"name": "Retro Strawberry Sundae & Frappe",
		"icon": "🍨",
		"price": 120.0,
		"multiplier": 2.5,
		"unlocked": false,
		"unlock_cost": 250.0,
		"desc": "Double strawberry sundae with whipped cream, cherry, and an icy retro diner frappe."
	},
	"steak_platter": {
		"id": "steak_platter",
		"star": 3,
		"name": "Double Cheese Steak Platter",
		"icon": "🥩",
		"price": 280.0,
		"multiplier": 4.0,
		"unlocked": false,
		"unlock_cost": 600.0,
		"desc": "Thick sizzling seared ribeye platter smothered in melted double Wisconsin cheddar."
	},
	"cocktail_tapas": {
		"id": "cocktail_tapas",
		"star": 4,
		"name": "Artisan Cocktail & Tapas Combo",
		"icon": "🍸",
		"price": 650.0,
		"multiplier": 6.5,
		"unlocked": false,
		"unlock_cost": 1500.0,
		"desc": "Handcrafted botanical cocktail paired with crunchy artisan tapas bites."
	},
	"michelin_feast": {
		"id": "michelin_feast",
		"star": 5,
		"name": "Golden Michelin Lobster & Ribeye Feast",
		"icon": "🦞",
		"price": 1500.0,
		"multiplier": 10.0,
		"unlocked": false,
		"unlock_cost": 4000.0,
		"desc": "Supreme 5-star Michelin feast: butter-poached lobster and 24k gold ribeye."
	},
	# Aliases & secondary menu items for variety
	"pasta": {
		"id": "pasta",
		"name": "Truffle Tagliatelle",
		"icon": "🍝",
		"price": 115.0,
		"multiplier": 1.5,
		"unlocked": false,
		"unlock_cost": 180.0,
		"desc": "Handmade ribbon pasta with shaved black winter truffles & parmesan"
	},
	"pizza": {
		"id": "pizza",
		"name": "Wood-Fired Margherita",
		"icon": "🍕",
		"price": 240.0,
		"multiplier": 2.0,
		"unlocked": false,
		"unlock_cost": 420.0,
		"desc": "Crispy bubbly crust with San Marzano tomatoes, fresh mozzarella & basil"
	},
	"sushi": {
		"id": "sushi",
		"name": "Deluxe Dragon Roll",
		"icon": "🍣",
		"price": 480.0,
		"multiplier": 3.0,
		"unlocked": false,
		"unlock_cost": 850.0,
		"desc": "Premium grilled eel, avocado, tobiko, and fresh Atlantic salmon"
	},
	"wagyu_steak": {
		"id": "wagyu_steak",
		"name": "Wagyu Bistro Ribeye",
		"icon": "🥩",
		"price": 750.0,
		"multiplier": 4.5,
		"unlocked": false,
		"unlock_cost": 2200.0,
		"desc": "A5 Japanese Wagyu steak seared on high-heat lava rock with herb butter"
	},
	"lava_cake": {
		"id": "lava_cake",
		"name": "Molten Gold Lava Cake",
		"icon": "🍰",
		"price": 1200.0,
		"multiplier": 5.0,
		"unlocked": false,
		"unlock_cost": 5000.0,
		"desc": "Decadent Valrhona dark chocolate cake with warm center & 24k gold leaf"
	}
}

# ─── Global Research Perks ──────────────────────────────────────────────────
var research_perks: Dictionary = {
	"fast_turnover": {
		"id": "fast_turnover",
		"name": "Fast Table Turnover",
		"icon": "⏩",
		"desc": "Guests eat 25% faster, freeing booths rapidly for new arriving patrons.",
		"effect": "+25% Eating Speed",
		"cost": 500.0,
		"unlocked": false
	},
	"high_roller_tips": {
		"id": "high_roller_tips",
		"name": "High-Roller Tips",
		"icon": "💰",
		"desc": "Satisfied diners leave generous cash tips across counters and tables.",
		"effect": "+20% Tip Chance & Tip Value",
		"cost": 1200.0,
		"unlocked": false
	},
	"valet_expansion": {
		"id": "valet_expansion",
		"name": "Valet Parking Expansion",
		"icon": "🚗",
		"desc": "Optimized valet lot parking layout and streamlined car intake.",
		"effect": "+4 Parking Bays & +25% Vehicle Traffic",
		"cost": 2500.0,
		"unlocked": false
	},
	"master_chef": {
		"id": "master_chef",
		"name": "Master Chef Mise-en-Place",
		"icon": "👨‍🍳",
		"desc": "Prepped gourmet ingredients cut kitchen stove cooking duration by 30%.",
		"effect": "+30% Kitchen Cooking Speed",
		"cost": 4000.0,
		"unlocked": false
	},
	"cocktail_infusion": {
		"id": "cocktail_infusion",
		"name": "Happy Hour Cocktail Infusion",
		"icon": "🍸",
		"desc": "Lounge guests order top-shelf mixology cocktails with rapid turnover.",
		"effect": "+35% Lounge Revenue & Instant Tips",
		"cost": 6500.0,
		"unlocked": false
	},
	"spotless_hygiene": {
		"id": "spotless_hygiene",
		"name": "Spotless Hygiene Certification",
		"icon": "🧼",
		"desc": "Sanitation protocols slash maintenance expenses and boost diner patience.",
		"effect": "-50% Cleaning Upkeep & +15% Patience",
		"cost": 10000.0,
		"unlocked": false
	}
}

# ─── Permanent Store Boosters ───────────────────────────────────────────────
var permanent_boosters: Dictionary = {
	"perm_2x_income": {
		"id": "perm_2x_income",
		"name": "Permanent x2 Income",
		"icon": "💎",
		"desc": "Doubles all restaurant station revenue permanently across all shifts and locations!",
		"effect": "+100% Station Output Forever (2x)",
		"gem_cost": 150,
		"diamond_cost": 150,
		"owned": false
	},
	"vip_auto_collector": {
		"id": "vip_auto_collector",
		"name": "VIP Auto-Collector",
		"icon": "🤖",
		"desc": "Executive concierge automatically sweeps up and deposits all floating table cash stacks and tips instantly!",
		"effect": "Instant Auto-Collect Floating Cash",
		"gem_cost": 100,
		"diamond_cost": 100,
		"owned": false
	},
	"golden_spatula": {
		"id": "golden_spatula",
		"name": "Golden Spatula",
		"icon": "👑",
		"desc": "Master chefs cook 50% faster permanently across all franchises!",
		"effect": "+50% Cooking Speed Forever",
		"gem_cost": 50,
		"owned": false
	},
	"golden_register": {
		"id": "golden_register",
		"name": "Golden Cash Register",
		"icon": "🌟",
		"desc": "Permanent +50% revenue multiplier on all food, drinks, and parking!",
		"effect": "+50% Revenue Multiplier Forever",
		"gem_cost": 100,
		"owned": false
	},
	"roller_skates": {
		"id": "roller_skates",
		"name": "Turbo Waiter Roller Skates",
		"icon": "⚡",
		"desc": "Waiters and busboys glide at double speed, clearing tables instantly!",
		"effect": "+100% Movement Speed Forever",
		"gem_cost": 75,
		"owned": false
	}
}

# ─── Collectible Cards & Gacha Chests ─────────────────────────────────────────
var wooden_chest_free_timestamp: float = 0.0

const CARD_DUPLICATES_TABLE = [
	1,    # Lv 0 -> 1 (unlocked upon 1st card drop)
	2,    # Lv 1 -> 2
	5,    # Lv 2 -> 3
	10,   # Lv 3 -> 4
	20,   # Lv 4 -> 5
	40,   # Lv 5 -> 6
	80,   # Lv 6 -> 7
	150,  # Lv 7 -> 8
	300,  # Lv 8 -> 9
	600   # Lv 9 -> 10
]

var collectible_cards: Dictionary = {
	"head_chef": {
		"id": "head_chef",
		"name": "Head Chef",
		"sector": "Kitchen",
		"rarity": "rare",
		"icon": "👨‍🍳",
		"bonus_desc": "+15% Kitchen Cook Speed per Level",
		"level": 0,
		"cards": 0
	},
	"head_waiter": {
		"id": "head_waiter",
		"name": "Head Waiter",
		"sector": "Dining",
		"rarity": "common",
		"icon": "🤵",
		"bonus_desc": "+12% Waiter Move & Wiping Speed per Level",
		"level": 0,
		"cards": 0
	},
	"mixologist": {
		"id": "mixologist",
		"name": "Mixologist",
		"sector": "Cocktail Lounge",
		"rarity": "epic",
		"icon": "🍸",
		"bonus_desc": "+25% Cocktail Lounge Bar Revenue per Level",
		"level": 0,
		"cards": 0
	},
	"soda_pop_star": {
		"id": "soda_pop_star",
		"name": "Soda Pop Star",
		"sector": "Milkshake Bar",
		"rarity": "rare",
		"icon": "🥤",
		"bonus_desc": "+20% Milkshake & Soda Revenue per Level",
		"level": 0,
		"cards": 0
	},
	"valet_captain": {
		"id": "valet_captain",
		"name": "Valet Captain",
		"sector": "Parking",
		"rarity": "epic",
		"icon": "🚗",
		"bonus_desc": "+20% Parking Vehicle Arrival Rate per Level",
		"level": 0,
		"cards": 0
	},
	"executive_tycoon": {
		"id": "executive_tycoon",
		"name": "Executive Tycoon",
		"sector": "Management",
		"rarity": "legendary",
		"icon": "💼",
		"bonus_desc": "-5% Station Upgrade Costs per Level",
		"level": 0,
		"cards": 0
	},
	"sous_chef": {
		"id": "sous_chef",
		"name": "Sous Chef",
		"sector": "Kitchen",
		"rarity": "common",
		"icon": "🍳",
		"bonus_desc": "+10% Kitchen Food Dish Revenue per Level",
		"level": 0,
		"cards": 0
	},
	"star_hostess": {
		"id": "star_hostess",
		"name": "Star Hostess",
		"sector": "Reception",
		"rarity": "common",
		"icon": "📋",
		"bonus_desc": "+15% Customer Lobby Wait Patience per Level",
		"level": 0,
		"cards": 0
	},
	"maitre_d": {
		"id": "maitre_d",
		"name": "Maître D'",
		"sector": "Dining",
		"rarity": "legendary",
		"icon": "🎩",
		"bonus_desc": "+25% Table Turnover Eating Speed per Level",
		"level": 0,
		"cards": 0
	},
	"sommelier": {
		"id": "sommelier",
		"name": "Master Sommelier",
		"sector": "Cocktail Lounge",
		"rarity": "epic",
		"icon": "🍾",
		"bonus_desc": "+30% High Roller & Tip Bonuses per Level",
		"level": 0,
		"cards": 0
	},
	"vip_chauffeur": {
		"id": "vip_chauffeur",
		"name": "VIP Chauffeur",
		"sector": "Parking",
		"rarity": "legendary",
		"icon": "🚁",
		"bonus_desc": "+50% VIP Investor & Critic Appearance Chance per Level",
		"level": 0,
		"cards": 0
	},
	"master_janitor": {
		"id": "master_janitor",
		"name": "Master Janitor",
		"sector": "Hygiene",
		"rarity": "rare",
		"icon": "🧹",
		"bonus_desc": "+25% Janitorial Cleaning Speed & Hygiene Retention per Level",
		"level": 0,
		"cards": 0
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
	check_star_dish_unlocks(false)
	if preview_all_max_levels:
		set_all_stations_max_level(true)
	level_updated.emit(restaurant_level, restaurant_xp, xp_to_next_level)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()

func save_game() -> void:
	var data = {
		"cash": cash,
		"golden_coins": golden_coins,
		"diamonds": diamonds,
		"gems": diamonds,
		"energy": energy,
		"energy_regen_timer": energy_regen_timer,
		"total_earned": total_earned,
		"star_rating": star_rating,
		"cleanliness": cleanliness,
		"restaurant_name": restaurant_name,
		"restaurant_level": restaurant_level,
		"restaurant_xp": restaurant_xp,
		"unlocked_stalls": unlocked_stalls,
		"terrace_unlocked": terrace_unlocked,
		"unlocked_tables": unlocked_tables,
		"station_levels": station_levels,
		"menu_items": menu_items,
		"staff_roster": staff_roster,
		"sector_managers": sector_managers,
		"active_quests": active_quests,
		"active_restaurant_id": active_restaurant_id,
		"marketing_level": marketing_level,
		"cash_per_sec": cash_per_sec,
		"research_perks": research_perks,
		"permanent_boosters": permanent_boosters,
		"collectible_cards": collectible_cards,
		"wooden_chest_free_timestamp": wooden_chest_free_timestamp,
		"active_objective_index": active_objective_index,
		"active_objective_current": active_objective_current,
		"last_free_spin_timestamp": last_free_spin_timestamp,
		"login_streak_days": login_streak_days,
		"last_login_claim_timestamp": last_login_claim_timestamp,
		"is_boosted": is_boosted,
		"boost_timer": boost_timer,
		"boost_multiplier": boost_multiplier,
		"world_restaurants_unlocked": {
			"idle_diner": world_restaurants["idle_diner"].get("unlocked", true),
			"idles_chain": world_restaurants["idles_chain"].get("unlocked", false),
			"snowy_peaks": world_restaurants["snowy_peaks"].get("unlocked", false),
			"taverna_athena": world_restaurants["taverna_athena"].get("unlocked", false),
			"noodle_palace": world_restaurants["noodle_palace"].get("unlocked", false),
			"sakura_springs": world_restaurants["sakura_springs"].get("unlocked", false),
		},
		"prestige_level": prestige_level,
		"franchise_keys": franchise_keys,
		"piggy_bank_diamonds": piggy_bank_diamonds,
		"fever_charge": fever_charge,
		"unlocked_star_tiers": unlocked_star_tiers,
		"claimed_star_rewards": claimed_star_rewards,
		"restaurant_valuation": get_restaurant_valuation(),
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
	
	cash = float(parsed.get("cash", cash))
	diamonds = int(parsed.get("diamonds", parsed.get("gems", diamonds)))
	golden_coins = int(parsed.get("golden_coins", golden_coins))
	fever_charge = float(parsed.get("fever_charge", fever_charge))
	energy = int(parsed.get("energy", energy))
	energy = clampi(energy, 0, max_energy)
	energy_regen_timer = float(parsed.get("energy_regen_timer", energy_regen_timer))
	total_earned = float(parsed.get("total_earned", total_earned))
	star_rating = float(parsed.get("star_rating", star_rating))
	cleanliness = float(parsed.get("cleanliness", cleanliness))
	prestige_level = int(parsed.get("prestige_level", prestige_level))
	franchise_keys = int(parsed.get("franchise_keys", franchise_keys))
	restaurant_name = str(parsed.get("restaurant_name", restaurant_name))
	restaurant_level = int(parsed.get("restaurant_level", restaurant_level))
	restaurant_xp = float(parsed.get("restaurant_xp", restaurant_xp))
	unlocked_stalls = int(parsed.get("unlocked_stalls", unlocked_stalls))
	terrace_unlocked = bool(parsed.get("terrace_unlocked", terrace_unlocked))
	xp_to_next_level = 250.0 * pow(1.35, restaurant_level - 1)
	cash_per_sec = float(parsed.get("cash_per_sec", cash_per_sec))
	marketing_level = int(parsed.get("marketing_level", marketing_level))
	
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

	if parsed.has("sector_managers") and typeof(parsed["sector_managers"]) == TYPE_DICTIONARY:
		for k in parsed["sector_managers"].keys():
			if sector_managers.has(k) and typeof(parsed["sector_managers"][k]) == TYPE_DICTIONARY:
				for field in ["assigned", "tier", "manager_name"]:
					if parsed["sector_managers"][k].has(field):
						sector_managers[k][field] = parsed["sector_managers"][k][field]
					
	if parsed.has("active_quests") and typeof(parsed["active_quests"]) == TYPE_ARRAY:
		for q in parsed["active_quests"]:
			for existing in active_quests:
				if existing.get("id") == q.get("id"):
					existing["current"] = q.get("current", existing["current"])
					existing["target"] = q.get("target", existing["target"])
					existing["reward_cash"] = q.get("reward_cash", existing["reward_cash"])
					existing["reward_gems"] = q.get("reward_gems", existing["reward_gems"])
					existing["claimed"] = q.get("claimed", existing["claimed"])

	if parsed.has("research_perks") and typeof(parsed["research_perks"]) == TYPE_DICTIONARY:
		for k in parsed["research_perks"].keys():
			if research_perks.has(k) and typeof(parsed["research_perks"][k]) == TYPE_DICTIONARY:
				research_perks[k]["unlocked"] = bool(parsed["research_perks"][k].get("unlocked", false))

	if parsed.has("permanent_boosters") and typeof(parsed["permanent_boosters"]) == TYPE_DICTIONARY:
		for k in parsed["permanent_boosters"].keys():
			if permanent_boosters.has(k) and typeof(parsed["permanent_boosters"][k]) == TYPE_DICTIONARY:
				permanent_boosters[k]["owned"] = bool(parsed["permanent_boosters"][k].get("owned", false))

	if parsed.has("wooden_chest_free_timestamp"):
		wooden_chest_free_timestamp = float(parsed["wooden_chest_free_timestamp"])

	if parsed.has("collectible_cards") and typeof(parsed["collectible_cards"]) == TYPE_DICTIONARY:
		for cid in parsed["collectible_cards"].keys():
			if collectible_cards.has(cid) and typeof(parsed["collectible_cards"][cid]) == TYPE_DICTIONARY:
				for prop in parsed["collectible_cards"][cid].keys():
					collectible_cards[cid][prop] = parsed["collectible_cards"][cid][prop]

	if parsed.has("active_objective_index"):
		active_objective_index = int(parsed["active_objective_index"])
	if parsed.has("active_objective_current"):
		active_objective_current = int(parsed["active_objective_current"])
	if parsed.has("last_free_spin_timestamp"):
		last_free_spin_timestamp = float(parsed["last_free_spin_timestamp"])
	if parsed.has("login_streak_days"):
		login_streak_days = int(parsed["login_streak_days"])
	if parsed.has("last_login_claim_timestamp"):
		last_login_claim_timestamp = float(parsed["last_login_claim_timestamp"])
	if parsed.has("is_boosted"):
		is_boosted = bool(parsed["is_boosted"])
	if parsed.has("boost_timer"):
		boost_timer = float(parsed["boost_timer"])
	if parsed.has("boost_multiplier"):
		boost_multiplier = float(parsed["boost_multiplier"])

	if parsed.has("unlocked_star_tiers") and typeof(parsed["unlocked_star_tiers"]) == TYPE_ARRAY:
		unlocked_star_tiers = []
		for t in parsed["unlocked_star_tiers"]:
			unlocked_star_tiers.append(int(t))
		if not unlocked_star_tiers.has(1):
			unlocked_star_tiers.append(1)
	if parsed.has("claimed_star_rewards") and typeof(parsed["claimed_star_rewards"]) == TYPE_ARRAY:
		claimed_star_rewards = []
		for t in parsed["claimed_star_rewards"]:
			claimed_star_rewards.append(int(t))

	if parsed.has("piggy_bank_diamonds"):
		piggy_bank_diamonds = clampi(int(parsed["piggy_bank_diamonds"]), 0, PIGGY_BANK_CAP)

	currencies_updated.emit(cash, golden_coins, diamonds, energy)
	cash_changed.emit(cash)
	diamonds_changed.emit(diamonds)
	gems_changed.emit(diamonds)
	golden_coins_changed.emit(golden_coins)
	energy_changed.emit(energy)
	piggy_bank_updated.emit(piggy_bank_diamonds, PIGGY_BANK_CAP)

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

	_process_manager_skills(delta)

	# Lightning Energy Regeneration: 1 unit every 60 seconds up to max_energy (50)
	if energy < max_energy:
		energy_regen_timer += delta
		if energy_regen_timer >= 60.0:
			energy_regen_timer -= 60.0
			add_energy(1)
	else:
		energy_regen_timer = 0.0

	if is_boosted:
		boost_timer -= delta
		if boost_timer <= 0.0:
			boost_timer = 0.0
			is_boosted = false
			boost_toggled.emit(false)

	if vip_revenue_multiplier_timer > 0.0:
		vip_revenue_multiplier_timer -= delta
		if vip_revenue_multiplier_timer <= 0.0:
			vip_revenue_multiplier_timer = 0.0

	if rush_hour_timer > 0.0:
		rush_hour_timer -= delta
		if rush_hour_timer <= 0.0:
			rush_hour_timer = 0.0
			rush_hour_changed.emit(false, 0.0)
		else:
			rush_hour_changed.emit(true, rush_hour_timer)
	else:
		rush_hour_auto_timer -= delta
		if rush_hour_auto_timer <= 0.0:
			rush_hour_auto_timer = RUSH_HOUR_AUTO_INTERVAL
			_activate_rush_hour(false)

	# Update Diner Fever Frenzy
	if is_fever_active:
		fever_timer -= delta
		if fever_timer <= 0.0:
			end_fever_mode()
		else:
			fever_charge = (fever_timer / FEVER_DURATION) * fever_max_charge
			fever_meter_updated.emit(fever_charge, fever_max_charge, true)
			fever_mode_changed.emit(true, fever_timer)

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
	else:
		boost_timer = 0.0
	boost_toggled.emit(is_boosted)

func add_cash(amount: float, world_pos: Vector3 = Vector3.ZERO) -> void:
	var rest_mult: float = get_active_revenue_multiplier()
	var fever_mult: float = get_fever_profit_multiplier()
	var final_amount: float = amount * rest_mult * fever_mult
	cash += final_amount
	total_earned += final_amount
	
	recent_earnings.append([Time.get_ticks_msec(), final_amount])
	add_xp(final_amount * 0.15)
	_progress_quest("earn_cash", int(final_amount))
	
	cash_changed.emit(cash)
	currencies_updated.emit(cash, golden_coins, diamonds, energy)
	if world_pos != Vector3.ZERO:
		spawn_floating_cash.emit(final_amount, world_pos)
		spawn_flying_currency_trail.emit(world_pos, final_amount, "cash")
	
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("coin", 0.08)

func spend_cash(amount: float) -> bool:
	if cash >= amount:
		cash -= amount
		cash_changed.emit(cash)
		currencies_updated.emit(cash, golden_coins, diamonds, energy)
		return true
	return false

func add_golden_coins(amount: int, world_pos: Vector3 = Vector3.ZERO) -> void:
	golden_coins += amount
	golden_coins_changed.emit(golden_coins)
	currencies_updated.emit(cash, golden_coins, diamonds, energy)
	if world_pos != Vector3.ZERO:
		spawn_flying_currency_trail.emit(world_pos, float(amount), "gold")
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("gold_coin")

func spend_golden_coins(amount: int) -> bool:
	if golden_coins >= amount:
		golden_coins -= amount
		golden_coins_changed.emit(golden_coins)
		currencies_updated.emit(cash, golden_coins, diamonds, energy)
		return true
	return false

func get_golden_coins() -> int:
	return golden_coins

func add_diamonds(amount: int, world_pos: Vector3 = Vector3.ZERO) -> void:
	diamonds += amount
	diamonds_changed.emit(diamonds)
	gems_changed.emit(diamonds)
	currencies_updated.emit(cash, golden_coins, diamonds, energy)
	if world_pos != Vector3.ZERO:
		spawn_flying_currency_trail.emit(world_pos, float(amount), "diamond")
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("diamond")

func spend_diamonds(amount: int) -> bool:
	if diamonds >= amount:
		diamonds -= amount
		diamonds_changed.emit(diamonds)
		gems_changed.emit(diamonds)
		currencies_updated.emit(cash, golden_coins, diamonds, energy)
		return true
	return false

func get_diamonds() -> int:
	return diamonds

func add_gems(amount: int) -> void:
	add_diamonds(amount)

func spend_gems(amount: int) -> bool:
	return spend_diamonds(amount)

func add_energy(amount: int) -> void:
	energy = clampi(energy + amount, 0, max_energy)
	energy_changed.emit(energy)
	currencies_updated.emit(cash, golden_coins, diamonds, energy)

func spend_energy(amount: int) -> bool:
	if energy >= amount:
		energy -= amount
		energy_changed.emit(energy)
		currencies_updated.emit(cash, golden_coins, diamonds, energy)
		return true
	return false

func get_energy() -> int:
	return energy

func get_max_energy() -> int:
	return max_energy

func trigger_overdrive(cost: int = 10, duration: float = 60.0) -> bool:
	if spend_energy(cost):
		add_boost_time(duration)
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("energy")
		return true
	return false

func is_vip_auto_collector_active() -> bool:
	return is_permanent_booster_owned("vip_auto_collector")

func apply_overdrive_boost(multiplier: float, duration_seconds: float) -> void:
	is_boosted = true
	if multiplier > boost_multiplier:
		boost_multiplier = multiplier
		boost_timer = duration_seconds
	else:
		boost_timer += duration_seconds
	overdrive_boost_activated.emit(boost_multiplier, boost_timer)
	boost_toggled.emit(true)
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("upgrade", 0.1, 2.2)
	save_game()

func add_boost_time(seconds: float) -> void:
	apply_overdrive_boost(2.0, seconds)

func execute_time_skip(hours: int, cost_diamonds: int = 0, cost_gold: int = 0) -> float:
	if cost_diamonds > 0 and not spend_diamonds(cost_diamonds):
		return 0.0
	if cost_gold > 0 and not spend_golden_coins(cost_gold):
		return 0.0
	var seconds = float(hours * 3600)
	var rate = get_effective_cash_per_sec()
	var total_reward = max(rate * seconds, float(hours) * 1800.0)
	add_cash(total_reward)
	time_skip_activated.emit(hours, total_reward)
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("claim")
	save_game()
	return total_reward

func can_claim_daily_gift() -> bool:
	return not daily_gift_claimed

func claim_daily_gift() -> bool:
	if daily_gift_claimed:
		return false
	daily_gift_claimed = true
	add_cash(250.0)
	add_diamonds(5)
	add_golden_coins(50)
	add_energy(15)
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("claim")
	return true

func buy_shop_item(item_id: String) -> bool:
	match item_id:
		"daily_gift":
			return claim_daily_gift()
		# Permanent Multipliers & Featured Bundles
		"perm_2x_income":
			if spend_diamonds(150):
				if permanent_boosters.has("perm_2x_income"):
					permanent_boosters["perm_2x_income"]["owned"] = true
				shop_updated.emit()
				save_game()
				var am = get_node_or_null("/root/AudioManager")
				if am != null and am.has_method("play_sfx"):
					am.play_sfx("upgrade", 0.0, 3.2)
				return true
		"vip_auto_collector":
			if spend_diamonds(100):
				if permanent_boosters.has("vip_auto_collector"):
					permanent_boosters["vip_auto_collector"]["owned"] = true
				shop_updated.emit()
				save_game()
				var am = get_node_or_null("/root/AudioManager")
				if am != null and am.has_method("play_sfx"):
					am.play_sfx("upgrade", 0.0, 3.2)
				return true
		# Instant Time Skips
		"timeskip_1h_diamond":
			return execute_time_skip(1, 20, 0) > 0.0
		"timeskip_1h_gold":
			return execute_time_skip(1, 0, 150) > 0.0
		"timeskip_4h_diamond":
			return execute_time_skip(4, 60, 0) > 0.0
		"timeskip_4h_gold":
			return execute_time_skip(4, 0, 500) > 0.0
		"timeskip_24h_diamond":
			return execute_time_skip(24, 250, 0) > 0.0
		"timeskip_24h_gold":
			return execute_time_skip(24, 0, 2000) > 0.0
		# Temporary Overdrive Boosts
		"boost_2x_1h":
			if spend_diamonds(25):
				apply_overdrive_boost(2.0, 3600.0)
				return true
		"boost_5x_15m":
			if spend_diamonds(45):
				apply_overdrive_boost(5.0, 900.0)
				return true
		"boost_10x_5m":
			if spend_diamonds(75):
				apply_overdrive_boost(10.0, 300.0)
				return true
		"boost_5m":
			if spend_diamonds(15):
				apply_overdrive_boost(2.0, 300.0)
				return true
		"boost_15m":
			if spend_diamonds(35):
				apply_overdrive_boost(2.0, 900.0)
				return true
		# Gacha Chests
		"chest_wooden", "wooden_chest":
			return open_chest("wooden").get("success", false)
		"chest_silver", "silver_chest":
			return open_chest("silver").get("success", false)
		"chest_golden", "golden_chest", "chest_epic", "epic_chest", "chest_golden_epic":
			return open_chest("golden_epic").get("success", false)
		# Diamond, Golden Coin & Energy Exchange
		"cash_chest_small", "cash_small":
			if spend_diamonds(10):
				add_cash(1000.0)
				return true
		"cash_chest_medium", "cash_medium":
			if spend_diamonds(40):
				add_cash(6500.0)
				return true
		"cash_chest_grand", "cash_vault":
			if spend_diamonds(150):
				add_cash(35000.0)
				return true
		"gold_pouch":
			if spend_diamonds(15):
				add_golden_coins(100)
				return true
		"gold_chest":
			if spend_diamonds(60):
				add_golden_coins(500)
				return true
		"gold_trove":
			if spend_diamonds(150):
				add_golden_coins(1500)
				return true
		"energy_pack", "energy_small":
			if spend_diamonds(10):
				add_energy(25)
				return true
		"energy_full":
			if spend_diamonds(20):
				add_energy(50)
				return true
		"buy_gems":
			if spend_cash(2500.0):
				add_diamonds(50)
				return true
		"buy_gems_large":
			if spend_cash(10000.0):
				add_diamonds(250)
				return true
		_:
			if permanent_boosters.has(item_id):
				return buy_permanent_booster(item_id)
	return false

func add_xp(amount: float) -> void:
	restaurant_xp += amount
	var leveled_up: bool = false
	while restaurant_xp >= xp_to_next_level:
		restaurant_xp -= xp_to_next_level
		restaurant_level += 1
		xp_to_next_level = round(250.0 * pow(1.35, restaurant_level - 1))
		star_rating = min(5.0, star_rating + 0.05)
		reputation_changed.emit(round(star_rating * 10))
		add_gems(5)
		leveled_up = true
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade", 0.0, 3.5)
	if leveled_up:
		check_star_dish_unlocks(true)
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
	var disc: float = 1.0 - (get_card_upgrade_discount() if has_method("get_card_upgrade_discount") else 0.0)
	if has_method("get_manager_upgrade_discount"):
		disc *= (1.0 - get_manager_upgrade_discount())
	return max(1.0, round(cfg.base_cost * pow(cfg.cost_mult, lvl - 1) * disc))

# Formula: Revenue = BaseRevenue * RevenueMultiplier^(L - 1)
func get_station_income(station_id: String) -> float:
	var lvl: int = get_station_level(station_id)
	var cfg = get_station_config(station_id)
	var rev: float = round(cfg.base_rev * pow(cfg.rev_mult, lvl - 1))
	if is_boosted:
		rev *= boost_multiplier
	if is_permanent_booster_owned("perm_2x_income"):
		rev *= 2.0
	if vip_revenue_multiplier_timer > 0.0:
		rev *= 1.5
	if has_method("get_manager_efficiency_multiplier"):
		rev *= get_manager_efficiency_multiplier()
	if is_permanent_booster_owned("golden_register"):
		rev *= 1.5
	if has_method("get_active_revenue_multiplier"):
		rev *= get_active_revenue_multiplier()
	if has_method("get_prestige_multiplier"):
		rev *= get_prestige_multiplier()
	if is_fever_active:
		rev *= get_fever_profit_multiplier()
	
	var sid = station_id.to_lower()
	if (sid == "cocktail_lounge" or sid == "bar") and has_method("get_card_cocktail_revenue_multiplier"):
		rev *= get_card_cocktail_revenue_multiplier()
	elif (sid == "milkshake_bar" or sid == "milkshake") and has_method("get_card_milkshake_revenue_multiplier"):
		rev *= get_card_milkshake_revenue_multiplier()
	elif (sid == "kitchen_cook" or sid == "stove") and has_method("get_card_kitchen_revenue_multiplier"):
		rev *= get_card_kitchen_revenue_multiplier()
		
	return round(rev)

func get_upgrade_multi_info(station_id: String, mode: String) -> Dictionary:
	var current_lvl: int = get_station_level(station_id)
	var station_max: int = get_station_max_level(station_id)
	var max_avail: int = station_max - current_lvl
	if max_avail <= 0:
		return {"cost": 0.0, "levels": 0, "can_afford": false}
	
	var norm_mode: String = mode.to_upper().trim_prefix("X")
	var target_levels: int = 1
	if norm_mode == "10":
		target_levels = min(10, max_avail)
	elif norm_mode == "MAX":
		target_levels = max_avail
		
	var cfg = get_station_config(station_id)
	var total_cost: float = 0.0
	var affordable_levels: int = 0
	var temp_lvl = current_lvl
	var disc: float = 1.0 - (get_card_upgrade_discount() if has_method("get_card_upgrade_discount") else 0.0)
	
	for i in range(target_levels):
		var c = max(1.0, round(cfg.base_cost * pow(cfg.cost_mult, temp_lvl - 1) * disc))
		if norm_mode == "MAX":
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
			
	if norm_mode == "MAX" and affordable_levels == 0:
		total_cost = max(1.0, round(cfg.base_cost * pow(cfg.cost_mult, current_lvl - 1) * disc))
		return {"cost": total_cost, "levels": 1, "can_afford": cash >= total_cost}
		
	return {"cost": total_cost, "levels": affordable_levels, "can_afford": cash >= total_cost and affordable_levels > 0}

func upgrade_station_multi(station_id: String, mode: String, consecutive_step: int = 0) -> bool:
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

		# Station Level Milestone Rewards (Levels 10, 25, 50): +5 Diamonds & +25 Golden Coins
		var milestone_thresholds = [10, 25, 50]
		for m in milestone_thresholds:
			if current_lvl < m and new_lvl >= m:
				add_diamonds(5)
				add_golden_coins(25)
				station_milestone_reached.emit(station_id, m, 5, 25)

		progress_objective("station_level", info.levels, station_id)
		deposit_piggy_bank(info.levels)

		save_game()
		
		var am = get_node_or_null("/root/AudioManager")
		if am != null:
			if consecutive_step > 0 and am.has_method("play_upgrade_sfx"):
				am.play_upgrade_sfx(consecutive_step)
			elif am.has_method("play_sfx"):
				am.play_sfx("upgrade")
		return true
	return false

func upgrade_station(station_id: String) -> bool:
	return upgrade_station_multi(station_id, "1", 0)

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
		for tier in [1, 2, 3, 4, 5]:
			if not unlocked_star_tiers.has(tier):
				unlocked_star_tiers.append(tier)
			var dish_id = STAR_DISH_TIERS[tier]["id"]
			if menu_items.has(dish_id):
				menu_items[dish_id]["unlocked"] = true
	save_game()

func is_table_unlocked(table_id: String) -> bool:
	return unlocked_tables.get(table_id, true)

func get_unlocked_table_count() -> int:
	var count: int = 0
	for i in range(1, 13):
		if is_table_unlocked("table_%d" % i):
			count += 1
	return count

func get_table_unlock_cost(table_id: String) -> float:
	var base = table_unlock_costs.get(table_id, 200.0)
	var disc = 1.0 - (get_card_upgrade_discount() if has_method("get_card_upgrade_discount") else 0.0)
	return max(1.0, round(base * disc))

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

# ─── Smart Quick-Upgrade Recommendation & Milestone System ───────────────────
func get_smart_upgrade_recommendation() -> Dictionary:
	var candidate_ids = [
		"table_1", "table_2", "table_3", "table_4", "table_5", "table_6",
		"table_7", "table_8", "table_9", "table_10", "table_11", "table_12",
		"kitchen_cook", "milkshake_bar", "parking_lot"
	]
	
	var station_names = {
		"kitchen_cook": "Master Stove",
		"stove": "Master Stove",
		"milkshake_bar": "Milkshake Diner",
		"parking_lot": "Parking Lot",
		"parking": "Parking Lot"
	}
	var station_icons = {
		"kitchen_cook": "🍳",
		"stove": "🍳",
		"milkshake_bar": "🥤",
		"parking_lot": "🚗",
		"parking": "🚗"
	}
	for i in range(1, 13):
		var tid = "table_%d" % i
		station_names[tid] = "Booth #%d" % i
		station_icons[tid] = "🪑"
	
	var candidates: Array = []
	var milestone_thresholds = [10, 25, 50]
	
	for sid in candidate_ids:
		if sid.begins_with("table_") and not is_table_unlocked(sid):
			continue
		
		var cur_lvl = get_station_level(sid)
		var max_lvl = get_station_max_level(sid)
		if cur_lvl >= max_lvl:
			continue
		
		var info = get_upgrade_multi_info(sid, "1")
		var cost = info.cost
		var can_afford = cash >= cost
		var next_lvl = cur_lvl + 1
		
		var is_milestone = false
		var milestone_target = 0
		for m in milestone_thresholds:
			if m <= max_lvl and cur_lvl < m and next_lvl <= m:
				if (m - cur_lvl) <= 2:
					is_milestone = true
					milestone_target = m
					break
		
		var sname = station_names.get(sid, sid.capitalize())
		var sicon = station_icons.get(sid, "🍽️")
		
		candidates.append({
			"station_id": sid,
			"station_name": sname,
			"level": cur_lvl,
			"next_level": next_lvl,
			"cost": cost,
			"can_afford": can_afford,
			"is_milestone": is_milestone,
			"is_immediate_milestone": (next_lvl in milestone_thresholds),
			"milestone_target": milestone_target,
			"icon": sicon
		})
		
	if candidates.is_empty():
		return {}
		
	# Priority 1: Any station within 1-2 levels of a Milestone that the player can afford
	var milestone_affordable: Array = []
	for c in candidates:
		if c.is_milestone and c.can_afford:
			milestone_affordable.append(c)
	if not milestone_affordable.is_empty():
		milestone_affordable.sort_custom(func(a, b): return a.cost < b.cost)
		return milestone_affordable[0]
		
	# Priority 2: Lowest-cost affordable upgrade across all active sectors
	var general_affordable: Array = []
	for c in candidates:
		if c.can_afford:
			general_affordable.append(c)
	if not general_affordable.is_empty():
		general_affordable.sort_custom(func(a, b): return a.cost < b.cost)
		return general_affordable[0]
		
	# Fallback: Lowest-cost overall across active sectors
	candidates.sort_custom(func(a, b): return a.cost < b.cost)
	return candidates[0]

func get_station_next_milestone_info(station_id: String) -> Dictionary:
	var cur_lvl: int = get_station_level(station_id)
	var max_lvl: int = get_station_max_level(station_id)
	var milestone_thresholds = [10, 25, 50]
	var mults = {10: "x2", 25: "x2", 50: "x3"}
	var target_milestone = max_lvl
	var target_mult = "x2"
	var prev_milestone = 1
	for m in milestone_thresholds:
		if m <= max_lvl and cur_lvl < m:
			target_milestone = m
			target_mult = mults.get(m, "x2")
			break
		elif cur_lvl >= m:
			prev_milestone = m
	return {
		"current_level": cur_lvl,
		"max_level": max_lvl,
		"target_level": target_milestone,
		"prev_level": prev_milestone,
		"multiplier_text": target_mult,
		"is_max": cur_lvl >= max_lvl
	}

func get_station_duration(station_id: String) -> float:
	var lvl = get_station_level(station_id)
	var sid = station_id.to_lower()
	if sid.begins_with("table_"):
		return max(5.0, 12.0 - (lvl - 1) * 0.15)
	elif sid == "kitchen_cook" or sid == "stove":
		return max(1.5, 4.5 - (lvl - 1) * 0.08)
	elif sid.begins_with("milkshake"):
		return max(1.0, 2.8 - (lvl - 1) * 0.04)
	elif sid.begins_with("parking"):
		return max(2.5, 5.0 - (lvl - 1) * 0.1)
	return 5.0

func award_critic_review(is_positive: bool, bounty: float = 0.0) -> void:
	if is_positive:
		star_rating = min(5.0, star_rating + 0.1)
		reputation_changed.emit(round(star_rating * 10))
		add_xp(120.0)
		add_golden_coins(25)
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
	elif station_id.begins_with("cocktail"):
		if lvl >= 10:
			return "👑 TIER 3 • LUXURY MAHOGANY COCKTAIL LOUNGE"
		elif lvl >= 5:
			return "★ TIER 2 • ARTISAN SPEAKEASY BAR"
		else:
			return "🍸 TIER 1 • CLASSIC COCKTAIL BAR"
	elif station_id == "restroom":
		if lvl >= 10:
			return "👑 TIER 3 • SPARKLING MARBLE SUITE"
		elif lvl >= 5:
			return "★ TIER 2 • SANITIZED CERAMIC RESTROOM"
		else:
			return "🧼 TIER 1 • STANDARD RESTROOM"
	elif station_id == "manager_office":
		if lvl >= 10:
			return "👑 TIER 3 • EXECUTIVE CORNER OFFICE"
		elif lvl >= 5:
			return "★ TIER 2 • MAHOGANY MANAGEMENT OFFICE"
		else:
			return "💼 TIER 1 • OPERATIONS OFFICE"
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
	elif station_id.begins_with("cocktail"):
		if lvl < 5:
			return "Next: Lv. 5 unlocks Vintage Wine Racks & Crystal Stemware"
		elif lvl < 10:
			return "Next: Lv. 10 unlocks Top-Shelf Liquors (+50% rev)"
		else:
			return "MAX TIER UNLOCKED • Peak Lounge Prestige!"
	elif station_id == "restroom":
		if lvl < 5:
			return "Next: Lv. 5 unlocks Automatic Sanitizers & Hand Dryers"
		elif lvl < 10:
			return "Next: Lv. 10 unlocks Marble Counters & Scent Diffusers"
		else:
			return "MAX TIER UNLOCKED • Spotless 5-Star Hygiene!"
	elif station_id == "manager_office":
		if lvl < 5:
			return "Next: Lv. 5 unlocks Executive Analytics Desk & Filing Suite"
		elif lvl < 10:
			return "Next: Lv. 10 unlocks Floor Inspection Drone & Coffee Station"
		else:
			return "MAX TIER UNLOCKED • Executive GM Master Suite!"
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
		for tier in STAR_DISH_TIERS.keys():
			if STAR_DISH_TIERS[tier].get("id") == dish_id:
				if not unlocked_star_tiers.has(tier):
					unlocked_star_tiers.append(tier)
				break
		add_xp(cost * 0.35)
		_progress_quest("unlock_recipe", 1)
		menu_updated.emit()
		save_game()
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade", 0.0, 3.0)
		return true
	return false

# ─── Play Store Star Rating Dish Unlocks ────────────────────────────────────
func get_star_dish(star_tier: int) -> Dictionary:
	return STAR_DISH_TIERS.get(star_tier, {})

func get_all_star_dishes() -> Array:
	var list: Array = []
	for tier in [1, 2, 3, 4, 5]:
		if STAR_DISH_TIERS.has(tier):
			list.append(STAR_DISH_TIERS[tier])
	return list

func is_star_dish_unlocked(star_tier: int) -> bool:
	return unlocked_star_tiers.has(star_tier)

func get_current_star_tier() -> int:
	var max_unlocked = 1
	for tier in unlocked_star_tiers:
		if tier > max_unlocked:
			max_unlocked = tier
	return max_unlocked

func unlock_star_dish(star_tier: int, show_celebration: bool = true) -> bool:
	if not STAR_DISH_TIERS.has(star_tier):
		return false
	if not unlocked_star_tiers.has(star_tier):
		unlocked_star_tiers.append(star_tier)
	var dish_info = STAR_DISH_TIERS[star_tier]
	var dish_id = dish_info.get("id", "")
	if menu_items.has(dish_id):
		menu_items[dish_id]["unlocked"] = true
	save_game()
	menu_updated.emit()
	if show_celebration:
		star_dish_unlocked.emit(star_tier, dish_info)
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("upgrade", 0.0, 3.5)
	return true

func check_star_dish_unlocks(show_celebration: bool = true) -> void:
	for tier in [1, 2, 3, 4, 5]:
		var required_level = STAR_THRESHOLDS.get(tier, 1)
		if restaurant_level >= required_level:
			if not unlocked_star_tiers.has(tier):
				unlock_star_dish(tier, show_celebration)
			else:
				var dish_id = STAR_DISH_TIERS[tier].get("id", "")
				if menu_items.has(dish_id) and not menu_items[dish_id].get("unlocked", false):
					menu_items[dish_id]["unlocked"] = true

func claim_star_dish_reward(star_tier: int) -> bool:
	if not unlocked_star_tiers.has(star_tier):
		return false
	if claimed_star_rewards.has(star_tier):
		return false
	claimed_star_rewards.append(star_tier)
	add_gems(25) # +25 DIAMONDS
	save_game()
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("coin", 0.0, 2.0)
	return true

func is_star_reward_claimed(star_tier: int) -> bool:
	return claimed_star_rewards.has(star_tier)

func preview_star_dish_celebration(star_tier: int) -> void:
	if STAR_DISH_TIERS.has(star_tier):
		star_dish_unlocked.emit(star_tier, STAR_DISH_TIERS[star_tier])

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
	var mult = 1.0 + (lvl - 1) * 0.15
	if staff_id.begins_with("waiter") and has_method("get_card_waiter_speed_multiplier"):
		mult *= get_card_waiter_speed_multiplier()
	if has_method("get_manager_walk_speed_multiplier"):
		mult *= get_manager_walk_speed_multiplier()
	return mult

func get_staff_cooking_multiplier(staff_id: String) -> float:
	var lvl = get_staff_level(staff_id)
	var mult = 1.0 + (lvl - 1) * 0.20
	if has_method("get_card_cook_speed_multiplier"):
		mult *= get_card_cook_speed_multiplier()
	if has_method("get_manager_cooking_speed_multiplier"):
		mult *= get_manager_cooking_speed_multiplier()
	return mult

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

# ─── Sector Manager Active Skills (Kolibri Games System) ───────────────────
func is_manager_assigned(sector_id: String) -> bool:
	return sector_managers.get(sector_id, {}).get("assigned", false)

func get_sector_manager(sector_id: String) -> Dictionary:
	return sector_managers.get(sector_id, {})

func get_sector_manager_tier(sector_id: String) -> String:
	return sector_managers.get(sector_id, {}).get("tier", "junior")

func assign_sector_manager(sector_id: String, tier: String, mgr_name: String = "") -> void:
	if not sector_managers.has(sector_id):
		return
	var mgr = sector_managers[sector_id]
	mgr["assigned"] = true
	mgr["tier"] = tier
	if mgr_name != "":
		mgr["manager_name"] = mgr_name
	manager_assigned.emit(sector_id, tier)
	save_game()

func promote_sector_manager(sector_id: String) -> bool:
	if not sector_managers.has(sector_id):
		return false
	var mgr = sector_managers[sector_id]
	var current_tier = mgr.get("tier", "junior")
	var target_tier = ""
	var cost = 500.0
	if current_tier == "junior":
		target_tier = "senior"
		cost = 500.0
	elif current_tier == "senior":
		target_tier = "executive"
		cost = 1200.0
	else:
		return false
	
	if spend_cash(cost):
		mgr["tier"] = target_tier
		manager_assigned.emit(sector_id, target_tier)
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade")
		save_game()
		return true
	return false

func can_activate_manager_skill(sector_id: String) -> bool:
	if not sector_managers.has(sector_id):
		return false
	var mgr = sector_managers[sector_id]
	return mgr.get("assigned", false) and not mgr.get("is_active", false) and mgr.get("cooldown_timer", 0.0) <= 0.0

func is_manager_skill_active(sector_id: String) -> bool:
	if not sector_managers.has(sector_id):
		return false
	return sector_managers[sector_id].get("is_active", false)

func activate_manager_skill(sector_id: String) -> bool:
	if not can_activate_manager_skill(sector_id):
		return false
	var mgr = sector_managers[sector_id]
	mgr["is_active"] = true
	var act_dur = float(mgr.get("active_duration", 60.0))
	mgr["active_timer"] = act_dur
	mgr["cooldown_timer"] = 0.0
	manager_skill_activated.emit(sector_id)

	# Special immediate trigger logic for Instant Table Clean
	if mgr.get("skill_id") == "instant_table_clean":
		_trigger_instant_table_clean()

	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("chime", 0.0, 1.2)

	save_game()
	return true

func activate_all_manager_skills() -> int:
	var activated_count = 0
	for sec_id in sector_managers.keys():
		if can_activate_manager_skill(sec_id):
			if activate_manager_skill(sec_id):
				activated_count += 1
	if activated_count > 0:
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("purchase", 0.0, 1.1)
	return activated_count

func is_any_manager_skill_ready() -> bool:
	for sec_id in sector_managers.keys():
		if can_activate_manager_skill(sec_id):
			return true
	return false

func get_ready_manager_skills_count() -> int:
	var count = 0
	for sec_id in sector_managers.keys():
		if can_activate_manager_skill(sec_id):
			count += 1
	return count

func get_manager_upgrade_discount() -> float:
	if is_manager_skill_active("milkshake"):
		var tier = get_sector_manager_tier("milkshake")
		if tier == "executive":
			return 0.40
		elif tier == "senior":
			return 0.35
		return 0.30
	return 0.0

func get_manager_cooking_speed_multiplier() -> float:
	if is_manager_skill_active("kitchen"):
		var tier = get_sector_manager_tier("kitchen")
		if tier == "executive":
			return 2.5
		elif tier == "senior":
			return 2.2
		return 2.0
	return 1.0

func get_manager_walk_speed_multiplier() -> float:
	if is_manager_skill_active("lounge"):
		var tier = get_sector_manager_tier("lounge")
		if tier == "executive":
			return 2.5
		elif tier == "senior":
			return 2.2
		return 2.0
	return 1.0

func _trigger_instant_table_clean() -> void:
	if restaurant_node != null and restaurant_node.has_method("clean_all_dirty_tables"):
		restaurant_node.clean_all_dirty_tables()
	elif is_inside_tree():
		var rest = get_tree().current_scene.find_child("Restaurant", true, false)
		if rest != null and rest.has_method("clean_all_dirty_tables"):
			rest.clean_all_dirty_tables()

func _process_manager_skills(delta: float) -> void:
	for sec_id in sector_managers.keys():
		var mgr = sector_managers[sec_id]
		if mgr.get("is_active", false):
			mgr["active_timer"] -= delta
			if mgr["active_timer"] <= 0.0:
				mgr["active_timer"] = 0.0
				mgr["is_active"] = false
				var cd_dur = float(mgr.get("cooldown_duration", 300.0))
				if mgr.get("tier") == "executive":
					cd_dur = 220.0
				elif mgr.get("tier") == "senior":
					cd_dur = 260.0
				mgr["cooldown_timer"] = cd_dur
				manager_skill_ended.emit(sec_id)
		elif mgr.get("cooldown_timer", 0.0) > 0.0:
			mgr["cooldown_timer"] -= delta
			if mgr["cooldown_timer"] <= 0.0:
				mgr["cooldown_timer"] = 0.0
				manager_skill_ready.emit(sec_id)

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
	progress_objective("serve_customers", 1)
	deposit_piggy_bank(1)

func claim_quest(quest_id: String) -> bool:
	for q in active_quests:
		if q.get("id") == quest_id and q.get("current", 0) >= q.get("target", 1) and not q.get("claimed", false):
			var r_cash = q.get("reward_cash", 100.0)
			var r_gems = q.get("reward_gems", 5)
			add_cash(r_cash)
			add_diamonds(r_gems)
			add_golden_coins(15)
			
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
	var market_bonus = get_marketing_traffic_multiplier()
	var flyer_bonus = 1.5 if is_campaign_active("flyers") else 1.0
	var card_bonus = get_card_parking_rate_multiplier() if has_method("get_card_parking_rate_multiplier") else 1.0
	return park_bonus * market_bonus * flyer_bonus * card_bonus

func is_rush_hour_active() -> bool:
	return rush_hour_timer > 0.0

func get_rush_hour_time_left() -> float:
	return max(0.0, rush_hour_timer)

func get_customer_walk_speed_multiplier() -> float:
	return 2.0 if is_rush_hour_active() else 1.0

func get_vehicle_arrival_multiplier() -> float:
	return 2.0 if is_rush_hour_active() else 1.0

func try_start_rush_hour() -> bool:
	if is_rush_hour_active():
		return false
	if not spend_energy(RUSH_HOUR_ENERGY_COST):
		return false
	_activate_rush_hour(true)
	return true

func _activate_rush_hour(_paid: bool) -> void:
	rush_hour_timer = RUSH_HOUR_DURATION
	rush_hour_auto_timer = RUSH_HOUR_AUTO_INTERVAL
	rush_hour_changed.emit(true, rush_hour_timer)
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("upgrade", 0.05, 2.4)

func get_dish_price_multiplier() -> float:
	var mult = 1.35 if is_campaign_active("social_ad") else 1.0
	if is_boosted:
		mult *= boost_multiplier
	if is_permanent_booster_owned("perm_2x_income"):
		mult *= 2.0
	if vip_revenue_multiplier_timer > 0.0:
		mult *= 1.5
	if has_method("get_card_kitchen_revenue_multiplier"):
		mult *= get_card_kitchen_revenue_multiplier()
	return mult

func get_patience_multiplier() -> float:
	var mult = 1.5 if is_campaign_active("radio_spot") else 1.0
	if vip_revenue_multiplier_timer > 0.0:
		mult *= 1.25
	if has_method("get_card_patience_multiplier"):
		mult *= get_card_patience_multiplier()
	return mult

# ─── Marketing Level & VIP Systems ──────────────────────────────────────────
func get_marketing_level() -> int:
	return marketing_level

func get_marketing_max_level() -> int:
	return MARKETING_MAX_LEVEL

func get_marketing_traffic_multiplier() -> float:
	return 1.0 + (marketing_level - 1) * 0.15

func get_marketing_upgrade_cost() -> float:
	if marketing_level >= MARKETING_MAX_LEVEL:
		return 0.0
	return round(120.0 * pow(1.18, marketing_level - 1))

func upgrade_marketing() -> bool:
	if marketing_level >= MARKETING_MAX_LEVEL:
		return false
	var cost = get_marketing_upgrade_cost()
	if spend_cash(cost):
		marketing_level += 1
		add_xp(cost * 0.25)
		marketing_upgraded.emit(marketing_level)
		marketing_changed.emit()
		save_game()
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade")
		return true
	return false

func award_vip_investor_reward(world_pos: Vector3 = Vector3.ZERO) -> float:
	var grant = max(3500.0, get_effective_cash_per_sec() * 120.0)
	grant = round(grant)
	add_cash(grant, world_pos)
	add_diamonds(10, world_pos)
	vip_revenue_multiplier_timer = 60.0
	add_xp(350.0)
	vip_investor_awarded.emit(grant)
	save_game()
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("claim")
	return grant

func award_investor_choice(choice: String, world_pos: Vector3 = Vector3.ZERO) -> Dictionary:
	var cash_grant = max(15000.0, round(get_effective_cash_per_sec() * 120.0))
	var diamond_grant = 15
	vip_revenue_multiplier_timer = 60.0
	add_xp(350.0)
	var result = {}
	if choice == "cash":
		add_cash(cash_grant, world_pos)
		vip_investor_awarded.emit(cash_grant)
		result = {"type": "cash", "amount": cash_grant}
	else:
		add_diamonds(diamond_grant, world_pos)
		vip_investor_awarded.emit(float(diamond_grant))
		result = {"type": "diamonds", "amount": diamond_grant}
	save_game()
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("claim")
	return result

func start_vip_boost(duration: float = 60.0) -> void:
	vip_revenue_multiplier_timer = max(vip_revenue_multiplier_timer, duration)

# ─── Golden Piggy Bank System ────────────────────────────────────────────────
func deposit_piggy_bank(amount: int = 1) -> void:
	if piggy_bank_diamonds < PIGGY_BANK_CAP:
		piggy_bank_diamonds = mini(PIGGY_BANK_CAP, piggy_bank_diamonds + amount)
		piggy_bank_updated.emit(piggy_bank_diamonds, PIGGY_BANK_CAP)

func smash_piggy_bank() -> int:
	var claim_amount = piggy_bank_diamonds
	if claim_amount > 0:
		add_diamonds(claim_amount)
		piggy_bank_diamonds = 0
		piggy_bank_updated.emit(piggy_bank_diamonds, PIGGY_BANK_CAP)
		save_game()
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("claim")
	return claim_amount

func get_piggy_bank_diamonds() -> int:
	return piggy_bank_diamonds

func is_piggy_bank_full() -> bool:
	return piggy_bank_diamonds >= PIGGY_BANK_CAP

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

# ─── Franchise Prestige & Valuation API ─────────────────────────────────────
func get_restaurant_valuation() -> float:
	var earned_part: float = total_earned * 0.75
	var station_part: float = 0.0
	
	# Tables 1 to 12
	for i in range(1, 13):
		var tid = "table_%d" % i
		if is_table_unlocked(tid):
			var lvl = get_station_level(tid)
			station_part += float(lvl) * 250.0
	
	# Core sectors (kitchen, milkshake bar, parking lot, lounge, host desk, restroom)
	for sid in ["kitchen_cook", "milkshake_bar", "parking_lot", "cocktail_lounge", "host_desk", "restroom"]:
		var lvl = get_station_level(sid)
		station_part += float(lvl) * 500.0
	
	# Current star rating quality multiplier (e.g. 5.0 stars = 1.0x baseline, up to 1.25x)
	var star_mult: float = clampf(star_rating / 5.0, 0.6, 1.25)
	var valuation: float = (earned_part + station_part * 1.5) * star_mult
	return maxf(valuation, 500.0)

func are_core_stations_max_level() -> bool:
	var core_stations = [
		"kitchen_cook", "milkshake_bar", "parking_lot",
		"table_1", "table_2", "table_3", "table_4", "table_5", "table_6",
		"table_7", "table_8", "table_9", "table_10", "table_11", "table_12"
	]
	for sid in core_stations:
		if get_station_level(sid) < 50:
			return false
	return true

func can_prestige() -> bool:
	return get_restaurant_valuation() >= PRESTIGE_VALUATION_THRESHOLD or are_core_stations_max_level()

func get_prestige_keys_gain() -> int:
	var val = get_restaurant_valuation()
	return maxi(1, int(floor(val / 15000.0)))

func get_prestige_diamonds_gain() -> int:
	var keys = get_prestige_keys_gain()
	return 25 + (keys * 15)

func get_prestige_multiplier() -> float:
	return 1.0 + (float(prestige_level) * 0.50)

func execute_prestige() -> bool:
	if not can_prestige():
		return false
	
	var keys_gained = get_prestige_keys_gain()
	var diamonds_gained = get_prestige_diamonds_gain()
	
	prestige_level += 1
	franchise_keys += keys_gained
	diamonds += diamonds_gained
	gems = diamonds
	
	# Reset cash to starting baseline + prestige bonus
	cash = 500.0 * (1.0 + float(prestige_level))
	
	# Reset station levels to 1
	for sid in station_levels.keys():
		station_levels[sid] = 1
	
	# Save updated state
	save_game()
	
	# Broadcast signals
	franchise_keys_changed.emit(franchise_keys)
	diamonds_changed.emit(diamonds)
	cash_changed.emit(cash)
	currencies_updated.emit(cash, golden_coins, diamonds, energy)
	prestige_updated.emit(prestige_level, franchise_keys, get_prestige_multiplier())
	franchise_prestiged.emit(prestige_level, keys_gained, diamonds_gained)
	
	# Notify stations to reset visual tiers and 3D level labels
	for sid in station_levels.keys():
		station_upgraded.emit(sid, 1)
	
	# Celebration chime
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_milestone_chime"):
		am.play_milestone_chime(50)
	
	return true


# ─── Big-Number Currency Formatter ──────────────────────────────────────────
static func format_currency(amount: float) -> String:
	if amount < 0.0:
		return "- " + format_currency(-amount)
	if amount < 1000.0:
		return "$%d" % round(amount)

	var suffixes: Array[String] = ["K", "M", "B", "T", "AA", "AB", "AC", "AD"]
	var tier: int = int(floor(log(amount) / log(1000.0)))
	var s_idx: int = clampi(tier - 1, 0, suffixes.size() - 1)
	var div: float = pow(1000.0, s_idx + 1)
	var val: float = amount / div

	if val >= 999.95 and s_idx + 1 < suffixes.size():
		s_idx += 1
		div = pow(1000.0, s_idx + 1)
		val = amount / div

	var sfx: String = suffixes[s_idx]
	if val >= 100.0:
		return "$%.0f%s" % [val, sfx]
	else:
		return "$%.1f%s" % [val, sfx]

func format_money(amount: float) -> String:
	return format_currency(amount)

# ─── Financial Analytics Breakdown ──────────────────────────────────────────
func get_financial_breakdown() -> Dictionary:
	# 1. Income Streams (per second)
	var dining_sec: float = 0.0
	for i in range(1, 13):
		var tid = "table_%d" % i
		if is_table_unlocked(tid):
			dining_sec += get_station_income(tid) / 10.0
	dining_sec += get_station_income("kitchen_cook") / 6.0
	dining_sec = max(dining_sec, 8.5)

	var milkshake_sec: float = (get_station_income("milkshake_bar") / 8.0) + (get_station_income("milkshake_blender") / 12.0)
	milkshake_sec = max(milkshake_sec, 5.6)

	var cocktail_sec: float = 0.0
	if STATION_CONFIGS.has("cocktail_bar"):
		cocktail_sec = get_station_income("cocktail_bar") / 8.0
	else:
		cocktail_sec = 6.8
	cocktail_sec = max(cocktail_sec, 6.8)

	var parking_sec: float = get_station_income("parking_lot") / 5.0
	parking_sec = max(parking_sec, 4.3)

	var total_income_sec: float = dining_sec + milkshake_sec + cocktail_sec + parking_sec

	# 2. Operational Expenses (per second)
	var m_lvl = get_marketing_level()
	var marketing_sec: float = 50.0 / 60.0 + (float(m_lvl - 1) * 0.4)

	var unl_tables = get_unlocked_table_count()
	var cleaning_sec: float = 300.0 / 60.0 + (float(unl_tables) * 0.25)
	if is_perk_unlocked("spotless_hygiene"):
		cleaning_sec *= 0.5

	var staff_sec: float = 0.0
	for sid in staff_roster.keys():
		var s_data = staff_roster[sid]
		if s_data.get("hired", false):
			staff_sec += float(s_data.get("level", 1)) * 0.45
	staff_sec = max(staff_sec, 4.2)

	var total_expense_sec: float = marketing_sec + cleaning_sec + staff_sec
	var net_sec: float = total_income_sec - total_expense_sec

	return {
		"income": {
			"dining": dining_sec,
			"milkshake": milkshake_sec,
			"cocktail": cocktail_sec,
			"parking": parking_sec,
			"parking_min": max(25830.0, parking_sec * 60.0),
			"total": total_income_sec
		},
		"expenses": {
			"marketing": marketing_sec,
			"marketing_min": max(50.0, marketing_sec * 60.0),
			"cleaning": cleaning_sec,
			"cleaning_min": max(300.0, cleaning_sec * 60.0),
			"staff": staff_sec,
			"total": total_expense_sec
		},
		"net_profit": net_sec
	}

# ─── Research Perks Methods ─────────────────────────────────────────────────
func get_research_perks() -> Dictionary:
	return research_perks

func is_perk_unlocked(perk_id: String) -> bool:
	return research_perks.get(perk_id, {}).get("unlocked", false)

func unlock_perk(perk_id: String) -> bool:
	if not research_perks.has(perk_id):
		return false
	var perk = research_perks[perk_id]
	if perk.get("unlocked", false):
		return true
	var cost = float(perk.get("cost", 500.0))
	if not spend_cash(cost):
		return false
	perk["unlocked"] = true
	perks_updated.emit()
	save_game()
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("upgrade", 0.0, 3.2)
	return true

# ─── Permanent Store Boosters Methods ───────────────────────────────────────
func get_permanent_boosters() -> Dictionary:
	return permanent_boosters

func is_permanent_booster_owned(booster_id: String) -> bool:
	return permanent_boosters.get(booster_id, {}).get("owned", false)

func buy_permanent_booster(booster_id: String) -> bool:
	if not permanent_boosters.has(booster_id):
		return false
	var b = permanent_boosters[booster_id]
	if b.get("owned", false):
		return true
	var g_cost = int(b.get("gem_cost", 50))
	if not spend_gems(g_cost):
		return false
	b["owned"] = true
	shop_updated.emit()
	save_game()
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("upgrade", 0.0, 3.2)
	return true

# ─── Operational Alerts & Diagnostics ───────────────────────────────────────
func register_restaurant(node: Node3D) -> void:
	restaurant_node = node

func get_restaurant() -> Node3D:
	if restaurant_node != null and is_instance_valid(restaurant_node):
		return restaurant_node
	var tree = get_tree()
	if tree != null and tree.current_scene != null:
		var found = tree.current_scene.find_child("Restaurant", true, false)
		if found != null:
			restaurant_node = found
			return restaurant_node
	return null

func notify_vip_arrival(vip_node: Node3D, title: String, type: String, duration: float) -> void:
	vip_arrived.emit(vip_node, title, type, duration)

func get_bottleneck_status() -> Dictionary:
	var r = get_restaurant()
	if r != null and r.has_method("get_sector_bottleneck_status"):
		return r.get_sector_bottleneck_status()
	return {
		"text": "Optimal Flow",
		"color": Color(0.18, 0.78, 0.35, 1.0),
		"code": "OPTIMAL",
		"icon": "🟢"
	}

# ─── Restroom & Sanitation Hygiene System ──────────────────────────────────
func get_cleanliness() -> float:
	return cleanliness

func record_restroom_use() -> void:
	var loss: float = 2.0
	if is_perk_unlocked("spotless_hygiene"):
		loss *= 0.5
	var jan_lvl = get_card_level("master_janitor")
	if jan_lvl > 0:
		loss /= (1.0 + float(jan_lvl) * 0.25)
	cleanliness = clampf(cleanliness - loss, 20.0, 100.0)
	_update_hygiene_star_rating()
	cleanliness_updated.emit(cleanliness)

func record_dirty_table() -> void:
	var loss: float = 2.5
	if is_perk_unlocked("spotless_hygiene"):
		loss *= 0.5
	var jan_lvl = get_card_level("master_janitor")
	if jan_lvl > 0:
		loss /= (1.0 + float(jan_lvl) * 0.25)
	cleanliness = clampf(cleanliness - loss, 20.0, 100.0)
	_update_hygiene_star_rating()
	cleanliness_updated.emit(cleanliness)

func record_table_cleaned() -> void:
	cleanliness = clampf(cleanliness + 4.0, 0.0, 100.0)
	_update_hygiene_star_rating()
	cleanliness_updated.emit(cleanliness)

func _update_hygiene_star_rating() -> void:
	if cleanliness >= 75.0:
		star_rating = 5.0
	else:
		star_rating = clampf(4.0 + (cleanliness / 100.0) * 1.0, 4.0, 5.0)
	reputation_changed.emit(round(star_rating * 10))

func get_financial_summary() -> Dictionary:
	return get_financial_breakdown()

func get_cleaning_upkeep_cost() -> float:
	var fin = get_financial_breakdown()
	var base_upkeep = fin.get("expenses", {}).get("cleaning_min", 300.0)
	if is_perk_unlocked("spotless_hygiene"):
		base_upkeep *= 0.5
	return max(150.0, base_upkeep)

func trigger_rapid_sanitation() -> bool:
	var cost = get_cleaning_upkeep_cost()
	if spend_cash(cost):
		cleanliness = 100.0
		star_rating = 5.0
		reputation_changed.emit(round(star_rating * 10))
		cleanliness_updated.emit(cleanliness)
		rapid_sanitation_triggered.emit(cost)
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("cash_register", 0.05, 1.2)
		save_game()
		return true
	return false

# ─── Collectible Card Management & Multipliers ──────────────────────────────
func get_card(card_id: String) -> Dictionary:
	return collectible_cards.get(card_id, {})

func get_all_cards() -> Dictionary:
	return collectible_cards

func get_card_level(card_id: String) -> int:
	return int(collectible_cards.get(card_id, {}).get("level", 0))

func get_card_count(card_id: String) -> int:
	return int(collectible_cards.get(card_id, {}).get("cards", 0))

func get_card_cards_needed(card_id: String) -> int:
	var lvl = get_card_level(card_id)
	if lvl >= 10:
		return 0
	return CARD_DUPLICATES_TABLE[clamp(lvl, 0, CARD_DUPLICATES_TABLE.size() - 1)]

func get_card_gold_cost(card_id: String) -> int:
	var card = collectible_cards.get(card_id, {})
	var lvl = int(card.get("level", 0))
	if lvl >= 10:
		return 0
	var rarity = str(card.get("rarity", "common")).to_lower()
	var base = 50
	match rarity:
		"rare":
			base = 100
		"epic":
			base = 250
		"legendary":
			base = 500
		_:
			base = 50
	return base * (lvl + 1)

func can_upgrade_card(card_id: String) -> bool:
	if not collectible_cards.has(card_id):
		return false
	var lvl = get_card_level(card_id)
	if lvl < 1 or lvl >= 10:
		return false
	var needed = get_card_cards_needed(card_id)
	var cost = get_card_gold_cost(card_id)
	return get_card_count(card_id) >= needed and golden_coins >= cost

func upgrade_card(card_id: String) -> bool:
	if not can_upgrade_card(card_id):
		return false
	var cost = get_card_gold_cost(card_id)
	var needed = get_card_cards_needed(card_id)
	if spend_golden_coins(cost):
		var card = collectible_cards[card_id]
		card["cards"] -= needed
		card["level"] += 1
		card_updated.emit(card_id, card["level"], card["cards"])
		cards_updated.emit()
		save_game()
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade", 0.0, 3.5)
		return true
	return false

func add_card_duplicates(card_id: String, amount: int) -> void:
	if not collectible_cards.has(card_id) or amount <= 0:
		return
	var card = collectible_cards[card_id]
	if card["level"] == 0:
		card["level"] = 1
		card["cards"] += (amount - 1)
	else:
		card["cards"] += amount
	card_updated.emit(card_id, card["level"], card["cards"])
	cards_updated.emit()
	save_game()

# ─── Sector Multipliers from Collectible Cards ──────────────────────────────
func get_card_cook_speed_multiplier() -> float:
	return 1.0 + get_card_level("head_chef") * 0.15

func get_card_waiter_speed_multiplier() -> float:
	return 1.0 + get_card_level("head_waiter") * 0.12

func get_card_cocktail_revenue_multiplier() -> float:
	return 1.0 + get_card_level("mixologist") * 0.25

func get_card_milkshake_revenue_multiplier() -> float:
	return 1.0 + get_card_level("soda_pop_star") * 0.20

func get_card_parking_rate_multiplier() -> float:
	return 1.0 + get_card_level("valet_captain") * 0.20

func get_card_upgrade_discount() -> float:
	return min(0.50, get_card_level("executive_tycoon") * 0.05)

func get_card_kitchen_revenue_multiplier() -> float:
	return 1.0 + get_card_level("sous_chef") * 0.10

func get_card_patience_multiplier() -> float:
	return 1.0 + get_card_level("star_hostess") * 0.15

func get_card_table_turnover_multiplier() -> float:
	return 1.0 + get_card_level("maitre_d") * 0.25

func get_card_tip_multiplier() -> float:
	return 1.0 + get_card_level("sommelier") * 0.30

func get_card_vip_spawn_multiplier() -> float:
	return 1.0 + get_card_level("vip_chauffeur") * 0.50

func get_card_cleaning_multiplier() -> float:
	return 1.0 + get_card_level("master_janitor") * 0.25

# ─── Gacha Chest Systems ───────────────────────────────────────────────────
func can_claim_free_wooden_chest() -> bool:
	return wooden_chest_free_timestamp <= 0.0 or Time.get_unix_time_from_system() >= wooden_chest_free_timestamp

func get_free_wooden_chest_cooldown_left() -> float:
	return max(0.0, wooden_chest_free_timestamp - Time.get_unix_time_from_system())

func open_chest(chest_type: String) -> Dictionary:
	var ctype = chest_type.to_lower()
	var was_free = false
	
	match ctype:
		"wooden", "chest_wooden":
			ctype = "wooden"
			if can_claim_free_wooden_chest():
				was_free = true
				wooden_chest_free_timestamp = Time.get_unix_time_from_system() + 14400.0
			elif spend_golden_coins(100):
				pass
			else:
				return {"success": false, "reason": "Not enough Golden Coins"}
		"silver", "chest_silver":
			ctype = "silver"
			if not spend_diamonds(35):
				return {"success": false, "reason": "Not enough Diamonds"}
		"golden_epic", "golden", "epic", "chest_golden", "chest_epic", "chest_golden_epic":
			ctype = "golden_epic"
			if not spend_diamonds(120):
				return {"success": false, "reason": "Not enough Diamonds"}
		_:
			return {"success": false, "reason": "Invalid chest type"}
			
	var cash_gain: float = 0.0
	var coins_gain: int = 0
	var gems_gain: int = 0
	var card_drops_count: int = 2
	var rarity_weights = {"common": 75, "rare": 25, "epic": 0, "legendary": 0}
	var copies_min: int = 1
	var copies_max: int = 2
	
	if ctype == "wooden":
		cash_gain = round(randf_range(300.0, 800.0))
		coins_gain = randi_range(15, 40)
		gems_gain = 0
		card_drops_count = 2
		rarity_weights = {"common": 75, "rare": 25, "epic": 0, "legendary": 0}
		copies_min = 1
		copies_max = 2
	elif ctype == "silver":
		cash_gain = round(randf_range(2000.0, 5000.0))
		coins_gain = randi_range(50, 120)
		gems_gain = randi_range(3, 8)
		card_drops_count = 3
		rarity_weights = {"common": 45, "rare": 40, "epic": 15, "legendary": 0}
		copies_min = 2
		copies_max = 4
	elif ctype == "golden_epic":
		cash_gain = round(randf_range(10000.0, 25000.0))
		coins_gain = randi_range(200, 500)
		gems_gain = randi_range(15, 35)
		card_drops_count = 5
		rarity_weights = {"common": 20, "rare": 40, "epic": 25, "legendary": 15}
		copies_min = 3
		copies_max = 6
		
	# Select Cards based on rarity weights
	var reward_cards: Array = []
	for i in range(card_drops_count):
		var target_rarity = _pick_chest_rarity(rarity_weights)
		var eligible: Array = []
		for cid in collectible_cards.keys():
			if collectible_cards[cid].get("rarity", "common") == target_rarity:
				eligible.append(cid)
		if eligible.is_empty():
			eligible = collectible_cards.keys()
		var chosen_id = eligible[randi() % eligible.size()]
		var count = randi_range(copies_min, copies_max)
		add_card_duplicates(chosen_id, count)
		var cinfo = collectible_cards[chosen_id]
		reward_cards.append({
			"id": chosen_id,
			"name": cinfo.name,
			"rarity": cinfo.rarity,
			"icon": cinfo.icon,
			"count": count,
			"level": cinfo.level,
			"bonus_desc": cinfo.bonus_desc
		})
		
	add_cash(cash_gain)
	add_golden_coins(coins_gain)
	if gems_gain > 0:
		add_diamonds(gems_gain)
		
	var rewards = {
		"success": true,
		"chest_type": ctype,
		"was_free": was_free,
		"cash": cash_gain,
		"golden_coins": coins_gain,
		"diamonds": gems_gain,
		"cards": reward_cards
	}
	
	chest_opened.emit(ctype, rewards)
	progress_objective("open_chest", 1)
	save_game()
	
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("coin", 0.05, 1.2)
		
	return rewards

func _pick_chest_rarity(weights: Dictionary) -> String:
	var total: int = 0
	for w in weights.values():
		total += int(w)
	if total <= 0:
		return "common"
	var roll = randi_range(1, total)
	var accum = 0
	for r in ["legendary", "epic", "rare", "common"]:
		accum += int(weights.get(r, 0))
		if roll <= accum:
			return r
	return "common"

# ─── Idle Objectives System ──────────────────────────────────────────────────
func get_active_objective() -> Dictionary:
	var total_objs = OBJECTIVES_ROSTER.size()
	if total_objs == 0:
		return {}
	var base_idx = active_objective_index % total_objs
	var cycle = int(active_objective_index / total_objs)
	var template = OBJECTIVES_ROSTER[base_idx].duplicate(true)
	
	# Scale targets and rewards for subsequent loops
	var mult = 1.0 + float(cycle) * 0.5
	var target = template.get("target", 1)
	if template.get("type") == "station_level":
		target = min(100, target + cycle * 10)
		var sid = template.get("station_id", "table_1")
		template["current"] = min(target, get_station_level(sid))
	else:
		target = int(round(float(target) * mult))
		template["current"] = min(target, active_objective_current)
		
	template["target"] = target
	template["reward_diamonds"] = int(round(float(template.get("reward_diamonds", 5)) * mult))
	template["reward_golden_coins"] = int(round(float(template.get("reward_golden_coins", 25)) * mult))
	template["is_completed"] = template["current"] >= target
	return template

func progress_objective(type: String, amount: int = 1, station_id: String = "") -> void:
	var obj = get_active_objective()
	if obj.is_empty() or obj.get("is_completed", false):
		return
	var obj_type = obj.get("type", "")
	if obj_type != type:
		return
		
	if obj_type == "station_level":
		var target_sid = obj.get("station_id", "")
		var is_match = (station_id == target_sid) \
			or (station_id in ["stove", "kitchen_cook"] and target_sid in ["stove", "kitchen_cook"]) \
			or (station_id in ["parking", "parking_lot"] and target_sid in ["parking", "parking_lot"])
		if not is_match:
			return
	else:
		active_objective_current += amount
	
	var updated_obj = get_active_objective()
	objective_updated.emit(updated_obj)

func claim_active_objective() -> Dictionary:
	var obj = get_active_objective()
	if obj.is_empty() or not obj.get("is_completed", false):
		return {}
	
	var r_dia = obj.get("reward_diamonds", 0)
	var r_gold = obj.get("reward_golden_coins", 0)
	if r_dia > 0:
		add_diamonds(r_dia)
	if r_gold > 0:
		add_golden_coins(r_gold)
		
	var claimed_rewards = {
		"diamonds": r_dia,
		"golden_coins": r_gold,
		"title": obj.get("title", "")
	}
	
	active_objective_index += 1
	active_objective_current = 0
	save_game()
	
	var next_obj = get_active_objective()
	objective_claimed.emit(claimed_rewards)
	objective_updated.emit(next_obj)
	
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("cash_register", 0.05, 1.2)
		
	return claimed_rewards

func record_speedy_tip() -> void:
	progress_objective("speedy_tips", 1)

func record_table_cash_collected() -> void:
	progress_objective("collect_cash", 1)

# ─── Lucky Spin Wheel ───────────────────────────────────────────────────────
func can_claim_free_spin() -> bool:
	if last_free_spin_timestamp <= 0.0:
		return true
	var now = Time.get_unix_time_from_system()
	return (now - last_free_spin_timestamp) >= FREE_SPIN_COOLDOWN

func get_free_spin_cooldown_remaining() -> float:
	if last_free_spin_timestamp <= 0.0:
		return 0.0
	var now = Time.get_unix_time_from_system()
	var elapsed = now - last_free_spin_timestamp
	return max(0.0, FREE_SPIN_COOLDOWN - elapsed)

func can_spin_wheel() -> bool:
	if can_claim_free_spin():
		return true
	return energy >= 10

func spin_lucky_wheel() -> Dictionary:
	if not can_spin_wheel():
		return {}
	
	var is_free = can_claim_free_spin()
	if is_free:
		last_free_spin_timestamp = Time.get_unix_time_from_system()
	else:
		if not spend_energy(10):
			return {}
			
	var slice_index = randi() % WHEEL_SLICES.size()
	var prize = WHEEL_SLICES[slice_index].duplicate(true)
	
	var ptype = prize.get("type", "")
	if ptype == "diamonds":
		add_diamonds(prize.get("amount", 5))
	elif ptype == "golden_coins":
		add_golden_coins(prize.get("amount", 50))
	elif ptype == "time_skip":
		var hrs = prize.get("hours", 1)
		execute_time_skip(hrs, 0, 0)
	elif ptype == "chest":
		var ctype = prize.get("chest_type", "wooden")
		open_chest(ctype)
	elif ptype == "boost":
		var mult = prize.get("multiplier", 2.0)
		var dur = prize.get("duration", 900.0)
		apply_overdrive_boost(mult, dur)
		
	progress_objective("spin_wheel", 1)
	save_game()
	spin_wheel_completed.emit(slice_index, prize)
	return {
		"slice_index": slice_index,
		"prize": prize,
		"was_free": is_free
	}

# ─── 7-Day Daily Login ──────────────────────────────────────────────────────
func can_claim_daily_login() -> bool:
	if last_login_claim_timestamp <= 0.0:
		return true
	var now = Time.get_unix_time_from_system()
	return (now - last_login_claim_timestamp) >= LOGIN_CLAIM_COOLDOWN

func get_daily_login_cooldown_remaining() -> float:
	if last_login_claim_timestamp <= 0.0:
		return 0.0
	var now = Time.get_unix_time_from_system()
	var elapsed = now - last_login_claim_timestamp
	return max(0.0, LOGIN_CLAIM_COOLDOWN - elapsed)

func claim_daily_login() -> Dictionary:
	if not can_claim_daily_login():
		return {}
	
	login_streak_days = (login_streak_days % 7) + 1
	last_login_claim_timestamp = Time.get_unix_time_from_system()
	
	var reward = DAILY_LOGIN_REWARDS[login_streak_days - 1].duplicate(true)
	var rtype = reward.get("type", "")
	if rtype == "golden_coins":
		add_golden_coins(reward.get("amount", 50))
	elif rtype == "diamonds":
		add_diamonds(reward.get("amount", 10))
	elif rtype == "time_skip":
		execute_time_skip(reward.get("hours", 1), 0, 0)
	elif rtype == "chest":
		open_chest(reward.get("chest_type", "wooden"))
	elif rtype == "grand_jackpot":
		add_diamonds(reward.get("diamonds", 50))
		open_chest(reward.get("chest_type", "golden"))
		
	save_game()
	daily_login_claimed.emit(login_streak_days, reward)
	
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("cash_register", 0.05, 1.2)
		
	return reward

# ─── Diner Fever Combo & Frenzy Overdrive ──────────────────────────────────
func add_fever_charge(amount: float) -> void:
	if is_fever_active:
		return
	fever_charge = clampf(fever_charge + amount, 0.0, fever_max_charge)
	fever_meter_updated.emit(fever_charge, fever_max_charge, is_fever_active)
	if fever_charge >= fever_max_charge:
		start_fever_mode()

func penalize_fever_charge(amount: float = 25.0) -> void:
	if is_fever_active:
		return
	fever_charge = clampf(fever_charge - amount, 0.0, fever_max_charge)
	fever_meter_updated.emit(fever_charge, fever_max_charge, is_fever_active)

func tap_fever_surge() -> void:
	if is_fever_active:
		return
	add_fever_charge(2.0)
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("coin", 0.06, 0.0, 1.35)

func start_fever_mode() -> void:
	is_fever_active = true
	fever_timer = FEVER_DURATION
	fever_charge = fever_max_charge
	fever_mode_changed.emit(true, fever_timer)
	fever_meter_updated.emit(fever_charge, fever_max_charge, true)
	var am = get_node_or_null("/root/AudioManager")
	if am != null:
		if am.has_method("set_fever_pitch"):
			am.set_fever_pitch(true)
		if am.has_method("play_sfx"):
			am.play_sfx("upgrade", 0.0, 3.0, 1.25)

func end_fever_mode() -> void:
	is_fever_active = false
	fever_timer = 0.0
	fever_charge = 0.0
	fever_mode_changed.emit(false, 0.0)
	fever_meter_updated.emit(fever_charge, fever_max_charge, false)
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("set_fever_pitch"):
		am.set_fever_pitch(false)

func is_fever_mode_active() -> bool:
	return is_fever_active

func get_fever_speed_multiplier() -> float:
	return 2.0 if is_fever_active else 1.0

func get_fever_profit_multiplier() -> float:
	return 2.0 if is_fever_active else 1.0

