extends CanvasLayer

# ─── Top Bar Node References ────────────────────────────────────────────────
@onready var profile_panel: PanelContainer = get_node_or_null("HUD/TopBar/ProfilePanel")
@onready var avatar_label: Label = get_node_or_null("HUD/TopBar/ProfilePanel/VBox/AvatarLabel")
@onready var level_label: Label = get_node_or_null("HUD/TopBar/ProfilePanel/VBox/LevelLabel")
@onready var star_milestone_bar: ProgressBar = get_node_or_null("HUD/StarMilestoneBar/FillBar")
@onready var rest_name_label: Label = get_node_or_null("HUD/TopBar/ProfilePanel/VBox/RestNameLabel")
@onready var star_label: Label = get_node_or_null("HUD/TopBar/ProfilePanel/VBox/HBox/StarLabel")
@onready var xp_bar: ProgressBar = get_node_or_null("HUD/TopBar/ProfilePanel/VBox/XPBar")

@onready var cash_label: Label = $HUD/TopBar/CashPanel/HBox/VBox/CashLabel
@onready var cash_rate_label: Label = $HUD/TopBar/CashPanel/HBox/VBox/RateLabel
@onready var gem_panel: PanelContainer = get_node_or_null("HUD/TopBar/GemPanel")
@onready var gem_label: Label = $HUD/TopBar/GemPanel/HBox/GemLabel
@onready var add_gem_btn: Button = $HUD/TopBar/GemPanel/HBox/AddGemBtn
@onready var gold_panel: PanelContainer = get_node_or_null("HUD/TopBar/GoldCoinPanel")
@onready var gold_label: Label = get_node_or_null("HUD/TopBar/GoldCoinPanel/HBox/GoldCoinLabel")
@onready var add_gold_btn: Button = get_node_or_null("HUD/TopBar/GoldCoinPanel/HBox/AddGoldBtn")
@onready var energy_panel: PanelContainer = get_node_or_null("HUD/TopBar/EnergyPanel")
@onready var add_energy_btn: Button = get_node_or_null("HUD/TopBar/EnergyPanel/HBox/AddEnergyBtn")
@onready var boost_btn: Button = get_node_or_null("HUD/TopBar/BoostBtn") if get_node_or_null("HUD/TopBar/BoostBtn") != null else (get_node_or_null("HUD/RightDock/SideAdBtn") if get_node_or_null("HUD/RightDock/SideAdBtn") != null else get_node_or_null("HUD/FloatingBoostBanner"))
@onready var rush_hour_btn: Button = get_node_or_null("HUD/TopBar/RushHourBtn")

# ─── Left Objectives / Quest Banner ─────────────────────────────────────────
@onready var quest_banner: PanelContainer = $HUD/QuestBanner
@onready var quest_icon: Label = $HUD/QuestBanner/HBox/Icon
@onready var quest_title: Label = $HUD/QuestBanner/HBox/VBox/TitleLabel
@onready var quest_progress_label: Label = $HUD/QuestBanner/HBox/VBox/ProgressLabel
@onready var quest_bar: ProgressBar = $HUD/QuestBanner/HBox/VBox/ProgressBar
@onready var quest_claim_btn: Button = $HUD/QuestBanner/HBox/ClaimBtn

# ─── Bottom Navigation Dock ─────────────────────────────────────────────────
@onready var nav_parking_btn: Button = get_node_or_null("HUD/BottomDock/HBox/ParkingBtn")
@onready var nav_kitchen_btn: Button = get_node_or_null("HUD/BottomDock/HBox/KitchenBtn")
@onready var nav_dining_btn: Button = get_node_or_null("HUD/BottomDock/HBox/DiningBtn")
@onready var nav_milkshake_btn: Button = get_node_or_null("HUD/BottomDock/HBox/MilkshakeBtn")
@onready var nav_terrace_btn: Button = get_node_or_null("HUD/BottomDock/HBox/TerraceBtn")
@onready var nav_staff_btn: Button = get_node_or_null("HUD/BottomDock/HBox/StaffBtn")
@onready var nav_promo_btn: Button = get_node_or_null("HUD/BottomDock/HBox/PromoBtn")

# ─── Modals ─────────────────────────────────────────────────────────────────
@onready var upgrade_panel: PanelContainer = get_node_or_null("UpgradePanel")
@onready var upgrade_title: Label = get_node_or_null("UpgradePanel/VBox/StationCard/VBox/HeaderHBox/TitleLabel")
@onready var upgrade_level: Label = get_node_or_null("UpgradePanel/VBox/StationCard/VBox/HeaderHBox/LevelBadge") if get_node_or_null("UpgradePanel/VBox/StationCard/VBox/HeaderHBox/LevelBadge") != null else get_node_or_null("UpgradePanel/VBox/StationCard/VBox/HeaderHBox/LevelLabel")
@onready var upgrade_max_badge: Label = get_node_or_null("UpgradePanel/VBox/StationCard/VBox/HeaderHBox/MaxBadge")
@onready var upgrade_icon: Label = get_node_or_null("UpgradePanel/VBox/StationCard/VBox/BodyHBox/IconLabel")
@onready var upgrade_desc: Label = get_node_or_null("UpgradePanel/VBox/StationCard/VBox/BodyHBox/InfoVBox/DescLabel")
@onready var upgrade_income: Label = get_node_or_null("UpgradePanel/VBox/StationCard/VBox/BodyHBox/InfoVBox/IncomeLabel")
@onready var multi_1_btn: Button = get_node_or_null("UpgradePanel/VBox/StationCard/VBox/BodyHBox/ControlsVBox/MultiHBox/Multi1Btn")
@onready var multi_10_btn: Button = get_node_or_null("UpgradePanel/VBox/StationCard/VBox/BodyHBox/ControlsVBox/MultiHBox/Multi10Btn")
@onready var multi_max_btn: Button = get_node_or_null("UpgradePanel/VBox/StationCard/VBox/BodyHBox/ControlsVBox/MultiHBox/MultiMaxBtn")
@onready var upgrade_btn: Button = get_node_or_null("UpgradePanel/VBox/StationCard/VBox/BodyHBox/ControlsVBox/UpgradeBtn")
@onready var close_btn: Button = get_node_or_null("UpgradePanel/VBox/TopTabsHBox/CloseBtn")
@onready var tab_upgrades_btn: Button = get_node_or_null("UpgradePanel/VBox/TopTabsHBox/TabUpgradesBtn")
@onready var tab_staff_btn: Button = get_node_or_null("UpgradePanel/VBox/TopTabsHBox/TabStaffBtn")
@onready var zone_title_label: Label = get_node_or_null("UpgradePanel/VBox/HeaderBar/HBox/ZoneTitle")
@onready var hours_badge_label: Label = get_node_or_null("UpgradePanel/VBox/HeaderBar/HBox/HoursBadge")
@onready var upgrade_milestone_bar: ProgressBar = get_node_or_null("UpgradePanel/VBox/MilestoneBar")
var _station_progress_bar: ProgressBar = null
var star_dish_unlock_modal: Control = null
var piggy_bank_modal: Control = null
var investor_offer_modal: Control = null
var station_progress_bar: ProgressBar:
	get:
		if _station_progress_bar != null and is_instance_valid(_station_progress_bar):
			return _station_progress_bar
		_station_progress_bar = get_node_or_null("UpgradePanel/VBox/StationCard/VBox/StationMilestoneBox/BarTrack/StationProgressBar")
		return _station_progress_bar

var _ticks_overlay: Control = null
var ticks_overlay: Control:
	get:
		if _ticks_overlay != null and is_instance_valid(_ticks_overlay):
			return _ticks_overlay
		_ticks_overlay = get_node_or_null("UpgradePanel/VBox/StationCard/VBox/StationMilestoneBox/BarTrack/TicksOverlay")
		return _ticks_overlay

var _milestone_labels_hbox: HBoxContainer = null
var milestone_labels_hbox: HBoxContainer:
	get:
		if _milestone_labels_hbox != null and is_instance_valid(_milestone_labels_hbox):
			return _milestone_labels_hbox
		_milestone_labels_hbox = get_node_or_null("UpgradePanel/VBox/StationCard/VBox/StationMilestoneBox/MilestoneLabelsHBox")
		return _milestone_labels_hbox
@onready var sub_upgrade_grid: GridContainer = get_node_or_null("UpgradePanel/VBox/SubUpgradeGrid")
@onready var stat_cash_lbl: Label = get_node_or_null("UpgradePanel/VBox/StatsRibbon/HBox/CashStat")
@onready var stat_energy_lbl: Label = get_node_or_null("UpgradePanel/VBox/StatsRibbon/HBox/EnergyStat")
@onready var stat_gem_lbl: Label = get_node_or_null("UpgradePanel/VBox/StatsRibbon/HBox/GemStat")

@onready var dining_panel: PanelContainer = $DiningPanel
@onready var dining_vbox: VBoxContainer = $DiningPanel/VBox/Scroll/VBox
@onready var close_dining_btn: Button = $DiningPanel/VBox/CloseBtn

@onready var kitchen_panel: PanelContainer = $KitchenPanel
@onready var kitchen_vbox: VBoxContainer = $KitchenPanel/VBox/Scroll/VBox
@onready var close_kitchen_btn: Button = $KitchenPanel/VBox/CloseBtn

@onready var terrace_panel: PanelContainer = get_node_or_null("TerracePanel")
@onready var terrace_vbox: VBoxContainer = get_node_or_null("TerracePanel/VBox/Scroll/VBox")
@onready var close_terrace_btn: Button = get_node_or_null("TerracePanel/VBox/CloseBtn")

@onready var parking_panel: PanelContainer = get_node_or_null("ParkingPanel")
@onready var parking_vbox: VBoxContainer = get_node_or_null("ParkingPanel/VBox/Scroll/VBox")
@onready var close_parking_btn: Button = get_node_or_null("ParkingPanel/VBox/CloseBtn")

@onready var staff_panel: PanelContainer = get_node_or_null("StaffPanel")
@onready var staff_vbox: VBoxContainer = get_node_or_null("StaffPanel/VBox/StaffScroll/StaffVBox")
@onready var close_staff_btn: Button = get_node_or_null("StaffPanel/VBox/TopTabsHBox/CloseStaffBtn")
@onready var staff_tab_upgrades_btn: Button = get_node_or_null("StaffPanel/VBox/TopTabsHBox/TabUpgradesBtn")

@onready var marketing_panel: PanelContainer = get_node_or_null("MarketingPanel")
@onready var marketing_vbox: VBoxContainer = get_node_or_null("MarketingPanel/VBox/Scroll/VBox")
@onready var close_marketing_btn: Button = get_node_or_null("MarketingPanel/VBox/CloseBtn")

@onready var quests_panel: PanelContainer = $QuestsPanel
@onready var quests_vbox: VBoxContainer = $QuestsPanel/VBox/Scroll/VBox
@onready var close_quests_btn: Button = $QuestsPanel/VBox/CloseBtn

# ─── World Map & Right Action Dock ──────────────────────────────────────────
@onready var map_btn: Button = get_node_or_null("HUD/LeftDock/MapBtn") if get_node_or_null("HUD/LeftDock/MapBtn") != null else (get_node_or_null("HUD/TopBar/MapBtn") if get_node_or_null("HUD/TopBar/MapBtn") != null else get_node_or_null("HUD/RightDock/SideMapBtn"))
@onready var side_map_btn: Button = get_node_or_null("HUD/LeftDock/MapBtn") if get_node_or_null("HUD/LeftDock/MapBtn") != null else get_node_or_null("HUD/RightDock/SideMapBtn")
@onready var side_piggy_bank_btn: Button = get_node_or_null("HUD/RightDock/SidePiggyBankBtn")
@onready var piggy_counter_label: Label = get_node_or_null("HUD/RightDock/SidePiggyBankBtn/DiamondPill/CounterLabel")
@onready var side_ad_btn: Button = get_node_or_null("HUD/RightDock/SideAdBtn")
@onready var side_settings_btn: Button = get_node_or_null("HUD/RightDock/SideSettingsBtn")
@onready var side_lightbulb_btn: Button = get_node_or_null("HUD/RightDock/SideLightbulbBtn")
@onready var side_stats_btn: Button = get_node_or_null("HUD/RightDock/SideStatsBtn")
@onready var side_staff_btn: Button = get_node_or_null("HUD/RightDock/SideStaffBtn")

@onready var clock_label: Label = get_node_or_null("HUD/TopBar/ClockPanel/HBox/ClockLabel")
@onready var energy_label: Label = get_node_or_null("HUD/TopBar/EnergyPanel/HBox/EnergyLabel")
@onready var live_label: Label = get_node_or_null("HUD/TopBar/LivePanel/HBox/LiveLabel")
@onready var status_ribbons: VBoxContainer = get_node_or_null("HUD/StatusRibbons")

@onready var world_map_panel: PanelContainer = get_node_or_null("WorldMapPanel")
@onready var world_map_grid: GridContainer = get_node_or_null("WorldMapPanel/VBox/Scroll/CardsGrid")
@onready var close_world_map_btn: Button = get_node_or_null("WorldMapPanel/VBox/TopHBox/CloseWorldMapBtn")

@onready var floating_boost_btn: Button = get_node_or_null("HUD/FloatingBoostBanner")
@onready var activate_all_managers_btn: Button = get_node_or_null("HUD/ActivateAllManagersBtn")
var staff_refresh_timer: float = 0.0
@onready var ribbon_marketing: PanelContainer = get_node_or_null("HUD/StatusRibbons/RibbonMarketing")
@onready var ribbon_marketing_lbl: Label = get_node_or_null("HUD/StatusRibbons/RibbonMarketing/Label")
@onready var ribbon_parking: PanelContainer = get_node_or_null("HUD/StatusRibbons/RibbonParking")
@onready var ribbon_parking_lbl: Label = get_node_or_null("HUD/StatusRibbons/RibbonParking/Label")
@onready var ribbon_cleaning: PanelContainer = get_node_or_null("HUD/StatusRibbons/RibbonCleaning")
@onready var ribbon_cleaning_lbl: Label = get_node_or_null("HUD/StatusRibbons/RibbonCleaning/Label")
var boost_timer_bar: Panel = null
@onready var shop_btn: Button = get_node_or_null("HUD/LeftDock/ShopBtn") if get_node_or_null("HUD/LeftDock/ShopBtn") != null else get_node_or_null("HUD/ShopBtn")
@onready var shop_panel: PanelContainer = get_node_or_null("ShopPanel")
@onready var shop_vbox: VBoxContainer = get_node_or_null("ShopPanel/VBox/Scroll/ItemsVBox")
@onready var close_shop_btn: Button = get_node_or_null("ShopPanel/VBox/HeaderBanner/BannerHBox/CloseShopBtn") if get_node_or_null("ShopPanel/VBox/HeaderBanner/BannerHBox/CloseShopBtn") != null else get_node_or_null("ShopPanel/VBox/TopHBox/CloseShopBtn")
@onready var tab_featured_btn: Button = get_node_or_null("ShopPanel/VBox/TabsScroll/TabsHBox/TabFeatured")
@onready var tab_boosts_btn: Button = get_node_or_null("ShopPanel/VBox/TabsScroll/TabsHBox/TabBoosts")
@onready var tab_timeskips_btn: Button = get_node_or_null("ShopPanel/VBox/TabsScroll/TabsHBox/TabTimeSkips")
@onready var tab_chests_btn: Button = get_node_or_null("ShopPanel/VBox/TabsScroll/TabsHBox/TabChests")
@onready var tab_currencies_btn: Button = get_node_or_null("ShopPanel/VBox/TabsScroll/TabsHBox/TabCurrencies")

@onready var analytics_panel: PanelContainer = get_node_or_null("AnalyticsPanel")
@onready var analytics_vbox: VBoxContainer = get_node_or_null("AnalyticsPanel/VBox/Scroll/VBox")
@onready var close_analytics_btn: Button = get_node_or_null("AnalyticsPanel/VBox/CloseBtn")

@onready var perks_panel: PanelContainer = get_node_or_null("PerksPanel")
@onready var perks_vbox: VBoxContainer = get_node_or_null("PerksPanel/VBox/Scroll/VBox")
@onready var close_perks_btn: Button = get_node_or_null("PerksPanel/VBox/CloseBtn")

@onready var currency_trails_layer: Control = get_node_or_null("HUD/CurrencyTrailsLayer")
@onready var header_multi_pill: PanelContainer = get_node_or_null("UpgradePanel/VBox/HeaderBar/HBox/MultiTogglePill")
@onready var header_multi_1_btn: Button = get_node_or_null("UpgradePanel/VBox/HeaderBar/HBox/MultiTogglePill/PillHBox/HeaderMulti1Btn")
@onready var header_multi_10_btn: Button = get_node_or_null("UpgradePanel/VBox/HeaderBar/HBox/MultiTogglePill/PillHBox/HeaderMulti10Btn")
@onready var header_multi_max_btn: Button = get_node_or_null("UpgradePanel/VBox/HeaderBar/HBox/MultiTogglePill/PillHBox/HeaderMultiMaxBtn")

@onready var cards_btn: Button = get_node_or_null("HUD/BottomDock/HBox/CardsBtn")
@onready var side_cards_btn: Button = get_node_or_null("HUD/RightDock/SideCardsBtn")
@onready var cards_panel: PanelContainer = get_node_or_null("CardsPanel")
@onready var cards_grid: GridContainer = get_node_or_null("CardsPanel/VBox/Scroll/CardsGrid")
@onready var close_cards_btn: Button = get_node_or_null("CardsPanel/VBox/CloseBtn")
@onready var close_cards_banner_btn: Button = get_node_or_null("CardsPanel/VBox/HeaderBanner/BannerHBox/CloseCardsBtn")

@onready var chest_reward_modal: PanelContainer = get_node_or_null("ChestRewardModal")
@onready var chest_reward_header: Label = get_node_or_null("ChestRewardModal/VBox/Header")
@onready var chest_reward_currencies_box: HBoxContainer = get_node_or_null("ChestRewardModal/VBox/CurrenciesHBox")
@onready var chest_reward_cards_box: VBoxContainer = get_node_or_null("ChestRewardModal/VBox/Scroll/CardsContainer")
@onready var chest_reward_collect_btn: Button = get_node_or_null("ChestRewardModal/VBox/CollectBtn")

@onready var side_spin_btn: Button = get_node_or_null("HUD/RightDock/SideSpinBtn")
@onready var spin_modal: PanelContainer = get_node_or_null("SpinWheelModal")
@onready var spin_tab_btn: Button = get_node_or_null("SpinWheelModal/VBox/TabsHBox/TabSpinBtn")
@onready var daily_tab_btn: Button = get_node_or_null("SpinWheelModal/VBox/TabsHBox/TabDailyBtn")
@onready var spin_view: VBoxContainer = get_node_or_null("SpinWheelModal/VBox/SpinView")
@onready var daily_view: VBoxContainer = get_node_or_null("SpinWheelModal/VBox/DailyView")
@onready var wheel_graphic: Control = get_node_or_null("SpinWheelModal/VBox/SpinView/WheelCenterContainer/WheelGraphic")
@onready var spin_status_label: Label = get_node_or_null("SpinWheelModal/VBox/SpinView/SpinStatusLabel")
@onready var spin_action_btn: Button = get_node_or_null("SpinWheelModal/VBox/SpinView/SpinActionBtn")
@onready var spin_result_label: Label = get_node_or_null("SpinWheelModal/VBox/SpinView/SpinResultLabel")
@onready var streak_label: Label = get_node_or_null("SpinWheelModal/VBox/DailyView/StreakLabel")
@onready var daily_cards_container: GridContainer = get_node_or_null("SpinWheelModal/VBox/DailyView/DailyScroll/DailyCardsContainer")
@onready var claim_daily_btn: Button = get_node_or_null("SpinWheelModal/VBox/DailyView/ClaimDailyBtn")
@onready var close_spin_btn: Button = get_node_or_null("SpinWheelModal/VBox/CloseSpinBtn")
@onready var close_spin_banner_btn: Button = get_node_or_null("SpinWheelModal/VBox/HeaderBanner/BannerHBox/CloseSpinBannerBtn")

var quest_banner_style_normal: StyleBoxFlat = null
var quest_banner_style_completed: StyleBoxFlat = null
var is_spinning_wheel: bool = false
var wheel_labels_initialized: bool = false

var current_station_id: String = ""
var current_multiplier: String = "1"
var current_shop_category: String = "featured"
var displayed_cash: float = 650.0
var displayed_gold: float = 150.0
var displayed_gems: float = 50.0
var displayed_rate: float = 0.0
var cash_tween: Tween = null
var gold_tween: Tween = null
var gems_tween: Tween = null
var rate_tween: Tween = null
var sim_time_minutes: float = 8.0 * 60.0 + 34.0
var analytics_refresh_timer: float = 0.0

# ─── Hold-to-Upgrade State ──────────────────────────────────────────────────
var _is_holding_upgrade: bool = false
var _hold_station_id: String = ""
var _hold_is_staff: bool = false
var _hold_timer: float = 0.0
var _hold_consecutive: int = 0
var _hold_delay_passed: bool = false
var _just_upgraded_on_hold: bool = false
const HOLD_INITIAL_DELAY: float = 0.35

var cash_texture: Texture2D = null
var gold_texture: Texture2D = null
var diamond_texture: Texture2D = null
var energy_texture: Texture2D = null
var _custom_textures: Dictionary = {}

func get_custom_texture(res_path: String) -> ImageTexture:
	if _custom_textures.has(res_path):
		return _custom_textures[res_path]
	var global_path = ProjectSettings.globalize_path(res_path)
	if FileAccess.file_exists(global_path):
		var img = Image.load_from_file(global_path)
		if img != null:
			var tex = ImageTexture.create_from_image(img)
			_custom_textures[res_path] = tex
			return tex
	return null

var style_multi_active: StyleBoxFlat = null
var style_multi_inactive: StyleBoxFlat = null
var shop_tab_style_active: StyleBoxFlat = null
var shop_tab_style_inactive: StyleBoxFlat = null

# ─── VIP Arrival Alert Toast & Bottleneck Status ─────────────────────────────
var active_vip_toast: PanelContainer = null
var active_vip_node: Node3D = null
var active_vip_duration: float = 0.0
var active_vip_timer: float = 0.0
var active_vip_progress_bar: ProgressBar = null

func _get_game_manager() -> Node:
	if is_inside_tree():
		var n = get_node_or_null("/root/GameManager")
		if n != null:
			return n
	var loop = Engine.get_main_loop()
	if loop is SceneTree:
		var st = loop as SceneTree
		if st.root != null:
			return st.root.get_node_or_null("GameManager")
	return null

func _get_audio_manager() -> Node:
	if is_inside_tree():
		var n = get_node_or_null("/root/AudioManager")
		if n != null:
			return n
	var loop = Engine.get_main_loop()
	if loop is SceneTree:
		var st = loop as SceneTree
		if st.root != null:
			return st.root.get_node_or_null("AudioManager")
	return null

func _setup_currency_hud_icons() -> void:
	var cash_tex = get_custom_texture("res://assets/textures/bubble_cash_stack.png")
	if cash_tex != null:
		var cash_p = get_node_or_null("HUD/TopBar/CashPanel")
		if cash_p is Control:
			cash_p.clip_contents = false
		var cash_icon_lbl = get_node_or_null("HUD/TopBar/CashPanel/HBox/Icon")
		if cash_icon_lbl is Label and cash_icon_lbl.get_parent() != null:
			var p = cash_icon_lbl.get_parent()
			var idx = cash_icon_lbl.get_index()
			cash_icon_lbl.queue_free()
			var tr = TextureRect.new()
			tr.name = "Icon"
			tr.texture = cash_tex
			tr.custom_minimum_size = Vector2(30, 30)
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			p.add_child(tr)
			p.move_child(tr, idx)

	var dia_tex = get_custom_texture("res://assets/textures/icon_diamond.png")
	if dia_tex != null:
		var gem_p = get_node_or_null("HUD/TopBar/GemPanel")
		if gem_p is Control:
			gem_p.clip_contents = false
		var gem_icon_lbl = get_node_or_null("HUD/TopBar/GemPanel/HBox/Icon")
		if gem_icon_lbl is Label and gem_icon_lbl.get_parent() != null:
			var p = gem_icon_lbl.get_parent()
			var idx = gem_icon_lbl.get_index()
			gem_icon_lbl.queue_free()
			var tr = TextureRect.new()
			tr.name = "Icon"
			tr.texture = dia_tex
			tr.custom_minimum_size = Vector2(28, 28)
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			p.add_child(tr)
			p.move_child(tr, idx)

	var gold_tex = get_custom_texture("res://assets/textures/icon_gold_coin.png")
	if gold_tex != null:
		var gold_p = get_node_or_null("HUD/TopBar/GoldCoinPanel")
		if gold_p is Control:
			gold_p.clip_contents = false
		var gold_icon_lbl = get_node_or_null("HUD/TopBar/GoldCoinPanel/HBox/Icon")
		if gold_icon_lbl is Label and gold_icon_lbl.get_parent() != null:
			var p = gold_icon_lbl.get_parent()
			var idx = gold_icon_lbl.get_index()
			gold_icon_lbl.queue_free()
			var tr = TextureRect.new()
			tr.name = "Icon"
			tr.texture = gold_tex
			tr.custom_minimum_size = Vector2(28, 28)
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			p.add_child(tr)
			p.move_child(tr, idx)

	var energy_tex_res = get_custom_texture("res://assets/textures/icon_energy.png")
	if energy_tex_res != null:
		var energy_p = get_node_or_null("HUD/TopBar/EnergyPanel")
		if energy_p is Control:
			energy_p.clip_contents = false
		var energy_icon_lbl = get_node_or_null("HUD/TopBar/EnergyPanel/HBox/Icon")
		if energy_icon_lbl is Label and energy_icon_lbl.get_parent() != null:
			var p = energy_icon_lbl.get_parent()
			var idx = energy_icon_lbl.get_index()
			energy_icon_lbl.queue_free()
			var tr = TextureRect.new()
			tr.name = "Icon"
			tr.texture = energy_tex_res
			tr.custom_minimum_size = Vector2(28, 28)
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			p.add_child(tr)
			p.move_child(tr, idx)

func _check_cinematic_entrance() -> void:
	var cam = get_viewport().get_camera_3d() if is_inside_tree() else null
	if cam == null and get_parent() != null:
		cam = get_parent().find_child("Camera3D", true, false)
	if cam != null and cam.get("is_performing_cinematic_reveal") == true:
		_setup_hud_entrance(cam)

func _setup_hud_entrance(cam: Camera3D) -> void:
	var hud_root = get_node_or_null("HUD")
	if hud_root is Control:
		hud_root.modulate.a = 0.0
	if not cam.is_connected("cinematic_reveal_completed", _play_hud_entrance):
		cam.cinematic_reveal_completed.connect(_play_hud_entrance, CONNECT_ONE_SHOT)

func _play_hud_entrance() -> void:
	var hud_root = get_node_or_null("HUD")
	if hud_root is Control:
		var tw = create_tween()
		tw.tween_property(hud_root, "modulate:a", 1.0, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _ready() -> void:
	_check_cinematic_entrance()
	_hide_all_modals()
	_setup_currency_hud_icons()
	_apply_mobile_kolibri_ui_styling()
	
	if boost_btn != null and not boost_btn.pressed.is_connected(_on_boost_pressed):
		boost_btn.pressed.connect(_on_boost_pressed)
	_ensure_rush_hour_button()
	if add_gem_btn != null: add_gem_btn.pressed.connect(func(): _open_shop_at_section("currencies"))
	if add_gold_btn != null: add_gold_btn.pressed.connect(func(): _open_shop_at_section("currencies"))
	if add_energy_btn != null: add_energy_btn.pressed.connect(func(): _open_shop_at_section("currencies"))

	if tab_featured_btn != null: tab_featured_btn.pressed.connect(func(): _select_shop_category("featured"))
	if tab_boosts_btn != null: tab_boosts_btn.pressed.connect(func(): _select_shop_category("boosts"))
	if tab_timeskips_btn != null: tab_timeskips_btn.pressed.connect(func(): _select_shop_category("timeskips"))
	if tab_chests_btn != null: tab_chests_btn.pressed.connect(func(): _select_shop_category("chests"))
	if tab_currencies_btn != null: tab_currencies_btn.pressed.connect(func(): _select_shop_category("currencies"))
	
	# Navigation Dock with Camera Smooth Glides
	if nav_parking_btn != null:
		nav_parking_btn.pressed.connect(func():
			_focus_camera("parking")
			_toggle_modal(parking_panel, _refresh_parking_panel)
		)
	if nav_kitchen_btn != null:
		nav_kitchen_btn.pressed.connect(func():
			_focus_camera("kitchen")
			var gm = get_node_or_null("/root/GameManager")
			var lvl = gm.get_station_level("stove") if gm != null else 1
			open_upgrade("stove", "Master Range Stoves", lvl)
		)
	if nav_dining_btn != null:
		nav_dining_btn.pressed.connect(func():
			_focus_camera("dining")
			var gm = get_node_or_null("/root/GameManager")
			var lvl = gm.get_station_level("table_1") if gm != null else 1
			open_upgrade("table_1", "Booth Table 1", lvl)
		)
	if nav_milkshake_btn != null:
		nav_milkshake_btn.pressed.connect(func():
			_focus_camera("milkshake")
			var gm = get_node_or_null("/root/GameManager")
			var lvl = gm.get_station_level("milkshake_bar") if gm != null else 1
			open_upgrade("milkshake_bar", "Bar Top Counter", lvl)
		)
	if nav_terrace_btn != null:
		nav_terrace_btn.pressed.connect(func():
			_focus_camera("terrace")
			_toggle_modal(terrace_panel, _refresh_terrace_panel)
		)
	if nav_staff_btn != null:
		nav_staff_btn.pressed.connect(func():
			_toggle_modal(staff_panel, _refresh_staff_panel)
		)
	if nav_promo_btn != null:
		nav_promo_btn.pressed.connect(func():
			_toggle_modal(marketing_panel, _refresh_marketing_panel)
		)
	if cards_btn != null:
		cards_btn.pressed.connect(func():
			_toggle_modal(cards_panel, _refresh_cards_panel)
		)
	
	# Quest Banner Click & Styles
	quest_banner_style_normal = create_mobile_inner_card_style()

	quest_banner_style_completed = StyleBoxFlat.new()
	quest_banner_style_completed.bg_color = Color(0.22, 0.847, 0.282, 0.98)
	quest_banner_style_completed.border_width_left = 2
	quest_banner_style_completed.border_width_top = 2
	quest_banner_style_completed.border_width_right = 2
	quest_banner_style_completed.border_width_bottom = 5
	quest_banner_style_completed.border_color = Color(0.12, 0.52, 0.18, 1.0)
	quest_banner_style_completed.set_corner_radius_all(18)
	quest_banner_style_completed.content_margin_left = 14.0
	quest_banner_style_completed.content_margin_top = 8.0
	quest_banner_style_completed.content_margin_right = 14.0
	quest_banner_style_completed.content_margin_bottom = 8.0
	quest_banner_style_completed.shadow_color = Color(0.1, 0.5, 0.2, 0.4)
	quest_banner_style_completed.shadow_size = 8

	quest_banner.gui_input.connect(_on_quest_banner_input)
	quest_claim_btn.pressed.connect(_on_banner_claim_pressed)
	
	# Upgrade Modal & Multiplier Buttons
	style_multi_active = create_mobile_action_button_style(Color(1.0, 0.624, 0.11, 1.0), Color(0.72, 0.35, 0.05, 1.0), false, 10)
	style_multi_active.content_margin_left = 10.0
	style_multi_active.content_margin_top = 4.0
	style_multi_active.content_margin_right = 10.0
	style_multi_active.content_margin_bottom = 4.0

	style_multi_inactive = StyleBoxFlat.new()
	style_multi_inactive.bg_color = Color(0.88, 0.82, 0.72, 0.85)
	style_multi_inactive.border_width_bottom = 2
	style_multi_inactive.border_color = Color(0.72, 0.65, 0.55, 0.8)
	style_multi_inactive.set_corner_radius_all(10)
	style_multi_inactive.content_margin_left = 10.0
	style_multi_inactive.content_margin_top = 4.0
	style_multi_inactive.content_margin_right = 10.0
	style_multi_inactive.content_margin_bottom = 4.0

	if multi_1_btn != null: multi_1_btn.pressed.connect(func(): _set_multiplier("1"))
	if multi_10_btn != null: multi_10_btn.pressed.connect(func(): _set_multiplier("10"))
	if multi_max_btn != null: multi_max_btn.pressed.connect(func(): _set_multiplier("MAX"))
	if header_multi_1_btn != null: header_multi_1_btn.pressed.connect(func(): _set_multiplier("1"))
	if header_multi_10_btn != null: header_multi_10_btn.pressed.connect(func(): _set_multiplier("10"))
	if header_multi_max_btn != null: header_multi_max_btn.pressed.connect(func(): _set_multiplier("MAX"))
	if upgrade_btn != null:
		_connect_hold_upgrade_button(upgrade_btn, func(): return current_station_id)
		upgrade_btn.pressed.connect(_on_upgrade_pressed)
	if close_btn != null: close_btn.pressed.connect(func(): _close_modal(upgrade_panel))
	if tab_upgrades_btn != null: tab_upgrades_btn.pressed.connect(func():
		_play_click_sfx()
		var gm = get_node_or_null("/root/GameManager")
		var sid = current_station_id if current_station_id != "" else "milkshake_bar"
		var lvl = gm.get_station_level(sid) if gm != null else 1
		open_upgrade(sid, "Bar Top" if sid.begins_with("milkshake") else "Dining", lvl)
	)
	if tab_staff_btn != null: tab_staff_btn.pressed.connect(func():
		_toggle_modal(staff_panel, _refresh_staff_panel)
	)
	
	# Modal Close Buttons
	if close_dining_btn != null: close_dining_btn.pressed.connect(func(): _close_modal(dining_panel))
	if close_kitchen_btn != null: close_kitchen_btn.pressed.connect(func(): _close_modal(kitchen_panel))
	if close_terrace_btn != null: close_terrace_btn.pressed.connect(func(): _close_modal(terrace_panel))
	if close_parking_btn != null: close_parking_btn.pressed.connect(func(): _close_modal(parking_panel))
	if close_staff_btn != null: close_staff_btn.pressed.connect(func(): _close_modal(staff_panel))
	if staff_tab_upgrades_btn != null:
		staff_tab_upgrades_btn.pressed.connect(func():
			_play_click_sfx()
			var gm = get_node_or_null("/root/GameManager")
			var lvl = gm.get_station_level("stove") if gm != null else 1
			open_upgrade("stove", "Master Range Stoves", lvl)
		)
	if close_marketing_btn != null: close_marketing_btn.pressed.connect(func(): _close_modal(marketing_panel))
	if close_quests_btn != null: close_quests_btn.pressed.connect(func(): _close_modal(quests_panel))
	if close_world_map_btn != null: close_world_map_btn.pressed.connect(func(): _close_modal(world_map_panel))
	if close_shop_btn != null: close_shop_btn.pressed.connect(func(): _close_modal(shop_panel))
	if close_analytics_btn != null: close_analytics_btn.pressed.connect(func(): _close_modal(analytics_panel))
	if close_perks_btn != null: close_perks_btn.pressed.connect(func(): _close_modal(perks_panel))

	if floating_boost_btn != null:
		floating_boost_btn.pressed.connect(_on_boost_pressed)
		if boost_timer_bar == null:
			boost_timer_bar = Panel.new()
			boost_timer_bar.name = "GoldenTimerBar"
			boost_timer_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
			boost_timer_bar.anchor_left = 0.0
			boost_timer_bar.anchor_top = 0.88
			boost_timer_bar.anchor_right = 1.0
			boost_timer_bar.anchor_bottom = 1.0
			boost_timer_bar.offset_left = 6.0
			boost_timer_bar.offset_right = -6.0
			boost_timer_bar.offset_top = -3.0
			boost_timer_bar.offset_bottom = -2.0
			
			var sb = StyleBoxFlat.new()
			sb.bg_color = Color(1.0, 0.84, 0.2, 0.95)
			sb.set_corner_radius_all(4)
			boost_timer_bar.add_theme_stylebox_override("panel", sb)
			floating_boost_btn.add_child(boost_timer_bar)
			boost_timer_bar.visible = false

	if activate_all_managers_btn != null:
		activate_all_managers_btn.pressed.connect(_on_activate_all_managers_pressed)

	if ribbon_marketing != null:
		ribbon_marketing.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				_play_click_sfx()
				_toggle_modal(analytics_panel, _refresh_analytics_panel)
		)

	if ribbon_parking != null:
		ribbon_parking.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				_play_click_sfx()
				_toggle_modal(analytics_panel, _refresh_analytics_panel)
		)

	if ribbon_cleaning != null:
		ribbon_cleaning.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				_play_click_sfx()
				var gm = get_node_or_null("/root/GameManager")
				if gm != null and gm.has_method("trigger_rapid_sanitation"):
					var success = gm.trigger_rapid_sanitation()
					if not success:
						_toggle_modal(analytics_panel, _refresh_analytics_panel)
				else:
					_toggle_modal(analytics_panel, _refresh_analytics_panel)
		)

	if shop_btn != null:
		shop_btn.pressed.connect(func():
			_toggle_modal(shop_panel, _refresh_shop_panel)
		)

	if map_btn != null:
		map_btn.pressed.connect(func():
			_toggle_modal(world_map_panel, _refresh_world_map)
		)
	if side_map_btn != null:
		side_map_btn.pressed.connect(func():
			_toggle_modal(world_map_panel, _refresh_world_map)
		)
	if side_ad_btn != null:
		side_ad_btn.pressed.connect(func():
			_play_click_sfx()
			_on_boost_pressed()
		)
	if side_settings_btn != null:
		side_settings_btn.pressed.connect(func():
			_toggle_modal(marketing_panel, _refresh_marketing_panel)
		)
	if side_piggy_bank_btn != null:
		side_piggy_bank_btn.pressed.connect(func():
			open_piggy_bank_modal()
		)
	if side_lightbulb_btn != null:
		side_lightbulb_btn.pressed.connect(func():
			_toggle_modal(perks_panel, _refresh_perks_panel)
		)
	if side_stats_btn != null:
		side_stats_btn.pressed.connect(func():
			_toggle_modal(analytics_panel, _refresh_analytics_panel)
		)
	if side_staff_btn != null:
		side_staff_btn.pressed.connect(func():
			_toggle_modal(staff_panel, _refresh_staff_panel)
		)
	if side_cards_btn != null:
		side_cards_btn.pressed.connect(func():
			_toggle_modal(cards_panel, _refresh_cards_panel)
		)
	if side_spin_btn != null:
		side_spin_btn.pressed.connect(func():
			_toggle_modal(spin_modal, _refresh_spin_wheel)
		)

	if close_cards_btn != null:
		close_cards_btn.pressed.connect(func(): _close_modal(cards_panel))
	if close_cards_banner_btn != null:
		close_cards_banner_btn.pressed.connect(func(): _close_modal(cards_panel))
	if chest_reward_collect_btn != null:
		chest_reward_collect_btn.pressed.connect(func(): _close_modal(chest_reward_modal))

	if close_spin_btn != null:
		close_spin_btn.pressed.connect(func(): _close_modal(spin_modal))
	if close_spin_banner_btn != null:
		close_spin_banner_btn.pressed.connect(func(): _close_modal(spin_modal))
	if spin_tab_btn != null:
		spin_tab_btn.pressed.connect(_on_spin_tab_pressed)
	if daily_tab_btn != null:
		daily_tab_btn.pressed.connect(_on_daily_tab_pressed)
	if spin_action_btn != null:
		spin_action_btn.pressed.connect(_on_spin_action_pressed)
	if claim_daily_btn != null:
		claim_daily_btn.pressed.connect(_on_claim_daily_pressed)
	if wheel_graphic != null:
		wheel_graphic.draw.connect(_on_wheel_graphic_draw)

	# Connect GameManager signals
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		if gm.has_signal("station_milestone_reached"):
			gm.station_milestone_reached.connect(_on_station_milestone_reached)
		if gm.has_signal("objective_updated"):
			gm.objective_updated.connect(func(_obj): _refresh_quest_banner())
		if gm.has_signal("objective_claimed"):
			gm.objective_claimed.connect(func(_rew): _refresh_quest_banner())
		if gm.has_signal("spin_wheel_completed"):
			gm.spin_wheel_completed.connect(func(_idx, _prize): _refresh_spin_wheel())
		if gm.has_signal("daily_login_claimed"):
			gm.daily_login_claimed.connect(func(_day, _reward): _refresh_daily_login())
		if gm.has_signal("chest_opened"):
			gm.chest_opened.connect(_on_chest_opened)
		if gm.has_signal("cards_updated"):
			gm.cards_updated.connect(_on_cards_updated)
		gm.cash_changed.connect(_on_cash_changed)
		gm.gems_changed.connect(_on_gems_changed)
		if gm.has_signal("golden_coins_changed"):
			gm.golden_coins_changed.connect(_on_golden_coins_changed)
		if gm.has_signal("diamonds_changed"):
			gm.diamonds_changed.connect(_on_gems_changed)
		if gm.has_signal("energy_changed"):
			if not gm.energy_changed.is_connected(_on_energy_changed):
				gm.energy_changed.connect(_on_energy_changed)
		if gm.has_signal("currencies_updated"):
			gm.currencies_updated.connect(_on_currencies_updated)
		if gm.has_signal("time_skip_activated"):
			gm.time_skip_activated.connect(_on_time_skip_activated)
		if gm.has_signal("overdrive_boost_activated"):
			gm.overdrive_boost_activated.connect(_on_overdrive_boost_activated)
		if gm.has_signal("franchise_prestiged"):
			gm.franchise_prestiged.connect(_on_franchise_prestiged)
		if gm.has_signal("prestige_updated"):
			gm.prestige_updated.connect(func(_l, _k, _m):
				if world_map_panel != null and world_map_panel.visible:
					_refresh_world_map()
			)
		if gm.has_signal("franchise_keys_changed"):
			gm.franchise_keys_changed.connect(func(_k):
				if world_map_panel != null and world_map_panel.visible:
					_refresh_world_map()
			)
		gm.cash_rate_updated.connect(_on_cash_rate_updated)
		gm.level_updated.connect(_on_level_updated)
		gm.station_upgraded.connect(_on_station_upgraded)
		gm.boost_toggled.connect(_on_boost_toggled)
		gm.staff_updated.connect(_on_staff_updated)
		if gm.has_signal("manager_skill_activated"):
			gm.manager_skill_activated.connect(func(_sec):
				if staff_panel != null and staff_panel.visible:
					_refresh_staff_panel()
			)
		if gm.has_signal("manager_skill_ended"):
			gm.manager_skill_ended.connect(func(_sec):
				if staff_panel != null and staff_panel.visible:
					_refresh_staff_panel()
			)
		if gm.has_signal("manager_skill_ready"):
			gm.manager_skill_ready.connect(func(_sec):
				if staff_panel != null and staff_panel.visible:
					_refresh_staff_panel()
			)
		if gm.has_signal("manager_assigned"):
			gm.manager_assigned.connect(func(_sec, _tier):
				if staff_panel != null and staff_panel.visible:
					_refresh_staff_panel()
			)
		gm.table_unlocked.connect(_on_table_unlocked)
		gm.quests_updated.connect(_on_quests_updated)
		gm.campaign_updated.connect(_on_campaign_updated)
		gm.offline_earnings_available.connect(_on_offline_earnings_available)
		gm.critic_review_awarded.connect(_on_critic_review_awarded)
		if gm.has_signal("star_dish_unlocked") and not gm.star_dish_unlocked.is_connected(_on_star_dish_unlocked):
			gm.star_dish_unlocked.connect(_on_star_dish_unlocked)
		if gm.has_signal("piggy_bank_updated"):
			if not gm.piggy_bank_updated.is_connected(_on_piggy_bank_updated):
				gm.piggy_bank_updated.connect(_on_piggy_bank_updated)
			_on_piggy_bank_updated(gm.get_piggy_bank_diamonds(), gm.PIGGY_BANK_CAP)
		if gm.has_signal("investor_offer_requested"):
			if not gm.investor_offer_requested.is_connected(_on_investor_offer_requested):
				gm.investor_offer_requested.connect(_on_investor_offer_requested)
		if gm.has_signal("spawn_flying_currency_trail"):
			gm.spawn_flying_currency_trail.connect(spawn_flying_currency_trail)
		if gm.has_signal("marketing_changed"):
			gm.marketing_changed.connect(func():
				_update_marketing_ribbon()
				if marketing_panel != null and marketing_panel.visible:
					_refresh_marketing_panel()
			)
		if gm.has_signal("marketing_upgraded"):
			gm.marketing_upgraded.connect(func(_lvl):
				_update_marketing_ribbon()
				if marketing_panel != null and marketing_panel.visible:
					_refresh_marketing_panel()
			)
		if gm.has_signal("world_restaurants_updated"):
			gm.world_restaurants_updated.connect(func():
				if world_map_panel != null and world_map_panel.visible:
					_refresh_world_map()
			)
		if gm.has_signal("perks_updated"):
			gm.perks_updated.connect(func():
				if perks_panel != null and perks_panel.visible:
					_refresh_perks_panel()
			)
		if gm.has_signal("shop_updated"):
			gm.shop_updated.connect(func():
				if shop_panel != null and shop_panel.visible:
					_refresh_shop_panel()
			)
		if gm.has_signal("vip_arrived"):
			gm.vip_arrived.connect(_on_vip_arrived)
		gm.menu_updated.connect(func():
			if kitchen_panel != null and kitchen_panel.visible:
				_refresh_kitchen_panel()
			if perks_panel != null and perks_panel.visible:
				_refresh_perks_panel()
		)
		if gm.has_signal("cleanliness_updated"):
			gm.cleanliness_updated.connect(func(_new_cln):
				_update_status_ribbons()
				_update_top_bar(gm.cash, gm.gems, gm.star_rating, gm.restaurant_name, gm.restaurant_level, gm.restaurant_xp, gm.xp_to_next_level)
			)
		if gm.has_signal("rapid_sanitation_triggered"):
			gm.rapid_sanitation_triggered.connect(func(cost_deducted):
				_update_status_ribbons()
				_update_top_bar(gm.cash, gm.gems, gm.star_rating, gm.restaurant_name, gm.restaurant_level, gm.restaurant_xp, gm.xp_to_next_level)
				_show_rapid_sanitation_banner(cost_deducted)
			)
		
		
		displayed_cash = gm.cash
		displayed_gold = float(gm.golden_coins)
		displayed_gems = float(gm.diamonds)
		displayed_rate = gm.get_effective_cash_per_sec()
		_update_top_bar(gm.cash, gm.gems, gm.star_rating, gm.restaurant_name, gm.restaurant_level, gm.restaurant_xp, gm.xp_to_next_level)
		if gold_label != null:
			gold_label.text = "%d" % gm.golden_coins
		if energy_label != null:
			energy_label.text = "%d/%d" % [gm.energy, gm.max_energy]
		if cash_rate_label != null:
			cash_rate_label.text = "+%s/s" % _format_money(displayed_rate)
		_set_multiplier("1")
		_refresh_quest_banner()
		_refresh_star_milestone_bar()
	
	_wire_all_buttons_in_tree(self)
	_update_affordability_badges()

# ─── Tactile Squash-and-Stretch & Affordability Feedback ────────────────────
func apply_button_squash_and_stretch(btn: Button) -> void:
	if btn == null or not is_instance_valid(btn):
		return
	btn.pivot_offset = btn.size * 0.5
	var tw = create_tween()
	tw.tween_property(btn, "scale", Vector2(0.92, 0.92), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(btn, "scale", Vector2(1.04, 1.04), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(btn, "scale", Vector2.ONE, 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _wire_button_bounce(btn: Button) -> void:
	if btn == null or not is_instance_valid(btn):
		return
	if btn.has_meta("bounce_wired"):
		return
	btn.set_meta("bounce_wired", true)
	btn.pressed.connect(func():
		apply_button_squash_and_stretch(btn)
	)

func _wire_all_buttons_in_tree(root_node: Node) -> void:
	if root_node == null:
		return
	if root_node is Button:
		_wire_button_bounce(root_node as Button)
	for child in root_node.get_children():
		_wire_all_buttons_in_tree(child)

func _set_button_affordability_badge(btn: Button, affordable: bool) -> void:
	if btn == null or not is_instance_valid(btn):
		return
	var badge = btn.get_node_or_null("AffordabilityBadge")
	if not affordable:
		if badge != null:
			badge.visible = false
		return
		
	if badge == null:
		badge = PanelContainer.new()
		badge.name = "AffordabilityBadge"
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.anchor_left = 1.0
		badge.anchor_top = 0.0
		badge.anchor_right = 1.0
		badge.anchor_bottom = 0.0
		badge.offset_left = -16.0
		badge.offset_top = -2.0
		badge.offset_right = 2.0
		badge.offset_bottom = 16.0
		badge.custom_minimum_size = Vector2(18, 18)
		badge.z_index = 5
		
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color(0.18, 0.78, 0.35, 1.0)
		sb.set_corner_radius_all(9)
		sb.border_width_left = 1
		sb.border_width_top = 1
		sb.border_width_right = 1
		sb.border_width_bottom = 1
		sb.border_color = Color(1.0, 1.0, 1.0, 0.9)
		badge.add_theme_stylebox_override("panel", sb)
		
		var lbl = Label.new()
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl.text = "▲"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 10)
		lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
		badge.add_child(lbl)
		
		btn.add_child(badge)
		
	badge.visible = true

func _update_affordability_badges() -> void:
	var gm = _get_game_manager()
	if gm == null:
		return
		
	# 1. Parking category (nav_parking_btn)
	var can_afford_parking: bool = false
	if gm.get_station_level("parking_lot") < gm.get_station_max_level("parking_lot"):
		var p_cost = gm.get_upgrade_cost("parking_lot")
		if p_cost > 0.0 and gm.cash >= p_cost:
			can_afford_parking = true
	_set_button_affordability_badge(nav_parking_btn, can_afford_parking)
	
	# 2. Kitchen category (nav_kitchen_btn)
	var can_afford_kitchen: bool = false
	for k_sid in ["stove", "kitchen_cook"]:
		if gm.get_station_level(k_sid) < gm.get_station_max_level(k_sid):
			var k_cost = gm.get_upgrade_cost(k_sid)
			if k_cost > 0.0 and gm.cash >= k_cost:
				can_afford_kitchen = true
				break
	_set_button_affordability_badge(nav_kitchen_btn, can_afford_kitchen)
	
	# 3. Dining category (nav_dining_btn)
	var can_afford_dining: bool = false
	for i in range(1, 9):
		var t_id = "table_%d" % i
		if not gm.is_table_unlocked(t_id):
			if gm.cash >= gm.get_table_unlock_cost(t_id):
				can_afford_dining = true
				break
		else:
			if gm.get_station_level(t_id) < gm.get_station_max_level(t_id):
				var t_cost = gm.get_upgrade_cost(t_id)
				if t_cost > 0.0 and gm.cash >= t_cost:
					can_afford_dining = true
					break
	_set_button_affordability_badge(nav_dining_btn, can_afford_dining)
	
	# 4. Milkshake Diner category (nav_milkshake_btn)
	var can_afford_milkshake: bool = false
	for m_sid in ["milkshake_bar", "milkshake_blender", "jukebox"]:
		if gm.get_station_level(m_sid) < gm.get_station_max_level(m_sid):
			var m_cost = gm.get_upgrade_cost(m_sid)
			if m_cost > 0.0 and gm.cash >= m_cost:
				can_afford_milkshake = true
				break
	_set_button_affordability_badge(nav_milkshake_btn, can_afford_milkshake)
	
	# 5. Terrace category (nav_terrace_btn)
	var can_afford_terrace: bool = false
	for i in range(9, 13):
		var t_id = "table_%d" % i
		if not gm.is_table_unlocked(t_id):
			if gm.cash >= gm.get_table_unlock_cost(t_id):
				can_afford_terrace = true
				break
		else:
			if gm.get_station_level(t_id) < gm.get_station_max_level(t_id):
				var t_cost = gm.get_upgrade_cost(t_id)
				if t_cost > 0.0 and gm.cash >= t_cost:
					can_afford_terrace = true
					break
	if not can_afford_terrace:
		for l_sid in ["cocktail_lounge", "cocktail_bar"]:
			if gm.get_station_level(l_sid) < gm.get_station_max_level(l_sid):
				var l_cost = gm.get_upgrade_cost(l_sid)
				if l_cost > 0.0 and gm.cash >= l_cost:
					can_afford_terrace = true
					break
	_set_button_affordability_badge(nav_terrace_btn, can_afford_terrace)
	
	# 6. Staff category (nav_staff_btn, side_staff_btn, tab_staff_btn)
	var can_afford_staff: bool = false
	for sid in gm.staff_roster.keys():
		var s_data = gm.staff_roster[sid]
		var hired = gm.is_staff_hired(sid)
		if not hired:
			var hire_cost = s_data.get("hire_cost", 0.0)
			if hire_cost > 0.0 and gm.cash >= hire_cost:
				can_afford_staff = true
				break
		else:
			var lvl = gm.get_staff_level(sid)
			if lvl < 25:
				var up_cost = gm.get_staff_upgrade_cost(sid)
				if up_cost > 0.0 and gm.cash >= up_cost:
					can_afford_staff = true
					break
	_set_button_affordability_badge(nav_staff_btn, can_afford_staff)
	_set_button_affordability_badge(side_staff_btn, can_afford_staff)
	_set_button_affordability_badge(tab_staff_btn, can_afford_staff)
	
	# 7. Station Tabs (tab_upgrades_btn, staff_tab_upgrades_btn)
	var can_afford_current_station: bool = false
	var active_sid = current_station_id if current_station_id != "" else "milkshake_bar"
	if gm.get_station_level(active_sid) < gm.get_station_max_level(active_sid):
		var s_cost = gm.get_upgrade_cost(active_sid)
		if s_cost > 0.0 and gm.cash >= s_cost:
			can_afford_current_station = true
	_set_button_affordability_badge(tab_upgrades_btn, can_afford_current_station)
	_set_button_affordability_badge(staff_tab_upgrades_btn, can_afford_kitchen or can_afford_current_station)

	# 8. Cards category (cards_btn, side_cards_btn)
	var can_afford_cards: bool = false
	if gm.has_method("get_all_cards"):
		var all_cards = gm.get_all_cards()
		for cid in all_cards.keys():
			if gm.can_upgrade_card(cid):
				can_afford_cards = true
				break
	_set_button_affordability_badge(cards_btn, can_afford_cards)
	_set_button_affordability_badge(side_cards_btn, can_afford_cards)

	# 9. Chests tab badge (if free wooden chest is ready)
	var can_claim_chest: bool = gm.has_method("can_claim_free_wooden_chest") and gm.can_claim_free_wooden_chest()
	_set_button_affordability_badge(tab_chests_btn, can_claim_chest)

	# 10. Lucky Spin & 7-Day Login badge (side_spin_btn)
	var can_claim_spin_or_daily: bool = false
	if gm.has_method("can_claim_free_spin") and gm.can_claim_free_spin():
		can_claim_spin_or_daily = true
	elif gm.has_method("can_claim_daily_login") and gm.can_claim_daily_login():
		can_claim_spin_or_daily = true
	_set_button_affordability_badge(side_spin_btn, can_claim_spin_or_daily)

func _focus_camera(zone: String) -> void:
	var cam = get_viewport().get_camera_3d()
	if cam != null and cam.has_method("focus_zone"):
		cam.focus_zone(zone, true)

func _focus_camera_on_station(station_id: String) -> void:
	var cam = get_viewport().get_camera_3d()
	if cam != null:
		if cam.has_method("focus_station"):
			cam.focus_station(station_id)
		elif cam.has_method("focus_zone"):
			cam.focus_zone(station_id, true)

func _highlight_station_in_3d(station_id: String) -> void:
	_clear_3d_highlights()
	var search_root: Node = null
	if get_tree() != null:
		search_root = get_tree().current_scene if get_tree().current_scene != null else get_tree().root
	if search_root == null:
		return
		
	var target_node: Node = null
	if station_id.begins_with("table_"):
		var t_num = station_id.trim_prefix("table_")
		target_node = search_root.find_child("Table" + t_num, true, false)
		if target_node == null:
			target_node = search_root.find_child("Table_" + t_num, true, false)
	elif station_id == "stove" or station_id == "kitchen_cook":
		target_node = search_root.find_child("CookingStation", true, false)
		
	if target_node != null and target_node.has_method("set_highlight"):
		target_node.set_highlight(true)

func _clear_3d_highlights() -> void:
	var search_root: Node = null
	if get_tree() != null:
		search_root = get_tree().current_scene if get_tree().current_scene != null else get_tree().root
	if search_root == null:
		return
	var tables_node = search_root.find_child("Tables", true, false)
	if tables_node != null:
		for t in tables_node.get_children():
			if t.has_method("set_highlight"):
				t.set_highlight(false)
	else:
		for c in search_root.get_children():
			if c.has_method("set_highlight"):
				c.set_highlight(false)
	var stove_node = search_root.find_child("CookingStation", true, false)
	if stove_node != null and stove_node.has_method("set_highlight"):
		stove_node.set_highlight(false)

func _hide_all_modals() -> void:
	_clear_3d_highlights()
	if upgrade_panel != null: upgrade_panel.visible = false
	if dining_panel != null: dining_panel.visible = false
	if kitchen_panel != null: kitchen_panel.visible = false
	if terrace_panel != null: terrace_panel.visible = false
	if parking_panel != null: parking_panel.visible = false
	if staff_panel != null: staff_panel.visible = false
	if marketing_panel != null: marketing_panel.visible = false
	if quests_panel != null: quests_panel.visible = false
	if world_map_panel != null: world_map_panel.visible = false
	if shop_panel != null: shop_panel.visible = false
	if analytics_panel != null: analytics_panel.visible = false
	if perks_panel != null: perks_panel.visible = false
	if cards_panel != null: cards_panel.visible = false
	if chest_reward_modal != null: chest_reward_modal.visible = false
	if star_dish_unlock_modal != null and is_instance_valid(star_dish_unlock_modal):
		star_dish_unlock_modal.visible = false
		star_dish_unlock_modal.queue_free()
		star_dish_unlock_modal = null
	if piggy_bank_modal != null and is_instance_valid(piggy_bank_modal):
		piggy_bank_modal.visible = false
		piggy_bank_modal.queue_free()
		piggy_bank_modal = null
	if investor_offer_modal != null and is_instance_valid(investor_offer_modal):
		investor_offer_modal.visible = false
		investor_offer_modal.queue_free()
		investor_offer_modal = null

func _open_modal(panel: PanelContainer) -> void:
	if panel == null: return
	_play_click_sfx()
	_hide_all_modals()
	_format_node_mobile_recursive(panel)
	_wire_all_buttons_in_tree(panel)
	_update_affordability_badges()
	panel.visible = true
	
	if panel == upgrade_panel:
		# Slide up bottom sheet drawer covering lower 45% - 48% of screen
		var vp_h: float = 648.0
		var vp = panel.get_viewport()
		if vp != null:
			var vrect = vp.get_visible_rect()
			if vrect.size.y > 0.0:
				vp_h = vrect.size.y
		var drawer_h = panel.size.y if panel.size.y > 0.0 else 308.0
		var resting_y = vp_h - drawer_h
		panel.position.y = vp_h + 20.0
		panel.scale = Vector2.ONE
		var tw = create_tween()
		tw.tween_property(panel, "position:y", resting_y, 0.20).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		panel.scale = Vector2(0.88, 0.88)
		var tw = create_tween()
		tw.tween_property(panel, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _close_modal(panel: PanelContainer) -> void:
	if panel == null: return
	_play_click_sfx()
	_clear_3d_highlights()
	
	if panel == upgrade_panel:
		# Slide down bottom sheet drawer off-screen
		var vp_h: float = 648.0
		var vp = panel.get_viewport()
		if vp != null:
			var vrect = vp.get_visible_rect()
			if vrect.size.y > 0.0:
				vp_h = vrect.size.y
		var drawer_h = panel.size.y if panel.size.y > 0.0 else 308.0
		var resting_y = vp_h - drawer_h
		var tw = create_tween()
		tw.tween_property(panel, "position:y", vp_h + 30.0, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_callback(func():
			panel.visible = false
			panel.position.y = resting_y
		)
	else:
		var tw = create_tween()
		tw.tween_property(panel, "scale", Vector2(0.9, 0.9), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_callback(func(): panel.visible = false)

func _toggle_modal(panel: PanelContainer, refresh_func: Callable) -> void:
	if panel == null: return
	if panel.visible:
		_close_modal(panel)
	else:
		refresh_func.call()
		_open_modal(panel)

func open_analytics_modal() -> void:
	if analytics_panel != null:
		_refresh_analytics_panel()
		_open_modal(analytics_panel)

func open_cards_panel() -> void:
	if cards_panel != null:
		_refresh_cards_panel()
		_open_modal(cards_panel)

func _play_click_sfx() -> void:
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("click", 0.08)

func _format_money(amount: float) -> String:
	if amount < 0.0:
		return "- " + _format_money(-amount)
	if amount < 1000.0:
		return "$%d" % round(amount)

	var suffixes: Array[String] = ["K", "M", "B", "T", "aa", "ab", "ac", "ad"]
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

# ─── Top Bar Updates ────────────────────────────────────────────────────────
func _update_top_bar(c: float, g: int, stars: float, rest_name: String, lvl: int, xp: float, next_xp: float) -> void:
	if rest_name_label != null: rest_name_label.text = rest_name
	if star_label != null: star_label.text = "★ %.1f" % stars
	if level_label != null: level_label.text = "Lv. %d" % lvl
	if xp_bar != null:
		xp_bar.max_value = next_xp
		xp_bar.value = xp
	if star_milestone_bar != null:
		star_milestone_bar.max_value = next_xp
		star_milestone_bar.value = xp
	if gem_label != null: gem_label.text = "%d" % g
	if cash_label != null: cash_label.text = _format_money(c)

func _on_cash_changed(new_cash: float) -> void:
	if cash_tween != null and cash_tween.is_valid():
		cash_tween.kill()
	cash_tween = create_tween()
	cash_tween.tween_method(func(val: float):
		displayed_cash = val
		if cash_label != null:
			cash_label.text = _format_money(val)
	, displayed_cash, new_cash, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	if upgrade_panel != null and upgrade_panel.visible:
		_refresh_upgrade_btn()
	if dining_panel != null and dining_panel.visible:
		_refresh_dining_panel()
	if kitchen_panel != null and kitchen_panel.visible:
		_refresh_kitchen_panel()
	if terrace_panel != null and terrace_panel.visible:
		_refresh_terrace_panel()
	if parking_panel != null and parking_panel.visible:
		_refresh_parking_panel()
	if staff_panel != null and staff_panel.visible:
		_refresh_staff_panel()
	if marketing_panel != null and marketing_panel.visible:
		_refresh_marketing_panel()
	if world_map_panel != null and world_map_panel.visible:
		_refresh_world_map()
	if shop_panel != null and shop_panel.visible:
		_refresh_shop_panel()
	_update_affordability_badges()

func _on_gems_changed(new_gems: int) -> void:
	if gems_tween != null and gems_tween.is_valid():
		gems_tween.kill()
	gems_tween = create_tween()
	gems_tween.tween_method(func(val: float):
		displayed_gems = val
		if gem_label != null:
			gem_label.text = "%d" % round(val)
	, displayed_gems, float(new_gems), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if shop_panel != null and shop_panel.visible:
		_refresh_shop_panel()

func _on_golden_coins_changed(new_gold: int) -> void:
	if gold_tween != null and gold_tween.is_valid():
		gold_tween.kill()
	gold_tween = create_tween()
	gold_tween.tween_method(func(val: float):
		displayed_gold = val
		if gold_label != null:
			gold_label.text = "%d" % round(val)
	, displayed_gold, float(new_gold), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if shop_panel != null and shop_panel.visible:
		_refresh_shop_panel()

func _on_energy_changed(new_energy: int) -> void:
	if energy_label != null:
		var gm = _get_game_manager()
		var max_e = gm.max_energy if gm != null else 50
		energy_label.text = "%d/%d" % [new_energy, max_e]
	if shop_panel != null and shop_panel.visible:
		_refresh_shop_panel()
	_update_rush_hour_button()

func _on_currencies_updated(c: float, g: int, d: int, e: int) -> void:
	_on_cash_changed(c)
	_on_golden_coins_changed(g)
	_on_gems_changed(d)
	_on_energy_changed(e)

func _on_time_skip_activated(hours: int, amount: float) -> void:
	trigger_time_skip_shower(hours, amount)

func _on_overdrive_boost_activated(_multiplier: float, _duration: float) -> void:
	var am = _get_audio_manager()
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("upgrade", 0.0, 2.5)
	if floating_boost_btn != null:
		_punch_ui_element(floating_boost_btn)

func _on_cash_rate_updated(new_rate: float) -> void:
	if rate_tween != null and rate_tween.is_valid():
		rate_tween.kill()
	rate_tween = create_tween()
	rate_tween.tween_method(func(val: float):
		displayed_rate = val
		if cash_rate_label != null:
			cash_rate_label.text = "+%s/s" % _format_money(val)
	, displayed_rate, new_rate, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_level_updated(lvl: int, cur_xp: float, max_xp: float) -> void:
	if level_label != null: level_label.text = "Lv. %d" % lvl
	if xp_bar != null:
		xp_bar.max_value = max_xp
		xp_bar.value = cur_xp
	if star_milestone_bar != null:
		star_milestone_bar.max_value = max_xp
		star_milestone_bar.value = cur_xp
	_refresh_star_milestone_bar()

func _process(delta: float) -> void:
	sim_time_minutes += delta * 4.0
	if sim_time_minutes >= 24.0 * 60.0:
		sim_time_minutes -= 24.0 * 60.0
	var total_mins = int(sim_time_minutes)
	var hours = int(total_mins / 60)
	var mins = total_mins % 60
	var am_pm = "AM" if hours < 12 else "PM"
	var display_hour = hours % 12
	if display_hour == 0:
		display_hour = 12
	if clock_label != null:
		clock_label.text = "%02d:%02d %s" % [display_hour, mins, am_pm]

	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		if gm.is_boosted:
			var s = ceil(gm.boost_timer)
			var mult_str = "%.0fX" % gm.boost_multiplier if gm.boost_multiplier >= 2.0 else "2X"
			var time_str = ""
			if s >= 3600.0:
				time_str = "%dh %dm" % [int(s / 3600.0), int((int(s) % 3600) / 60)]
			elif s >= 60.0:
				time_str = "%dm %02ds" % [int(s / 60.0), int(s) % 60]
			else:
				time_str = "%ds" % int(s)

			if floating_boost_btn != null:
				floating_boost_btn.text = "🔥 %s BOOST (%s)" % [mult_str, time_str]
				floating_boost_btn.add_theme_color_override("font_color", Color(1.0, 0.95, 0.3, 1.0))
				floating_boost_btn.scale = Vector2.ONE
			if boost_timer_bar != null:
				boost_timer_bar.visible = true
				var progress = clamp(gm.boost_timer / 60.0, 0.0, 1.0)
				boost_timer_bar.anchor_right = progress
			if boost_btn != null:
				boost_btn.text = "⚡ %s (%s)" % [mult_str, time_str]
		else:
			if floating_boost_btn != null:
				floating_boost_btn.text = "▶️  x2 BOOST!"
				floating_boost_btn.add_theme_color_override("font_color", Color(1.0, 0.88, 0.25, 1.0))
				var pulse = 1.0 + 0.02 * sin(Time.get_ticks_msec() * 0.003)
				floating_boost_btn.scale = Vector2(pulse, pulse)
				floating_boost_btn.pivot_offset = floating_boost_btn.size * 0.5
			if boost_timer_bar != null:
				boost_timer_bar.visible = false
			if boost_btn != null:
				boost_btn.text = "⚡ 2X"
		_update_activate_all_managers_button(delta)

	_update_status_ribbons()
	_update_rush_hour_button()
	if analytics_panel != null and analytics_panel.visible:
		analytics_refresh_timer += delta
		if analytics_refresh_timer >= 0.5:
			analytics_refresh_timer = 0.0
			_refresh_analytics_panel()
	if staff_panel != null and staff_panel.visible:
		staff_refresh_timer += delta
		if staff_refresh_timer >= 1.0:
			staff_refresh_timer = 0.0
			_refresh_staff_panel()

	# ─── VIP Arrival Alert Toast Countdown ─────────────────────────────────────
	if active_vip_toast != null and is_instance_valid(active_vip_toast):
		active_vip_timer -= delta
		if active_vip_progress_bar != null and is_instance_valid(active_vip_progress_bar):
			active_vip_progress_bar.value = max(0.0, active_vip_timer)
		var is_vip_valid = is_instance_valid(active_vip_node)
		if is_vip_valid:
			if active_vip_node.get("vip_reward_claimed") == true or (active_vip_node.has_method("get") and active_vip_node.get("current_state") == 8):
				is_vip_valid = false
		if active_vip_timer <= 0.0 or not is_vip_valid:
			_dismiss_vip_toast()

	# ─── Hold-to-Upgrade continuous loop ───────────────────────────────────────
	if _is_holding_upgrade and _hold_station_id != "":
		_hold_timer += delta
		if not _hold_delay_passed:
			if _hold_timer >= HOLD_INITIAL_DELAY:
				_hold_delay_passed = true
				_hold_timer = 0.0
				_perform_hold_step()
		else:
			var interval = max(0.05, 0.14 - _hold_consecutive * 0.005)
			if _hold_timer >= interval:
				_hold_timer = 0.0
				_perform_hold_step()

func _ensure_rush_hour_button() -> void:
	if rush_hour_btn != null:
		if not rush_hour_btn.pressed.is_connected(_on_rush_hour_pressed):
			rush_hour_btn.pressed.connect(_on_rush_hour_pressed)
		return
	var target_parent = get_node_or_null("HUD/TopBar")
	if target_parent == null:
		return
	rush_hour_btn = Button.new()
	rush_hour_btn.name = "RushHourBtn"
	rush_hour_btn.text = "🔥 RUSH HOUR  (15⚡)"
	rush_hour_btn.add_theme_font_size_override("font_size", 13)
	rush_hour_btn.add_theme_color_override("font_color", Color(0.12, 0.06, 0.02, 1.0))
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.92, 0.32, 0.12, 1.0)
	sb.border_width_bottom = 3
	sb.border_color = Color(0.55, 0.12, 0.04, 1.0)
	sb.set_corner_radius_all(16)
	sb.content_margin_left = 14.0
	sb.content_margin_right = 14.0
	sb.content_margin_top = 8.0
	sb.content_margin_bottom = 8.0
	rush_hour_btn.add_theme_stylebox_override("normal", sb)
	var sb_h = sb.duplicate()
	sb_h.bg_color = Color(1.0, 0.42, 0.16, 1.0)
	rush_hour_btn.add_theme_stylebox_override("hover", sb_h)
	var sb_d = sb.duplicate()
	sb_d.bg_color = Color(0.35, 0.18, 0.12, 1.0)
	rush_hour_btn.add_theme_stylebox_override("disabled", sb_d)
	target_parent.add_child(rush_hour_btn)
	rush_hour_btn.pressed.connect(_on_rush_hour_pressed)
	var gm = get_node_or_null("/root/GameManager")
	if gm != null and gm.has_signal("rush_hour_changed"):
		gm.rush_hour_changed.connect(func(_a, _t): _update_rush_hour_button())
	if gm != null and gm.has_signal("energy_changed"):
		if not gm.energy_changed.is_connected(_on_energy_changed):
			gm.energy_changed.connect(_on_energy_changed)

func _on_rush_hour_pressed() -> void:
	_play_click_sfx()
	var gm = get_node_or_null("/root/GameManager")
	if gm == null:
		return
	if gm.has_method("is_rush_hour_active") and gm.is_rush_hour_active():
		return
	if gm.has_method("try_start_rush_hour"):
		if not gm.try_start_rush_hour():
			_spawn_reward_floater("Need 15 Energy for Rush Hour!")
	_update_rush_hour_button()

func _update_rush_hour_button() -> void:
	if rush_hour_btn == null:
		return
	var gm = get_node_or_null("/root/GameManager")
	if gm == null:
		return
	var active = gm.has_method("is_rush_hour_active") and gm.is_rush_hour_active()
	if active:
		var left = int(ceil(gm.get_rush_hour_time_left())) if gm.has_method("get_rush_hour_time_left") else 0
		rush_hour_btn.text = "🔥 RUSH HOUR  %ds" % left
		rush_hour_btn.disabled = true
		rush_hour_btn.modulate = Color(1.0, 0.92, 0.45, 1.0)
	else:
		rush_hour_btn.text = "🔥 RUSH HOUR  (15⚡)"
		rush_hour_btn.disabled = gm.energy < 15
		rush_hour_btn.modulate = Color.WHITE

func _on_boost_pressed() -> void:
	_play_click_sfx()
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.toggle_boost()

func _on_boost_toggled(active: bool) -> void:
	if active:
		boost_btn.text = "⚡ 2X ACTIVE!"
		boost_btn.modulate = Color(1.0, 0.85, 0.2, 1.0)
		if floating_boost_btn != null:
			floating_boost_btn.text = "🔥 2X ACTIVE!"
			floating_boost_btn.add_theme_color_override("font_color", Color(0.95, 0.45, 0.1, 1.0))
	else:
		boost_btn.text = "⚡ 2X RUSH"
		boost_btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
		if floating_boost_btn != null:
			floating_boost_btn.text = "▶️  x2 BOOST!"
			floating_boost_btn.add_theme_color_override("font_color", Color(0.12, 0.65, 0.25, 1.0))

func _on_add_gem_pressed() -> void:
	_play_click_sfx()
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.add_gems(25)

# ─── Quests & Active Objective Tracker ─────────────────────────────────────
func _refresh_quest_banner() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm == null or quest_banner == null:
		return
	
	quest_banner.visible = true
	var obj = gm.get_active_objective() if gm.has_method("get_active_objective") else {}
	if obj.is_empty():
		return
		
	quest_icon.text = obj.get("icon", "🎯")
	quest_title.text = obj.get("title", "Objective")
	var cur = int(obj.get("current", 0))
	var tar = int(obj.get("target", 1))
	var is_completed = bool(obj.get("is_completed", false))
	
	quest_bar.max_value = tar
	quest_bar.value = cur
	
	if is_completed:
		quest_progress_label.text = "%d / %d  •  COMPLETED!" % [cur, tar]
		quest_progress_label.add_theme_color_override("font_color", Color(0.85, 1.0, 0.85, 1.0))
		quest_claim_btn.visible = true
		
		var r_dia = int(obj.get("reward_diamonds", 0))
		var r_gold = int(obj.get("reward_golden_coins", 0))
		var reward_str = ""
		if r_dia > 0 and r_gold > 0:
			reward_str = "+%d💎 +%d🪙" % [r_dia, r_gold]
		elif r_dia > 0:
			reward_str = "+%d💎" % r_dia
		else:
			reward_str = "+%d🪙" % r_gold
			
		quest_claim_btn.text = "CLAIM REWARD (%s)" % reward_str
		
		# Turn pill green on completion
		if quest_banner_style_completed != null:
			quest_banner.add_theme_stylebox_override("panel", quest_banner_style_completed)
	else:
		quest_progress_label.text = "%d / %d" % [cur, tar]
		quest_progress_label.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0, 0.85))
		quest_claim_btn.visible = false
		if quest_banner_style_normal != null:
			quest_banner.add_theme_stylebox_override("panel", quest_banner_style_normal)

func _on_quest_banner_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_play_click_sfx()
		var gm = get_node_or_null("/root/GameManager")
		if gm == null:
			return
		var obj = gm.get_active_objective() if gm.has_method("get_active_objective") else {}
		if obj.get("is_completed", false):
			_on_banner_claim_pressed()
		else:
			# Interactive contextual guidance for the active objective
			var otype = obj.get("type", "")
			if otype == "station_level":
				var sid = obj.get("station_id", "table_1")
				var lvl = gm.get_station_level(sid)
				var title = "Dining"
				if sid.begins_with("kitchen") or sid == "stove":
					title = "Kitchen"
				elif sid.begins_with("milkshake"):
					title = "Milkshake Bar"
				elif sid.begins_with("parking"):
					title = "Parking"
				open_upgrade(sid, title, lvl)
			elif otype == "spin_wheel":
				_toggle_modal(spin_modal, _refresh_spin_wheel)
			elif otype == "open_chest":
				_toggle_modal(shop_panel, func(): _select_shop_category("chests"))
			else:
				_toggle_modal(quests_panel, _refresh_quests_panel)

func _on_banner_claim_pressed() -> void:
	_play_click_sfx()
	var gm = get_node_or_null("/root/GameManager")
	if gm == null:
		return
	if gm.has_method("claim_active_objective"):
		var rew = gm.claim_active_objective()
		if not rew.is_empty():
			var r_dia = rew.get("diamonds", 0)
			var r_gold = rew.get("golden_coins", 0)
			_spawn_reward_floater("✨ OBJECTIVE CLAIMED! +%d 💎 +%d 🪙" % [r_dia, r_gold])
			if r_dia > 0:
				spawn_flying_currency_trail(Vector3.ZERO, r_dia, "diamonds")
			elif r_gold > 0:
				spawn_flying_currency_trail(Vector3.ZERO, r_gold, "golden_coins")
			_refresh_quest_banner()
			return
	for q in gm.active_quests:
		if q.get("current", 0) >= q.get("target", 1):
			gm.claim_quest(q.get("id"))
			break

func _on_quests_updated() -> void:
	_refresh_quest_banner()
	if quests_panel != null and quests_panel.visible:
		_refresh_quests_panel()

func _refresh_quests_panel() -> void:
	for c in quests_vbox.get_children():
		c.queue_free()
	var gm = get_node_or_null("/root/GameManager")
	if gm == null:
		return
	for q in gm.active_quests:
		var card = _create_quest_card(q, gm)
		quests_vbox.add_child(card)

func _create_quest_card(q: Dictionary, gm: Node) -> PanelContainer:
	var p = PanelContainer.new()
	p.add_theme_stylebox_override("panel", _get_card_style())
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	p.add_child(hbox)
	
	var ic = Label.new()
	ic.text = q.get("icon", "🎯")
	ic.add_theme_font_size_override("font_size", 28)
	hbox.add_child(ic)
	
	var vb = VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vb)
	
	var tit = Label.new()
	tit.text = q.get("title", "")
	tit.add_theme_font_size_override("font_size", 16)
	tit.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	vb.add_child(tit)
	
	var desc = Label.new()
	desc.text = q.get("desc", "")
	desc.add_theme_font_size_override("font_size", 12)
	desc.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9, 0.8))
	vb.add_child(desc)
	
	var pb = ProgressBar.new()
	pb.custom_minimum_size = Vector2(100, 12)
	pb.show_percentage = false
	pb.max_value = q.get("target", 1)
	pb.value = q.get("current", 0)
	vb.add_child(pb)
	
	var btn = Button.new()
	var cur = q.get("current", 0)
	var tar = q.get("target", 1)
	if cur >= tar:
		btn.text = "CLAIM\n+" + _format_money(q.get("reward_cash", 100)) + " 💎+%d" % q.get("reward_gems", 5)
		btn.add_theme_stylebox_override("normal", _get_green_btn_style())
		btn.pressed.connect(func():
			_play_click_sfx()
			gm.claim_quest(q.get("id"))
		)
	else:
		btn.text = "%d / %d" % [cur, tar]
		btn.disabled = true
	hbox.add_child(btn)
	return p

# ─── Station Upgrade Logic (Click in 3D or from UI) ─────────────────────────
func open_upgrade(station_id: String, station_name: String, level: int) -> void:
	current_station_id = station_id
	var gm = get_node_or_null("/root/GameManager")
	if gm == null:
		return
	
	var actual_level = max(level, gm.get_station_level(station_id))
	var station_max = gm.get_station_max_level(station_id)
	var is_max = actual_level >= station_max
	
	if upgrade_title != null: upgrade_title.text = station_name
	if upgrade_level != null: upgrade_level.text = "Level %d / %d" % [actual_level, station_max]
	var inc = gm.get_station_income(station_id)
	if upgrade_income != null: upgrade_income.text = "💵 +" + _format_money(inc) + " / cust   ⚡ +%d" % max(5, actual_level * 2)
	if upgrade_desc != null: upgrade_desc.text = "Upgrade the %s to increase cash earned by the restaurant." % station_name
	
	if upgrade_max_badge != null:
		upgrade_max_badge.visible = is_max
		if is_max:
			upgrade_max_badge.text = "⭐ MAX LEVEL"
			var sb = StyleBoxFlat.new()
			sb.bg_color = Color(0.96, 0.65, 0.12, 1.0)
			sb.set_corner_radius_all(6)
			sb.content_margin_left = 6.0
			sb.content_margin_right = 6.0
			sb.content_margin_top = 2.0
			sb.content_margin_bottom = 2.0
			upgrade_max_badge.add_theme_stylebox_override("normal", sb)
			upgrade_max_badge.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	
	var icon_char = "🍳"
	if station_id.begins_with("table"):
		var tnum = int(station_id.trim_prefix("table_"))
		icon_char = "🌿" if tnum >= 10 else "🪑"
	elif station_id == "host_desk":
		icon_char = "🛎️"
	elif station_id.begins_with("milkshake"):
		icon_char = "🥤"
	elif station_id == "jukebox":
		icon_char = "🎵"
	elif station_id.begins_with("parking"):
		icon_char = "🚗"
	if upgrade_icon != null:
		upgrade_icon.text = icon_char
	
	# Reddish-brown header bar zone title and operating hours
	if zone_title_label != null:
		if station_id.begins_with("milkshake"):
			zone_title_label.text = "🥤 Milkshake Bar"
		elif station_id == "stove" or station_id == "kitchen_cook":
			zone_title_label.text = "🍳 Kitchen"
		elif station_id == "host_desk":
			zone_title_label.text = "🛎️ Lobby"
		elif station_id.begins_with("parking"):
			zone_title_label.text = "🚗 Parking"
		else:
			zone_title_label.text = "🪑 Dining"
			
	if hours_badge_label != null:
		if station_id.begins_with("milkshake"):
			hours_badge_label.text = "☀️ Opens: 11:00 AM"
		elif station_id.begins_with("parking"):
			hours_badge_label.text = "☀️ 24 Hours Open"
		else:
			hours_badge_label.text = "🌙 Closes: 11:00 PM"

	_update_header_bottleneck_pill()

	if upgrade_milestone_bar != null:
		if is_max:
			upgrade_milestone_bar.min_value = 0
			upgrade_milestone_bar.max_value = station_max
			upgrade_milestone_bar.value = station_max
		else:
			var next_milestone = 5 if level < 5 else (10 if level < 10 else (25 if level < 25 else station_max))
			var prev_milestone = 1 if level < 5 else (5 if level < 10 else (10 if level < 25 else 25))
			upgrade_milestone_bar.min_value = prev_milestone
			upgrade_milestone_bar.max_value = next_milestone
			upgrade_milestone_bar.value = level
	
	if stat_cash_lbl != null: stat_cash_lbl.text = "💵 %s" % _format_money(gm.cash)
	if stat_gem_lbl != null: stat_gem_lbl.text = "💎 %d" % gm.gems
	if stat_energy_lbl != null: stat_energy_lbl.text = "⚡ %d" % max(12, gm.restaurant_level * 6)
	
	_focus_camera_on_station(station_id)
	_highlight_station_in_3d(station_id)
	_update_station_milestones(station_id, actual_level, station_max)
	
	_refresh_upgrade_tiles(gm)
	_refresh_upgrade_btn()
	_open_modal(upgrade_panel)

func _refresh_upgrade_tiles(gm: Node) -> void:
	if sub_upgrade_grid == null or gm == null:
		return
	for c in sub_upgrade_grid.get_children():
		c.queue_free()

	# 2-row grid with 10 sub-upgrade items (5 per row)
	var stations_list = []
	if current_station_id.begins_with("milkshake"):
		stations_list = [
			{"id": "milkshake_bar", "name": "Bar Top", "short": "Bar Top", "icon": "🥤"},
			{"id": "milkshake_blender", "name": "Frappes", "short": "Blender", "icon": "🍨"},
			{"id": "jukebox", "name": "Jukebox", "short": "Music", "icon": "🎵"},
			{"id": "table_1", "name": "Booth 1", "short": "Booth 1", "icon": "🪑"},
			{"id": "table_2", "name": "Booth 2", "short": "Booth 2", "icon": "🪑"},
			{"id": "table_3", "name": "Booth 3", "short": "Booth 3", "icon": "🪑"},
			{"id": "table_4", "name": "Booth 4", "short": "Booth 4", "icon": "🪑"},
			{"id": "table_10", "name": "Planters", "short": "Decor", "icon": "🌿"},
			{"id": "table_11", "name": "Sports TV", "short": "TV Screen", "icon": "📺"},
			{"id": "table_12", "name": "Sound Sys", "short": "Speakers", "icon": "📻"}
		]
	elif current_station_id == "stove":
		stations_list = [
			{"id": "stove", "name": "Master Stoves", "short": "Stoves", "icon": "🍳"},
			{"id": "host_desk", "name": "Host Desk", "short": "Host", "icon": "🛎️"},
			{"id": "table_1", "name": "Prep Station", "short": "Prep", "icon": "🔪"},
			{"id": "table_2", "name": "Deep Fryer", "short": "Fryer", "icon": "🍟"},
			{"id": "table_3", "name": "Dishwasher", "short": "Dishes", "icon": "🧼"},
			{"id": "table_4", "name": "Cold Storage", "short": "Pantry", "icon": "🧊"},
			{"id": "table_5", "name": "Spice Rack", "short": "Spices", "icon": "🧂"},
			{"id": "table_6", "name": "Range Hood", "short": "Vent", "icon": "💨"},
			{"id": "table_7", "name": "Order Rack", "short": "Tickets", "icon": "🧾"},
			{"id": "table_8", "name": "Chef Cutlery", "short": "Knives", "icon": "🍽️"}
		]
	else:
		stations_list = [
			{"id": "table_1", "name": "Booth 1", "short": "Booth 1", "icon": "🪑"},
			{"id": "table_2", "name": "Booth 2", "short": "Booth 2", "icon": "🪑"},
			{"id": "table_3", "name": "Booth 3", "short": "Booth 3", "icon": "🪑"},
			{"id": "table_4", "name": "Booth 4", "short": "Booth 4", "icon": "🪑"},
			{"id": "table_5", "name": "Booth 5", "short": "Booth 5", "icon": "🪑"},
			{"id": "table_6", "name": "Booth 6", "short": "Booth 6", "icon": "🪑"},
			{"id": "milkshake_bar", "name": "Bar Top", "short": "Bar Top", "icon": "🥤"},
			{"id": "stove", "name": "Stoves", "short": "Stoves", "icon": "🍳"},
			{"id": "host_desk", "name": "Host Desk", "short": "Host", "icon": "🛎️"},
			{"id": "jukebox", "name": "Jukebox", "short": "Music", "icon": "🎵"}
		]

	for st in stations_list:
		var sid: String = st["id"]
		var is_unlocked: bool = true
		if sid.begins_with("table"):
			is_unlocked = gm.is_table_unlocked(sid)
		
		var lvl: int = gm.get_station_level(sid)
		var is_selected: bool = (sid == current_station_id)

		var tile_btn = Button.new()
		tile_btn.custom_minimum_size = Vector2(70, 52)
		
		var sb = StyleBoxFlat.new()
		sb.set_corner_radius_all(10)
		sb.content_margin_top = 4.0
		sb.content_margin_bottom = 4.0
		sb.content_margin_left = 4.0
		sb.content_margin_right = 4.0
		if is_selected:
			sb.bg_color = Color(0.62, 0.24, 0.14, 1.0)
			sb.border_width_left = 2
			sb.border_width_top = 2
			sb.border_width_right = 2
			sb.border_width_bottom = 2
			sb.border_color = Color(1.0, 1.0, 1.0, 1.0)
			sb.shadow_color = Color(1.0, 0.8, 0.3, 0.4)
			sb.shadow_size = 4
		else:
			sb.bg_color = Color(0.42, 0.16, 0.10, 1.0)
			sb.border_width_bottom = 2
			sb.border_color = Color(0.28, 0.10, 0.06, 1.0)
		tile_btn.add_theme_stylebox_override("normal", sb)

		var station_max = gm.get_station_max_level(sid)
		var is_max = lvl >= station_max
		var badge_str = "⭐ MAX" if is_max else ("Lv. %d" % lvl if is_unlocked else "🔒 Lock")
		tile_btn.text = "%s %s\n%s" % [st["icon"], st["short"], badge_str]
		tile_btn.add_theme_font_size_override("font_size", 10)
		tile_btn.add_theme_color_override("font_color", Color(1, 1, 1, 1) if is_unlocked else Color(0.7, 0.7, 0.7, 0.7))

		tile_btn.pressed.connect(func():
			_play_click_sfx()
			open_upgrade(sid, st["name"], lvl)
		)
		sub_upgrade_grid.add_child(tile_btn)
	_wire_all_buttons_in_tree(sub_upgrade_grid)
	_update_affordability_badges()

func _set_multiplier(mode: String) -> void:
	_play_click_sfx()
	var norm = mode.to_upper().trim_prefix("X")
	if norm != "10" and norm != "MAX":
		norm = "1"
	current_multiplier = norm
	if multi_1_btn != null: multi_1_btn.modulate = Color(1, 1, 1, 1) if norm == "1" else Color(0.65, 0.7, 0.8, 0.7)
	if multi_10_btn != null: multi_10_btn.modulate = Color(1, 1, 1, 1) if norm == "10" else Color(0.65, 0.7, 0.8, 0.7)
	if multi_max_btn != null: multi_max_btn.modulate = Color(1, 1, 1, 1) if norm == "MAX" else Color(0.65, 0.7, 0.8, 0.7)
	_update_header_multi_styles(norm)
	_refresh_upgrade_btn()

func _update_header_multi_styles(norm: String) -> void:
	if header_multi_1_btn != null:
		if style_multi_active != null and style_multi_inactive != null:
			header_multi_1_btn.add_theme_stylebox_override("normal", style_multi_active if norm == "1" else style_multi_inactive)
		header_multi_1_btn.modulate = Color(1.0, 1.0, 1.0, 1.0) if norm == "1" else Color(0.75, 0.8, 0.9, 0.8)
	if header_multi_10_btn != null:
		if style_multi_active != null and style_multi_inactive != null:
			header_multi_10_btn.add_theme_stylebox_override("normal", style_multi_active if norm == "10" else style_multi_inactive)
		header_multi_10_btn.modulate = Color(1.0, 1.0, 1.0, 1.0) if norm == "10" else Color(0.75, 0.8, 0.9, 0.8)
	if header_multi_max_btn != null:
		if style_multi_active != null and style_multi_inactive != null:
			header_multi_max_btn.add_theme_stylebox_override("normal", style_multi_active if norm == "MAX" else style_multi_inactive)
		header_multi_max_btn.modulate = Color(1.0, 1.0, 1.0, 1.0) if norm == "MAX" else Color(0.75, 0.8, 0.9, 0.8)

func _refresh_upgrade_btn() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm == null or current_station_id == "" or upgrade_btn == null:
		return
	var lvl = gm.get_station_level(current_station_id)
	var station_max = gm.get_station_max_level(current_station_id)
	var is_max = lvl >= station_max
	var info = gm.get_upgrade_multi_info(current_station_id, current_multiplier)
	if is_max or info.levels <= 0:
		upgrade_btn.text = "MAX LEVEL\n(COMPLETED)"
		upgrade_btn.disabled = true
		apply_mobile_button_theme(upgrade_btn, Color(0.55, 0.58, 0.62, 1.0), Color(0.38, 0.40, 0.45, 1.0), 16)
		if upgrade_max_badge != null:
			upgrade_max_badge.visible = true
			upgrade_max_badge.text = "⭐ MAX LEVEL"
			upgrade_max_badge.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
			apply_mobile_typography(upgrade_max_badge, 5, Color(1.0, 0.85, 0.2, 1.0))
	else:
		var cost_str = "💵 " + _format_money(info.cost)
		if info.levels > 1:
			upgrade_btn.text = "UPGRADE (+%d)\n%s" % [info.levels, cost_str]
		else:
			upgrade_btn.text = "UPGRADE\n%s" % cost_str
		upgrade_btn.disabled = not info.can_afford
		if info.can_afford:
			apply_mobile_button_theme(upgrade_btn, Color(0.22, 0.847, 0.282, 1.0), Color(0.12, 0.52, 0.18, 1.0), 16)
		else:
			apply_mobile_button_theme(upgrade_btn, Color(0.78, 0.45, 0.15, 1.0), Color(0.52, 0.28, 0.08, 1.0), 16)
		if upgrade_max_badge != null:
			upgrade_max_badge.visible = false

func _on_upgrade_pressed() -> void:
	if _just_upgraded_on_hold:
		return
	_play_click_sfx()
	var gm = get_node_or_null("/root/GameManager")
	if gm != null and current_station_id != "":
		gm.upgrade_station_multi(current_station_id, current_multiplier, 0)
		_punch_upgrade_btn()

func _on_station_upgraded(station_id: String, new_lvl: int) -> void:
	if station_id == current_station_id and upgrade_panel != null and upgrade_panel.visible:
		var gm = get_node_or_null("/root/GameManager")
		if gm != null:
			var station_max = gm.get_station_max_level(station_id)
			var is_max = new_lvl >= station_max
			if upgrade_level != null: upgrade_level.text = "Level %d / %d" % [new_lvl, station_max]
			var inc = gm.get_station_income(station_id)
			if upgrade_income != null: upgrade_income.text = "💵 +" + _format_money(inc) + " / cust   ⚡ +%d" % max(5, new_lvl * 2)
			if upgrade_max_badge != null:
				upgrade_max_badge.visible = is_max
				if is_max:
					upgrade_max_badge.text = "⭐ MAX LEVEL"
					upgrade_max_badge.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
			if upgrade_milestone_bar != null:
				if is_max:
					upgrade_milestone_bar.min_value = 0
					upgrade_milestone_bar.max_value = station_max
					upgrade_milestone_bar.value = station_max
				else:
					upgrade_milestone_bar.value = new_lvl
			_update_station_milestones(station_id, new_lvl, station_max)
			_refresh_upgrade_btn()
			_refresh_upgrade_tiles(gm)
	if dining_panel != null and dining_panel.visible:
		_refresh_dining_panel()
	if kitchen_panel != null and kitchen_panel.visible:
		_refresh_kitchen_panel()
	if terrace_panel != null and terrace_panel.visible:
		_refresh_terrace_panel()
	_update_affordability_badges()

# ─── Dining Floor Management Modal ──────────────────────────────────────────
func _refresh_dining_panel() -> void:
	for c in dining_vbox.get_children():
		c.queue_free()
	var gm = get_node_or_null("/root/GameManager")
	if gm == null:
		return
	
	for i in range(1, 10): # Indoor tables 1 to 9
		var tid = "table_%d" % i
		var card = _create_table_card(tid, i, gm)
		dining_vbox.add_child(card)

func _create_table_card(table_id: String, index: int, gm: Node) -> PanelContainer:
	var p = PanelContainer.new()
	p.add_theme_stylebox_override("panel", _get_card_style())
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	p.add_child(hbox)
	
	var icon = Label.new()
	icon.text = "🪑"
	icon.add_theme_font_size_override("font_size", 26)
	hbox.add_child(icon)
	
	var vb = VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vb)
	
	var is_unlocked = gm.is_table_unlocked(table_id)
	var lvl = gm.get_station_level(table_id)
	
	var name_lbl = Label.new()
	name_lbl.text = "Dining Table #%d" % index
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	vb.add_child(name_lbl)
	
	var sub_lbl = Label.new()
	if is_unlocked:
		sub_lbl.text = "%s • Level %d (+%s/dish)" % [gm.get_station_tier_title(table_id, lvl), lvl, _format_money(gm.get_station_income(table_id))]
		sub_lbl.add_theme_color_override("font_color", Color(0.45, 0.95, 0.55, 1))
	else:
		sub_lbl.text = "Locked Station • Unlock for Customers"
		sub_lbl.add_theme_color_override("font_color", Color(0.8, 0.7, 0.5, 0.8))
	sub_lbl.add_theme_font_size_override("font_size", 12)
	vb.add_child(sub_lbl)
	
	var btn = Button.new()
	if is_unlocked:
		var info = gm.get_upgrade_multi_info(table_id, current_multiplier)
		if info.levels <= 0:
			btn.text = "MAX"
			btn.disabled = true
		else:
			btn.text = "UPGRADE +%d\n(%s)" % [info.levels, _format_money(info.cost)]
			btn.disabled = not info.can_afford
			_connect_hold_upgrade_button(btn, func(): return table_id)
			btn.pressed.connect(func():
				if _just_upgraded_on_hold:
					return
				_play_click_sfx()
				gm.upgrade_station_multi(table_id, current_multiplier, 0)
			)
			btn.add_theme_stylebox_override("normal", _get_green_btn_style())
	else:
		var cost = gm.get_table_unlock_cost(table_id)
		btn.text = "UNLOCK\n(%s)" % _format_money(cost)
		btn.disabled = gm.cash < cost
		btn.pressed.connect(func():
			_play_click_sfx()
			gm.unlock_table(table_id)
		)
		btn.add_theme_stylebox_override("normal", _get_gold_btn_style())
	hbox.add_child(btn)
	return p

func _on_table_unlocked(_table_id: String) -> void:
	if dining_panel != null and dining_panel.visible:
		_refresh_dining_panel()
	if terrace_panel != null and terrace_panel.visible:
		_refresh_terrace_panel()
	_update_affordability_badges()

# ─── Outdoor Terrace Panel ──────────────────────────────────────────────────
func _refresh_terrace_panel() -> void:
	if terrace_vbox == null: return
	for c in terrace_vbox.get_children():
		c.queue_free()
	var gm = get_node_or_null("/root/GameManager")
	if gm == null:
		return
	
	if not gm.is_terrace_unlocked():
		var card = PanelContainer.new()
		card.add_theme_stylebox_override("panel", _get_card_style())
		var vb = VBoxContainer.new()
		vb.add_theme_constant_override("separation", 10)
		card.add_child(vb)
		
		var title = Label.new()
		title.text = "🌿 SUNNY GARDEN TERRACE EXPANSION"
		title.add_theme_font_size_override("font_size", 17)
		title.add_theme_color_override("font_color", Color(1, 0.88, 0.35, 1))
		vb.add_child(title)
		
		var desc = Label.new()
		desc.text = "Expand your restaurant outdoors with 3 luxury patio umbrella tables, garden hedges, and +50% tips from outdoor diners!"
		desc.add_theme_font_size_override("font_size", 12)
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vb.add_child(desc)
		
		var btn = Button.new()
		btn.text = "UNLOCK TERRACE (%s)" % _format_money(gm.TERRACE_UNLOCK_COST)
		btn.disabled = gm.cash < gm.TERRACE_UNLOCK_COST
		btn.add_theme_stylebox_override("normal", _get_gold_btn_style())
		btn.pressed.connect(func():
			_play_click_sfx()
			if gm.unlock_terrace():
				_focus_camera("terrace")
				_refresh_terrace_panel()
		)
		vb.add_child(btn)
		terrace_vbox.add_child(card)
	else:
		for tid in ["table_10", "table_11", "table_12"]:
			var card = _create_table_card(tid, int(tid.trim_prefix("table_")), gm)
			terrace_vbox.add_child(card)

# ─── Parking Lot Panel ──────────────────────────────────────────────────────
func _refresh_parking_panel() -> void:
	if parking_vbox == null: return
	for c in parking_vbox.get_children():
		c.queue_free()
	var gm = get_node_or_null("/root/GameManager")
	if gm == null:
		return
		
	for i in range(1, 5):
		var p = PanelContainer.new()
		p.add_theme_stylebox_override("panel", _get_card_style())
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 12)
		p.add_child(hbox)
		
		var icon = Label.new()
		icon.text = "🚗" if i <= 2 else ("🚙" if i == 3 else "🏎️")
		icon.add_theme_font_size_override("font_size", 28)
		hbox.add_child(icon)
		
		var vb = VBoxContainer.new()
		vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(vb)
		
		var name_lbl = Label.new()
		name_lbl.text = "Parking Stall #%d" % i
		name_lbl.add_theme_font_size_override("font_size", 16)
		name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		vb.add_child(name_lbl)
		
		var is_unlocked = gm.is_stall_unlocked(i)
		var sub_lbl = Label.new()
		sub_lbl.add_theme_font_size_override("font_size", 12)
		if is_unlocked:
			sub_lbl.text = "Active Stall • +$15 Parking Fee per Visitor"
			sub_lbl.add_theme_color_override("font_color", Color(0.45, 0.95, 0.55, 1))
		else:
			sub_lbl.text = "Locked Stall • Expand for More Car Traffic"
			sub_lbl.add_theme_color_override("font_color", Color(0.8, 0.7, 0.5, 0.8))
		vb.add_child(sub_lbl)
		
		var btn = Button.new()
		if is_unlocked:
			btn.text = "✓ ACTIVE"
			btn.disabled = true
		else:
			var cost = gm.get_stall_unlock_cost(i)
			btn.text = "UNLOCK\n(%s)" % _format_money(cost)
			btn.disabled = gm.cash < cost
			btn.add_theme_stylebox_override("normal", _get_gold_btn_style())
			btn.pressed.connect(func():
				_play_click_sfx()
				gm.unlock_parking_stall(i)
				_refresh_parking_panel()
			)
		hbox.add_child(btn)
		parking_vbox.add_child(p)

# ─── Kitchen Management Modal ───────────────────────────────────────────────
func _refresh_kitchen_panel() -> void:
	for c in kitchen_vbox.get_children():
		c.queue_free()
	var gm = get_node_or_null("/root/GameManager")
	if gm == null:
		return
	
	kitchen_vbox.add_child(_create_kitchen_card("stove", "Master Range Stoves", "🍳", gm))
	kitchen_vbox.add_child(_create_kitchen_card("host_desk", "Reception Host Desk", "🛎️", gm))

	# Section Header: Menu & Recipes
	var sep = HSeparator.new()
	kitchen_vbox.add_child(sep)
	
	var menu_header = Label.new()
	menu_header.text = "📖 BISTRO MENU & RECIPES"
	menu_header.add_theme_font_size_override("font_size", 16)
	menu_header.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35, 1.0))
	kitchen_vbox.add_child(menu_header)

	for dish_id in ["burger", "pasta", "pizza", "sushi"]:
		if gm.menu_items.has(dish_id):
			kitchen_vbox.add_child(_create_recipe_card(gm.menu_items[dish_id], gm))

func _create_recipe_card(item: Dictionary, gm: Node) -> PanelContainer:
	var p = PanelContainer.new()
	p.add_theme_stylebox_override("panel", _get_card_style())
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	p.add_child(hbox)
	
	var icon = Label.new()
	icon.text = item.get("icon", "🍽️")
	icon.add_theme_font_size_override("font_size", 28)
	hbox.add_child(icon)
	
	var vb = VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vb)
	
	var name_lbl = Label.new()
	name_lbl.text = item.get("name", "Dish")
	name_lbl.add_theme_font_size_override("font_size", 15)
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	vb.add_child(name_lbl)
	
	var desc_lbl = Label.new()
	var price_val = item.get("price", 45.0)
	var is_unlocked = item.get("unlocked", false)
	if is_unlocked:
		desc_lbl.text = "%s / Order • Active on Table Menus" % _format_money(price_val)
		desc_lbl.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55, 1))
	else:
		desc_lbl.text = "Earns %s / Order • %s" % [_format_money(price_val), item.get("desc", "")]
		desc_lbl.add_theme_color_override("font_color", Color(0.75, 0.82, 0.9, 0.8))
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(desc_lbl)
	
	var btn = Button.new()
	if is_unlocked:
		btn.text = "SERVING\n(%s)" % _format_money(price_val)
		btn.disabled = true
		btn.add_theme_stylebox_override("normal", _get_green_btn_style())
	else:
		var cost = item.get("unlock_cost", 180.0)
		btn.text = "UNLOCK\n(%s)" % _format_money(cost)
		btn.disabled = gm.cash < cost
		btn.add_theme_stylebox_override("normal", _get_gold_btn_style())
		btn.pressed.connect(func():
			_play_click_sfx()
			if gm.unlock_dish(item.get("id")):
				_refresh_kitchen_panel()
		)
	hbox.add_child(btn)
	return p

func _create_kitchen_card(st_id: String, st_name: String, icon_str: String, gm: Node) -> PanelContainer:
	var p = PanelContainer.new()
	p.add_theme_stylebox_override("panel", _get_card_style())
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	p.add_child(hbox)
	
	var icon = Label.new()
	icon.text = icon_str
	icon.add_theme_font_size_override("font_size", 28)
	hbox.add_child(icon)
	
	var vb = VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vb)
	
	var lvl = gm.get_station_level(st_id)
	var name_lbl = Label.new()
	name_lbl.text = st_name
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	vb.add_child(name_lbl)
	
	var sub_lbl = Label.new()
	sub_lbl.text = "%s • Level %d" % [gm.get_station_tier_title(st_id, lvl), lvl]
	sub_lbl.add_theme_color_override("font_color", Color(0.45, 0.95, 0.55, 1))
	sub_lbl.add_theme_font_size_override("font_size", 12)
	vb.add_child(sub_lbl)
	
	var btn = Button.new()
	var info = gm.get_upgrade_multi_info(st_id, current_multiplier)
	if info.levels <= 0:
		btn.text = "MAX"
		btn.disabled = true
	else:
		btn.text = "UPGRADE +%d\n(%s)" % [info.levels, _format_money(info.cost)]
		btn.disabled = not info.can_afford
		_connect_hold_upgrade_button(btn, func(): return st_id)
		btn.pressed.connect(func():
			if _just_upgraded_on_hold:
				return
			_play_click_sfx()
			gm.upgrade_station_multi(st_id, current_multiplier, 0)
		)
		btn.add_theme_stylebox_override("normal", _get_green_btn_style())
	hbox.add_child(btn)
	return p

# ─── Staff Roster Modal ─────────────────────────────────────────────────────
func _on_staff_updated(_sid: String) -> void:
	if staff_panel != null and staff_panel.visible:
		_refresh_staff_panel()
	_update_affordability_badges()

func _refresh_staff_panel() -> void:
	if staff_vbox == null:
		return
	for c in staff_vbox.get_children():
		c.queue_free()
	var gm = get_node_or_null("/root/GameManager")
	if gm == null:
		return

	# Kolibri Sector Managers (Active Skills)
	if gm.get("sector_managers") is Dictionary:
		staff_vbox.add_child(_create_staff_section_header("👑 SECTOR MANAGERS (ACTIVE SKILLS)", "Assign leaders to unlock powerful 60s active boosts & instant table clears"))
		for sec_id in ["kitchen", "dining", "milkshake", "lounge"]:
			if gm.sector_managers.has(sec_id):
				staff_vbox.add_child(_create_sector_manager_card(sec_id, gm.sector_managers[sec_id], gm))

	var sections = [
		{
			"title": "🍳 KITCHEN CHEFS (4 SLOTS)",
			"sub": "Master cooking, knife prep, expedited pass orders, and bakery",
			"ids": ["chef_stove", "chef_prep", "chef_sous", "chef_pastry"]
		},
		{
			"title": "🛎️ DINING FLOOR WAITERS (4 SLOTS)",
			"sub": "Frontline table service, multi-dish delivery, and table turn speed",
			"ids": ["waiter_1", "waiter_2", "waiter_3", "waiter_4"]
		},
		{
			"title": "🍸 LOUNGE & SODA FOUNTAIN (2 SLOTS)",
			"sub": "Cocktail mixology and 50s diner sundaes, sodas & frappes",
			"ids": ["bartender", "barista"]
		},
		{
			"title": "📋 FACILITIES & MANAGEMENT (3 SLOTS)",
			"sub": "Lobby guest greeting, restaurant hygiene, and floor inspection tours",
			"ids": ["hostess", "janitor", "manager"]
		}
	]

	for sec in sections:
		staff_vbox.add_child(_create_staff_section_header(sec["title"], sec["sub"]))
		for sid in sec["ids"]:
			if gm.staff_roster.has(sid):
				staff_vbox.add_child(_create_staff_card(gm.staff_roster[sid], gm))

func _create_staff_section_header(title_text: String, sub_text: String) -> PanelContainer:
	var p = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.14, 0.18, 0.26, 0.95)
	sb.border_width_left = 3
	sb.border_color = Color(0.96, 0.72, 0.18, 1.0)
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(8)
	p.add_theme_stylebox_override("panel", sb)

	var vb = VBoxContainer.new()
	p.add_child(vb)

	var t_lbl = Label.new()
	t_lbl.text = title_text
	t_lbl.add_theme_font_size_override("font_size", 14)
	t_lbl.add_theme_color_override("font_color", Color(1.0, 0.92, 0.65, 1.0))
	vb.add_child(t_lbl)

	var s_lbl = Label.new()
	s_lbl.text = sub_text
	s_lbl.add_theme_font_size_override("font_size", 11)
	s_lbl.add_theme_color_override("font_color", Color(0.75, 0.82, 0.92, 0.8))
	vb.add_child(s_lbl)

	return p

func _create_staff_card(st: Dictionary, gm: Node) -> PanelContainer:
	var p = PanelContainer.new()
	p.add_theme_stylebox_override("panel", _get_card_style())
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	p.add_child(hbox)
	
	var icon = Label.new()
	var role = st.get("role", "waiter")
	match role:
		"chef": icon.text = "👨‍🍳"
		"waiter": icon.text = "👔"
		"hostess": icon.text = "💁‍♀️"
		"bartender": icon.text = "🍸"
		"barista": icon.text = "🥤"
		"janitor": icon.text = "🧹"
		"manager": icon.text = "💼"
		_: icon.text = "👔"
	icon.add_theme_font_size_override("font_size", 30)
	hbox.add_child(icon)
	
	var vb = VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vb)
	
	var name_lbl = Label.new()
	name_lbl.text = st.get("name", "Staff")
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	vb.add_child(name_lbl)
	
	var is_hired = st.get("hired", false)
	var lvl = st.get("level", 1)
	var sid = st["id"]
	var spd = gm.get_staff_speed_multiplier(sid)
	
	var sub_lbl = Label.new()
	if is_hired:
		match role:
			"waiter":
				var cap = gm.get_staff_capacity(sid)
				sub_lbl.text = "Level %d • Speed: +%d%% • Carry: %d Plates" % [lvl, round((spd - 1.0) * 100), cap]
			"chef":
				var cook_spd = gm.get_staff_cooking_multiplier(sid)
				sub_lbl.text = "Level %d • Cook Speed: +%d%% • Speed: +%d%%" % [lvl, round((cook_spd - 1.0) * 100), round((spd - 1.0) * 100)]
			"hostess":
				sub_lbl.text = "Level %d • Patience Buff: +35%% • Speed: +%d%%" % [lvl, round((spd - 1.0) * 100)]
			"bartender":
				var mix_spd = gm.get_staff_serving_multiplier(sid)
				sub_lbl.text = "Level %d • Mix Speed: +%d%% • Lounge Tips: +%d%%" % [lvl, round((mix_spd - 1.0) * 100), round((mix_spd - 1.0) * 80)]
			"barista":
				var soda_spd = gm.get_staff_serving_multiplier(sid)
				sub_lbl.text = "Level %d • Prep Speed: +%d%% • Sundae Tips: +%d%%" % [lvl, round((soda_spd - 1.0) * 100), round((soda_spd - 1.0) * 80)]
			"janitor":
				sub_lbl.text = "Level %d • Sweeping Speed: +%d%% • Hygiene: +100%%" % [lvl, round((spd - 1.0) * 100)]
			"manager":
				var eff = gm.get_manager_efficiency_multiplier()
				var insp_text = " [ACTIVE INSPECTION!]" if gm.is_manager_inspection_active else ""
				sub_lbl.text = "Level %d • Office Tour Boost: +%d%%%s" % [lvl, round((eff - 1.0) * 100), insp_text]
			_:
				sub_lbl.text = "Level %d • Speed: +%d%%" % [lvl, round((spd - 1.0) * 100)]
		sub_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0, 1))
	else:
		sub_lbl.text = "Available for Hire • Click to Recruit"
		sub_lbl.add_theme_color_override("font_color", Color(0.95, 0.75, 0.2, 0.9))
	sub_lbl.add_theme_font_size_override("font_size", 12)
	vb.add_child(sub_lbl)
	
	var desc_lbl = Label.new()
	desc_lbl.text = st.get("desc", "")
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85, 0.8))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(desc_lbl)
	
	var btn = Button.new()
	if is_hired:
		var cost = gm.get_staff_upgrade_cost(sid)
		btn.text = "UPGRADE\n(%s)" % _format_money(cost)
		btn.disabled = gm.cash < cost
		_connect_hold_upgrade_button(btn, func(): return sid, true)
		btn.pressed.connect(func():
			if _just_upgraded_on_hold:
				return
			_play_click_sfx()
			gm.upgrade_staff(sid)
		)
		btn.add_theme_stylebox_override("normal", _get_green_btn_style())
	else:
		var cost = st.get("hire_cost", 200.0)
		btn.text = "HIRE\n(%s)" % _format_money(cost)
		btn.disabled = gm.cash < cost
		btn.pressed.connect(func():
			_play_click_sfx()
			gm.hire_staff(sid)
		)
		btn.add_theme_stylebox_override("normal", _get_gold_btn_style())
	hbox.add_child(btn)
	return p

func _create_sector_manager_card(sec_id: String, mgr: Dictionary, gm: Node) -> PanelContainer:
	var p = PanelContainer.new()
	p.add_theme_stylebox_override("panel", _get_card_style())

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	p.add_child(hbox)

	var icon = Label.new()
	icon.text = mgr.get("skill_icon", "⚡")
	icon.add_theme_font_size_override("font_size", 30)
	hbox.add_child(icon)

	var vb = VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vb)

	# Name + Tier badge
	var header_hbox = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 6)
	vb.add_child(header_hbox)

	var name_lbl = Label.new()
	name_lbl.text = mgr.get("manager_name", "Sector Manager")
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	header_hbox.add_child(name_lbl)

	var tier = mgr.get("tier", "junior")
	var tier_badge = Label.new()
	var tier_color = Color(0.75, 0.82, 0.90, 0.95)
	if tier == "executive":
		tier_badge.text = "[👑 EXECUTIVE]"
		tier_color = Color(1.0, 0.85, 0.2, 1.0)
	elif tier == "senior":
		tier_badge.text = "[⭐ SENIOR]"
		tier_color = Color(0.4, 0.85, 1.0, 1.0)
	else:
		tier_badge.text = "[JUNIOR]"
		tier_color = Color(0.8, 0.85, 0.9, 0.85)
	tier_badge.add_theme_font_size_override("font_size", 11)
	tier_badge.add_theme_color_override("font_color", tier_color)
	header_hbox.add_child(tier_badge)

	var sec_lbl = Label.new()
	sec_lbl.text = mgr.get("sector_name", "Sector")
	sec_lbl.add_theme_font_size_override("font_size", 12)
	sec_lbl.add_theme_color_override("font_color", Color(0.96, 0.75, 0.2, 0.9))
	vb.add_child(sec_lbl)

	var skill_lbl = Label.new()
	skill_lbl.text = "⚡ %s: %s" % [mgr.get("skill_name", "Skill"), mgr.get("skill_desc", "")]
	skill_lbl.add_theme_font_size_override("font_size", 11)
	skill_lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95, 0.85))
	skill_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(skill_lbl)

	var status_lbl = Label.new()
	var is_act = mgr.get("is_active", false)
	var cd_timer = float(mgr.get("cooldown_timer", 0.0))
	var act_timer = float(mgr.get("active_timer", 0.0))

	if is_act:
		status_lbl.text = "🟢 ACTIVE! (%ds remaining)" % int(ceil(act_timer))
		status_lbl.add_theme_color_override("font_color", Color(0.2, 0.95, 0.4, 1.0))
	elif cd_timer > 0.0:
		var mins = int(cd_timer) / 60
		var secs = int(cd_timer) % 60
		status_lbl.text = "⏳ Cooldown: %02d:%02d" % [mins, secs]
		status_lbl.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85, 0.8))
	else:
		status_lbl.text = "✨ Skill Ready To Activate"
		status_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	status_lbl.add_theme_font_size_override("font_size", 11)
	vb.add_child(status_lbl)

	# Action Buttons (Activate & Promote)
	var btn_vbox = VBoxContainer.new()
	btn_vbox.add_theme_constant_override("separation", 6)
	hbox.add_child(btn_vbox)

	var act_btn = Button.new()
	act_btn.custom_minimum_size = Vector2(104, 34)
	if is_act:
		act_btn.text = "ACTIVE\n(%ds)" % int(ceil(act_timer))
		act_btn.disabled = true
		apply_mobile_button_theme(act_btn, Color(0.18, 0.65, 0.28, 1.0), Color(0.10, 0.42, 0.18, 1.0), 12)
	elif cd_timer > 0.0:
		var mins = int(cd_timer) / 60
		var secs = int(cd_timer) % 60
		act_btn.text = "COOLDOWN\n%02d:%02d" % [mins, secs]
		act_btn.disabled = true
		apply_mobile_button_theme(act_btn, Color(0.4, 0.44, 0.5, 1.0), Color(0.25, 0.28, 0.32, 1.0), 12)
	else:
		act_btn.text = "⚡ ACTIVATE\n(60s)"
		act_btn.disabled = false
		apply_mobile_button_theme(act_btn, Color(0.22, 0.847, 0.282, 1.0), Color(0.12, 0.52, 0.18, 1.0), 12)
		act_btn.pressed.connect(func():
			_play_click_sfx()
			gm.activate_manager_skill(sec_id)
			_refresh_staff_panel()
		)
	btn_vbox.add_child(act_btn)

	if tier != "executive":
		var prom_btn = Button.new()
		prom_btn.custom_minimum_size = Vector2(104, 30)
		var prom_cost = 500.0 if tier == "junior" else 1200.0
		prom_btn.text = "PROMOTE\n(%s)" % _format_money(prom_cost)
		prom_btn.disabled = gm.cash < prom_cost
		apply_mobile_button_theme(prom_btn, Color(1.0, 0.624, 0.11, 1.0), Color(0.72, 0.35, 0.05, 1.0), 12)
		prom_btn.pressed.connect(func():
			_play_click_sfx()
			if gm.promote_sector_manager(sec_id):
				_refresh_staff_panel()
		)
		btn_vbox.add_child(prom_btn)

	return p

func _update_activate_all_managers_button(_delta: float) -> void:
	if activate_all_managers_btn == null:
		return
	var gm = get_node_or_null("/root/GameManager")
	if gm == null or not gm.has_method("get_ready_manager_skills_count"):
		return
	
	var ready_count = gm.get_ready_manager_skills_count()
	if ready_count > 0:
		activate_all_managers_btn.visible = true
		activate_all_managers_btn.disabled = false
		activate_all_managers_btn.text = "⚡%d" % ready_count
		var pulse = 1.0 + 0.05 * sin(Time.get_ticks_msec() * 0.006)
		activate_all_managers_btn.scale = Vector2(pulse, pulse)
		activate_all_managers_btn.pivot_offset = activate_all_managers_btn.size * 0.5
		activate_all_managers_btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		var any_active = false
		if gm.has_method("is_manager_skill_active") and gm.get("sector_managers") is Dictionary:
			for sec_id in gm.sector_managers.keys():
				if gm.is_manager_skill_active(sec_id):
					any_active = true
					break
		activate_all_managers_btn.scale = Vector2.ONE
		if any_active:
			activate_all_managers_btn.visible = true
			activate_all_managers_btn.disabled = true
			activate_all_managers_btn.text = "⚡⏳"
			activate_all_managers_btn.modulate = Color(0.4, 0.95, 0.5, 0.9)
		else:
			activate_all_managers_btn.visible = true
			activate_all_managers_btn.disabled = true
			activate_all_managers_btn.text = "⚡"
			activate_all_managers_btn.modulate = Color(0.7, 0.75, 0.8, 0.6)

func _on_activate_all_managers_pressed() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm == null or not gm.has_method("activate_all_manager_skills"):
		return
	if gm.is_any_manager_skill_ready():
		_play_click_sfx()
		var count = gm.activate_all_manager_skills()
		if count > 0:
			_punch_ui_element(activate_all_managers_btn)
			var am = get_node_or_null("/root/AudioManager")
			if am != null and am.has_method("play_sfx"):
				am.play_sfx("upgrade", 0.0, 1.25)
			if staff_panel != null and staff_panel.visible:
				_refresh_staff_panel()

# ─── Marketing Campaigns Modal ──────────────────────────────────────────────
func _on_campaign_updated(_cid: String, _active: bool, _time_left: float) -> void:
	if marketing_panel != null and marketing_panel.visible:
		_refresh_marketing_panel()

func _refresh_marketing_panel() -> void:
	if marketing_vbox == null: return
	for c in marketing_vbox.get_children():
		c.queue_free()
	var gm = get_node_or_null("/root/GameManager")
	if gm == null:
		return
	marketing_vbox.add_child(_create_marketing_agency_card(gm))
	for cid in ["flyers", "social_ad", "radio_spot"]:
		if gm.campaigns.has(cid):
			marketing_vbox.add_child(_create_campaign_card(gm.campaigns[cid], gm))

func _create_marketing_agency_card(gm: Node) -> PanelContainer:
	var p = PanelContainer.new()
	var card_sb = _get_card_style()
	card_sb.border_color = Color(1.0, 0.75, 0.2, 0.95)
	card_sb.border_width_left = 3
	p.add_theme_stylebox_override("panel", card_sb)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	p.add_child(hbox)
	
	var icon = Label.new()
	icon.text = "📣"
	icon.add_theme_font_size_override("font_size", 32)
	hbox.add_child(icon)
	
	var vb = VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vb)
	
	var m_lvl = gm.get_marketing_level() if gm.has_method("get_marketing_level") else 1
	var max_lvl = gm.get_marketing_max_level() if gm.has_method("get_marketing_max_level") else 25
	var traffic_pct = round((gm.get_marketing_traffic_multiplier() - 1.0) * 100) if gm.has_method("get_marketing_traffic_multiplier") else 0
	
	var name_lbl = Label.new()
	name_lbl.text = "Marketing Agency (Lv. %d / %d)" % [m_lvl, max_lvl]
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.25, 1.0))
	vb.add_child(name_lbl)
	
	var desc_lbl = Label.new()
	desc_lbl.text = "Roadside billboard & diner promotions: +%d%% arrival rate!" % traffic_pct
	desc_lbl.add_theme_font_size_override("font_size", 12)
	desc_lbl.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0, 0.9))
	vb.add_child(desc_lbl)
	
	var btn = Button.new()
	if m_lvl >= max_lvl:
		btn.text = "MAX LEVEL\n(+360% Traffic)"
		btn.disabled = true
		btn.add_theme_stylebox_override("normal", _get_gold_btn_style())
	else:
		var cost = gm.get_marketing_upgrade_cost() if gm.has_method("get_marketing_upgrade_cost") else 150.0
		btn.text = "UPGRADE\n(%s)" % _format_money(cost)
		btn.disabled = gm.cash < cost
		btn.pressed.connect(func():
			_play_click_sfx()
			if gm.upgrade_marketing():
				_refresh_marketing_panel()
				_update_marketing_ribbon()
		)
		btn.add_theme_stylebox_override("normal", _get_green_btn_style())
	hbox.add_child(btn)
	return p

func _create_campaign_card(camp: Dictionary, gm: Node) -> PanelContainer:
	var p = PanelContainer.new()
	p.add_theme_stylebox_override("panel", _get_card_style())
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	p.add_child(hbox)
	
	var icon = Label.new()
	icon.text = camp.get("icon", "📢")
	icon.add_theme_font_size_override("font_size", 30)
	hbox.add_child(icon)
	
	var vb = VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vb)
	
	var name_lbl = Label.new()
	name_lbl.text = camp.get("name", "Campaign")
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	vb.add_child(name_lbl)
	
	var desc_lbl = Label.new()
	desc_lbl.text = camp.get("desc", "")
	desc_lbl.add_theme_font_size_override("font_size", 12)
	desc_lbl.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9, 0.9))
	vb.add_child(desc_lbl)
	
	var time_left = camp.get("time_left", 0.0)
	var is_active = time_left > 0.0
	
	var btn = Button.new()
	if is_active:
		btn.text = "ACTIVE\n(%ds)" % ceil(time_left)
		btn.disabled = true
		btn.add_theme_stylebox_override("normal", _get_gold_btn_style())
	else:
		var cost = camp.get("cost", 100.0)
		btn.text = "LAUNCH\n(%s)" % _format_money(cost)
		btn.disabled = gm.cash < cost
		btn.pressed.connect(func():
			_play_click_sfx()
			gm.start_campaign(camp["id"])
		)
		btn.add_theme_stylebox_override("normal", _get_green_btn_style())
	hbox.add_child(btn)
	return p

func _update_status_ribbons() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm == null:
		return
	var fin = gm.get_financial_breakdown() if gm.has_method("get_financial_breakdown") else {}
	var m_lvl = gm.get_marketing_level() if gm.has_method("get_marketing_level") else 1
	var has_campaign = false
	for cid in gm.campaigns.keys():
		if gm.campaigns[cid].get("time_left", 0.0) > 0.0:
			has_campaign = true
			break
	if ribbon_marketing_lbl != null and ribbon_marketing != null:
		if m_lvl <= 1 and not has_campaign:
			var m_exp = fin.get("expenses", {}).get("marketing_min", 50.0)
			ribbon_marketing_lbl.text = "📉 - %s Marketing" % _format_money(m_exp)
			ribbon_marketing_lbl.add_theme_color_override("font_color", Color(1.0, 0.72, 0.72, 1.0))
			ribbon_marketing.add_theme_stylebox_override("panel", _get_red_ribbon_style())
		else:
			var traffic_pct = round((gm.get_marketing_traffic_multiplier() - 1.0) * 100)
			ribbon_marketing_lbl.text = "📈 +%d%% Traffic (Lv. %d)" % [traffic_pct, m_lvl]
			ribbon_marketing_lbl.add_theme_color_override("font_color", Color(0.72, 1.0, 0.75, 1.0))
			ribbon_marketing.add_theme_stylebox_override("panel", _get_green_ribbon_style())

	if ribbon_parking_lbl != null:
		var p_inc = fin.get("income", {}).get("parking_min", 25830.0)
		ribbon_parking_lbl.text = "📈 + %s Parking" % _format_money(p_inc)

	if ribbon_cleaning_lbl != null:
		var c_exp = gm.get_cleaning_upkeep_cost() if gm != null and gm.has_method("get_cleaning_upkeep_cost") else fin.get("expenses", {}).get("cleaning_min", 300.0)
		var cln = gm.cleanliness if gm != null else 100.0
		if cln < 75.0:
			ribbon_cleaning_lbl.text = "🧹 - %s Clean (%d%%)" % [_format_money(c_exp), round(cln)]
			ribbon_cleaning_lbl.add_theme_color_override("font_color", Color(1.0, 0.72, 0.72, 1.0))
			if ribbon_cleaning != null:
				ribbon_cleaning.add_theme_stylebox_override("panel", _get_red_ribbon_style())
		else:
			ribbon_cleaning_lbl.text = "🧹 - %s Cleaning (%d%%)" % [_format_money(c_exp), round(cln)]
			ribbon_cleaning_lbl.add_theme_color_override("font_color", Color(0.72, 1.0, 0.75, 1.0))
			if ribbon_cleaning != null:
				ribbon_cleaning.add_theme_stylebox_override("panel", _get_green_ribbon_style())

func _show_rapid_sanitation_banner(cost_deducted: float) -> void:
	if ribbon_cleaning != null:
		var tw = create_tween()
		tw.tween_property(ribbon_cleaning, "scale", Vector2(1.12, 1.12), 0.15)
		tw.tween_property(ribbon_cleaning, "scale", Vector2.ONE, 0.2)
	
	var hud_node = get_node_or_null("HUD")
	if hud_node == null:
		hud_node = self
		
	var toast = PanelContainer.new()
	toast.name = "SanitationToast"
	toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast.custom_minimum_size = Vector2(400, 56)
	toast.anchors_preset = Control.PRESET_CENTER_TOP
	toast.anchor_left = 0.5
	toast.anchor_top = 0.0
	toast.anchor_right = 0.5
	toast.anchor_bottom = 0.0
	toast.offset_left = -200.0
	toast.offset_right = 200.0
	toast.offset_top = 24.0
	toast.offset_bottom = 80.0
	toast.grow_horizontal = Control.GROW_DIRECTION_BOTH
	toast.pivot_offset = Vector2(200, 28)
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.24, 0.14, 0.95)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 3
	sb.border_color = Color(0.35, 0.95, 0.55, 1.0)
	sb.set_corner_radius_all(12)
	sb.set_content_margin_all(8)
	toast.add_theme_stylebox_override("panel", sb)
	
	var lbl = Label.new()
	lbl.text = "✨ RAPID SANITATION COMPLETE (-%s)!\n100%% Spotless • 5.0 Stars ⭐" % _format_money(cost_deducted)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", Color(0.9, 1.0, 0.92, 1.0))
	lbl.add_theme_font_size_override("font_size", 13)
	toast.add_child(lbl)
	
	toast.scale = Vector2.ZERO
	hud_node.add_child(toast)
	
	var tw2 = create_tween()
	tw2.tween_property(toast, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw2.tween_interval(2.2)
	tw2.tween_property(toast, "scale", Vector2(0.8, 0.8), 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw2.parallel().tween_property(toast, "modulate:a", 0.0, 0.2)
	tw2.chain().tween_callback(func():
		if is_instance_valid(toast):
			toast.queue_free()
	)

func _update_marketing_ribbon() -> void:
	_update_status_ribbons()

func _get_red_ribbon_style() -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.35, 0.12, 0.12, 0.88)
	sb.border_width_left = 3
	sb.border_color = Color(0.85, 0.25, 0.25, 1.0)
	sb.set_corner_radius_all(4)
	sb.set_content_margin_all(4)
	return sb

func _get_green_ribbon_style() -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.32, 0.16, 0.88)
	sb.border_width_left = 3
	sb.border_color = Color(0.25, 0.85, 0.45, 1.0)
	sb.set_corner_radius_all(4)
	sb.set_content_margin_all(4)
	return sb

# ─── Stylebox Generators & Kolibri Mobile UI Helpers ───────────────────────
func create_mobile_action_button_style(bg_col: Color = Color(0.22, 0.847, 0.282, 1.0), border_dark_col: Color = Color(0.12, 0.52, 0.18, 1.0), is_pressed: bool = false, corner_rad: int = 16) -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = bg_col
	sb.border_color = border_dark_col
	sb.border_width_left = 2
	sb.border_width_right = 2
	if is_pressed:
		sb.border_width_top = 4
		sb.border_width_bottom = 2
		sb.content_margin_top = 10.0
		sb.content_margin_bottom = 6.0
	else:
		sb.border_width_top = 2
		sb.border_width_bottom = 6
		sb.content_margin_top = 8.0
		sb.content_margin_bottom = 8.0
	sb.set_corner_radius_all(corner_rad)
	sb.content_margin_left = 16.0
	sb.content_margin_right = 16.0
	sb.shadow_color = Color(0, 0, 0, 0.35)
	sb.shadow_size = 6
	sb.shadow_offset = Vector2(0, 3)
	return sb

func create_mobile_modal_frame_style(bg_col: Color = Color(1.0, 0.718, 0.012, 1.0), border_col: Color = Color(0.32, 0.16, 0.06, 1.0)) -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = bg_col
	sb.border_color = border_col
	sb.border_width_left = 4
	sb.border_width_top = 4
	sb.border_width_right = 4
	sb.border_width_bottom = 7
	sb.set_corner_radius_all(24)
	sb.content_margin_left = 20.0
	sb.content_margin_top = 18.0
	sb.content_margin_right = 20.0
	sb.content_margin_bottom = 18.0
	sb.shadow_color = Color(0, 0, 0, 0.55)
	sb.shadow_size = 14
	sb.shadow_offset = Vector2(0, 5)
	return sb

func create_mobile_inner_card_style(bg_col: Color = Color(1.0, 0.973, 0.906, 1.0), border_col: Color = Color(0.85, 0.68, 0.42, 1.0)) -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = bg_col
	sb.border_color = border_col
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 4
	sb.set_corner_radius_all(18)
	sb.content_margin_left = 14.0
	sb.content_margin_top = 10.0
	sb.content_margin_right = 14.0
	sb.content_margin_bottom = 10.0
	sb.shadow_color = Color(0.35, 0.2, 0.05, 0.22)
	sb.shadow_size = 6
	sb.shadow_offset = Vector2(0, 2)
	return sb

func create_mobile_currency_capsule_style(bg_col: Color = Color(0.15, 0.09, 0.06, 0.98), border_col: Color = Color(1.0, 0.82, 0.22, 1.0)) -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = bg_col
	sb.border_color = border_col
	sb.border_width_left = 3
	sb.border_width_top = 2
	sb.border_width_right = 3
	sb.border_width_bottom = 4
	sb.set_corner_radius_all(22)
	sb.content_margin_left = 12.0
	sb.content_margin_top = 4.0
	sb.content_margin_right = 14.0
	sb.content_margin_bottom = 4.0
	sb.shadow_color = Color(0, 0, 0, 0.45)
	sb.shadow_size = 8
	sb.shadow_offset = Vector2(0, 2)
	return sb

func apply_mobile_typography(control: Control, outline_sz: int = 6, text_col: Color = Color.WHITE) -> void:
	if control == null:
		return
	if control is Label:
		if text_col != Color.TRANSPARENT:
			control.add_theme_color_override("font_color", text_col)
		control.add_theme_color_override("font_outline_color", Color(0.12, 0.08, 0.05, 1.0))
		control.add_theme_constant_override("outline_size", outline_sz)
		control.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.45))
		control.add_theme_constant_override("shadow_offset_x", 1)
		control.add_theme_constant_override("shadow_offset_y", 2)
		control.add_theme_constant_override("shadow_outline_size", 2)
	elif control is Button:
		if text_col != Color.TRANSPARENT:
			control.add_theme_color_override("font_color", text_col)
			control.add_theme_color_override("font_pressed_color", text_col)
			control.add_theme_color_override("font_hover_color", text_col)
			control.add_theme_color_override("font_focus_color", text_col)
		control.add_theme_color_override("font_outline_color", Color(0.12, 0.08, 0.05, 1.0))
		control.add_theme_constant_override("outline_size", outline_sz)
		control.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.45))
		control.add_theme_constant_override("shadow_offset_x", 1)
		control.add_theme_constant_override("shadow_offset_y", 2)

func apply_mobile_button_theme(btn: Button, bg_col: Color, border_dark_col: Color, corner_rad: int = 16, outline_sz: int = 6) -> void:
	if btn == null:
		return
	var normal_sb = create_mobile_action_button_style(bg_col, border_dark_col, false, corner_rad)
	var pressed_sb = create_mobile_action_button_style(bg_col, border_dark_col, true, corner_rad)
	var hover_sb = normal_sb.duplicate()
	hover_sb.bg_color = bg_col.lightened(0.12)
	var disabled_sb = normal_sb.duplicate()
	disabled_sb.bg_color = Color(0.5, 0.52, 0.56, 1.0)
	disabled_sb.border_color = Color(0.35, 0.36, 0.40, 1.0)
	btn.add_theme_stylebox_override("normal", normal_sb)
	btn.add_theme_stylebox_override("pressed", pressed_sb)
	btn.add_theme_stylebox_override("hover", hover_sb)
	btn.add_theme_stylebox_override("focus", normal_sb)
	btn.add_theme_stylebox_override("disabled", disabled_sb)
	apply_mobile_typography(btn, outline_sz, Color.WHITE)

func style_card_mobile(card: PanelContainer) -> void:
	if card == null:
		return
	card.add_theme_stylebox_override("panel", create_mobile_inner_card_style())
	_format_node_mobile_recursive(card)

func _format_node_mobile_recursive(node: Node) -> void:
	if node == null:
		return
	if node is Label:
		var curr_col = (node as Label).get_theme_color("font_color") if (node as Label).has_theme_color_override("font_color") else Color.WHITE
		if curr_col.r > 0.8 and curr_col.g > 0.7 and curr_col.b < 0.5:
			apply_mobile_typography(node, 6, curr_col)
		elif curr_col.g > 0.7 and curr_col.r < 0.6:
			apply_mobile_typography(node, 6, curr_col)
		elif curr_col.b > 0.8 and curr_col.r < 0.6:
			apply_mobile_typography(node, 6, curr_col)
		elif curr_col.r > 0.85 and curr_col.g > 0.85 and curr_col.b > 0.85:
			apply_mobile_typography(node, 6, Color(0.20, 0.12, 0.06, 1.0))
		else:
			apply_mobile_typography(node, 5, curr_col)
	elif node is Button:
		apply_mobile_typography(node, 6, Color.WHITE)
	for child in node.get_children():
		_format_node_mobile_recursive(child)

func _apply_mobile_kolibri_ui_styling() -> void:
	# 1. Top Currency Capsules
	var profile = get_node_or_null("HUD/TopBar/ProfilePanel")
	if profile is Control:
		profile.clip_contents = false
		profile.add_theme_stylebox_override("panel", create_mobile_currency_capsule_style(Color(0.20, 0.12, 0.28, 0.98), Color(1.0, 0.82, 0.22, 1.0)))
	var cash_p = get_node_or_null("HUD/TopBar/CashPanel")
	if cash_p is Control:
		cash_p.clip_contents = false
		cash_p.add_theme_stylebox_override("panel", create_mobile_currency_capsule_style())
	var gold_p = get_node_or_null("HUD/TopBar/GoldCoinPanel")
	if gold_p is Control:
		gold_p.clip_contents = false
		gold_p.add_theme_stylebox_override("panel", create_mobile_currency_capsule_style())
	var energy_p = get_node_or_null("HUD/TopBar/EnergyPanel")
	if energy_p is Control:
		energy_p.clip_contents = false
		energy_p.add_theme_stylebox_override("panel", create_mobile_currency_capsule_style())
	var gem_p = get_node_or_null("HUD/TopBar/GemPanel")
	if gem_p is Control:
		gem_p.clip_contents = false
		gem_p.add_theme_stylebox_override("panel", create_mobile_currency_capsule_style())
	var clock_p = get_node_or_null("HUD/TopBar/ClockPanel")
	if clock_p is Control:
		clock_p.add_theme_stylebox_override("panel", create_mobile_currency_capsule_style(Color(0.15, 0.09, 0.06, 0.98), Color(1.0, 0.82, 0.22, 0.9)))
	var live_p = get_node_or_null("HUD/TopBar/LivePanel")
	if live_p is Control:
		live_p.add_theme_stylebox_override("panel", create_mobile_currency_capsule_style(Color(0.15, 0.09, 0.06, 0.98), Color(0.25, 0.92, 0.45, 0.9)))

	# 2. Top Currency Heavy Outlined Typography
	apply_mobile_typography(cash_label, 7, Color(0.35, 1.0, 0.6))
	apply_mobile_typography(cash_rate_label, 5, Color(0.75, 1.0, 0.8))
	apply_mobile_typography(gold_label, 6, Color(1.0, 0.88, 0.4))
	apply_mobile_typography(energy_label, 6, Color(0.75, 0.92, 1.0))
	apply_mobile_typography(gem_label, 6, Color(0.92, 0.70, 1.0))
	apply_mobile_typography(clock_label, 5, Color(1.0, 0.95, 0.85))
	apply_mobile_typography(avatar_label, 6, Color.WHITE)
	apply_mobile_typography(level_label, 5, Color(1.0, 0.9, 0.4))
	apply_mobile_typography(quest_title, 6, Color.WHITE)
	apply_mobile_typography(quest_progress_label, 5, Color(1.0, 0.9, 0.6))

	# 3. Action Buttons & Mini Plus Buttons
	if boost_btn != null:
		apply_mobile_button_theme(boost_btn, Color(1.0, 0.624, 0.11, 1.0), Color(0.72, 0.35, 0.05, 1.0), 16)
	if rush_hour_btn != null:
		apply_mobile_button_theme(rush_hour_btn, Color(0.94, 0.35, 0.12, 1.0), Color(0.58, 0.15, 0.05, 1.0), 16)
	if quest_claim_btn != null:
		apply_mobile_button_theme(quest_claim_btn, Color(0.22, 0.847, 0.282, 1.0), Color(0.12, 0.52, 0.18, 1.0), 12)
	if map_btn != null:
		apply_mobile_button_theme(map_btn, Color(1.0, 0.624, 0.11, 1.0), Color(0.72, 0.35, 0.05, 1.0), 14)
	if add_gold_btn != null:
		apply_mobile_button_theme(add_gold_btn, Color(0.22, 0.847, 0.282, 1.0), Color(0.12, 0.52, 0.18, 1.0), 10)
	if add_energy_btn != null:
		apply_mobile_button_theme(add_energy_btn, Color(0.22, 0.847, 0.282, 1.0), Color(0.12, 0.52, 0.18, 1.0), 10)
	if add_gem_btn != null:
		apply_mobile_button_theme(add_gem_btn, Color(0.22, 0.847, 0.282, 1.0), Color(0.12, 0.52, 0.18, 1.0), 10)

	# 4. Bottom Dock & Navigation Buttons
	var dock = get_node_or_null("HUD/BottomDock")
	if dock is PanelContainer:
		var dock_sb = create_mobile_modal_frame_style(Color(0.24, 0.14, 0.08, 0.98), Color(1.0, 0.78, 0.22, 0.95))
		dock.add_theme_stylebox_override("panel", dock_sb)
	for nav_btn in [nav_parking_btn, nav_kitchen_btn, nav_dining_btn, nav_milkshake_btn, nav_terrace_btn, nav_staff_btn, nav_promo_btn]:
		if nav_btn != null:
			apply_mobile_button_theme(nav_btn, Color(1.0, 0.624, 0.11, 1.0), Color(0.72, 0.35, 0.05, 1.0), 16)

	# 5. Oversized Floating Edge Buttons (Left & Right margins)
	var edge_buttons = [
		{"btn": shop_btn, "bg": Color(1.0, 0.624, 0.11, 1.0), "border": Color(0.58, 0.28, 0.05, 1.0)},
		{"btn": map_btn, "bg": Color(0.12, 0.58, 0.95, 1.0), "border": Color(0.06, 0.28, 0.58, 1.0)},
		{"btn": side_piggy_bank_btn, "bg": Color(1.0, 0.72, 0.16, 1.0), "border": Color(0.62, 0.36, 0.05, 1.0)},
		{"btn": side_ad_btn, "bg": Color(0.98, 0.48, 0.08, 1.0), "border": Color(0.58, 0.22, 0.04, 1.0)},
		{"btn": side_stats_btn, "bg": Color(0.16, 0.72, 0.52, 1.0), "border": Color(0.08, 0.38, 0.28, 1.0)},
		{"btn": side_spin_btn, "bg": Color(0.58, 0.18, 0.88, 1.0), "border": Color(0.32, 0.08, 0.52, 1.0)},
	]
	for eb in edge_buttons:
		var b: Button = eb["btn"]
		if b != null:
			apply_mobile_button_theme(b, eb["bg"], eb["border"], 36)
			var badge = b.find_child("BadgeLabel", true, false)
			if badge is Label:
				apply_mobile_typography(badge, 6, Color.WHITE)
			var icon_l = b.find_child("Icon", true, false)
			if icon_l is Label:
				apply_mobile_typography(icon_l, 6, Color.WHITE)

	# Bottom-Center Floating x2 Boost Pill Button
	if floating_boost_btn != null:
		apply_mobile_typography(floating_boost_btn, 6, Color(1.0, 0.88, 0.25, 1.0))
	if activate_all_managers_btn != null:
		apply_mobile_typography(activate_all_managers_btn, 6, Color(1.0, 0.95, 0.4, 1.0))

	# 6. UpgradePanel Drawer & Inner Station Card
	if upgrade_panel != null:
		upgrade_panel.add_theme_stylebox_override("panel", create_mobile_modal_frame_style(Color(1.0, 0.718, 0.012, 1.0), Color(0.32, 0.16, 0.06, 1.0)))
	var st_card = get_node_or_null("UpgradePanel/VBox/StationCard")
	if st_card is PanelContainer:
		st_card.add_theme_stylebox_override("panel", create_mobile_inner_card_style())
	if upgrade_title != null:
		apply_mobile_typography(upgrade_title, 6, Color(0.2, 0.12, 0.06, 1.0))
	if upgrade_level != null:
		apply_mobile_typography(upgrade_level, 6, Color(0.45, 0.25, 0.1, 1.0))
	if upgrade_income != null:
		apply_mobile_typography(upgrade_income, 6, Color(0.12, 0.65, 0.25, 1.0))
	if upgrade_btn != null:
		apply_mobile_button_theme(upgrade_btn, Color(0.22, 0.847, 0.282, 1.0), Color(0.12, 0.52, 0.18, 1.0), 16)
	if close_btn != null:
		apply_mobile_button_theme(close_btn, Color(0.88, 0.24, 0.24, 1.0), Color(0.55, 0.12, 0.12, 1.0), 14)
	if tab_upgrades_btn != null:
		var tab_up_sb = StyleBoxFlat.new()
		tab_up_sb.bg_color = Color(1.0, 0.718, 0.012, 1.0)
		tab_up_sb.border_width_left = 3
		tab_up_sb.border_width_top = 4
		tab_up_sb.border_width_right = 3
		tab_up_sb.border_width_bottom = 0
		tab_up_sb.border_color = Color(0.32, 0.16, 0.06, 1.0)
		tab_up_sb.corner_radius_top_left = 18
		tab_up_sb.corner_radius_top_right = 18
		tab_up_sb.content_margin_left = 18.0
		tab_up_sb.content_margin_right = 18.0
		tab_up_sb.content_margin_top = 8.0
		tab_up_sb.content_margin_bottom = 6.0
		tab_upgrades_btn.add_theme_stylebox_override("normal", tab_up_sb)
		apply_mobile_typography(tab_upgrades_btn, 6, Color.WHITE)
	if tab_staff_btn != null:
		var tab_st_sb = StyleBoxFlat.new()
		tab_st_sb.bg_color = Color(0.85, 0.72, 0.55, 0.95)
		tab_st_sb.border_width_left = 2
		tab_st_sb.border_width_top = 3
		tab_st_sb.border_width_right = 2
		tab_st_sb.border_width_bottom = 0
		tab_st_sb.border_color = Color(0.48, 0.32, 0.18, 1.0)
		tab_st_sb.corner_radius_top_left = 18
		tab_st_sb.corner_radius_top_right = 18
		tab_st_sb.content_margin_left = 18.0
		tab_st_sb.content_margin_right = 18.0
		tab_st_sb.content_margin_top = 8.0
		tab_st_sb.content_margin_bottom = 6.0
		tab_staff_btn.add_theme_stylebox_override("normal", tab_st_sb)
		apply_mobile_typography(tab_staff_btn, 6, Color.WHITE)

	# 7. Modals: Golden-Amber Outer Frame & Chunky Outlines
	var modals = [
		dining_panel, kitchen_panel, terrace_panel, parking_panel,
		marketing_panel, staff_panel, quests_panel, world_map_panel
	]
	for mod in modals:
		if mod != null and mod is PanelContainer:
			mod.add_theme_stylebox_override("panel", create_mobile_modal_frame_style())
			var hdr = mod.find_child("Header", true, false)
			if hdr is Label:
				apply_mobile_typography(hdr, 7, Color.WHITE)
			var cl_btn = mod.find_child("CloseBtn", true, false)
			if cl_btn is Button:
				apply_mobile_button_theme(cl_btn, Color(0.88, 0.24, 0.24, 1.0), Color(0.55, 0.12, 0.12, 1.0), 14)

func _get_card_style() -> StyleBoxFlat:
	return create_mobile_inner_card_style()

func _get_green_btn_style() -> StyleBoxFlat:
	return create_mobile_action_button_style(Color(0.22, 0.847, 0.282, 1.0), Color(0.12, 0.52, 0.18, 1.0), false, 14)

func _get_gold_btn_style() -> StyleBoxFlat:
	return create_mobile_action_button_style(Color(1.0, 0.624, 0.11, 1.0), Color(0.72, 0.35, 0.05, 1.0), false, 14)

var welcome_modal: PanelContainer = null
var _pending_offline_earnings: Array = []

func _on_offline_earnings_available(earned: float, elapsed: float) -> void:
	var cam = get_viewport().get_camera_3d() if is_inside_tree() else null
	if cam == null and get_parent() != null:
		cam = get_parent().find_child("Camera3D", true, false)
	if cam != null and cam.get("is_performing_cinematic_reveal") == true:
		_pending_offline_earnings = [earned, elapsed]
		if not cam.is_connected("cinematic_reveal_completed", _on_camera_reveal_for_welcome):
			cam.cinematic_reveal_completed.connect(_on_camera_reveal_for_welcome, CONNECT_ONE_SHOT)
		return
	_show_welcome_back_modal(earned, elapsed)

func _on_camera_reveal_for_welcome() -> void:
	if not _pending_offline_earnings.is_empty():
		var args = _pending_offline_earnings
		_pending_offline_earnings = []
		_show_welcome_back_modal(args[0], args[1])

func _show_welcome_back_modal(earned: float, elapsed: float) -> void:
	if welcome_modal != null and is_instance_valid(welcome_modal):
		welcome_modal.queue_free()

	welcome_modal = PanelContainer.new()
	welcome_modal.name = "WelcomeBackModal"
	welcome_modal.custom_minimum_size = Vector2(460, 320)
	welcome_modal.anchors_preset = Control.PRESET_CENTER
	welcome_modal.anchor_left = 0.5
	welcome_modal.anchor_top = 0.5
	welcome_modal.anchor_right = 0.5
	welcome_modal.anchor_bottom = 0.5
	welcome_modal.offset_left = -230
	welcome_modal.offset_top = -160
	welcome_modal.offset_right = 230
	welcome_modal.offset_bottom = 160
	welcome_modal.pivot_offset = Vector2(230, 160)

	welcome_modal.add_theme_stylebox_override("panel", create_mobile_modal_frame_style())

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	welcome_modal.add_child(vb)

	var title = Label.new()
	title.text = "✨ WELCOME BACK, CHEF! ✨"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	apply_mobile_typography(title, 7, Color(1.0, 0.88, 0.25, 1.0))
	vb.add_child(title)

	var inner_card = PanelContainer.new()
	inner_card.add_theme_stylebox_override("panel", create_mobile_inner_card_style())
	var inner_vb = VBoxContainer.new()
	inner_vb.add_theme_constant_override("separation", 8)
	inner_card.add_child(inner_vb)

	var mins = max(1, int(elapsed / 60.0))
	var desc = Label.new()
	desc.text = "While you were away for %d min (capped at 8h),\nyour staff kept cooking at 85%% efficiency:" % mins
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.add_theme_font_size_override("font_size", 14)
	apply_mobile_typography(desc, 5, Color(0.28, 0.18, 0.10, 1.0))
	inner_vb.add_child(desc)

	var cash_val = Label.new()
	cash_val.text = "+" + _format_money(earned)
	cash_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cash_val.add_theme_font_size_override("font_size", 34)
	apply_mobile_typography(cash_val, 7, Color(0.15, 0.78, 0.32, 1.0))
	inner_vb.add_child(cash_val)

	vb.add_child(inner_card)

	var hb = HBoxContainer.new()
	hb.alignment = BoxContainer.ALIGNMENT_CENTER
	hb.add_theme_constant_override("separation", 16)
	vb.add_child(hb)

	var collect_btn = Button.new()
	collect_btn.text = "COLLECT (1X)"
	collect_btn.custom_minimum_size = Vector2(160, 46)
	apply_mobile_button_theme(collect_btn, Color(0.22, 0.847, 0.282, 1.0), Color(0.12, 0.52, 0.18, 1.0), 16)
	collect_btn.add_theme_font_size_override("font_size", 15)
	collect_btn.pressed.connect(func(): _claim_offline(1.0))
	hb.add_child(collect_btn)

	var double_btn = Button.new()
	double_btn.text = "⚡ 2X PROMO BOOST!"
	double_btn.custom_minimum_size = Vector2(180, 46)
	apply_mobile_button_theme(double_btn, Color(1.0, 0.624, 0.11, 1.0), Color(0.72, 0.35, 0.05, 1.0), 16)
	double_btn.add_theme_font_size_override("font_size", 15)
	double_btn.pressed.connect(func(): _claim_offline(2.0))
	hb.add_child(double_btn)

	add_child(welcome_modal)

	welcome_modal.scale = Vector2(0.4, 0.4)
	var tw = create_tween()
	tw.tween_property(welcome_modal, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _claim_offline(mult: float) -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		var payout = gm.claim_offline_earnings(mult)
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade", 0.05, 3.0)
		_spawn_reward_floater("+$" + _format_money(payout) + " COLLECTED! 🎉")
	if welcome_modal != null and is_instance_valid(welcome_modal):
		var tw = create_tween()
		tw.tween_property(welcome_modal, "scale", Vector2(0.2, 0.2), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tw.tween_callback(welcome_modal.queue_free)

func _spawn_reward_floater(txt: String) -> void:
	var lbl = Label.new()
	lbl.text = txt
	lbl.add_theme_font_size_override("font_size", 24)
	lbl.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55))
	lbl.position = Vector2(640.0 - 140.0, 360.0 - 50.0)
	add_child(lbl)
	
	var tw = create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 70.0, 1.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.9).set_delay(0.2)
	tw.tween_callback(lbl.queue_free)

func _on_critic_review_awarded(stars: float, is_positive: bool) -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		_update_top_bar(gm.cash, gm.gems, stars, gm.restaurant_name, gm.restaurant_level, gm.restaurant_xp, gm.xp_to_next_level)
	
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		if is_positive:
			am.play_sfx("upgrade", 0.05, 3.0)
		else:
			am.play_sfx("angry")

	var banner = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	if is_positive:
		style.bg_color = Color(0.11, 0.14, 0.22, 0.95)
		style.border_color = Color(0.96, 0.77, 0.27, 1.0)
	else:
		style.bg_color = Color(0.24, 0.11, 0.12, 0.95)
		style.border_color = Color(0.95, 0.27, 0.30, 1.0)
	banner.add_theme_stylebox_override("panel", style)
	
	var lbl = Label.new()
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 16)
	if is_positive:
		lbl.text = "👑 MICHELIN 5-STAR CRITIC REVIEW! ⭐ +0.1 STARS • +2 GEMS 💎"
		lbl.add_theme_color_override("font_color", Color(1.0, 0.92, 0.55))
	else:
		lbl.text = "💢 CRITIC DOCKED STARS (-0.1 ★)! Food took too long!"
		lbl.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
	banner.add_child(lbl)
	
	banner.custom_minimum_size = Vector2(500, 48)
	banner.anchors_preset = Control.PRESET_CENTER_TOP
	banner.anchor_left = 0.5
	banner.anchor_top = 0.0
	banner.anchor_right = 0.5
	banner.anchor_bottom = 0.0
	banner.offset_left = -250
	banner.offset_right = 250
	banner.offset_top = 70
	banner.offset_bottom = 118
	banner.pivot_offset = Vector2(250, 24)
	banner.scale = Vector2(0.5, 0.5)
	add_child(banner)
	
	var tw = create_tween()
	tw.tween_property(banner, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(3.0)
	tw.tween_property(banner, "scale", Vector2(0.3, 0.3), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(banner, "modulate:a", 0.0, 0.25)
	tw.tween_callback(banner.queue_free)

# ─── Play Store Star Rating Signature Dishes & Celebration Modal ───────────
func _on_star_dish_unlocked(star_tier: int, dish_info: Dictionary) -> void:
	_refresh_star_milestone_bar()
	_show_star_dish_unlock_modal(star_tier, dish_info)

func _refresh_star_milestone_bar() -> void:
	var gm = get_node_or_null("/root/GameManager")
	var hbox = get_node_or_null("HUD/StarMilestoneBar/HBox")
	if hbox == null or gm == null:
		return
	var items = [
		{"tier": 1, "node": hbox.get_node_or_null("Star1"), "title": "★1 🍔 Burger"},
		{"tier": 2, "node": hbox.get_node_or_null("Star2"), "title": "★2 🍨 Sundae"},
		{"tier": 3, "node": hbox.get_node_or_null("Star3"), "title": "★3 🥩 Steak"},
		{"tier": 4, "node": hbox.get_node_or_null("Star4"), "title": "★4 🍸 Cocktail"},
		{"tier": 5, "node": hbox.get_node_or_null("Star5"), "title": "★5 🦞 Michelin"}
	]
	for it in items:
		var lbl: Label = it["node"]
		if lbl != null:
			lbl.text = it["title"]
			var is_unlocked: bool = gm.is_star_dish_unlocked(it["tier"]) if gm.has_method("is_star_dish_unlocked") else (it["tier"] == 1)
			if is_unlocked:
				lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.25, 1.0))
			else:
				lbl.add_theme_color_override("font_color", Color(0.65, 0.72, 0.85, 0.65))

func _show_star_dish_unlock_modal(star_tier: int, dish_info: Dictionary) -> void:
	var gm = get_node_or_null("/root/GameManager")
	var hud_node = get_node_or_null("HUD")
	if hud_node == null:
		hud_node = self
		
	# Clean up any existing modal instance
	if star_dish_unlock_modal != null and is_instance_valid(star_dish_unlock_modal):
		star_dish_unlock_modal.queue_free()
		star_dish_unlock_modal = null

	var modal_root = Control.new()
	modal_root.name = "StarDishUnlockModal"
	modal_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_root.mouse_filter = Control.MOUSE_FILTER_STOP
	star_dish_unlock_modal = modal_root

	# Dark Royal Navy Scrim
	var scrim = ColorRect.new()
	scrim.name = "Scrim"
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.04, 0.07, 0.12, 0.85)
	modal_root.add_child(scrim)

	# Sunburst Rays Background Container
	var sunburst_ctrl = Control.new()
	sunburst_ctrl.name = "SunburstRays"
	sunburst_ctrl.set_anchors_preset(Control.PRESET_CENTER)
	sunburst_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Create 16 alternating golden rays
	var ray_count = 16
	for r_i in range(ray_count):
		var ray_poly = Polygon2D.new()
		var a_start = (float(r_i) / float(ray_count)) * TAU
		var a_end = ((float(r_i) + 0.5) / float(ray_count)) * TAU
		var ray_pts = PackedVector2Array()
		ray_pts.append(Vector2.ZERO)
		var ray_radius = 550.0
		var ray_steps = 6
		for s_i in range(ray_steps + 1):
			var a = a_start + (a_end - a_start) * (float(s_i) / float(ray_steps))
			ray_pts.append(Vector2(cos(a), sin(a)) * ray_radius)
		ray_poly.polygon = ray_pts
		if r_i % 2 == 0:
			ray_poly.color = Color(1.0, 0.82, 0.22, 0.18)
		else:
			ray_poly.color = Color(1.0, 0.90, 0.35, 0.08)
		sunburst_ctrl.add_child(ray_poly)
	modal_root.add_child(sunburst_ctrl)

	# Rotate sunburst continuously
	var rot_tween = modal_root.create_tween().set_loops()
	rot_tween.tween_property(sunburst_ctrl, "rotation", TAU, 18.0).as_relative()

	# Center Card Container
	var center_box = CenterContainer.new()
	center_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_root.add_child(center_box)

	var card_panel = PanelContainer.new()
	card_panel.name = "CardPanel"
	card_panel.custom_minimum_size = Vector2(380, 480)
	
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.09, 0.12, 0.19, 0.98)
	card_style.set_corner_radius_all(24)
	card_style.border_width_left = 3
	card_style.border_width_top = 3
	card_style.border_width_right = 3
	card_style.border_width_bottom = 3
	card_style.border_color = Color(1.0, 0.84, 0.22, 1.0)
	card_style.shadow_color = Color(0.0, 0.0, 0.0, 0.6)
	card_style.shadow_size = 18
	card_style.content_margin_left = 24
	card_style.content_margin_right = 24
	card_style.content_margin_top = 22
	card_style.content_margin_bottom = 22
	card_panel.add_theme_stylebox_override("panel", card_style)
	center_box.add_child(card_panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card_panel.add_child(vbox)

	# Top Close Button Row
	var top_row = HBoxContainer.new()
	var top_spacer = Control.new()
	top_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(top_spacer)
	
	var close_btn = Button.new()
	close_btn.text = "✕"
	close_btn.custom_minimum_size = Vector2(32, 32)
	close_btn.flat = true
	close_btn.add_theme_font_size_override("font_size", 18)
	close_btn.add_theme_color_override("font_color", Color(0.8, 0.85, 0.95, 0.8))
	top_row.add_child(close_btn)
	vbox.add_child(top_row)

	# Star Rating Badge Row
	var stars_box = HBoxContainer.new()
	stars_box.alignment = BoxContainer.ALIGNMENT_CENTER
	var star_str = ""
	for s in range(1, 6):
		if s <= star_tier:
			star_str += "★ "
		else:
			star_str += "☆ "
	var star_badge = Label.new()
	star_badge.text = star_str.strip_edges()
	star_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	star_badge.add_theme_font_size_override("font_size", 22)
	star_badge.add_theme_color_override("font_color", Color(1.0, 0.86, 0.24, 1.0))
	vbox.add_child(star_badge)

	# Header Title
	var title_lbl = Label.new()
	title_lbl.text = "🌟 NEW SIGNATURE DISH! 🌟"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 16)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35, 1.0))
	vbox.add_child(title_lbl)

	# Large Dish Icon with Floating Bounce
	var icon_lbl = Label.new()
	icon_lbl.name = "DishIcon"
	icon_lbl.text = dish_info.get("icon", "🍽️")
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.add_theme_font_size_override("font_size", 68)
	vbox.add_child(icon_lbl)

	var icon_tw = modal_root.create_tween().set_loops()
	icon_tw.tween_property(icon_lbl, "scale", Vector2(1.12, 1.12), 0.65).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	icon_tw.tween_property(icon_lbl, "scale", Vector2(1.0, 1.0), 0.65).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Dish Name
	var name_lbl = Label.new()
	name_lbl.name = "DishName"
	name_lbl.text = dish_info.get("name", "Gourmet Dish")
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_lbl.add_theme_font_size_override("font_size", 20)
	name_lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	vbox.add_child(name_lbl)

	# Dish Description
	var desc_lbl = Label.new()
	desc_lbl.text = dish_info.get("desc", "")
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 12)
	desc_lbl.add_theme_color_override("font_color", Color(0.72, 0.78, 0.88, 0.9))
	vbox.add_child(desc_lbl)

	# Selling Price Multiplier Pill
	var mult_pill = PanelContainer.new()
	var pill_style = StyleBoxFlat.new()
	pill_style.bg_color = Color(0.2, 0.15, 0.05, 0.95)
	pill_style.border_color = Color(1.0, 0.82, 0.22, 0.9)
	pill_style.border_width_left = 2
	pill_style.border_width_top = 2
	pill_style.border_width_right = 2
	pill_style.border_width_bottom = 2
	pill_style.set_corner_radius_all(14)
	pill_style.content_margin_left = 12
	pill_style.content_margin_right = 12
	pill_style.content_margin_top = 8
	pill_style.content_margin_bottom = 8
	mult_pill.add_theme_stylebox_override("panel", pill_style)
	
	var mult_val: float = dish_info.get("multiplier", 1.0)
	var mult_lbl = Label.new()
	mult_lbl.name = "MultiplierLabel"
	mult_lbl.text = "🔥 x%.1f Base Selling Multiplier! 🔥" % mult_val
	mult_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mult_lbl.add_theme_font_size_override("font_size", 14)
	mult_lbl.add_theme_color_override("font_color", Color(1.0, 0.86, 0.28, 1.0))
	mult_pill.add_child(mult_lbl)
	vbox.add_child(mult_pill)

	# Green "CLAIM +25 DIAMONDS" Button
	var claim_btn = Button.new()
	claim_btn.name = "ClaimRewardBtn"
	claim_btn.text = "💎 CLAIM +25 DIAMONDS 💎"
	claim_btn.custom_minimum_size = Vector2(0, 46)
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.12, 0.68, 0.32, 1.0)
	btn_style.set_corner_radius_all(16)
	btn_style.border_width_bottom = 4
	btn_style.border_color = Color(0.06, 0.42, 0.18, 1.0)
	claim_btn.add_theme_stylebox_override("normal", btn_style)
	
	var btn_hover = btn_style.duplicate()
	btn_hover.bg_color = Color(0.16, 0.76, 0.38, 1.0)
	claim_btn.add_theme_stylebox_override("hover", btn_hover)
	
	var btn_pressed = btn_style.duplicate()
	btn_pressed.border_width_bottom = 0
	claim_btn.add_theme_stylebox_override("pressed", btn_pressed)
	
	claim_btn.add_theme_font_size_override("font_size", 15)
	claim_btn.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(claim_btn)

	var dismiss_action = func():
		if is_instance_valid(modal_root):
			var tw_close = modal_root.create_tween()
			tw_close.tween_property(card_panel, "scale", Vector2(0.3, 0.3), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			tw_close.parallel().tween_property(modal_root, "modulate:a", 0.0, 0.2)
			tw_close.tween_callback(func():
				if is_instance_valid(modal_root):
					modal_root.queue_free()
				star_dish_unlock_modal = null
			)

	claim_btn.pressed.connect(func():
		if gm != null:
			if gm.has_method("claim_star_dish_reward"):
				gm.claim_star_dish_reward(star_tier)
			else:
				gm.add_gems(25)
		dismiss_action.call()
	)

	close_btn.pressed.connect(dismiss_action)

	hud_node.add_child(modal_root)

	# Scale-in Elastic Entrance
	card_panel.pivot_offset = card_panel.custom_minimum_size * 0.5
	card_panel.scale = Vector2(0.2, 0.2)
	modal_root.modulate.a = 0.0
	
	var in_tw = modal_root.create_tween()
	in_tw.tween_property(modal_root, "modulate:a", 1.0, 0.15)
	in_tw.parallel().tween_property(card_panel, "scale", Vector2.ONE, 0.38).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("upgrade", 0.0, 4.0)

# ─── Golden Piggy Bank System ────────────────────────────────────────────────
func _on_piggy_bank_updated(current: int, max_cap: int) -> void:
	if piggy_counter_label != null:
		if current >= max_cap:
			piggy_counter_label.text = "MAX"
			piggy_counter_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2, 1.0))
		else:
			piggy_counter_label.text = str(current)
			piggy_counter_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.4, 1.0))
	if piggy_bank_modal != null and is_instance_valid(piggy_bank_modal):
		_refresh_piggy_bank_modal_contents(current, max_cap)

func _open_piggy_bank_modal() -> void:
	open_piggy_bank_modal()

func open_piggy_bank_modal() -> void:
	var gm = get_node_or_null("/root/GameManager")
	var hud_node = get_node_or_null("HUD")
	if hud_node == null:
		hud_node = self

	# Clean up any existing modal instance
	if piggy_bank_modal != null and is_instance_valid(piggy_bank_modal):
		piggy_bank_modal.queue_free()
		piggy_bank_modal = null

	var current_diamonds = gm.get_piggy_bank_diamonds() if gm != null and gm.has_method("get_piggy_bank_diamonds") else 0
	var max_cap = gm.PIGGY_BANK_CAP if gm != null and "PIGGY_BANK_CAP" in gm else 250

	var modal_root = Control.new()
	modal_root.name = "PiggyBankModal"
	modal_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_root.mouse_filter = Control.MOUSE_FILTER_STOP
	piggy_bank_modal = modal_root

	# Dark Navy Scrim
	var scrim = ColorRect.new()
	scrim.name = "Scrim"
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.04, 0.07, 0.12, 0.85)
	modal_root.add_child(scrim)

	# Golden Sunburst Rays Container
	var sunburst_ctrl = Control.new()
	sunburst_ctrl.name = "SunburstRays"
	sunburst_ctrl.set_anchors_preset(Control.PRESET_CENTER)
	sunburst_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ray_count = 16
	for r_i in range(ray_count):
		var ray_poly = Polygon2D.new()
		var a_start = (float(r_i) / float(ray_count)) * TAU
		var a_end = ((float(r_i) + 0.5) / float(ray_count)) * TAU
		var ray_pts = PackedVector2Array()
		ray_pts.append(Vector2.ZERO)
		var ray_radius = 560.0
		var ray_steps = 6
		for s_i in range(ray_steps + 1):
			var a = a_start + (a_end - a_start) * (float(s_i) / float(ray_steps))
			ray_pts.append(Vector2(cos(a), sin(a)) * ray_radius)
		ray_poly.polygon = ray_pts
		if r_i % 2 == 0:
			ray_poly.color = Color(1.0, 0.82, 0.22, 0.18)
		else:
			ray_poly.color = Color(1.0, 0.90, 0.35, 0.07)
		sunburst_ctrl.add_child(ray_poly)
	modal_root.add_child(sunburst_ctrl)

	var rot_tween = modal_root.create_tween().set_loops()
	rot_tween.tween_property(sunburst_ctrl, "rotation", TAU, 18.0).as_relative()

	# Center Card Container
	var center_box = CenterContainer.new()
	center_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_root.add_child(center_box)

	var card_panel = PanelContainer.new()
	card_panel.name = "CardPanel"
	card_panel.custom_minimum_size = Vector2(390, 510)
	
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.10, 0.13, 0.20, 0.98)
	card_style.set_corner_radius_all(24)
	card_style.border_width_left = 3
	card_style.border_width_top = 3
	card_style.border_width_right = 3
	card_style.border_width_bottom = 3
	card_style.border_color = Color(1.0, 0.82, 0.22, 1.0)
	card_style.shadow_color = Color(0.0, 0.0, 0.0, 0.6)
	card_style.shadow_size = 14
	card_panel.add_theme_stylebox_override("panel", card_style)
	center_box.add_child(card_panel)

	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.add_theme_constant_override("separation", 12)
	card_panel.add_child(vbox)

	# 1. Header Bar with Close Button
	var header_hbox = HBoxContainer.new()
	vbox.add_child(header_hbox)

	var title_lbl = Label.new()
	title_lbl.name = "TitleLabel"
	title_lbl.text = "🐷 GOLDEN PIGGY BANK 🐷"
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.25, 1.0))
	header_hbox.add_child(title_lbl)

	var close_btn = Button.new()
	close_btn.name = "CloseBtn"
	close_btn.text = "✕"
	close_btn.custom_minimum_size = Vector2(34, 34)
	var close_sb = StyleBoxFlat.new()
	close_sb.bg_color = Color(0.2, 0.2, 0.26, 0.85)
	close_sb.set_corner_radius_all(17)
	close_btn.add_theme_stylebox_override("normal", close_sb)
	close_btn.add_theme_font_size_override("font_size", 14)
	close_btn.add_theme_color_override("font_color", Color.WHITE)
	header_hbox.add_child(close_btn)

	# Subtitle
	var sub_lbl = Label.new()
	sub_lbl.text = "Every station upgrade & completed order\nsaves free Diamonds into your Piggy Bank!"
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.add_theme_font_size_override("font_size", 11)
	sub_lbl.add_theme_color_override("font_color", Color(0.78, 0.84, 0.95, 0.9))
	vbox.add_child(sub_lbl)

	# 2. Golden Graphic Card
	var gfx_panel = PanelContainer.new()
	gfx_panel.name = "GraphicCard"
	gfx_panel.custom_minimum_size = Vector2(340, 200)
	var gfx_sb = StyleBoxFlat.new()
	gfx_sb.bg_color = Color(0.14, 0.11, 0.22, 0.92)
	gfx_sb.border_width_left = 2
	gfx_sb.border_width_top = 2
	gfx_sb.border_width_right = 2
	gfx_sb.border_width_bottom = 2
	gfx_sb.border_color = Color(1.0, 0.82, 0.22, 0.6)
	gfx_sb.set_corner_radius_all(18)
	gfx_panel.add_theme_stylebox_override("panel", gfx_sb)
	vbox.add_child(gfx_panel)

	var gfx_vbox = VBoxContainer.new()
	gfx_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	gfx_vbox.add_theme_constant_override("separation", 6)
	gfx_panel.add_child(gfx_vbox)

	var pig_icon = Label.new()
	pig_icon.name = "PigIcon"
	pig_icon.text = "🐷"
	pig_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pig_icon.add_theme_font_size_override("font_size", 64)
	gfx_vbox.add_child(pig_icon)

	var pig_tw = modal_root.create_tween().set_loops()
	pig_tw.tween_property(pig_icon, "scale", Vector2(1.08, 1.08), 0.75).set_trans(Tween.TRANS_SINE)
	pig_tw.tween_property(pig_icon, "scale", Vector2.ONE, 0.75).set_trans(Tween.TRANS_SINE)
	pig_icon.pivot_offset = Vector2(32, 32)

	var count_lbl = Label.new()
	count_lbl.name = "PiggyDiamondCount"
	count_lbl.text = "%d / %d 💎" % [current_diamonds, max_cap]
	count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_lbl.add_theme_font_size_override("font_size", 26)
	count_lbl.add_theme_color_override("font_color", Color(1.0, 0.92, 0.35, 1.0))
	gfx_vbox.add_child(count_lbl)

	# 3. Progress Track
	var pbar = ProgressBar.new()
	pbar.name = "PiggyProgressBar"
	pbar.custom_minimum_size = Vector2(320, 18)
	pbar.min_value = 0.0
	pbar.max_value = float(max_cap)
	pbar.value = float(current_diamonds)
	pbar.show_percentage = false
	
	var pb_bg = StyleBoxFlat.new()
	pb_bg.bg_color = Color(0.06, 0.08, 0.12, 0.95)
	pb_bg.set_corner_radius_all(9)
	pbar.add_theme_stylebox_override("background", pb_bg)

	var pb_fill = StyleBoxFlat.new()
	pb_fill.bg_color = Color(1.0, 0.75, 0.15, 1.0)
	pb_fill.set_corner_radius_all(9)
	pbar.add_theme_stylebox_override("fill", pb_fill)
	vbox.add_child(pbar)

	# Status Hint
	var hint_lbl = Label.new()
	hint_lbl.name = "StatusHint"
	if current_diamonds >= max_cap:
		hint_lbl.text = "🔥 BANK FULL! SMASH OPEN TO CLAIM! 🔥"
		hint_lbl.add_theme_color_override("font_color", Color(1.0, 0.65, 0.2, 1.0))
	else:
		hint_lbl.text = "⚡ %d more Diamonds to reach capacity! ⚡" % (max_cap - current_diamonds)
		hint_lbl.add_theme_color_override("font_color", Color(0.65, 0.85, 1.0, 0.85))
	hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_lbl.add_theme_font_size_override("font_size", 12)
	vbox.add_child(hint_lbl)

	# 4. Smash Open Button
	var smash_btn = Button.new()
	smash_btn.name = "SmashOpenBtn"
	smash_btn.custom_minimum_size = Vector2(340, 52)
	if current_diamonds > 0:
		smash_btn.text = "🔨 SMASH OPEN (CLAIM +%d 💎)" % current_diamonds
	else:
		smash_btn.text = "🔨 SMASH OPEN (+0 💎)"
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.14, 0.72, 0.35, 1.0)
	btn_style.set_corner_radius_all(18)
	btn_style.border_width_left = 2
	btn_style.border_width_top = 2
	btn_style.border_width_right = 2
	btn_style.border_width_bottom = 5
	btn_style.border_color = Color(0.06, 0.42, 0.18, 1.0)
	smash_btn.add_theme_stylebox_override("normal", btn_style)
	
	var btn_hover = btn_style.duplicate()
	btn_hover.bg_color = Color(0.18, 0.78, 0.4, 1.0)
	smash_btn.add_theme_stylebox_override("hover", btn_hover)
	
	var btn_pressed = btn_style.duplicate()
	btn_pressed.border_width_bottom = 0
	smash_btn.add_theme_stylebox_override("pressed", btn_pressed)
	smash_btn.add_theme_font_size_override("font_size", 15)
	smash_btn.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(smash_btn)

	var dismiss_action = func():
		if is_instance_valid(modal_root):
			var tw_close = modal_root.create_tween()
			tw_close.tween_property(card_panel, "scale", Vector2(0.3, 0.3), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			tw_close.parallel().tween_property(modal_root, "modulate:a", 0.0, 0.2)
			tw_close.tween_callback(func():
				if is_instance_valid(modal_root):
					modal_root.queue_free()
				piggy_bank_modal = null
			)

	smash_btn.pressed.connect(func():
		if gm != null:
			var claimed = gm.smash_piggy_bank() if gm.has_method("smash_piggy_bank") else 0
			if claimed > 0:
				if has_method("spawn_flying_currency_trail"):
					spawn_flying_currency_trail(Vector3.ZERO, float(claimed), "diamonds")
		dismiss_action.call()
	)

	close_btn.pressed.connect(dismiss_action)
	scrim.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			dismiss_action.call()
	)

	hud_node.add_child(modal_root)

	# Scale-in Elastic Entrance
	card_panel.pivot_offset = card_panel.custom_minimum_size * 0.5
	card_panel.scale = Vector2(0.2, 0.2)
	modal_root.modulate.a = 0.0
	
	var in_tw = modal_root.create_tween()
	in_tw.tween_property(modal_root, "modulate:a", 1.0, 0.15)
	in_tw.parallel().tween_property(card_panel, "scale", Vector2.ONE, 0.38).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("upgrade", 0.0, 3.0)

func _refresh_piggy_bank_modal_contents(current: int, max_cap: int) -> void:
	if piggy_bank_modal == null or not is_instance_valid(piggy_bank_modal):
		return
	var count_lbl = piggy_bank_modal.find_child("PiggyDiamondCount", true, false)
	if count_lbl is Label:
		count_lbl.text = "%d / %d 💎" % [current, max_cap]
	var pbar = piggy_bank_modal.find_child("PiggyProgressBar", true, false)
	if pbar is ProgressBar:
		pbar.value = float(current)
		pbar.max_value = float(max_cap)
	var hint_lbl = piggy_bank_modal.find_child("StatusHint", true, false)
	if hint_lbl is Label:
		if current >= max_cap:
			hint_lbl.text = "🔥 BANK FULL! SMASH OPEN TO CLAIM! 🔥"
			hint_lbl.add_theme_color_override("font_color", Color(1.0, 0.65, 0.2, 1.0))
		else:
			hint_lbl.text = "⚡ %d more Diamonds to reach capacity! ⚡" % (max_cap - current)
			hint_lbl.add_theme_color_override("font_color", Color(0.65, 0.85, 1.0, 0.85))
	var smash_btn = piggy_bank_modal.find_child("SmashOpenBtn", true, false)
	if smash_btn is Button:
		if current > 0:
			smash_btn.text = "🔨 SMASH OPEN (CLAIM +%d 💎)" % current
		else:
			smash_btn.text = "🔨 SMASH OPEN (+0 💎)"

# ─── Roadside VIP Angel Investor Offers ──────────────────────────────────────
func _on_investor_offer_requested(investor_node: Node3D, cash_amount: float, diamond_amount: int) -> void:
	open_investor_offer_modal(investor_node, cash_amount, diamond_amount)

func _open_investor_offer_modal(investor_node: Node3D = null, cash_amount: float = 0.0, diamond_amount: int = 0) -> void:
	open_investor_offer_modal(investor_node, cash_amount, diamond_amount)

func open_investor_offer_modal(investor_node: Node3D = null, cash_amount: float = 0.0, diamond_amount: int = 0) -> void:
	var gm = get_node_or_null("/root/GameManager")
	var hud_node = get_node_or_null("HUD")
	if hud_node == null:
		hud_node = self

	# Clean up any existing modal instance
	if investor_offer_modal != null and is_instance_valid(investor_offer_modal):
		investor_offer_modal.queue_free()
		investor_offer_modal = null

	if cash_amount <= 0.0:
		var eff_rate = gm.get_effective_cash_per_sec() if gm != null and gm.has_method("get_effective_cash_per_sec") else 125.0
		cash_amount = max(15000.0, round(eff_rate * 120.0))
	if diamond_amount <= 0:
		diamond_amount = 15

	var modal_root = Control.new()
	modal_root.name = "InvestorOfferModal"
	modal_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_root.mouse_filter = Control.MOUSE_FILTER_STOP
	investor_offer_modal = modal_root

	# Dark Navy Scrim
	var scrim = ColorRect.new()
	scrim.name = "Scrim"
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.04, 0.07, 0.12, 0.85)
	modal_root.add_child(scrim)

	# Sunburst Rays Container (Royal Blue & Gold rays)
	var sunburst_ctrl = Control.new()
	sunburst_ctrl.name = "SunburstRays"
	sunburst_ctrl.set_anchors_preset(Control.PRESET_CENTER)
	sunburst_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ray_count = 16
	for r_i in range(ray_count):
		var ray_poly = Polygon2D.new()
		var a_start = (float(r_i) / float(ray_count)) * TAU
		var a_end = ((float(r_i) + 0.5) / float(ray_count)) * TAU
		var ray_pts = PackedVector2Array()
		ray_pts.append(Vector2.ZERO)
		var ray_radius = 560.0
		var ray_steps = 6
		for s_i in range(ray_steps + 1):
			var a = a_start + (a_end - a_start) * (float(s_i) / float(ray_steps))
			ray_pts.append(Vector2(cos(a), sin(a)) * ray_radius)
		ray_poly.polygon = ray_pts
		if r_i % 2 == 0:
			ray_poly.color = Color(1.0, 0.82, 0.22, 0.18)
		else:
			ray_poly.color = Color(0.2, 0.5, 1.0, 0.09)
		sunburst_ctrl.add_child(ray_poly)
	modal_root.add_child(sunburst_ctrl)

	var rot_tween = modal_root.create_tween().set_loops()
	rot_tween.tween_property(sunburst_ctrl, "rotation", TAU, 20.0).as_relative()

	# Center Card Container
	var center_box = CenterContainer.new()
	center_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_root.add_child(center_box)

	var card_panel = PanelContainer.new()
	card_panel.name = "CardPanel"
	card_panel.custom_minimum_size = Vector2(410, 520)
	
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.08, 0.11, 0.19, 0.98)
	card_style.set_corner_radius_all(24)
	card_style.border_width_left = 3
	card_style.border_width_top = 3
	card_style.border_width_right = 3
	card_style.border_width_bottom = 3
	card_style.border_color = Color(1.0, 0.84, 0.22, 1.0)
	card_style.shadow_color = Color(0.0, 0.0, 0.0, 0.6)
	card_style.shadow_size = 14
	card_panel.add_theme_stylebox_override("panel", card_style)
	center_box.add_child(card_panel)

	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.add_theme_constant_override("separation", 12)
	card_panel.add_child(vbox)

	# 1. Header with Close Button
	var header_hbox = HBoxContainer.new()
	vbox.add_child(header_hbox)

	var title_lbl = Label.new()
	title_lbl.name = "TitleLabel"
	title_lbl.text = "💼 VIP ANGEL INVESTOR 💼"
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.25, 1.0))
	header_hbox.add_child(title_lbl)

	var close_btn = Button.new()
	close_btn.name = "CloseBtn"
	close_btn.text = "✕"
	close_btn.custom_minimum_size = Vector2(34, 34)
	var close_sb = StyleBoxFlat.new()
	close_sb.bg_color = Color(0.2, 0.2, 0.26, 0.85)
	close_sb.set_corner_radius_all(17)
	close_btn.add_theme_stylebox_override("normal", close_sb)
	close_btn.add_theme_font_size_override("font_size", 14)
	close_btn.add_theme_color_override("font_color", Color.WHITE)
	header_hbox.add_child(close_btn)

	# Subtitle
	var sub_lbl = Label.new()
	sub_lbl.text = "A Wall Street venture capitalist has arrived at your diner\nwith a lucrative roadside investment deal!"
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.add_theme_font_size_override("font_size", 11)
	sub_lbl.add_theme_color_override("font_color", Color(0.8, 0.86, 0.95, 0.9))
	vbox.add_child(sub_lbl)

	# Briefcase Illustration
	var case_icon = Label.new()
	case_icon.name = "BriefcaseIcon"
	case_icon.text = "💼"
	case_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	case_icon.add_theme_font_size_override("font_size", 54)
	vbox.add_child(case_icon)

	var choice_title = Label.new()
	choice_title.text = "CHOOSE YOUR VENTURE CAPITAL DEAL:"
	choice_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	choice_title.add_theme_font_size_override("font_size", 12)
	choice_title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.22, 1.0))
	vbox.add_child(choice_title)

	# 2. Offer A: Massive Cash Injection Button
	var cash_btn = Button.new()
	cash_btn.name = "AcceptCashBtn"
	cash_btn.custom_minimum_size = Vector2(360, 68)
	var cash_str = gm.format_currency(cash_amount) if gm != null and gm.has_method("format_currency") else ("$%d" % round(cash_amount))
	cash_btn.text = "💵  ACCEPT %s CASH\n(120x Instant Revenue Boost! 🚀)" % cash_str
	
	var cash_sb = StyleBoxFlat.new()
	cash_sb.bg_color = Color(0.12, 0.65, 0.32, 1.0)
	cash_sb.set_corner_radius_all(18)
	cash_sb.border_width_left = 2
	cash_sb.border_width_top = 2
	cash_sb.border_width_right = 2
	cash_sb.border_width_bottom = 5
	cash_sb.border_color = Color(0.06, 0.38, 0.16, 1.0)
	cash_btn.add_theme_stylebox_override("normal", cash_sb)
	
	var cash_hover = cash_sb.duplicate()
	cash_hover.bg_color = Color(0.16, 0.72, 0.38, 1.0)
	cash_btn.add_theme_stylebox_override("hover", cash_hover)
	
	var cash_press = cash_sb.duplicate()
	cash_press.border_width_bottom = 0
	cash_btn.add_theme_stylebox_override("pressed", cash_press)
	cash_btn.add_theme_font_size_override("font_size", 14)
	cash_btn.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(cash_btn)

	# 3. Offer B: Diamond Pack Button
	var diamond_btn = Button.new()
	diamond_btn.name = "AcceptDiamondsBtn"
	diamond_btn.custom_minimum_size = Vector2(360, 68)
	diamond_btn.text = "💎  ACCEPT +%d DIAMONDS\n(Permanent Upgrades & Vault Boosts! 💎)" % diamond_amount
	
	var dia_sb = StyleBoxFlat.new()
	dia_sb.bg_color = Color(0.55, 0.22, 0.85, 1.0)
	dia_sb.set_corner_radius_all(18)
	dia_sb.border_width_left = 2
	dia_sb.border_width_top = 2
	dia_sb.border_width_right = 2
	dia_sb.border_width_bottom = 5
	dia_sb.border_color = Color(0.32, 0.10, 0.52, 1.0)
	diamond_btn.add_theme_stylebox_override("normal", dia_sb)
	
	var dia_hover = dia_sb.duplicate()
	dia_hover.bg_color = Color(0.62, 0.28, 0.92, 1.0)
	diamond_btn.add_theme_stylebox_override("hover", dia_hover)
	
	var dia_press = dia_sb.duplicate()
	dia_press.border_width_bottom = 0
	diamond_btn.add_theme_stylebox_override("pressed", dia_press)
	diamond_btn.add_theme_font_size_override("font_size", 14)
	diamond_btn.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(diamond_btn)

	var dismiss_action = func():
		if is_instance_valid(modal_root):
			var tw_close = modal_root.create_tween()
			tw_close.tween_property(card_panel, "scale", Vector2(0.3, 0.3), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			tw_close.parallel().tween_property(modal_root, "modulate:a", 0.0, 0.2)
			tw_close.tween_callback(func():
				if is_instance_valid(modal_root):
					modal_root.queue_free()
				investor_offer_modal = null
			)

	cash_btn.pressed.connect(func():
		if investor_node != null and is_instance_valid(investor_node) and investor_node.has_method("claim_vip_investor_choice"):
			investor_node.claim_vip_investor_choice("cash")
		elif gm != null and gm.has_method("award_investor_choice"):
			gm.award_investor_choice("cash")
		dismiss_action.call()
	)

	diamond_btn.pressed.connect(func():
		if investor_node != null and is_instance_valid(investor_node) and investor_node.has_method("claim_vip_investor_choice"):
			investor_node.claim_vip_investor_choice("diamonds")
		elif gm != null and gm.has_method("award_investor_choice"):
			gm.award_investor_choice("diamonds")
		dismiss_action.call()
	)

	close_btn.pressed.connect(dismiss_action)
	scrim.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			dismiss_action.call()
	)

	hud_node.add_child(modal_root)

	# Scale-in Elastic Entrance
	card_panel.pivot_offset = card_panel.custom_minimum_size * 0.5
	card_panel.scale = Vector2(0.2, 0.2)
	modal_root.modulate.a = 0.0
	
	var in_tw = modal_root.create_tween()
	in_tw.tween_property(modal_root, "modulate:a", 1.0, 0.15)
	in_tw.parallel().tween_property(card_panel, "scale", Vector2.ONE, 0.38).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("bell", 0.0, 3.0)

# ─── Michelin Critic & VIP Arrival Toast Banner ──────────────────────────────
func _on_vip_arrived(vip_node: Node3D, title: String, type: String, duration: float) -> void:
	if active_vip_toast != null and is_instance_valid(active_vip_toast):
		active_vip_toast.queue_free()
		active_vip_toast = null
		
	active_vip_node = vip_node
	active_vip_duration = max(5.0, duration)
	active_vip_timer = active_vip_duration
	
	var toast = PanelContainer.new()
	toast.name = "VipArrivalToast"
	toast.custom_minimum_size = Vector2(420, 54)
	toast.anchors_preset = Control.PRESET_CENTER_TOP
	toast.anchor_left = 0.5
	toast.anchor_top = 0.0
	toast.anchor_right = 0.5
	toast.anchor_bottom = 0.0
	toast.offset_left = -210.0
	toast.offset_right = 210.0
	toast.offset_top = -65.0
	toast.offset_bottom = -11.0
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.12, 0.08, 0.96)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(1.0, 0.82, 0.22, 1.0)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	toast.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	toast.add_child(vbox)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(hbox)
	
	var title_lbl = Label.new()
	title_lbl.text = title
	title_lbl.add_theme_font_size_override("font_size", 13)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.92, 0.35, 1.0))
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(title_lbl)
	
	var locate_btn = Button.new()
	locate_btn.name = "LocateBtn"
	locate_btn.text = "📍 LOCATE"
	locate_btn.custom_minimum_size = Vector2(76, 24)
	locate_btn.add_theme_font_size_override("font_size", 11)
	locate_btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.85, 0.65, 0.12, 1.0)
	btn_style.set_corner_radius_all(6)
	btn_style.content_margin_left = 8
	btn_style.content_margin_right = 8
	btn_style.content_margin_top = 3
	btn_style.content_margin_bottom = 3
	locate_btn.add_theme_stylebox_override("normal", btn_style)
	
	var btn_hover = btn_style.duplicate()
	btn_hover.bg_color = Color(0.96, 0.75, 0.2, 1.0)
	locate_btn.add_theme_stylebox_override("hover", btn_hover)
	
	locate_btn.pressed.connect(func():
		_locate_vip(vip_node)
	)
	apply_button_squash_and_stretch(locate_btn)
	hbox.add_child(locate_btn)
	
	var pbar = ProgressBar.new()
	pbar.name = "ProgressBar"
	pbar.custom_minimum_size = Vector2(0, 6)
	pbar.max_value = active_vip_duration
	pbar.value = active_vip_duration
	pbar.show_percentage = false
	
	var pbar_bg = StyleBoxFlat.new()
	pbar_bg.bg_color = Color(0.2, 0.18, 0.15, 0.8)
	pbar_bg.set_corner_radius_all(3)
	pbar.add_theme_stylebox_override("background", pbar_bg)
	
	var pbar_fill = StyleBoxFlat.new()
	pbar_fill.bg_color = Color(1.0, 0.82, 0.22, 1.0)
	pbar_fill.set_corner_radius_all(3)
	pbar.add_theme_stylebox_override("fill", pbar_fill)
	vbox.add_child(pbar)
	
	active_vip_progress_bar = pbar
	
	toast.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_locate_vip(vip_node)
	)
	
	var hud_node = get_node_or_null("HUD")
	if hud_node != null:
		hud_node.add_child(toast)
	else:
		add_child(toast)
		
	active_vip_toast = toast
	
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("bell", 0.05, 3.0)
		
	var tw = create_tween()
	tw.tween_property(toast, "offset_top", 24.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(toast, "offset_bottom", 78.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _locate_vip(vip_node: Node3D) -> void:
	if vip_node == null or not is_instance_valid(vip_node):
		return
	var cam = get_viewport().get_camera_3d() if get_viewport() != null else null
	if cam == null:
		var tree = get_tree()
		if tree != null and tree.current_scene != null:
			cam = tree.current_scene.find_child("Camera3D", true, false)
	if cam != null and is_instance_valid(cam):
		if cam.has_method("focus_target_node"):
			cam.focus_target_node(vip_node, 0.45)
		elif cam.has_method("pan_to_position"):
			var wp = vip_node.global_position
			cam.pan_to_position(Vector3(wp.x + 18.37, 15.0, wp.z + 18.37), 0.45, false)
	_play_click_sfx()

func _dismiss_vip_toast() -> void:
	if active_vip_toast == null or not is_instance_valid(active_vip_toast):
		active_vip_toast = null
		return
	var t = active_vip_toast
	active_vip_toast = null
	var tw = create_tween()
	tw.tween_property(t, "offset_top", -65.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(t, "offset_bottom", -11.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_callback(t.queue_free)

func _update_header_bottleneck_pill() -> void:
	var gm = get_node_or_null("/root/GameManager")
	var info = gm.get_bottleneck_status() if gm != null and gm.has_method("get_bottleneck_status") else {"text": "Optimal Flow", "color": Color(0.18, 0.78, 0.35, 1.0), "code": "OPTIMAL", "icon": "🟢"}
	
	var header_hbox = get_node_or_null("UpgradePanel/VBox/HeaderBar/HBox")
	if header_hbox == null:
		return
	var pill = header_hbox.get_node_or_null("BottleneckStatusPill")
	if pill == null:
		pill = PanelContainer.new()
		pill.name = "BottleneckStatusPill"
		var lbl = Label.new()
		lbl.name = "BottleneckLabel"
		lbl.add_theme_font_size_override("font_size", 11)
		pill.add_child(lbl)
		header_hbox.add_child(pill)
		if hours_badge_label != null and hours_badge_label.get_parent() == header_hbox:
			header_hbox.move_child(pill, hours_badge_label.get_index())
			
	var p_style = StyleBoxFlat.new()
	var col = info.get("color", Color(0.18, 0.78, 0.35)) as Color
	p_style.bg_color = col.lerp(Color.BLACK, 0.7)
	p_style.border_width_left = 1
	p_style.border_width_top = 1
	p_style.border_width_right = 1
	p_style.border_width_bottom = 1
	p_style.border_color = col
	p_style.set_corner_radius_all(6)
	p_style.content_margin_left = 6
	p_style.content_margin_right = 6
	p_style.content_margin_top = 2
	p_style.content_margin_bottom = 2
	pill.add_theme_stylebox_override("panel", p_style)
	
	var pill_lbl = pill.get_node_or_null("BottleneckLabel") as Label
	if pill_lbl != null:
		pill_lbl.text = "%s %s" % [info.get("icon", "🟢"), info.get("text", "Optimal Flow")]
		pill_lbl.add_theme_color_override("font_color", col)

# ─── Financial Analytics Modal ──────────────────────────────────────────────
func _refresh_analytics_panel() -> void:
	if analytics_vbox == null: return
	for c in analytics_vbox.get_children():
		c.queue_free()
	var gm = get_node_or_null("/root/GameManager")
	if gm == null: return
	
	var fin = gm.get_financial_breakdown() if gm.has_method("get_financial_breakdown") else {}
	var income_data = fin.get("income", {})
	var expense_data = fin.get("expenses", {})
	var net_sec = float(fin.get("net_profit", 0.0))
	
	# Sector Bottleneck Status Pill
	var bottleneck_info = gm.get_bottleneck_status() if gm.has_method("get_bottleneck_status") else {"text": "Optimal Flow", "color": Color(0.18, 0.78, 0.35, 1.0), "code": "OPTIMAL", "icon": "🟢"}
	var b_banner = PanelContainer.new()
	var b_style = StyleBoxFlat.new()
	var b_col = bottleneck_info.get("color", Color(0.18, 0.78, 0.35)) as Color
	b_style.bg_color = b_col.lerp(Color.BLACK, 0.75)
	b_style.border_width_left = 3
	b_style.border_width_top = 1
	b_style.border_width_right = 1
	b_style.border_width_bottom = 1
	b_style.border_color = b_col
	b_style.set_corner_radius_all(10)
	b_style.set_content_margin_all(10)
	b_banner.add_theme_stylebox_override("panel", b_style)
	
	var b_hbox = HBoxContainer.new()
	b_hbox.add_theme_constant_override("separation", 10)
	b_banner.add_child(b_hbox)
	
	var b_icon = Label.new()
	b_icon.text = bottleneck_info.get("icon", "🟢")
	b_icon.add_theme_font_size_override("font_size", 16)
	b_hbox.add_child(b_icon)
	
	var b_vbox = VBoxContainer.new()
	b_vbox.add_theme_constant_override("separation", 1)
	b_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b_hbox.add_child(b_vbox)
	
	var b_tag = Label.new()
	b_tag.text = "OPERATIONAL BOTTLENECK DIAGNOSTIC"
	b_tag.add_theme_font_size_override("font_size", 11)
	b_tag.add_theme_color_override("font_color", Color(0.78, 0.85, 0.9, 0.85))
	b_vbox.add_child(b_tag)
	
	var b_text = Label.new()
	b_text.text = bottleneck_info.get("text", "Optimal Flow")
	b_text.add_theme_font_size_override("font_size", 15)
	b_text.add_theme_color_override("font_color", b_col)
	b_vbox.add_child(b_text)
	
	analytics_vbox.add_child(b_banner)
	
	# Net Profit Margin Banner
	var net_banner = PanelContainer.new()
	var net_style = StyleBoxFlat.new()
	net_style.bg_color = Color(0.1, 0.35, 0.2, 0.95) if net_sec >= 0.0 else Color(0.4, 0.12, 0.12, 0.95)
	net_style.border_width_left = 3
	net_style.border_color = Color(0.3, 0.95, 0.5, 1.0) if net_sec >= 0.0 else Color(0.95, 0.3, 0.3, 1.0)
	net_style.set_corner_radius_all(10)
	net_style.set_content_margin_all(12)
	net_banner.add_theme_stylebox_override("panel", net_style)
	
	var net_vbox = VBoxContainer.new()
	net_vbox.add_theme_constant_override("separation", 2)
	net_banner.add_child(net_vbox)
	
	var net_title = Label.new()
	net_title.text = "📈 NET CASH FLOW (PROFIT RATE)"
	net_title.add_theme_font_size_override("font_size", 12)
	net_title.add_theme_color_override("font_color", Color(0.8, 0.95, 0.85, 0.85))
	net_vbox.add_child(net_title)
	
	var net_val = Label.new()
	var net_str = ("+" if net_sec >= 0.0 else "-") + _format_money(abs(net_sec))
	var net_min_str = ("+" if net_sec >= 0.0 else "-") + _format_money(abs(net_sec * 60.0))
	net_val.text = "%s / sec   (%s / min)" % [net_str, net_min_str]
	net_val.add_theme_font_size_override("font_size", 18)
	net_val.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55, 1.0) if net_sec >= 0.0 else Color(1.0, 0.45, 0.45, 1.0))
	net_vbox.add_child(net_val)
	analytics_vbox.add_child(net_banner)
	
	# Section 1: Incomes
	var inc_head = Label.new()
	inc_head.text = "💵 LIVE REVENUE STREAMS (+%s/s)" % _format_money(income_data.get("total", 0.0))
	inc_head.add_theme_font_size_override("font_size", 14)
	inc_head.add_theme_color_override("font_color", Color(0.35, 0.95, 0.55, 1.0))
	analytics_vbox.add_child(inc_head)
	
	analytics_vbox.add_child(_create_analytics_row("🍽️ Dining Room Tables", "Main restaurant dining booths, bistro orders & kitchen stoves", "+" + _format_money(income_data.get("dining", 0.0)) + "/s", Color(0.2, 0.85, 0.45, 1.0)))
	analytics_vbox.add_child(_create_analytics_row("🥤 50s Milkshake Bar", "Stainless steel soda fountain, blenders & sundaes", "+" + _format_money(income_data.get("milkshake", 0.0)) + "/s", Color(0.2, 0.85, 0.45, 1.0)))
	analytics_vbox.add_child(_create_analytics_row("🍸 Cocktail Lounge", "Mahogany bar stools, mixology cocktails & wine goblets", "+" + _format_money(income_data.get("cocktail", 0.0)) + "/s", Color(0.2, 0.85, 0.45, 1.0)))
	analytics_vbox.add_child(_create_analytics_row("🚗 Valet Parking Lot", "Automated customer arrivals, valet turnaround & helipad drops", "+" + _format_money(income_data.get("parking", 0.0)) + "/s", Color(0.2, 0.85, 0.45, 1.0)))
	
	# Section 2: Expenses
	var exp_head = Label.new()
	exp_head.text = "📉 OPERATIONAL EXPENSES (-%s/s)" % _format_money(expense_data.get("total", 0.0))
	exp_head.add_theme_font_size_override("font_size", 14)
	exp_head.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45, 1.0))
	analytics_vbox.add_child(exp_head)
	
	analytics_vbox.add_child(_create_analytics_row("📢 Marketing & Campaigns", "Roadside billboard advertising, diner neon & flyers (-%s/min)" % _format_money(expense_data.get("marketing_min", 50.0)), "-" + _format_money(expense_data.get("marketing", 0.0)) + "/s", Color(1.0, 0.45, 0.45, 1.0)))
	analytics_vbox.add_child(_create_analytics_row("🧹 Cleaning & Sanitation", "Dining room janitorial maintenance, busboy supplies (-%s/min)" % _format_money(expense_data.get("cleaning_min", 300.0)), "-" + _format_money(expense_data.get("cleaning", 0.0)) + "/s", Color(1.0, 0.45, 0.45, 1.0)))
	analytics_vbox.add_child(_create_analytics_row("👔 Staff Payroll & Wages", "Active hourly wages for chefs, waiters, hostess, bartender, cleaner & manager", "-" + _format_money(expense_data.get("staff", 0.0)) + "/s", Color(1.0, 0.45, 0.45, 1.0)))

func _create_analytics_row(title: String, desc: String, value_txt: String, val_color: Color) -> PanelContainer:
	var p = PanelContainer.new()
	p.add_theme_stylebox_override("panel", _get_card_style())
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	p.add_child(hbox)
	
	var vb = VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_theme_constant_override("separation", 2)
	hbox.add_child(vb)
	
	var title_lbl = Label.new()
	title_lbl.text = title
	title_lbl.add_theme_font_size_override("font_size", 14)
	title_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	vb.add_child(title_lbl)
	
	var desc_lbl = Label.new()
	desc_lbl.text = desc
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.7, 0.78, 0.88, 0.85))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(desc_lbl)
	
	var val_lbl = Label.new()
	val_lbl.text = value_txt
	val_lbl.add_theme_font_size_override("font_size", 15)
	val_lbl.add_theme_color_override("font_color", val_color)
	hbox.add_child(val_lbl)
	
	return p

# ─── Global Perks & Menu Book Modal ─────────────────────────────────────────
func _refresh_perks_panel() -> void:
	if perks_vbox == null: return
	for c in perks_vbox.get_children():
		c.queue_free()
	var gm = get_node_or_null("/root/GameManager")
	if gm == null: return

	# Section 1: Research Perks
	var sec1 = Label.new()
	sec1.text = "🔬 RESTAURANT-WIDE RESEARCH PERKS"
	sec1.add_theme_font_size_override("font_size", 15)
	sec1.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35, 1.0))
	perks_vbox.add_child(sec1)

	var perks = gm.get_research_perks() if gm.has_method("get_research_perks") else {}
	for pid in perks.keys():
		var perk = perks[pid]
		perks_vbox.add_child(_create_perk_card(perk, gm))

	# Section 2: Michelin Gourmet Menu Book
	var sec2 = Label.new()
	sec2.text = "📖 MICHELIN GOURMET RECIPES & DISHES"
	sec2.add_theme_font_size_override("font_size", 15)
	sec2.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0, 1.0))
	perks_vbox.add_child(sec2)

	for item_id in gm.menu_items.keys():
		var item = gm.menu_items[item_id]
		perks_vbox.add_child(_create_menu_perk_card(item, gm))

func _create_perk_card(perk: Dictionary, gm: Node) -> PanelContainer:
	var p = PanelContainer.new()
	p.add_theme_stylebox_override("panel", _get_card_style())
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	p.add_child(hbox)
	
	var icon_lbl = Label.new()
	icon_lbl.text = perk.get("icon", "💡")
	icon_lbl.add_theme_font_size_override("font_size", 24)
	hbox.add_child(icon_lbl)
	
	var vb = VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_theme_constant_override("separation", 2)
	hbox.add_child(vb)
	
	var name_lbl = Label.new()
	name_lbl.text = perk.get("name", "Perk")
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	vb.add_child(name_lbl)
	
	var eff_lbl = Label.new()
	eff_lbl.text = "⚡ " + perk.get("effect", "")
	eff_lbl.add_theme_font_size_override("font_size", 12)
	eff_lbl.add_theme_color_override("font_color", Color(0.35, 0.95, 0.55, 1.0))
	vb.add_child(eff_lbl)
	
	var desc_lbl = Label.new()
	desc_lbl.text = perk.get("desc", "")
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.7, 0.78, 0.88, 0.85))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(desc_lbl)
	
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(130, 40)
	var is_unlocked = perk.get("unlocked", false)
	var cost = float(perk.get("cost", 500.0))
	
	if is_unlocked:
		btn.text = "✓ RESEARCHED"
		btn.disabled = true
		btn.add_theme_stylebox_override("normal", _get_green_btn_style())
	else:
		btn.text = "RESEARCH\n(%s)" % _format_money(cost)
		btn.disabled = gm.cash < cost
		btn.add_theme_stylebox_override("normal", _get_gold_btn_style())
		btn.pressed.connect(func():
			_play_click_sfx()
			if gm.unlock_perk(perk["id"]):
				_refresh_perks_panel()
		)
	hbox.add_child(btn)
	return p

func _create_menu_perk_card(item: Dictionary, gm: Node) -> PanelContainer:
	var p = PanelContainer.new()
	p.add_theme_stylebox_override("panel", _get_card_style())
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	p.add_child(hbox)
	
	var icon_lbl = Label.new()
	icon_lbl.text = item.get("icon", "🍽️")
	icon_lbl.add_theme_font_size_override("font_size", 24)
	hbox.add_child(icon_lbl)
	
	var vb = VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_theme_constant_override("separation", 2)
	hbox.add_child(vb)
	
	var name_lbl = Label.new()
	name_lbl.text = item.get("name", "Dish")
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	vb.add_child(name_lbl)
	
	var rev_lbl = Label.new()
	rev_lbl.text = "💵 %s / Order • Active on Dining Menus" % _format_money(item.get("price", 45.0))
	rev_lbl.add_theme_font_size_override("font_size", 12)
	rev_lbl.add_theme_color_override("font_color", Color(0.35, 0.95, 0.55, 1.0))
	vb.add_child(rev_lbl)
	
	var desc_lbl = Label.new()
	desc_lbl.text = item.get("desc", "")
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.7, 0.78, 0.88, 0.85))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(desc_lbl)
	
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(130, 40)
	var is_unlocked = item.get("unlocked", false)
	var cost = float(item.get("unlock_cost", 100.0))
	
	if is_unlocked:
		btn.text = "✓ SERVING"
		btn.disabled = true
		btn.add_theme_stylebox_override("normal", _get_green_btn_style())
	else:
		btn.text = "UNLOCK\n(%s)" % _format_money(cost)
		btn.disabled = gm.cash < cost
		btn.add_theme_stylebox_override("normal", _get_gold_btn_style())
		btn.pressed.connect(func():
			_play_click_sfx()
			if gm.unlock_dish(item["id"]):
				_refresh_perks_panel()
		)
	hbox.add_child(btn)
	return p

# ─── World Map Display ──────────────────────────────────────────────────────
func _refresh_world_map() -> void:
	if world_map_grid == null:
		return

	var gm = get_node_or_null("/root/GameManager")
	if gm == null:
		return

	# Setup or refresh Franchise Prestige Banner at the top of WorldMapPanel
	if world_map_panel != null:
		var vbox = world_map_panel.get_node_or_null("VBox")
		if vbox != null:
			var old_banner = vbox.get_node_or_null("FranchisePrestigeBanner")
			if old_banner != null:
				old_banner.queue_free()
			var banner = _create_franchise_prestige_banner(gm)
			vbox.add_child(banner)
			vbox.move_child(banner, 1)

	for c in world_map_grid.get_children():
		c.queue_free()

	var rests = gm.get_world_restaurants()
	for rest_id in rests.keys():
		var r = rests[rest_id]
		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(360, 160)
		
		var card_style = StyleBoxFlat.new()
		card_style.bg_color = Color(0.12, 0.17, 0.28, 0.95)
		card_style.border_width_left = 2
		card_style.border_width_top = 2
		card_style.border_width_right = 2
		card_style.border_width_bottom = 4
		card_style.border_color = r.get("color", Color(0.3, 0.5, 0.8, 1.0))
		card_style.corner_radius_top_left = 14
		card_style.corner_radius_top_right = 14
		card_style.corner_radius_bottom_right = 14
		card_style.corner_radius_bottom_left = 14
		card_style.content_margin_left = 16.0
		card_style.content_margin_top = 12.0
		card_style.content_margin_right = 16.0
		card_style.content_margin_bottom = 12.0
		card.add_theme_stylebox_override("panel", card_style)

		var card_vbox = VBoxContainer.new()
		card_vbox.add_theme_constant_override("separation", 6)
		card.add_child(card_vbox)

		# Header: Icon + Name + Stars
		var head_hbox = HBoxContainer.new()
		head_hbox.add_theme_constant_override("separation", 8)
		card_vbox.add_child(head_hbox)

		var icon_lbl = Label.new()
		icon_lbl.text = r.get("icon", "🍽️")
		icon_lbl.add_theme_font_size_override("font_size", 24)
		head_hbox.add_child(icon_lbl)

		var name_lbl = Label.new()
		name_lbl.text = r.get("name", "Restaurant")
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.add_theme_font_size_override("font_size", 16)
		name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		head_hbox.add_child(name_lbl)

		var stars_lbl = Label.new()
		var s_count = int(r.get("stars", 1))
		stars_lbl.text = "★".repeat(s_count) + "☆".repeat(5 - s_count)
		stars_lbl.add_theme_font_size_override("font_size", 13)
		stars_lbl.add_theme_color_override("font_color", Color(1, 0.85, 0.25, 1))
		head_hbox.add_child(stars_lbl)

		# Tagline & Theme
		var tag_lbl = Label.new()
		tag_lbl.text = r.get("tagline", "")
		tag_lbl.add_theme_font_size_override("font_size", 11)
		tag_lbl.add_theme_color_override("font_color", Color(0.7, 0.82, 0.95, 0.85))
		if rest_id == "idle_diner":
			name_lbl.text = "⭐ Restaurant 1: Idle Diner"
			tag_lbl.text = "Classic 1950s American Diner • 100% Max Level Complete"
			tag_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35, 1.0))
		card_vbox.add_child(tag_lbl)

		# Multiplier & Stats
		var mult_lbl = Label.new()
		var mult_val = float(r.get("multiplier", 1.0))
		mult_lbl.text = "⚡ %s Revenue Multiplier" % ("%.1fx" % mult_val if mult_val < 10.0 else "%dx" % round(mult_val))
		mult_lbl.add_theme_font_size_override("font_size", 12)
		mult_lbl.add_theme_color_override("font_color", Color(0.4, 0.95, 0.6, 1))
		card_vbox.add_child(mult_lbl)

		# Bottom Action Button
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 36)
		
		var is_active = (gm.active_restaurant_id == rest_id)
		var is_unlocked = bool(r.get("unlocked", false))
		var cost = float(r.get("cost", 0.0))

		if is_active:
			btn.text = "🟢 RESTAURANT 1 (100% MAX LEVEL)" if rest_id == "idle_diner" else "🟢 CURRENT LOCATION"
			btn.disabled = true
			var btn_style = StyleBoxFlat.new()
			btn_style.bg_color = Color(0.12, 0.45, 0.25, 0.9)
			btn_style.corner_radius_top_left = 10
			btn_style.corner_radius_top_right = 10
			btn_style.corner_radius_bottom_right = 10
			btn_style.corner_radius_bottom_left = 10
			btn.add_theme_stylebox_override("disabled", btn_style)
			btn.add_theme_color_override("font_disabled_color", Color(0.7, 1.0, 0.8, 1))
		elif is_unlocked:
			btn.text = "✈️ VISIT / SWITCH"
			var btn_style = StyleBoxFlat.new()
			btn_style.bg_color = Color(0.2, 0.55, 0.85, 1)
			btn_style.corner_radius_top_left = 10
			btn_style.corner_radius_top_right = 10
			btn_style.corner_radius_bottom_right = 10
			btn_style.corner_radius_bottom_left = 10
			btn.add_theme_stylebox_override("normal", btn_style)
			btn.pressed.connect(func():
				_play_click_sfx()
				gm.switch_to_restaurant(rest_id)
				_close_modal(world_map_panel)
			)
		else:
			var can_afford = (gm.cash >= cost)
			btn.text = "🔒 UNLOCK (%s)" % _format_money(cost)
			btn.disabled = not can_afford
			var btn_style = StyleBoxFlat.new()
			btn_style.bg_color = Color(0.95, 0.6, 0.15, 1) if can_afford else Color(0.3, 0.35, 0.45, 0.6)
			btn_style.corner_radius_top_left = 10
			btn_style.corner_radius_top_right = 10
			btn_style.corner_radius_bottom_right = 10
			btn_style.corner_radius_bottom_left = 10
			btn.add_theme_stylebox_override("normal", btn_style)
			btn.pressed.connect(func():
				_play_click_sfx()
				if gm.unlock_world_restaurant(rest_id):
					_refresh_world_map()
			)

		card_vbox.add_child(btn)
		world_map_grid.add_child(card)

func _create_franchise_prestige_banner(gm: Node) -> Control:
	var banner = PanelContainer.new()
	banner.name = "FranchisePrestigeBanner"
	banner.custom_minimum_size = Vector2(0, 110)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.14, 0.24, 0.98)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 3
	style.border_color = Color(0.95, 0.78, 0.25, 1.0)
	style.set_corner_radius_all(12)
	style.content_margin_left = 16.0
	style.content_margin_top = 10.0
	style.content_margin_right = 16.0
	style.content_margin_bottom = 10.0
	banner.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	banner.add_child(vbox)
	
	var valuation = gm.get_restaurant_valuation() if gm.has_method("get_restaurant_valuation") else 500.0
	var p_lvl = gm.prestige_level if "prestige_level" in gm else 0
	var keys = gm.franchise_keys if "franchise_keys" in gm else 0
	var p_mult = gm.get_prestige_multiplier() if gm.has_method("get_prestige_multiplier") else 1.0
	var can_p = gm.can_prestige() if gm.has_method("can_prestige") else false
	var keys_reward = gm.get_prestige_keys_gain() if gm.has_method("get_prestige_keys_gain") else 1
	var diamonds_reward = gm.get_prestige_diamonds_gain() if gm.has_method("get_prestige_diamonds_gain") else 25

	# Row 1: Header + Stats Cluster
	var row1 = HBoxContainer.new()
	row1.add_theme_constant_override("separation", 10)
	vbox.add_child(row1)
	
	var crown_icon = Label.new()
	crown_icon.text = "👑"
	crown_icon.add_theme_font_size_override("font_size", 22)
	row1.add_child(crown_icon)
	
	var title_lbl = Label.new()
	title_lbl.text = "FRANCHISE VALUATION: %s" % _format_money(valuation)
	title_lbl.add_theme_font_size_override("font_size", 16)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35, 1.0))
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row1.add_child(title_lbl)
	
	var keys_pill = Label.new()
	keys_pill.text = "🔑 %d Keys" % keys
	keys_pill.add_theme_font_size_override("font_size", 13)
	keys_pill.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25, 1.0))
	row1.add_child(keys_pill)

	var sep = Label.new()
	sep.text = "•"
	sep.add_theme_color_override("font_color", Color(0.5, 0.6, 0.7, 0.8))
	row1.add_child(sep)
	
	var mult_pill = Label.new()
	mult_pill.text = "⭐ Prestige Lv. %d (+%d%% Profit)" % [p_lvl, int((p_mult - 1.0) * 100.0)]
	mult_pill.add_theme_font_size_override("font_size", 13)
	mult_pill.add_theme_color_override("font_color", Color(0.4, 0.95, 0.6, 1.0))
	row1.add_child(mult_pill)

	# Row 2: Subtitle / Progress details
	var row2 = HBoxContainer.new()
	vbox.add_child(row2)
	
	var desc_lbl = Label.new()
	desc_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc_lbl.add_theme_font_size_override("font_size", 11)
	if can_p:
		desc_lbl.text = "✨ VALUATION TARGET MET! Sell & Renovate to expand your empire with permanent profit boosts!"
		desc_lbl.add_theme_color_override("font_color", Color(0.45, 0.95, 0.65, 1.0))
	else:
		var target_val = 25000.0
		var pct = clampf((valuation / target_val) * 100.0, 0.0, 99.9)
		desc_lbl.text = "Target Valuation: $25.0K (%d%% met) • Reach $25K valuation or Max Level 50 core stations to Sell." % int(pct)
		desc_lbl.add_theme_color_override("font_color", Color(0.75, 0.85, 0.95, 0.85))
	row2.add_child(desc_lbl)

	# Row 3: Action & Rewards Bar
	var row3 = HBoxContainer.new()
	row3.add_theme_constant_override("separation", 12)
	vbox.add_child(row3)
	
	var reward_lbl = Label.new()
	reward_lbl.text = "Rewards on Sale:  +%d 🔑 Keys   •   +%d 💎 Diamonds   •   +50%% Permanent Profit" % [keys_reward, diamonds_reward]
	reward_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reward_lbl.add_theme_font_size_override("font_size", 12)
	reward_lbl.add_theme_color_override("font_color", Color(1.0, 0.92, 0.6, 0.95))
	row3.add_child(reward_lbl)
	
	var prestige_btn = Button.new()
	prestige_btn.custom_minimum_size = Vector2(240, 34)
	if can_p:
		prestige_btn.text = "⭐ SELL & RENOVATE (+%d 🔑)" % keys_reward
		var p_style = StyleBoxFlat.new()
		p_style.bg_color = Color(0.95, 0.72, 0.15, 1.0)
		p_style.border_width_bottom = 2
		p_style.border_color = Color(1.0, 0.9, 0.45, 1.0)
		p_style.set_corner_radius_all(8)
		prestige_btn.add_theme_stylebox_override("normal", p_style)
		prestige_btn.add_theme_color_override("font_color", Color(0.12, 0.08, 0.0, 1.0))
		prestige_btn.pressed.connect(func():
			_play_click_sfx()
			_show_prestige_confirmation_modal()
		)
	else:
		prestige_btn.text = "🔒 SELL & RENOVATE"
		prestige_btn.disabled = true
		var dis_style = StyleBoxFlat.new()
		dis_style.bg_color = Color(0.2, 0.25, 0.35, 0.6)
		dis_style.set_corner_radius_all(8)
		prestige_btn.add_theme_stylebox_override("disabled", dis_style)
		prestige_btn.add_theme_color_override("font_disabled_color", Color(0.6, 0.65, 0.75, 0.6))
	row3.add_child(prestige_btn)
	
	return banner

func _show_prestige_confirmation_modal() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm == null:
		return
	
	var keys_gained = gm.get_prestige_keys_gain() if gm.has_method("get_prestige_keys_gain") else 1
	var diamonds_gained = gm.get_prestige_diamonds_gain() if gm.has_method("get_prestige_diamonds_gain") else 25
	var cur_mult = gm.get_prestige_multiplier() if gm.has_method("get_prestige_multiplier") else 1.0
	var next_mult = cur_mult + 0.50

	var modal = PanelContainer.new()
	modal.name = "PrestigeConfirmModal"
	modal.custom_minimum_size = Vector2(460, 320)
	modal.anchors_preset = Control.PRESET_CENTER
	modal.anchor_left = 0.5
	modal.anchor_top = 0.5
	modal.anchor_right = 0.5
	modal.anchor_bottom = 0.5
	modal.offset_left = -230.0
	modal.offset_top = -160.0
	modal.offset_right = 230.0
	modal.offset_bottom = 160.0
	
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.08, 0.12, 0.20, 0.98)
	bg_style.border_width_left = 3
	bg_style.border_width_top = 3
	bg_style.border_width_right = 3
	bg_style.border_width_bottom = 5
	bg_style.border_color = Color(0.95, 0.78, 0.25, 1.0)
	bg_style.set_corner_radius_all(16)
	bg_style.content_margin_left = 22.0
	bg_style.content_margin_top = 18.0
	bg_style.content_margin_right = 22.0
	bg_style.content_margin_bottom = 18.0
	modal.add_theme_stylebox_override("panel", bg_style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	modal.add_child(vbox)
	
	var title = Label.new()
	title.text = "👑 EXPAND FRANCHISE EMPIRE?"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35, 1.0))
	vbox.add_child(title)
	
	var msg = Label.new()
	msg.text = "Are you ready to sell this restaurant location?\n\n" + \
		"⚠️  WHAT RESETS:\n" + \
		"• Cash resets to starting $500 (+ prestige bonus)\n" + \
		"• Station levels reset back to Level 1\n\n" + \
		"✨  PERMANENT PRESTIGE REWARDS:\n" + \
		"• +%d 🔑 Franchise Golden Keys\n" + \
		"• +%d 💎 Diamonds\n" + \
		"• +50%% Permanent Global Profit (New: %.1fx)\n" + \
		"• ALL Manager Cards & Permanent Boosters are KEPT!" % [keys_gained, diamonds_gained, next_mult]
	msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg.add_theme_font_size_override("font_size", 12)
	msg.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0, 0.95))
	vbox.add_child(msg)
	
	var btn_hbox = HBoxContainer.new()
	btn_hbox.add_theme_constant_override("separation", 14)
	vbox.add_child(btn_hbox)
	
	var cancel_btn = Button.new()
	cancel_btn.text = "Keep Operating"
	cancel_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cancel_btn.custom_minimum_size = Vector2(0, 36)
	var cancel_style = StyleBoxFlat.new()
	cancel_style.bg_color = Color(0.2, 0.25, 0.35, 0.8)
	cancel_style.set_corner_radius_all(10)
	cancel_btn.add_theme_stylebox_override("normal", cancel_style)
	cancel_btn.pressed.connect(func():
		_play_click_sfx()
		modal.queue_free()
	)
	btn_hbox.add_child(cancel_btn)
	
	var confirm_btn = Button.new()
	confirm_btn.text = "✨ CONFIRM & PRESTIGE ✨"
	confirm_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	confirm_btn.custom_minimum_size = Vector2(0, 36)
	var conf_style = StyleBoxFlat.new()
	conf_style.bg_color = Color(0.95, 0.72, 0.15, 1.0)
	conf_style.set_corner_radius_all(10)
	confirm_btn.add_theme_stylebox_override("normal", conf_style)
	confirm_btn.add_theme_color_override("font_color", Color(0.12, 0.08, 0.0, 1.0))
	confirm_btn.pressed.connect(func():
		_play_click_sfx()
		modal.queue_free()
		if gm.execute_prestige():
			_refresh_world_map()
	)
	btn_hbox.add_child(confirm_btn)
	
	add_child(modal)

func _on_franchise_prestiged(p_level: int, keys: int, d_earned: int) -> void:
	_show_franchise_toast("👑 FRANCHISE EMPIRE EXPANDED! Prestige Lv. %d (+%d 🔑, +%d 💎)" % [p_level, keys, d_earned])
	_refresh_world_map()

func _show_franchise_toast(text: String) -> void:
	var hud_node = get_node_or_null("HUD")
	if hud_node == null:
		hud_node = self
		
	var toast = PanelContainer.new()
	toast.name = "FranchisePrestigeToast"
	toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast.custom_minimum_size = Vector2(460, 56)
	toast.anchors_preset = Control.PRESET_CENTER_TOP
	toast.anchor_left = 0.5
	toast.anchor_top = 0.0
	toast.anchor_right = 0.5
	toast.anchor_bottom = 0.0
	toast.offset_left = -230.0
	toast.offset_right = 230.0
	toast.offset_top = 28.0
	toast.offset_bottom = 84.0
	toast.grow_horizontal = Control.GROW_DIRECTION_BOTH
	toast.pivot_offset = Vector2(230, 28)
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.08, 0.24, 0.96)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 3
	sb.border_color = Color(0.95, 0.78, 0.25, 1.0)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 16
	sb.content_margin_top = 8
	sb.content_margin_right = 16
	sb.content_margin_bottom = 8
	toast.add_theme_stylebox_override("panel", sb)
	
	var lbl = Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35, 1.0))
	toast.add_child(lbl)
	
	hud_node.add_child(toast)
	
	toast.scale = Vector2(0.8, 0.8)
	toast.modulate.a = 0.0
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(toast, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(toast, "modulate:a", 1.0, 0.25)
	tw.chain().tween_interval(3.5)
	tw.chain().tween_property(toast, "modulate:a", 0.0, 0.35)
	tw.tween_callback(toast.queue_free)

# ─── Tycoon Superstore Modal ────────────────────────────────────────────────
func _init_shop_tab_styles() -> void:
	shop_tab_style_active = StyleBoxFlat.new()
	shop_tab_style_active.bg_color = Color(0.95, 0.72, 0.15, 1.0)
	shop_tab_style_active.border_width_bottom = 3
	shop_tab_style_active.border_color = Color(1.0, 0.9, 0.45, 1.0)
	shop_tab_style_active.set_corner_radius_all(12)
	shop_tab_style_active.content_margin_left = 14.0
	shop_tab_style_active.content_margin_top = 6.0
	shop_tab_style_active.content_margin_right = 14.0
	shop_tab_style_active.content_margin_bottom = 6.0

	shop_tab_style_inactive = StyleBoxFlat.new()
	shop_tab_style_inactive.bg_color = Color(0.12, 0.15, 0.22, 0.9)
	shop_tab_style_inactive.border_width_bottom = 2
	shop_tab_style_inactive.border_color = Color(0.2, 0.25, 0.35, 0.8)
	shop_tab_style_inactive.set_corner_radius_all(12)
	shop_tab_style_inactive.content_margin_left = 14.0
	shop_tab_style_inactive.content_margin_top = 6.0
	shop_tab_style_inactive.content_margin_right = 14.0
	shop_tab_style_inactive.content_margin_bottom = 6.0

func _update_shop_tab_styles() -> void:
	if shop_tab_style_active == null:
		_init_shop_tab_styles()
	var tabs = {
		"featured": tab_featured_btn,
		"boosts": tab_boosts_btn,
		"timeskips": tab_timeskips_btn,
		"chests": tab_chests_btn,
		"currencies": tab_currencies_btn
	}
	for cat in tabs.keys():
		var btn = tabs[cat]
		if btn != null:
			if cat == current_shop_category:
				btn.add_theme_stylebox_override("normal", shop_tab_style_active)
				btn.add_theme_stylebox_override("hover", shop_tab_style_active)
				btn.add_theme_stylebox_override("pressed", shop_tab_style_active)
				btn.add_theme_color_override("font_color", Color(0.12, 0.08, 0.02, 1.0))
			else:
				btn.add_theme_stylebox_override("normal", shop_tab_style_inactive)
				btn.add_theme_stylebox_override("hover", shop_tab_style_inactive)
				btn.add_theme_stylebox_override("pressed", shop_tab_style_inactive)
				btn.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0, 1.0))

func _select_shop_category(category_name: String) -> void:
	_play_click_sfx()
	current_shop_category = category_name
	_update_shop_tab_styles()
	_refresh_shop_panel()

func _open_shop_at_section(category: String) -> void:
	_play_click_sfx()
	current_shop_category = category
	_update_shop_tab_styles()
	if shop_panel != null and not shop_panel.visible:
		_toggle_modal(shop_panel, _refresh_shop_panel)
	else:
		_refresh_shop_panel()

func _refresh_shop_panel() -> void:
	if shop_vbox == null: return
	for c in shop_vbox.get_children():
		c.queue_free()
	var gm = _get_game_manager()
	if gm == null: return

	_update_shop_tab_styles()

	match current_shop_category:
		"featured":
			# Daily Free Gift
			shop_vbox.add_child(_create_shop_card(
				"daily_gift",
				"🎁 Daily Supply Delivery",
				"Daily care package from head chef! Free cash & diamonds.",
				"+$250 Cash & +5 Gems",
				"FREE CLAIM" if gm.can_claim_daily_gift() else "✓ CLAIMED",
				Color(0.2, 0.75, 0.4, 1.0) if gm.can_claim_daily_gift() else Color(0.4, 0.4, 0.5, 0.6),
				not gm.can_claim_daily_gift(),
				gm
			))
			# Permanent x2 Income
			var perm_owned = gm.is_permanent_booster_owned("perm_2x_income")
			shop_vbox.add_child(_create_shop_card(
				"perm_2x_income",
				"👑 Permanent x2 Income",
				"Doubles all restaurant dishes, counters and drive-thru sales permanently!",
				"⭐ Permanent 2X Profit Multiplier",
				"✓ OWNED" if perm_owned else "💎 150 GEMS",
				Color(0.2, 0.75, 0.4, 1.0) if perm_owned else Color(0.95, 0.65, 0.15, 1.0),
				perm_owned or gm.diamonds < 150,
				gm
			))
			# VIP Auto-Collector
			var vip_owned = gm.is_permanent_booster_owned("vip_auto_collector")
			shop_vbox.add_child(_create_shop_card(
				"vip_auto_collector",
				"🤖 VIP Auto-Collector",
				"Automatically sweeps up and collects table cash stacks, customer tips and register earnings!",
				"⭐ Hands-Free Instant Cash Pickup",
				"✓ OWNED" if vip_owned else "💎 100 GEMS",
				Color(0.2, 0.75, 0.4, 1.0) if vip_owned else Color(0.95, 0.65, 0.15, 1.0),
				vip_owned or gm.diamonds < 100,
				gm
			))
			# Other permanent boosters
			var perm_boosters = gm.get_permanent_boosters() if gm.has_method("get_permanent_boosters") else {}
			for bid in ["fast_service", "vip_rush"]:
				if perm_boosters.has(bid):
					var b = perm_boosters[bid]
					var is_owned = b.get("owned", false)
					var gem_cost = int(b.get("gem_cost", 50))
					shop_vbox.add_child(_create_shop_card(
						bid,
						b.get("icon", "👑") + " " + b.get("name", "Booster") + " (Permanent)",
						b.get("desc", ""),
						"⭐ " + b.get("effect", ""),
						"✓ OWNED" if is_owned else "💎 %d GEMS" % gem_cost,
						Color(0.2, 0.75, 0.4, 1.0) if is_owned else Color(0.95, 0.65, 0.15, 1.0),
						is_owned or gm.diamonds < gem_cost,
						gm
					))

		"boosts":
			# Temporary Overdrive Boosts
			shop_vbox.add_child(_create_shop_card(
				"boost_2x_1h",
				"⚡ 2X Profit Rush (1 Hour)",
				"Doubles all restaurant revenue for a full 60 minutes (3600s)!",
				"🔥 2X Multiplier (1 Hour)",
				"💎 25 GEMS",
				Color(0.2, 0.7, 0.95, 1.0),
				gm.diamonds < 25,
				gm
			))
			shop_vbox.add_child(_create_shop_card(
				"boost_5x_15m",
				"🔥 5X Super Rush (15 Mins)",
				"Skyrockets diner dining speed and dish revenue by 500% for 15 minutes!",
				"🔥 5X Multiplier (15 Mins)",
				"💎 45 GEMS",
				Color(0.95, 0.45, 0.15, 1.0),
				gm.diamonds < 45,
				gm
			))
			shop_vbox.add_child(_create_shop_card(
				"boost_10x_5m",
				"💥 10X Mega Overdrive (5 Mins)",
				"Maximum diner rush! 10X revenue across all tables, bars and stations!",
				"🔥 10X Multiplier (5 Mins)",
				"💎 75 GEMS",
				Color(0.95, 0.25, 0.25, 1.0),
				gm.diamonds < 75,
				gm
			))
			shop_vbox.add_child(_create_shop_card(
				"boost_5m",
				"⚡ 5-Minute Lunch Rush",
				"Doubles all customer revenue and diner tips for 5 minutes (300s)!",
				"🔥 2X Multiplier (5 Mins)",
				"💎 15 GEMS",
				Color(0.2, 0.7, 0.95, 1.0),
				gm.diamonds < 15,
				gm
			))
			shop_vbox.add_child(_create_shop_card(
				"boost_15m",
				"🔥 15-Minute Happy Hour",
				"High-intensity diner rush! 2X revenue for a full 15 minutes (900s)!",
				"🔥 2X Multiplier (15 Mins)",
				"💎 35 GEMS",
				Color(0.95, 0.35, 0.25, 1.0),
				gm.diamonds < 35,
				gm
			))

		"timeskips":
			var rate = gm.get_effective_cash_per_sec()
			var reward_1h = max(rate * 3600.0, 1800.0)
			var reward_4h = max(rate * 14400.0, 7200.0)
			var reward_24h = max(rate * 86400.0, 43200.0)

			# 1-Hour Time Warp (Diamonds & Coins)
			shop_vbox.add_child(_create_shop_card(
				"timeskip_1h_diamond",
				"⏱️ 1-Hour Time Warp",
				"Instantly fast-forwards diner earnings by 1 hour based on current income rate.",
				"+%s Cash Immediately" % _format_money(reward_1h),
				"💎 20 GEMS",
				Color(0.2, 0.7, 0.95, 1.0),
				gm.diamonds < 20,
				gm
			))
			shop_vbox.add_child(_create_shop_card(
				"timeskip_1h_gold",
				"⏱️ 1-Hour Time Warp (Gold Coins)",
				"Fast-forward 1 hour of profits using golden prestige coins.",
				"+%s Cash Immediately" % _format_money(reward_1h),
				"🪙 150 COINS",
				Color(0.95, 0.75, 0.15, 1.0),
				gm.golden_coins < 150,
				gm
			))
			# 4-Hour Time Warp (Diamonds & Coins)
			shop_vbox.add_child(_create_shop_card(
				"timeskip_4h_diamond",
				"⏳ 4-Hour Time Warp",
				"Instantly fast-forwards diner earnings by 4 hours based on current income rate.",
				"+%s Cash Immediately" % _format_money(reward_4h),
				"💎 60 GEMS",
				Color(0.2, 0.7, 0.95, 1.0),
				gm.diamonds < 60,
				gm
			))
			shop_vbox.add_child(_create_shop_card(
				"timeskip_4h_gold",
				"⏳ 4-Hour Time Warp (Gold Coins)",
				"Fast-forward 4 hours of profits using golden prestige coins.",
				"+%s Cash Immediately" % _format_money(reward_4h),
				"🪙 500 COINS",
				Color(0.95, 0.75, 0.15, 1.0),
				gm.golden_coins < 500,
				gm
			))
			# 24-Hour Day Jump (Diamonds & Coins)
			shop_vbox.add_child(_create_shop_card(
				"timeskip_24h_diamond",
				"🚀 24-Hour Day Jump",
				"A massive 24-hour leap forward in restaurant revenue!",
				"+%s Cash Immediately" % _format_money(reward_24h),
				"💎 250 GEMS",
				Color(0.85, 0.35, 0.95, 1.0),
				gm.diamonds < 250,
				gm
			))
			shop_vbox.add_child(_create_shop_card(
				"timeskip_24h_gold",
				"🚀 24-Hour Day Jump (Gold Coins)",
				"A massive 24-hour leap forward in restaurant revenue with golden coins!",
				"+%s Cash Immediately" % _format_money(reward_24h),
				"🪙 2000 COINS",
				Color(0.95, 0.75, 0.15, 1.0),
				gm.golden_coins < 2000,
				gm
			))

		"chests":
			# Cards Roster Shortcut Banner
			shop_vbox.add_child(_create_shop_card(
				"view_cards",
				"🃏 Collectible Cards Roster",
				"Inspect all 12 sector managers, track duplicate progress bars, and level them up using Golden Coins!",
				"⭐ 12 Restaurant Boosters",
				"VIEW CARDS",
				Color(0.85, 0.4, 0.95, 1.0),
				false,
				gm
			))
			
			# 1. Wooden Chef Chest (Free claim every 4 hours or 100 Golden Coins)
			var wooden_can_free = gm.can_claim_free_wooden_chest() if gm.has_method("can_claim_free_wooden_chest") else false
			var cd_left = gm.get_free_wooden_chest_cooldown_left() if gm.has_method("get_free_wooden_chest_cooldown_left") else 0.0
			var wooden_btn_text = "FREE CLAIM" if wooden_can_free else "🪙 100 COINS"
			var wooden_val_text = "🎁 Free Ready!" if wooden_can_free else ("Free in %dm (or 100 Coins)" % int(ceil(cd_left / 60.0)))
			var wooden_btn_color = Color(0.2, 0.8, 0.4, 1.0) if wooden_can_free else Color(0.95, 0.75, 0.15, 1.0)
			var wooden_disabled = false if wooden_can_free else (gm.golden_coins < 100)
			shop_vbox.add_child(_create_shop_card(
				"chest_wooden",
				"🪵 Wooden Chef Chest",
				"Contains Cash, Golden Coins, and 2 Collectible Cards (Common & Rare)!",
				wooden_val_text,
				wooden_btn_text,
				wooden_btn_color,
				wooden_disabled,
				gm
			))

			# 2. Silver Maître D' Chest (35 Diamonds)
			shop_vbox.add_child(_create_shop_card(
				"chest_silver",
				"🥈 Silver Maître D' Chest",
				"Contains generous Cash, Gold Coins, Diamonds, and 3 Collectible Cards (Guaranteed Rare+, chance of Epic)!",
				"+2K-5K Cash, 50-120 Gold & 3 Cards",
				"💎 35 GEMS",
				Color(0.25, 0.72, 0.95, 1.0),
				gm.diamonds < 35,
				gm
			))

			# 3. Golden Epic Tycoon Chest (120 Diamonds)
			shop_vbox.add_child(_create_shop_card(
				"chest_golden_epic",
				"🏆 Golden Epic Tycoon Chest",
				"Massive fortune of Cash, Gold, Diamonds, and 5 Collectible Cards (Guaranteed Epic or Legendary)!",
				"+10K-25K Cash, 200-500 Gold & 5 Cards",
				"💎 120 GEMS",
				Color(1.0, 0.82, 0.2, 1.0),
				gm.diamonds < 120,
				gm
			))

			# Treasury Cash Tip Jars
			shop_vbox.add_child(_create_shop_card(
				"cash_chest_small",
				"💰 Small Tip Jar",
				"Instant cash infusion for quick kitchen expansions.",
				"+%s Cash" % _format_money(1000.0),
				"💎 10 GEMS",
				Color(0.95, 0.65, 0.15, 1.0),
				gm.diamonds < 10,
				gm
			))
			shop_vbox.add_child(_create_shop_card(
				"cash_chest_medium",
				"💼 Tycoon Briefcase",
				"Substantial stack of cash for multi-level dining upgrades.",
				"+%s Cash" % _format_money(6500.0),
				"💎 40 GEMS",
				Color(0.95, 0.65, 0.15, 1.0),
				gm.diamonds < 40,
				gm
			))
			shop_vbox.add_child(_create_shop_card(
				"cash_chest_grand",
				"🏦 Golden Diner Vault",
				"Massive bullion reserve to instantly fund any restaurant purchase.",
				"+%s Cash" % _format_money(35000.0),
				"💎 150 GEMS",
				Color(0.95, 0.65, 0.15, 1.0),
				gm.diamonds < 150,
				gm
			))

		"currencies":
			# Golden Coins Packs
			shop_vbox.add_child(_create_shop_card(
				"gold_pouch",
				"🪙 Pouch of Gold",
				"Prestige golden coins for unlocking high-tier research perks.",
				"+100 Golden Coins",
				"💎 15 GEMS",
				Color(0.95, 0.75, 0.15, 1.0),
				gm.diamonds < 15,
				gm
			))
			shop_vbox.add_child(_create_shop_card(
				"gold_chest",
				"🪙 Chest of Gold",
				"Hefty chest of gold coins to accelerate diner operations.",
				"+500 Golden Coins",
				"💎 60 GEMS",
				Color(0.95, 0.75, 0.15, 1.0),
				gm.diamonds < 60,
				gm
			))
			shop_vbox.add_child(_create_shop_card(
				"gold_trove",
				"🪙 Royal Gold Trove",
				"Abundant store of golden coins for serious prestige managers.",
				"+1500 Golden Coins",
				"💎 150 GEMS",
				Color(0.95, 0.75, 0.15, 1.0),
				gm.diamonds < 150,
				gm
			))
			# Energy Packs
			shop_vbox.add_child(_create_shop_card(
				"energy_pack",
				"⚡ Lightning Energy Pack",
				"Recharge station boost capacity immediately.",
				"+25 Lightning Energy",
				"💎 10 GEMS",
				Color(0.2, 0.7, 0.95, 1.0),
				gm.diamonds < 10 or gm.energy >= gm.max_energy,
				gm
			))
			shop_vbox.add_child(_create_shop_card(
				"energy_full",
				"⚡ Full Energy Refill",
				"Instantly refills energy reserves back to 50/50 maximum!",
				"+50 Max Energy (Full)",
				"💎 20 GEMS",
				Color(0.2, 0.8, 0.4, 1.0),
				gm.diamonds < 20 or gm.energy >= gm.max_energy,
				gm
			))
			# Diamond Purchases with Cash
			shop_vbox.add_child(_create_shop_card(
				"buy_gems",
				"💎 Diamond Stash",
				"Exchange diner cash earnings for precious diamonds.",
				"+50 Diamonds",
				_format_money(2500.0) + " CASH",
				Color(0.65, 0.45, 0.95, 1.0),
				gm.cash < 2500.0,
				gm
			))
			shop_vbox.add_child(_create_shop_card(
				"buy_gems_large",
				"💎 Diamond Treasury",
				"Large cash purchase for a substantial diamond hoard.",
				"+250 Diamonds",
				_format_money(10000.0) + " CASH",
				Color(0.65, 0.45, 0.95, 1.0),
				gm.cash < 10000.0,
				gm
			))

func _create_shop_card(item_id: String, title_txt: String, desc_txt: String, value_txt: String, btn_txt: String, btn_color: Color, is_disabled: bool, gm: Node) -> PanelContainer:
	var p = PanelContainer.new()
	p.add_theme_stylebox_override("panel", _get_card_style())

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)
	p.add_child(hbox)

	var icon_tex: Texture2D = null
	if item_id.begins_with("chest_wooden") or item_id == "wooden_chest":
		icon_tex = get_custom_texture("res://assets/textures/icon_chest_wood.png")
	elif item_id.begins_with("chest_silver") or item_id == "silver_chest":
		icon_tex = get_custom_texture("res://assets/textures/icon_chest_silver.png")
	elif item_id.begins_with("chest_golden") or item_id.begins_with("chest_epic") or item_id == "golden_chest":
		icon_tex = get_custom_texture("res://assets/textures/icon_chest_gold.png")
	elif item_id.begins_with("timeskip") or item_id.begins_with("time_skip"):
		icon_tex = get_custom_texture("res://assets/textures/icon_time_skip.png")
	elif item_id.begins_with("energy"):
		icon_tex = get_custom_texture("res://assets/textures/icon_energy.png")
	elif item_id.begins_with("gold"):
		icon_tex = get_custom_texture("res://assets/textures/icon_gold_coin.png")
	elif item_id.begins_with("buy_gems") or item_id.contains("diamond") or item_id == "perm_2x_income":
		icon_tex = get_custom_texture("res://assets/textures/icon_diamond.png")
	elif item_id.begins_with("boost"):
		icon_tex = get_custom_texture("res://assets/textures/icon_energy.png")

	if icon_tex != null:
		var tr = TextureRect.new()
		tr.texture = icon_tex
		tr.custom_minimum_size = Vector2(44, 44)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hbox.add_child(tr)

	var vb = VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_theme_constant_override("separation", 2)
	hbox.add_child(vb)

	var name_lbl = Label.new()
	name_lbl.text = title_txt
	name_lbl.add_theme_font_size_override("font_size", 15)
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	vb.add_child(name_lbl)

	var val_lbl = Label.new()
	val_lbl.text = value_txt
	val_lbl.add_theme_font_size_override("font_size", 13)
	val_lbl.add_theme_color_override("font_color", Color(0.4, 0.95, 0.6, 1))
	vb.add_child(val_lbl)

	var desc_lbl = Label.new()
	desc_lbl.text = desc_txt
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.7, 0.78, 0.88, 0.85))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(desc_lbl)

	var btn = Button.new()
	btn.text = btn_txt
	btn.disabled = is_disabled
	btn.custom_minimum_size = Vector2(130, 42)
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = btn_color
	btn_style.border_width_bottom = 3
	btn_style.border_color = btn_color.darkened(0.3)
	btn_style.set_corner_radius_all(10)
	btn_style.set_content_margin_all(8)
	btn.add_theme_stylebox_override("normal", btn_style)
	btn.pressed.connect(func():
		_play_click_sfx()
		if item_id == "view_cards" or item_id == "view_cards_roster":
			_open_modal(cards_panel)
			_refresh_cards_panel()
			return
		if gm.buy_shop_item(item_id):
			_refresh_shop_panel()
	)
	hbox.add_child(btn)
	return p

# ─── 3D-to-HUD Flying Currency Trails ───────────────────────────────────────
func spawn_flying_currency_trail(world_pos: Vector3, amount: float = 0.0, currency_type_or_count: Variant = "cash") -> void:
	var cam: Camera3D = get_viewport().get_camera_3d()
	if cam == null:
		return
	if cam.is_position_behind(world_pos):
		return
	
	var start_screen_pos: Vector2 = cam.unproject_position(world_pos)
	
	if currency_trails_layer == null:
		currency_trails_layer = get_node_or_null("HUD/CurrencyTrailsLayer")
		if currency_trails_layer == null:
			var hud_node = get_node_or_null("HUD")
			if hud_node != null:
				currency_trails_layer = Control.new()
				currency_trails_layer.name = "CurrencyTrailsLayer"
				currency_trails_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
				currency_trails_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
				hud_node.add_child(currency_trails_layer)
	
	if currency_trails_layer == null:
		return

	var currency_type: String = "cash"
	var coin_count: int = 5
	if currency_type_or_count is String:
		currency_type = currency_type_or_count
		if amount > 0.0:
			coin_count = clampi(int(amount / 20.0), 3, 7)
		else:
			coin_count = 5
	elif currency_type_or_count is int:
		coin_count = clampi(int(currency_type_or_count), 3, 7)

	var target_screen_pos: Vector2 = Vector2(160.0, 42.0)
	var target_panel: Control = null
	var sound_name: String = "coin"
	var trail_tex: Texture2D = null
	var fallback_emoji: String = "💵"

	match currency_type:
		"diamond", "diamonds", "gem", "gems":
			sound_name = "diamond"
			fallback_emoji = "💎"
			if gem_panel != null and gem_panel.is_inside_tree():
				target_panel = gem_panel
				target_screen_pos = gem_panel.global_position + gem_panel.size * 0.5
			if diamond_texture == null:
				diamond_texture = get_custom_texture("res://assets/textures/icon_diamond.png")
				if diamond_texture == null and ResourceLoader.exists("res://assets/textures/bubble_diamond.png"):
					diamond_texture = load("res://assets/textures/bubble_diamond.png")
			trail_tex = diamond_texture
			coin_count = clampi(int(amount), 3, 7) if amount > 0.0 else 5
		"gold", "gold_coin", "golden_coins":
			sound_name = "gold_coin"
			fallback_emoji = "🪙"
			if gold_panel != null and gold_panel.is_inside_tree():
				target_panel = gold_panel
				target_screen_pos = gold_panel.global_position + gold_panel.size * 0.5
			if gold_texture == null:
				gold_texture = get_custom_texture("res://assets/textures/icon_gold_coin.png")
				if gold_texture == null and ResourceLoader.exists("res://assets/textures/bubble_gold_coin.png"):
					gold_texture = load("res://assets/textures/bubble_gold_coin.png")
			trail_tex = gold_texture
			coin_count = clampi(int(amount / 10.0), 3, 7) if amount > 0.0 else 5
		"energy":
			sound_name = "energy"
			fallback_emoji = "⚡"
			if energy_panel != null and energy_panel.is_inside_tree():
				target_panel = energy_panel
				target_screen_pos = energy_panel.global_position + energy_panel.size * 0.5
			if energy_texture == null:
				energy_texture = get_custom_texture("res://assets/textures/icon_energy.png")
			trail_tex = energy_texture
			coin_count = clampi(int(amount / 5.0), 3, 6) if amount > 0.0 else 4
		_: # "cash"
			sound_name = "coin"
			fallback_emoji = "💵"
			var cash_panel = get_node_or_null("HUD/TopBar/CashPanel")
			if cash_panel != null and cash_panel.is_inside_tree():
				target_panel = cash_panel
				target_screen_pos = cash_panel.global_position + cash_panel.size * 0.5
			elif cash_label != null and cash_label.is_inside_tree():
				target_screen_pos = cash_label.global_position + cash_label.size * 0.5
			if cash_texture == null:
				cash_texture = get_custom_texture("res://assets/textures/bubble_cash_stack.png")
				if cash_texture == null and ResourceLoader.exists("res://assets/textures/bubble_cash_stack.png"):
					cash_texture = load("res://assets/textures/bubble_cash_stack.png")
			trail_tex = cash_texture
			if amount > 0.0:
				coin_count = clampi(int(amount / 20.0), 3, 7)

	for i in range(coin_count):
		var p0: Vector2 = start_screen_pos + Vector2(randf_range(-18.0, 18.0), randf_range(-18.0, 18.0))
		var mid: Vector2 = (p0 + target_screen_pos) * 0.5
		var arc_dir: Vector2 = Vector2(-(target_screen_pos.y - p0.y), target_screen_pos.x - p0.x).normalized()
		if arc_dir.y > 0:
			arc_dir = -arc_dir
		var p1: Vector2 = mid + arc_dir * randf_range(60.0, 130.0) + Vector2(0.0, -randf_range(30.0, 70.0))
		
		var sprite = TextureRect.new()
		sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if trail_tex != null:
			sprite.texture = trail_tex
			sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			sprite.custom_minimum_size = Vector2(26, 26)
			sprite.size = Vector2(26, 26)
			sprite.pivot_offset = Vector2(13, 13)
		else:
			var lbl = Label.new()
			lbl.text = fallback_emoji
			lbl.add_theme_font_size_override("font_size", 20)
			sprite.add_child(lbl)
			sprite.custom_minimum_size = Vector2(26, 26)
			sprite.size = Vector2(26, 26)
			sprite.pivot_offset = Vector2(13, 13)
			
		sprite.global_position = p0 - sprite.pivot_offset
		sprite.scale = Vector2.ZERO
		sprite.modulate.a = 0.0
		currency_trails_layer.add_child(sprite)
		
		var delay: float = float(i) * 0.04
		var tw = create_tween()
		if delay > 0.0:
			tw.tween_interval(delay)
		tw.chain().tween_property(sprite, "modulate:a", 1.0, 0.06)
		tw.parallel().tween_property(sprite, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
		# 0.45 second smooth arc flight to counter
		tw.parallel().tween_method(func(t: float):
			if not is_instance_valid(sprite):
				return
			var u: float = 1.0 - t
			var pt: Vector2 = u * u * p0 + 2.0 * u * t * p1 + t * t * target_screen_pos
			sprite.global_position = pt - sprite.pivot_offset
		, 0.0, 1.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		
		tw.chain().tween_callback(func():
			if is_instance_valid(sprite):
				sprite.queue_free()
			var am = _get_audio_manager()
			if am != null and am.has_method("play_sfx"):
				am.play_sfx(sound_name, 0.06, 0.5)
			if target_panel != null:
				_punch_ui_element(target_panel)
			else:
				_punch_treasury_counter()
		)

func _punch_ui_element(node: Control) -> void:
	if node != null and node.is_inside_tree():
		node.pivot_offset = node.size * 0.5
		var tw = create_tween()
		tw.tween_property(node, "scale", Vector2(1.14, 1.14), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(node, "scale", Vector2.ONE, 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _punch_treasury_counter() -> void:
	var cash_panel = get_node_or_null("HUD/TopBar/CashPanel")
	if cash_panel != null:
		_punch_ui_element(cash_panel)

# ─── Dramatic Instant Time Skip Cash Shower ─────────────────────────────────
func trigger_time_skip_shower(hours: int, amount: float) -> void:
	var hud_node = get_node_or_null("HUD")
	if hud_node == null:
		return
		
	# 1. Spawn falling cash shower (35 fluttering bills & coins)
	var vp_size = get_viewport().get_visible_rect().size
	var bill_tex = load("res://assets/textures/bubble_cash_stack.png") if ResourceLoader.exists("res://assets/textures/bubble_cash_stack.png") else null
	var coin_tex = load("res://assets/textures/bubble_gold_coin.png") if ResourceLoader.exists("res://assets/textures/bubble_gold_coin.png") else null

	for i in range(35):
		var bill = TextureRect.new()
		bill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var is_coin = (i % 3 == 0)
		var chosen_tex = coin_tex if (is_coin and coin_tex != null) else bill_tex
		if chosen_tex != null:
			bill.texture = chosen_tex
			bill.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			var sz = randf_range(28.0, 44.0)
			bill.custom_minimum_size = Vector2(sz, sz)
			bill.size = Vector2(sz, sz)
			bill.pivot_offset = Vector2(sz * 0.5, sz * 0.5)
		else:
			var lbl = Label.new()
			lbl.text = "🪙" if is_coin else "💵"
			lbl.add_theme_font_size_override("font_size", 28)
			bill.add_child(lbl)
			bill.custom_minimum_size = Vector2(32, 32)
			bill.size = Vector2(32, 32)
			bill.pivot_offset = Vector2(16, 16)

		var start_x = randf_range(20.0, vp_size.x - 20.0)
		var start_y = randf_range(-80.0, -20.0)
		var end_x = start_x + randf_range(-100.0, 100.0)
		var end_y = vp_size.y + randf_range(40.0, 100.0)
		var duration = randf_range(0.9, 1.6)
		var delay = randf_range(0.0, 0.45)

		bill.position = Vector2(start_x, start_y)
		bill.rotation = randf_range(-0.5, 0.5)
		bill.modulate.a = 0.0
		hud_node.add_child(bill)

		var tw = create_tween()
		if delay > 0.0:
			tw.tween_interval(delay)
		tw.parallel().tween_property(bill, "modulate:a", 1.0, 0.1)
		tw.parallel().tween_property(bill, "position:y", end_y, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.parallel().tween_property(bill, "position:x", end_x, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.parallel().tween_property(bill, "rotation", bill.rotation + randf_range(-2.0, 2.0), duration)
		tw.chain().tween_callback(func():
			if is_instance_valid(bill):
				bill.queue_free()
		)

	# 2. Grand celebratory announcement toast
	var toast = PanelContainer.new()
	toast.name = "TimeSkipToast"
	toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast.custom_minimum_size = Vector2(400, 100)
	toast.anchors_preset = Control.PRESET_CENTER
	toast.anchor_left = 0.5
	toast.anchor_top = 0.42
	toast.anchor_right = 0.5
	toast.anchor_bottom = 0.42
	toast.offset_left = -200.0
	toast.offset_right = 200.0
	toast.offset_top = -50.0
	toast.offset_bottom = 50.0
	toast.grow_horizontal = Control.GROW_DIRECTION_BOTH
	toast.grow_vertical = Control.GROW_DIRECTION_BOTH
	toast.pivot_offset = Vector2(200, 50)

	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.12, 0.22, 0.96)
	sb.border_width_left = 3
	sb.border_width_top = 3
	sb.border_width_right = 3
	sb.border_width_bottom = 4
	sb.border_color = Color(1.0, 0.85, 0.25, 1.0)
	sb.set_corner_radius_all(18)
	sb.content_margin_left = 20.0
	sb.content_margin_top = 14.0
	sb.content_margin_right = 20.0
	sb.content_margin_bottom = 14.0
	sb.shadow_color = Color(0.0, 0.0, 0.0, 0.6)
	sb.shadow_size = 16
	toast.add_theme_stylebox_override("panel", sb)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 4)
	toast.add_child(vb)

	var header_lbl = Label.new()
	header_lbl.text = "⏱️ %d-HOUR TIME WARP COMPLETED!" % hours
	header_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_lbl.add_theme_font_size_override("font_size", 16)
	header_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35, 1.0))
	vb.add_child(header_lbl)

	var reward_lbl = Label.new()
	reward_lbl.text = "+%s CASH CREDITED!" % _format_money(amount)
	reward_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_lbl.add_theme_font_size_override("font_size", 20)
	reward_lbl.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55, 1.0))
	vb.add_child(reward_lbl)

	toast.scale = Vector2.ZERO
	hud_node.add_child(toast)

	var toast_tw = create_tween()
	toast_tw.tween_property(toast, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	toast_tw.tween_interval(1.8)
	toast_tw.tween_property(toast, "scale", Vector2(0.8, 0.8), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	toast_tw.parallel().tween_property(toast, "modulate:a", 0.0, 0.25)
	toast_tw.chain().tween_callback(func():
		if is_instance_valid(toast):
			toast.queue_free()
	)

	var am = _get_audio_manager()
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("claim", 0.0, 2.0)
		am.play_sfx("coin", 0.05, 1.5)

# ─── Hold-to-Upgrade Implementation ─────────────────────────────────────────
func _start_hold_upgrade(station_or_staff_id: String, is_staff: bool = false) -> void:
	if station_or_staff_id == "":
		return
	_is_holding_upgrade = true
	_hold_station_id = station_or_staff_id
	_hold_is_staff = is_staff
	_hold_timer = 0.0
	_hold_consecutive = 0
	_hold_delay_passed = false
	_perform_hold_step()

func _stop_hold_upgrade() -> void:
	_is_holding_upgrade = false
	_hold_station_id = ""
	_hold_is_staff = false
	_hold_timer = 0.0
	_hold_consecutive = 0
	_hold_delay_passed = false
	if _just_upgraded_on_hold:
		var tree = get_tree()
		if tree != null:
			tree.process_frame.connect(func(): _just_upgraded_on_hold = false, CONNECT_ONE_SHOT)
		else:
			_just_upgraded_on_hold = false

func _perform_hold_step() -> void:
	var gm = _get_game_manager()
	if gm == null or _hold_station_id == "":
		_stop_hold_upgrade()
		return
		
	if _hold_is_staff:
		var cost = gm.get_staff_upgrade_cost(_hold_station_id)
		if gm.cash < cost:
			_stop_hold_upgrade()
			return
		_just_upgraded_on_hold = true
		var success = gm.upgrade_staff(_hold_station_id)
		if success:
			_hold_consecutive += 1
			var am = _get_audio_manager()
			if am != null and am.has_method("play_upgrade_sfx"):
				am.play_upgrade_sfx(_hold_consecutive)
		else:
			_stop_hold_upgrade()
		return
		
	var lvl = gm.get_station_level(_hold_station_id)
	var max_lvl = gm.get_station_max_level(_hold_station_id)
	if lvl >= max_lvl:
		_stop_hold_upgrade()
		return
		
	var info = gm.get_upgrade_multi_info(_hold_station_id, current_multiplier)
	if not info.can_afford or info.levels <= 0:
		_stop_hold_upgrade()
		return
		
	_just_upgraded_on_hold = true
	var success = gm.upgrade_station_multi(_hold_station_id, current_multiplier, _hold_consecutive)
	if success:
		_hold_consecutive += 1
		_punch_upgrade_btn()
	else:
		_stop_hold_upgrade()

func _punch_upgrade_btn() -> void:
	if upgrade_btn != null and upgrade_btn.is_inside_tree():
		upgrade_btn.pivot_offset = upgrade_btn.size * 0.5
		var tw = create_tween()
		tw.tween_property(upgrade_btn, "scale", Vector2(1.07, 1.07), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(upgrade_btn, "scale", Vector2.ONE, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _connect_hold_upgrade_button(btn: Button, get_id_callable: Callable, is_staff: bool = false) -> void:
	if btn == null:
		return
	btn.button_down.connect(func():
		var id = get_id_callable.call()
		_start_hold_upgrade(id, is_staff)
	)
	btn.button_up.connect(func():
		_stop_hold_upgrade()
	)
	btn.mouse_exited.connect(func():
		if _is_holding_upgrade:
			_stop_hold_upgrade()
	)

# ─── Milestone Progress Bar Ticks & Stars ───────────────────────────────────
func _update_station_milestones(_sid: String, cur_lvl: int, max_lvl: int) -> void:
	if station_progress_bar != null:
		station_progress_bar.max_value = max_lvl
		station_progress_bar.value = cur_lvl
		
	if ticks_overlay != null:
		for c in ticks_overlay.get_children():
			c.queue_free()
	if milestone_labels_hbox != null:
		for c in milestone_labels_hbox.get_children():
			c.queue_free()
			
	var milestones: Array[int] = [10, 25, 50]
	var multipliers: Dictionary = {10: "2x", 25: "3x", 50: "5x"}
	
	for m in milestones:
		if m > max_lvl:
			continue
		var frac: float = float(m) / float(max_lvl)
		var is_reached: bool = cur_lvl >= m
		
		if ticks_overlay != null:
			# Vertical tick divider through the progress bar
			var tick = ColorRect.new()
			tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tick.anchor_left = frac
			tick.anchor_right = frac
			tick.anchor_top = 0.0
			tick.anchor_bottom = 1.0
			tick.offset_left = -1.0
			tick.offset_right = 1.0
			tick.color = Color(1.0, 0.88, 0.25, 0.95) if is_reached else Color(0.18, 0.22, 0.30, 0.85)
			ticks_overlay.add_child(tick)
			
			# Tick notch marker
			var notch = ColorRect.new()
			notch.mouse_filter = Control.MOUSE_FILTER_IGNORE
			notch.anchor_left = frac
			notch.anchor_right = frac
			notch.anchor_top = 0.5
			notch.anchor_bottom = 0.5
			notch.offset_left = -2.0
			notch.offset_right = 2.0
			notch.offset_top = -4.0
			notch.offset_bottom = 4.0
			notch.color = Color(1.0, 1.0, 1.0, 0.95) if is_reached else Color(0.45, 0.5, 0.6, 0.8)
			ticks_overlay.add_child(notch)
			
		if milestone_labels_hbox != null:
			var mult_str = multipliers.get(m, "2x")
			var pill = PanelContainer.new()
			pill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var sb = StyleBoxFlat.new()
			sb.set_corner_radius_all(6)
			sb.content_margin_left = 4.0
			sb.content_margin_right = 4.0
			sb.content_margin_top = 2.0
			sb.content_margin_bottom = 2.0
			
			var lbl = Label.new()
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.add_theme_font_size_override("font_size", 10)
			
			if is_reached:
				sb.bg_color = Color(0.96, 0.65, 0.12, 1.0)
				sb.border_width_bottom = 1
				sb.border_color = Color(0.7, 0.45, 0.05, 1.0)
				lbl.text = "★ Lv.%d (%s BONUS)" % [m, mult_str]
				lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
			else:
				sb.bg_color = Color(0.12, 0.15, 0.22, 0.75)
				lbl.text = "☆ Lv.%d (%s)" % [m, mult_str]
				lbl.add_theme_color_override("font_color", Color(0.65, 0.7, 0.8, 0.7))
				
			pill.add_theme_stylebox_override("panel", sb)
			pill.add_child(lbl)
			milestone_labels_hbox.add_child(pill)

# ─── Collectible Cards & Gacha Chest Popups ─────────────────────────────────
func _on_chest_opened(chest_type: String, rewards: Dictionary) -> void:
	show_chest_reward_popup(chest_type, rewards)
	_update_affordability_badges()
	if shop_panel != null and shop_panel.visible:
		_refresh_shop_panel()

func _on_cards_updated() -> void:
	if cards_panel != null and cards_panel.visible:
		_refresh_cards_panel()
	_update_affordability_badges()

func show_chest_reward_popup(chest_type: String, rewards: Dictionary) -> void:
	if chest_reward_modal == null:
		return
		
	var ctype = chest_type.to_lower()
	var chest_name = "WOODEN CHEST"
	var chest_icon = "🪵"
	var header_col = Color(0.9, 0.75, 0.4, 1.0)
	if ctype.contains("silver"):
		chest_name = "SILVER MAÎTRE D' CHEST"
		chest_icon = "🥈"
		header_col = Color(0.4, 0.85, 1.0, 1.0)
	elif ctype.contains("golden") or ctype.contains("epic"):
		chest_name = "GOLDEN EPIC CHEST"
		chest_icon = "🏆"
		header_col = Color(1.0, 0.85, 0.2, 1.0)
		
	if chest_reward_header != null:
		chest_reward_header.text = "%s %s UNLOCKED!" % [chest_icon, chest_name]
		chest_reward_header.add_theme_color_override("font_color", header_col)
		
	# Populate Currencies Box
	if chest_reward_currencies_box != null:
		for c in chest_reward_currencies_box.get_children():
			c.queue_free()
			
		var cash_gain = float(rewards.get("cash", 0.0))
		if cash_gain > 0.0:
			var cpill = _create_reward_currency_chip("💵 +%s" % _format_money(cash_gain), Color(0.1, 0.22, 0.12, 0.95), Color(0.35, 1.0, 0.55, 1.0))
			chest_reward_currencies_box.add_child(cpill)
			
		var gold_gain = int(rewards.get("golden_coins", 0))
		if gold_gain > 0:
			var gold_tex = get_custom_texture("res://assets/textures/icon_gold_coin.png")
			var gpill = _create_reward_currency_chip("+%d Gold" % gold_gain, Color(0.24, 0.18, 0.05, 0.95), Color(1.0, 0.85, 0.25, 1.0), gold_tex)
			chest_reward_currencies_box.add_child(gpill)
			
		var gems_gain = int(rewards.get("diamonds", 0))
		if gems_gain > 0:
			var dia_tex = get_custom_texture("res://assets/textures/icon_diamond.png")
			var dpill = _create_reward_currency_chip("+%d Gems" % gems_gain, Color(0.18, 0.1, 0.25, 0.95), Color(0.85, 0.45, 1.0, 1.0), dia_tex)
			chest_reward_currencies_box.add_child(dpill)

	# Populate Cards Container
	if chest_reward_cards_box != null:
		for c in chest_reward_cards_box.get_children():
			c.queue_free()
			
		var reward_cards = rewards.get("cards", [])
		for rcard in reward_cards:
			var tile = _create_reward_card_chip(rcard)
			chest_reward_cards_box.add_child(tile)
			
	_open_modal(chest_reward_modal)
	
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("coin", 0.05, 1.2)

func _create_reward_currency_chip(text: String, bg_col: Color, text_col: Color, icon_tex: Texture2D = null) -> PanelContainer:
	var pc = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = bg_col
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 2
	sb.border_color = text_col.darkened(0.2)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 12.0
	sb.content_margin_right = 12.0
	sb.content_margin_top = 6.0
	sb.content_margin_bottom = 6.0
	pc.add_theme_stylebox_override("panel", sb)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	pc.add_child(hbox)

	if icon_tex != null:
		var tr = TextureRect.new()
		tr.texture = icon_tex
		tr.custom_minimum_size = Vector2(18, 18)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hbox.add_child(tr)

	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", text_col)
	hbox.add_child(lbl)
	return pc

func _create_reward_card_chip(rcard: Dictionary) -> PanelContainer:
	var pc = PanelContainer.new()
	var rarity = str(rcard.get("rarity", "common")).to_lower()
	var rcol = _get_card_rarity_color(rarity)
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.09, 0.12, 0.18, 0.95)
	sb.border_width_left = 2
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 2
	sb.border_color = rcol
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 12.0
	sb.content_margin_right = 12.0
	sb.content_margin_top = 6.0
	sb.content_margin_bottom = 6.0
	pc.add_theme_stylebox_override("panel", sb)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	pc.add_child(hbox)
	
	var icon_lbl = Label.new()
	icon_lbl.text = rcard.get("icon", "🃏")
	icon_lbl.add_theme_font_size_override("font_size", 22)
	hbox.add_child(icon_lbl)
	
	var vb = VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vb)
	
	var title_lbl = Label.new()
	title_lbl.text = "%s  (%s)" % [rcard.get("name", "Card"), rarity.to_upper()]
	title_lbl.add_theme_font_size_override("font_size", 13)
	title_lbl.add_theme_color_override("font_color", rcol)
	vb.add_child(title_lbl)
	
	var desc_lbl = Label.new()
	desc_lbl.text = rcard.get("bonus_desc", "")
	desc_lbl.add_theme_font_size_override("font_size", 10)
	desc_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9, 0.8))
	vb.add_child(desc_lbl)
	
	var count_badge = Label.new()
	count_badge.text = "+%d Cards! ✨" % int(rcard.get("count", 1))
	count_badge.add_theme_font_size_override("font_size", 13)
	count_badge.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55, 1.0))
	hbox.add_child(count_badge)
	
	return pc

func _get_card_rarity_color(rarity: String) -> Color:
	match rarity.to_lower():
		"rare":
			return Color(0.2, 0.65, 1.0, 1.0)
		"epic":
			return Color(0.8, 0.35, 1.0, 1.0)
		"legendary":
			return Color(1.0, 0.82, 0.2, 1.0)
		_:
			return Color(0.7, 0.78, 0.88, 1.0)

# ─── Collectible Cards Grid Roster ──────────────────────────────────────────
func _refresh_cards_panel() -> void:
	if cards_grid == null:
		return
	for c in cards_grid.get_children():
		c.queue_free()
		
	var gm = _get_game_manager()
	if gm == null or not gm.has_method("get_all_cards"):
		return
		
	var cards = gm.get_all_cards()
	for cid in cards.keys():
		var card = cards[cid]
		var tile = _create_card_roster_tile(card, gm)
		cards_grid.add_child(tile)

func _create_card_roster_tile(card: Dictionary, gm: Node) -> PanelContainer:
	var cid = card.get("id", "")
	var lvl = int(card.get("level", 0))
	var count = int(card.get("cards", 0))
	var rarity = str(card.get("rarity", "common")).to_lower()
	var rcol = _get_card_rarity_color(rarity)
	var is_locked = (lvl == 0)
	var is_max = (lvl >= 10)
	
	var pc = PanelContainer.new()
	pc.custom_minimum_size = Vector2(290, 140)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.11, 0.17, 0.95) if not is_locked else Color(0.06, 0.08, 0.12, 0.85)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 3
	sb.border_color = rcol if not is_locked else Color(0.3, 0.35, 0.45, 0.6)
	sb.set_corner_radius_all(14)
	sb.content_margin_left = 12.0
	sb.content_margin_right = 12.0
	sb.content_margin_top = 10.0
	sb.content_margin_bottom = 10.0
	pc.add_theme_stylebox_override("panel", sb)
	
	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	pc.add_child(vb)
	
	# Header Row: Icon + Name + Level Badge
	var top_hbox = HBoxContainer.new()
	top_hbox.add_theme_constant_override("separation", 8)
	vb.add_child(top_hbox)
	
	var icon_lbl = Label.new()
	icon_lbl.text = card.get("icon", "🃏")
	icon_lbl.add_theme_font_size_override("font_size", 22)
	top_hbox.add_child(icon_lbl)
	
	var name_vb = VBoxContainer.new()
	name_vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_vb.add_theme_constant_override("separation", 1)
	top_hbox.add_child(name_vb)
	
	var name_lbl = Label.new()
	name_lbl.text = card.get("name", "Manager")
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	name_vb.add_child(name_lbl)
	
	var sub_lbl = Label.new()
	sub_lbl.text = "%s • %s" % [card.get("sector", "Restaurant"), rarity.to_upper()]
	sub_lbl.add_theme_font_size_override("font_size", 10)
	sub_lbl.add_theme_color_override("font_color", rcol)
	name_vb.add_child(sub_lbl)
	
	var lvl_badge = Label.new()
	if is_locked:
		lvl_badge.text = "🔒 LOCKED"
		lvl_badge.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75, 0.7))
	elif is_max:
		lvl_badge.text = "★ MAX"
		lvl_badge.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	else:
		lvl_badge.text = "Lv. %d" % lvl
		lvl_badge.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55, 1.0))
	lvl_badge.add_theme_font_size_override("font_size", 12)
	top_hbox.add_child(lvl_badge)
	
	# Bonus Description
	var desc_lbl = Label.new()
	desc_lbl.text = card.get("bonus_desc", "")
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95, 0.9))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(desc_lbl)
	
	# Duplicate Progress Bar
	var needed = gm.get_card_cards_needed(cid) if gm.has_method("get_card_cards_needed") else 2
	var prog_box = VBoxContainer.new()
	prog_box.add_theme_constant_override("separation", 2)
	vb.add_child(prog_box)
	
	var pbar = ProgressBar.new()
	pbar.custom_minimum_size = Vector2(0, 8)
	pbar.show_percentage = false
	if is_locked:
		pbar.max_value = 1
		pbar.value = 0
	elif is_max:
		pbar.max_value = 1
		pbar.value = 1
	else:
		pbar.max_value = max(1, needed)
		pbar.value = min(count, needed)
	prog_box.add_child(pbar)
	
	var prog_lbl = Label.new()
	prog_lbl.add_theme_font_size_override("font_size", 10)
	if is_locked:
		prog_lbl.text = "Cards: 0/1 (Unlock in Chests)"
		prog_lbl.add_theme_color_override("font_color", Color(0.65, 0.7, 0.8, 0.7))
	elif is_max:
		prog_lbl.text = "Cards: Maximum Level Reached ⭐"
		prog_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	else:
		prog_lbl.text = "Cards: %d / %d duplicates" % [count, needed]
		prog_lbl.add_theme_color_override("font_color", Color(0.3, 0.9, 0.5, 1.0) if count >= needed else Color(0.75, 0.8, 0.9, 0.8))
	prog_box.add_child(prog_lbl)
	
	# Action Upgrade Button
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(0, 32)
	var gold_cost = gm.get_card_gold_cost(cid) if gm.has_method("get_card_gold_cost") else 50
	var can_up = gm.can_upgrade_card(cid) if gm.has_method("can_upgrade_card") else false
	
	var b_style = StyleBoxFlat.new()
	b_style.set_corner_radius_all(8)
	b_style.content_margin_left = 6.0
	b_style.content_margin_right = 6.0
	b_style.content_margin_top = 4.0
	b_style.content_margin_bottom = 4.0
	
	if is_locked:
		btn.text = "🔒 Unlock in Chests"
		btn.disabled = true
		b_style.bg_color = Color(0.12, 0.15, 0.2, 0.6)
	elif is_max:
		btn.text = "⭐ Maximum Tier"
		btn.disabled = true
		b_style.bg_color = Color(0.18, 0.15, 0.08, 0.8)
	elif can_up:
		btn.text = "UPGRADE (🪙 %d)" % gold_cost
		btn.disabled = false
		b_style.bg_color = Color(0.18, 0.68, 0.32, 1.0)
		b_style.border_width_bottom = 2
		b_style.border_color = Color(0.1, 0.45, 0.18, 1.0)
	elif count < needed:
		btn.text = "🪙 %d (%d/%d Cards)" % [gold_cost, count, needed]
		btn.disabled = true
		b_style.bg_color = Color(0.15, 0.18, 0.25, 0.7)
	else:
		btn.text = "🪙 %d (Need Coins)" % gold_cost
		btn.disabled = true
		b_style.bg_color = Color(0.25, 0.2, 0.1, 0.7)
		
	btn.add_theme_stylebox_override("normal", b_style)
	btn.add_theme_font_size_override("font_size", 12)
	btn.pressed.connect(func():
		_play_click_sfx()
		if gm.upgrade_card(cid):
			_refresh_cards_panel()
	)
	vb.add_child(btn)
	
	return pc

# ─── Station Level Milestone Rewards ─────────────────────────────────────────
func _on_station_milestone_reached(station_id: String, milestone_lvl: int, bonus_diamonds: int, bonus_golden_coins: int) -> void:
	var sname = station_id.replace("_", " ").capitalize()
	_spawn_reward_floater("🎉 %s LEVEL %d MILESTONE! +%d 💎 +%d 🪙" % [sname, milestone_lvl, bonus_diamonds, bonus_golden_coins])
	if bonus_diamonds > 0:
		spawn_flying_currency_trail(Vector3.ZERO, bonus_diamonds, "diamonds")
	if bonus_golden_coins > 0:
		spawn_flying_currency_trail(Vector3.ZERO, bonus_golden_coins, "golden_coins")
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("upgrade", 0.0, 1.8)
	_refresh_quest_banner()

# ─── Lucky Spin Wheel & 7-Day Login Methods ──────────────────────────────────
func _on_spin_tab_pressed() -> void:
	_play_click_sfx()
	if spin_view != null:
		spin_view.visible = true
	if daily_view != null:
		daily_view.visible = false
	_refresh_spin_wheel()

func _on_daily_tab_pressed() -> void:
	_play_click_sfx()
	if spin_view != null:
		spin_view.visible = false
	if daily_view != null:
		daily_view.visible = true
	_refresh_daily_login()

func _setup_wheel_labels() -> void:
	if wheel_graphic == null or wheel_labels_initialized:
		return
	wheel_labels_initialized = true
	
	var gm = get_node_or_null("/root/GameManager")
	var slices = gm.WHEEL_SLICES if gm != null and "WHEEL_SLICES" in gm else []
	var center = Vector2(130, 130)
	var radius = 75.0
	
	for i in range(slices.size()):
		var slice = slices[i]
		var angle = -PI/2.0 + float(i) * (TAU / 8.0)
		var lbl = Label.new()
		lbl.name = "SliceLabel_%d" % i
		lbl.text = slice.get("label", "")
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
		lbl.add_theme_constant_override("shadow_offset_x", 1)
		lbl.add_theme_constant_override("shadow_offset_y", 1)
		lbl.custom_minimum_size = Vector2(70, 24)
		lbl.size = Vector2(70, 24)
		lbl.pivot_offset = Vector2(35, 12)
		lbl.position = center + Vector2(cos(angle), sin(angle)) * radius - Vector2(35, 12)
		lbl.rotation = angle + PI/2.0
		wheel_graphic.add_child(lbl)

func _on_wheel_graphic_draw() -> void:
	if wheel_graphic == null:
		return
	var gm = get_node_or_null("/root/GameManager")
	var slices = gm.WHEEL_SLICES if gm != null and "WHEEL_SLICES" in gm else []
	if slices.size() == 0:
		return
		
	var center = Vector2(130, 130)
	var radius = 120.0
	var slice_count = slices.size()
	var angle_per_slice = TAU / float(slice_count)
	
	# Outer shadow & rim
	wheel_graphic.draw_circle(center, radius + 8.0, Color(0.04, 0.05, 0.08, 0.9))
	wheel_graphic.draw_circle(center, radius + 3.0, Color(0.95, 0.78, 0.22, 1.0))
	
	for i in range(slice_count):
		var slice = slices[i]
		var col = slice.get("color", Color(0.2, 0.5, 0.8))
		var start_angle = -PI/2.0 + float(i) * angle_per_slice - (angle_per_slice / 2.0)
		var end_angle = start_angle + angle_per_slice
		
		var pts = PackedVector2Array()
		pts.append(center)
		var segments = 16
		for s in range(segments + 1):
			var a = start_angle + (end_angle - start_angle) * (float(s) / float(segments))
			pts.append(center + Vector2(cos(a), sin(a)) * radius)
		wheel_graphic.draw_colored_polygon(pts, col)
		
		# Divider line
		var div_pt = center + Vector2(cos(start_angle), sin(start_angle)) * radius
		wheel_graphic.draw_line(center, div_pt, Color(1, 1, 1, 0.5), 2.0)
		
	# Outer rim dashed / studded accent
	wheel_graphic.draw_arc(center, radius, 0.0, TAU, 32, Color(0.2, 0.15, 0.05, 0.8), 2.0)
	
	# Center golden hub
	wheel_graphic.draw_circle(center, 30.0, Color(0.12, 0.1, 0.18, 1.0))
	wheel_graphic.draw_circle(center, 25.0, Color(0.95, 0.82, 0.2, 1.0))
	wheel_graphic.draw_circle(center, 18.0, Color(0.1, 0.08, 0.12, 1.0))

func _refresh_spin_wheel() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm == null:
		return
	_setup_wheel_labels()
	if wheel_graphic != null:
		wheel_graphic.queue_redraw()
		
	var is_free = gm.can_claim_free_spin() if gm.has_method("can_claim_free_spin") else false
	var can_spin = gm.can_spin_wheel() if gm.has_method("can_spin_wheel") else false
	
	if spin_action_btn != null:
		if is_spinning_wheel:
			spin_action_btn.disabled = true
			spin_action_btn.text = "SPINNING... 🎡"
		elif is_free:
			spin_action_btn.disabled = false
			spin_action_btn.text = "SPIN (FREE) 🎡"
		else:
			spin_action_btn.disabled = not can_spin
			spin_action_btn.text = "SPIN (10 ⚡) 🎡"
			
	if spin_status_label != null:
		if is_free:
			spin_status_label.text = "✨ 1 Free Daily Spin Available!"
			spin_status_label.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55))
		else:
			var cd = gm.get_free_spin_cooldown_remaining() if gm.has_method("get_free_spin_cooldown_remaining") else 0.0
			spin_status_label.text = "⚡ Energy: %d / 10  •  Free Spin in %s" % [gm.energy, _format_time_hms(cd)]
			spin_status_label.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95, 0.85))

func _on_spin_action_pressed() -> void:
	if is_spinning_wheel:
		return
	var gm = get_node_or_null("/root/GameManager")
	if gm == null or not gm.can_spin_wheel():
		_play_click_sfx()
		return
		
	var res = gm.spin_lucky_wheel()
	if res.is_empty():
		return
		
	is_spinning_wheel = true
	_play_click_sfx()
	if spin_action_btn != null:
		spin_action_btn.disabled = true
		spin_action_btn.text = "SPINNING... 🎡"
	if spin_result_label != null:
		spin_result_label.visible = false
		
	var winning_idx = int(res.get("slice_index", 0))
	var prize = res.get("prize", {})
	
	if wheel_graphic != null:
		var current_rot = wheel_graphic.rotation_degrees
		var base_align = 360.0 * 5.0 - float(winning_idx * 45)
		var target_rot = current_rot + base_align - fmod(current_rot, 360.0)
		
		var tw = create_tween().set_parallel(false)
		tw.tween_property(wheel_graphic, "rotation_degrees", target_rot, 2.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		
		# Play audio ticks
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			for k in range(8):
				tw.parallel().tween_callback(func(): am.play_sfx("click", 0.01, 1.0 + float(k) * 0.05)).set_delay(float(k) * 0.25)
				
		tw.tween_callback(func():
			is_spinning_wheel = false
			if spin_result_label != null:
				spin_result_label.visible = true
				spin_result_label.text = "🎉 YOU WON %s!" % prize.get("title", "AWESOME PRIZE").to_upper()
				
			if am != null and am.has_method("play_sfx"):
				am.play_sfx("cash_register", 0.05, 1.2)
				
			var ptype = prize.get("type", "")
			if ptype == "diamonds":
				spawn_flying_currency_trail(Vector3.ZERO, prize.get("amount", 5), "diamonds")
			elif ptype == "golden_coins":
				spawn_flying_currency_trail(Vector3.ZERO, prize.get("amount", 50), "golden_coins")
				
			_spawn_reward_floater("+" + prize.get("label", "Prize"))
			_refresh_spin_wheel()
			_update_affordability_badges()
		)
	else:
		is_spinning_wheel = false
		_refresh_spin_wheel()

func _refresh_daily_login() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm == null or daily_cards_container == null:
		return
		
	for c in daily_cards_container.get_children():
		c.queue_free()
		
	var streak = int(gm.login_streak_days) if "login_streak_days" in gm else 0
	var can_claim = gm.can_claim_daily_login() if gm.has_method("can_claim_daily_login") else false
	var rewards = gm.DAILY_LOGIN_REWARDS if "DAILY_LOGIN_REWARDS" in gm else []
	
	if streak_label != null:
		streak_label.text = "🔥 Streak: Day %d / 7 Days" % streak
		
	var current_day_ready = (streak % 7) + 1
	
	for r in rewards:
		var d = int(r.get("day", 1))
		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(120, 80)
		
		var sb = StyleBoxFlat.new()
		sb.set_corner_radius_all(10)
		sb.content_margin_left = 8.0
		sb.content_margin_right = 8.0
		sb.content_margin_top = 6.0
		sb.content_margin_bottom = 6.0
		
		var is_claimed = (d <= streak) and not (d == current_day_ready and can_claim)
		var is_today_ready = (d == current_day_ready) and can_claim
		
		if is_claimed:
			sb.bg_color = Color(0.1, 0.13, 0.18, 0.6)
			sb.border_width_bottom = 1
			sb.border_color = Color(0.2, 0.25, 0.35, 0.5)
		elif is_today_ready:
			sb.bg_color = Color(0.12, 0.42, 0.22, 0.95)
			sb.border_width_left = 2
			sb.border_width_top = 2
			sb.border_width_right = 2
			sb.border_width_bottom = 3
			sb.border_color = Color(0.35, 0.95, 0.55, 1.0)
			sb.shadow_color = Color(0.1, 0.85, 0.3, 0.3)
			sb.shadow_size = 6
		else:
			sb.bg_color = Color(0.14, 0.17, 0.24, 0.85)
			sb.border_width_bottom = 2
			sb.border_color = Color(0.25, 0.3, 0.4, 0.6)
			
		card.add_theme_stylebox_override("panel", sb)
		
		var vb = VBoxContainer.new()
		vb.theme_override_constants_set("separation", 2)
		
		var d_lbl = Label.new()
		d_lbl.text = "DAY %d" % d
		d_lbl.add_theme_font_size_override("font_size", 11)
		d_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3) if is_today_ready else Color(0.7, 0.8, 0.9, 0.8))
		d_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(d_lbl)
		
		var ic_lbl = Label.new()
		ic_lbl.text = r.get("icon", "🎁")
		ic_lbl.add_theme_font_size_override("font_size", 20)
		ic_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(ic_lbl)
		
		var rew_lbl = Label.new()
		rew_lbl.text = r.get("desc", "")
		rew_lbl.add_theme_font_size_override("font_size", 10)
		rew_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1) if not is_claimed else Color(0.5, 0.55, 0.6, 0.7))
		rew_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(rew_lbl)
		
		var st_lbl = Label.new()
		if is_claimed:
			st_lbl.text = "✅ Claimed"
			st_lbl.add_theme_color_override("font_color", Color(0.4, 0.75, 0.5, 0.8))
		elif is_today_ready:
			st_lbl.text = "READY! ✨"
			st_lbl.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55))
		else:
			st_lbl.text = "🔒 Locked"
			st_lbl.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75, 0.6))
		st_lbl.add_theme_font_size_override("font_size", 10)
		st_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(st_lbl)
		
		card.add_child(vb)
		daily_cards_container.add_child(card)
		
	if claim_daily_btn != null:
		if can_claim:
			claim_daily_btn.disabled = false
			claim_daily_btn.text = "CLAIM DAY %d REWARD 🎁" % current_day_ready
		else:
			claim_daily_btn.disabled = true
			var cd = gm.get_daily_login_cooldown_remaining() if gm.has_method("get_daily_login_cooldown_remaining") else 0.0
			claim_daily_btn.text = "NEXT REWARD IN %s ⏰" % _format_time_hms(cd)

func _on_claim_daily_pressed() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm == null or not gm.can_claim_daily_login():
		_play_click_sfx()
		return
		
	var rew = gm.claim_daily_login()
	if not rew.is_empty():
		_play_click_sfx()
		_spawn_reward_floater("🎁 Day %d: %s" % [gm.login_streak_days, rew.get("desc", "")])
		var rtype = rew.get("type", "")
		if rtype == "diamonds" or rtype == "grand_jackpot":
			spawn_flying_currency_trail(Vector3.ZERO, rew.get("amount", rew.get("diamonds", 10)), "diamonds")
		elif rtype == "golden_coins":
			spawn_flying_currency_trail(Vector3.ZERO, rew.get("amount", 50), "golden_coins")
		_refresh_daily_login()
		_update_affordability_badges()

func _format_time_hms(seconds: float) -> String:
	var total_sec = int(max(0.0, seconds))
	var hrs = total_sec / 3600
	var mins = (total_sec % 3600) / 60
	var secs = total_sec % 60
	if hrs > 0:
		return "%02dh %02dm" % [hrs, mins]
	return "%02dm %02ds" % [mins, secs]



