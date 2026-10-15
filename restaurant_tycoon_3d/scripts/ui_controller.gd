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
@onready var gem_label: Label = $HUD/TopBar/GemPanel/HBox/GemLabel
@onready var add_gem_btn: Button = $HUD/TopBar/GemPanel/HBox/AddGemBtn
@onready var boost_btn: Button = $HUD/TopBar/BoostBtn

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
@onready var map_btn: Button = get_node_or_null("HUD/TopBar/MapBtn")
@onready var side_map_btn: Button = get_node_or_null("HUD/RightDock/SideMapBtn")
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
@onready var ribbon_marketing: PanelContainer = get_node_or_null("HUD/StatusRibbons/RibbonMarketing")
@onready var ribbon_marketing_lbl: Label = get_node_or_null("HUD/StatusRibbons/RibbonMarketing/Label")
@onready var ribbon_parking: PanelContainer = get_node_or_null("HUD/StatusRibbons/RibbonParking")
@onready var ribbon_parking_lbl: Label = get_node_or_null("HUD/StatusRibbons/RibbonParking/Label")
@onready var ribbon_cleaning: PanelContainer = get_node_or_null("HUD/StatusRibbons/RibbonCleaning")
@onready var ribbon_cleaning_lbl: Label = get_node_or_null("HUD/StatusRibbons/RibbonCleaning/Label")
var boost_timer_bar: Panel = null
@onready var shop_btn: Button = get_node_or_null("HUD/ShopBtn")
@onready var shop_panel: PanelContainer = get_node_or_null("ShopPanel")
@onready var shop_vbox: VBoxContainer = get_node_or_null("ShopPanel/VBox/Scroll/ItemsVBox")
@onready var close_shop_btn: Button = get_node_or_null("ShopPanel/VBox/TopHBox/CloseShopBtn")

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

var current_station_id: String = ""
var current_multiplier: String = "1"
var displayed_cash: float = 650.0
var displayed_rate: float = 0.0
var cash_tween: Tween = null
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
var style_multi_active: StyleBoxFlat = null
var style_multi_inactive: StyleBoxFlat = null

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

func _ready() -> void:
	_hide_all_modals()
	
	boost_btn.pressed.connect(_on_boost_pressed)
	add_gem_btn.pressed.connect(_on_add_gem_pressed)
	
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
	
	# Quest Banner Click
	quest_banner.gui_input.connect(_on_quest_banner_input)
	quest_claim_btn.pressed.connect(_on_banner_claim_pressed)
	
	# Upgrade Modal & Multiplier Buttons
	style_multi_active = StyleBoxFlat.new()
	style_multi_active.bg_color = Color(0.96, 0.65, 0.12, 1.0)
	style_multi_active.border_width_bottom = 2
	style_multi_active.border_color = Color(0.7, 0.42, 0.05, 1.0)
	style_multi_active.set_corner_radius_all(8)
	style_multi_active.content_margin_left = 8.0
	style_multi_active.content_margin_top = 3.0
	style_multi_active.content_margin_right = 8.0
	style_multi_active.content_margin_bottom = 3.0

	style_multi_inactive = StyleBoxFlat.new()
	style_multi_inactive.bg_color = Color(0.12, 0.15, 0.22, 0.8)
	style_multi_inactive.set_corner_radius_all(8)
	style_multi_inactive.content_margin_left = 8.0
	style_multi_inactive.content_margin_top = 3.0
	style_multi_inactive.content_margin_right = 8.0
	style_multi_inactive.content_margin_bottom = 3.0

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

	# Connect GameManager signals
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.cash_changed.connect(_on_cash_changed)
		gm.gems_changed.connect(_on_gems_changed)
		gm.cash_rate_updated.connect(_on_cash_rate_updated)
		gm.level_updated.connect(_on_level_updated)
		gm.station_upgraded.connect(_on_station_upgraded)
		gm.boost_toggled.connect(_on_boost_toggled)
		gm.staff_updated.connect(_on_staff_updated)
		gm.table_unlocked.connect(_on_table_unlocked)
		gm.quests_updated.connect(_on_quests_updated)
		gm.campaign_updated.connect(_on_campaign_updated)
		gm.offline_earnings_available.connect(_on_offline_earnings_available)
		gm.critic_review_awarded.connect(_on_critic_review_awarded)
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
		gm.menu_updated.connect(func():
			if kitchen_panel != null and kitchen_panel.visible:
				_refresh_kitchen_panel()
			if perks_panel != null and perks_panel.visible:
				_refresh_perks_panel()
		)
		
		displayed_cash = gm.cash
		displayed_rate = gm.get_effective_cash_per_sec()
		_update_top_bar(gm.cash, gm.gems, gm.star_rating, gm.restaurant_name, gm.restaurant_level, gm.restaurant_xp, gm.xp_to_next_level)
		if cash_rate_label != null:
			cash_rate_label.text = "+%s/s" % _format_money(displayed_rate)
		_set_multiplier("1")
		_refresh_quest_banner()
	
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

func _open_modal(panel: PanelContainer) -> void:
	if panel == null: return
	_play_click_sfx()
	_hide_all_modals()
	_wire_all_buttons_in_tree(panel)
	_update_affordability_badges()
	panel.visible = true
	panel.scale = Vector2(0.88, 0.88)
	var tw = create_tween()
	tw.tween_property(panel, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _close_modal(panel: PanelContainer) -> void:
	if panel == null: return
	_play_click_sfx()
	_clear_3d_highlights()
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
	if gem_label != null: gem_label.text = "%d" % new_gems
	if shop_panel != null and shop_panel.visible:
		_refresh_shop_panel()

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
			if floating_boost_btn != null:
				floating_boost_btn.text = "🔥 2X BOOST (%ds)" % s
				floating_boost_btn.add_theme_color_override("font_color", Color(1.0, 0.88, 0.2, 1.0))
			if boost_timer_bar != null:
				boost_timer_bar.visible = true
				var progress = clamp(gm.boost_timer / 60.0, 0.0, 1.0)
				boost_timer_bar.anchor_right = progress
			if boost_btn != null:
				boost_btn.text = "⚡ 2X (%ds)" % s
		else:
			if floating_boost_btn != null:
				floating_boost_btn.text = "▶️  x2 BOOST!"
				floating_boost_btn.add_theme_color_override("font_color", Color(0.12, 0.65, 0.25, 1.0))
			if boost_timer_bar != null:
				boost_timer_bar.visible = false

	_update_status_ribbons()
	if analytics_panel != null and analytics_panel.visible:
		analytics_refresh_timer += delta
		if analytics_refresh_timer >= 0.5:
			analytics_refresh_timer = 0.0
			_refresh_analytics_panel()

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

# ─── Quests & Objectives Banner ─────────────────────────────────────────────
func _refresh_quest_banner() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm == null or gm.active_quests.size() == 0:
		return
	
	var active_q = null
	for q in gm.active_quests:
		if q.get("current", 0) >= q.get("target", 1):
			active_q = q
			break
	if active_q == null:
		active_q = gm.active_quests[0]
		
	quest_icon.text = active_q.get("icon", "🎯")
	quest_title.text = active_q.get("title", "Objective")
	var cur = active_q.get("current", 0)
	var tar = active_q.get("target", 1)
	quest_progress_label.text = "%d / %d" % [cur, tar]
	quest_bar.max_value = tar
	quest_bar.value = cur
	
	if cur >= tar:
		quest_claim_btn.visible = true
		quest_claim_btn.text = "CLAIM  +" + _format_money(active_q.get("reward_cash", 100))
	else:
		quest_claim_btn.visible = false

func _on_quest_banner_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_toggle_modal(quests_panel, _refresh_quests_panel)

func _on_banner_claim_pressed() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm == null:
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
		upgrade_btn.text = "MAX LEVEL"
		upgrade_btn.disabled = true
		if upgrade_max_badge != null:
			upgrade_max_badge.visible = true
			upgrade_max_badge.text = "⭐ MAX LEVEL"
			upgrade_max_badge.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	else:
		upgrade_btn.text = "UPGRADE +%d LVL\n(%s)" % [info.levels, _format_money(info.cost)]
		upgrade_btn.disabled = not info.can_afford
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
		var c_exp = fin.get("expenses", {}).get("cleaning_min", 300.0)
		ribbon_cleaning_lbl.text = "🧹 - %s Cleaning" % _format_money(c_exp)

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

# ─── Stylebox Generators ───────────────────────────────────────────────────
func _get_card_style() -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.11, 0.14, 0.20, 0.95)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 3
	sb.border_color = Color(0.24, 0.32, 0.44, 0.8)
	sb.set_corner_radius_all(14)
	sb.set_content_margin_all(12)
	return sb

func _get_green_btn_style() -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.18, 0.78, 0.42, 1.0)
	sb.border_width_bottom = 4
	sb.border_color = Color(0.10, 0.52, 0.28, 1.0)
	sb.set_corner_radius_all(12)
	sb.set_content_margin_all(10)
	return sb

func _get_gold_btn_style() -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.96, 0.72, 0.18, 1.0)
	sb.border_width_bottom = 4
	sb.border_color = Color(0.68, 0.48, 0.08, 1.0)
	sb.set_corner_radius_all(12)
	sb.set_content_margin_all(10)
	return sb

var welcome_modal: PanelContainer = null

func _on_offline_earnings_available(earned: float, elapsed: float) -> void:
	if welcome_modal != null and is_instance_valid(welcome_modal):
		welcome_modal.queue_free()

	welcome_modal = PanelContainer.new()
	welcome_modal.name = "WelcomeBackModal"
	welcome_modal.custom_minimum_size = Vector2(440, 300)
	welcome_modal.anchors_preset = Control.PRESET_CENTER
	welcome_modal.anchor_left = 0.5
	welcome_modal.anchor_top = 0.5
	welcome_modal.anchor_right = 0.5
	welcome_modal.anchor_bottom = 0.5
	welcome_modal.offset_left = -220
	welcome_modal.offset_top = -150
	welcome_modal.offset_right = 220
	welcome_modal.offset_bottom = 150
	welcome_modal.pivot_offset = Vector2(220, 150)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.14, 0.20, 0.96)
	style.border_color = Color(0.95, 0.82, 0.25, 1.0)
	style.set_border_width_all(3)
	style.set_corner_radius_all(18)
	style.shadow_color = Color(0, 0, 0, 0.6)
	style.shadow_size = 20
	welcome_modal.add_theme_stylebox_override("panel", style)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	welcome_modal.add_child(vb)

	var title = Label.new()
	title.text = "✨ WELCOME BACK, CHEF! ✨"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.25))
	vb.add_child(title)

	var mins = max(1, int(elapsed / 60.0))
	var desc = Label.new()
	desc.text = "While you were away for %d min (capped at 8h),\nyour staff kept cooking at 85%% efficiency:" % mins
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.add_theme_font_size_override("font_size", 15)
	desc.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
	vb.add_child(desc)

	var cash_val = Label.new()
	cash_val.text = "+" + _format_money(earned)
	cash_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cash_val.add_theme_font_size_override("font_size", 34)
	cash_val.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55))
	vb.add_child(cash_val)

	var hb = HBoxContainer.new()
	hb.alignment = BoxContainer.ALIGNMENT_CENTER
	hb.add_theme_constant_override("separation", 16)
	vb.add_child(hb)

	var collect_btn = Button.new()
	collect_btn.text = "COLLECT (1X)"
	collect_btn.custom_minimum_size = Vector2(160, 44)
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.22, 0.58, 0.32, 1.0)
	btn_style.set_corner_radius_all(10)
	collect_btn.add_theme_stylebox_override("normal", btn_style)
	collect_btn.add_theme_font_size_override("font_size", 16)
	collect_btn.pressed.connect(func(): _claim_offline(1.0))
	hb.add_child(collect_btn)

	var double_btn = Button.new()
	double_btn.text = "⚡ 2X PROMO BOOST!"
	double_btn.custom_minimum_size = Vector2(170, 44)
	var double_style = StyleBoxFlat.new()
	double_style.bg_color = Color(0.92, 0.65, 0.12, 1.0)
	double_style.set_corner_radius_all(10)
	double_btn.add_theme_stylebox_override("normal", double_style)
	double_btn.add_theme_font_size_override("font_size", 16)
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
	for c in world_map_grid.get_children():
		c.queue_free()

	var gm = get_node_or_null("/root/GameManager")
	if gm == null:
		return

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

# ─── Tycoon Superstore Modal ────────────────────────────────────────────────
func _refresh_shop_panel() -> void:
	if shop_vbox == null: return
	for c in shop_vbox.get_children():
		c.queue_free()
	var gm = get_node_or_null("/root/GameManager")
	if gm == null: return

	# 1. Daily Free Gift
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

	# 2. Instant Cash Packs
	shop_vbox.add_child(_create_shop_card(
		"cash_small",
		"💰 Small Tip Jar",
		"Instant cash infusion for quick kitchen expansions.",
		"+%s Cash" % _format_money(500.0),
		"💎 10 GEMS",
		Color(0.95, 0.65, 0.15, 1.0),
		gm.gems < 10,
		gm
	))

	shop_vbox.add_child(_create_shop_card(
		"cash_medium",
		"💼 Tycoon Briefcase",
		"Substantial stack of cash for multi-level dining upgrades.",
		"+%s Cash" % _format_money(2500.0),
		"💎 40 GEMS",
		Color(0.95, 0.65, 0.15, 1.0),
		gm.gems < 40,
		gm
	))

	shop_vbox.add_child(_create_shop_card(
		"cash_vault",
		"🏦 Golden Diner Vault",
		"Massive bullion reserve to instantly fund any restaurant purchase.",
		"+%s Cash" % _format_money(10000.0),
		"💎 120 GEMS",
		Color(0.95, 0.65, 0.15, 1.0),
		gm.gems < 120,
		gm
	))

	# 3. Revenue Boosters
	shop_vbox.add_child(_create_shop_card(
		"boost_5m",
		"⚡ 5-Minute Lunch Rush",
		"Doubles all customer revenue and diner tips for 5 minutes (300s)!",
		"🔥 2X Multiplier (5 Mins)",
		"💎 15 GEMS",
		Color(0.2, 0.7, 0.95, 1.0),
		gm.gems < 15,
		gm
	))

	shop_vbox.add_child(_create_shop_card(
		"boost_15m",
		"🔥 15-Minute Happy Hour",
		"High-intensity diner rush! 2X revenue for a full 15 minutes (900s)!",
		"🔥 2X Multiplier (15 Mins)",
		"💎 35 GEMS",
		Color(0.95, 0.35, 0.25, 1.0),
		gm.gems < 35,
		gm
	))

	# 4. Permanent Boosters
	var perm_boosters = gm.get_permanent_boosters() if gm.has_method("get_permanent_boosters") else {}
	for bid in perm_boosters.keys():
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
			is_owned or gm.gems < gem_cost,
			gm
		))

	# 5. Currency Exchange
	shop_vbox.add_child(_create_shop_card(
		"buy_gems",
		"💎 Diamond Stash",
		"Exchange bistro earnings for precious premium diamonds.",
		"+50 Gems",
		_format_money(1000.0) + " CASH",
		Color(0.65, 0.45, 0.95, 1.0),
		gm.cash < 1000.0,
		gm
	))

func _create_shop_card(item_id: String, title_txt: String, desc_txt: String, value_txt: String, btn_txt: String, btn_color: Color, is_disabled: bool, gm: Node) -> PanelContainer:
	var p = PanelContainer.new()
	p.add_theme_stylebox_override("panel", _get_card_style())

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)
	p.add_child(hbox)

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
		if gm.buy_shop_item(item_id):
			_refresh_shop_panel()
	)
	hbox.add_child(btn)
	return p

# ─── 3D-to-HUD Flying Currency Trails ───────────────────────────────────────
func spawn_flying_currency_trail(world_pos: Vector3, amount: float = 0.0, count: int = 5) -> void:
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
		
	var target_screen_pos: Vector2 = Vector2(160.0, 42.0)
	var cash_panel = get_node_or_null("HUD/TopBar/CashPanel")
	if cash_panel != null and cash_panel.is_inside_tree():
		target_screen_pos = cash_panel.global_position + cash_panel.size * 0.5
	elif cash_label != null and cash_label.is_inside_tree():
		target_screen_pos = cash_label.global_position + cash_label.size * 0.5
		
	if cash_texture == null:
		if ResourceLoader.exists("res://assets/textures/bubble_cash_stack.png"):
			cash_texture = load("res://assets/textures/bubble_cash_stack.png")
			
	var coin_count: int = clampi(count, 3, 7)
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
		if cash_texture != null:
			sprite.texture = cash_texture
			sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			sprite.custom_minimum_size = Vector2(26, 26)
			sprite.size = Vector2(26, 26)
			sprite.pivot_offset = Vector2(13, 13)
		else:
			var lbl = Label.new()
			lbl.text = "💵"
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
		
		# 0.45 second smooth arc flight to treasury counter
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
				am.play_sfx("coin", 0.06, 0.5)
			_punch_treasury_counter()
		)

func _punch_treasury_counter() -> void:
	var cash_panel = get_node_or_null("HUD/TopBar/CashPanel")
	if cash_panel != null and cash_panel.is_inside_tree():
		cash_panel.pivot_offset = cash_panel.size * 0.5
		var tw = create_tween()
		tw.tween_property(cash_panel, "scale", Vector2(1.14, 1.14), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(cash_panel, "scale", Vector2.ONE, 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

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

