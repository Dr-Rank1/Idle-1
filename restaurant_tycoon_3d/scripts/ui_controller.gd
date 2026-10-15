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
@onready var shop_btn: Button = get_node_or_null("HUD/ShopBtn")
@onready var shop_panel: PanelContainer = get_node_or_null("ShopPanel")
@onready var shop_vbox: VBoxContainer = get_node_or_null("ShopPanel/VBox/Scroll/ItemsVBox")
@onready var close_shop_btn: Button = get_node_or_null("ShopPanel/VBox/TopHBox/CloseShopBtn")

var current_station_id: String = ""
var current_multiplier: String = "1"
var displayed_cash: float = 650.0
var sim_time_minutes: float = 8.0 * 60.0 + 34.0

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
	
	# Upgrade Modal
	if multi_1_btn != null: multi_1_btn.pressed.connect(func(): _set_multiplier("1"))
	if multi_10_btn != null: multi_10_btn.pressed.connect(func(): _set_multiplier("10"))
	if multi_max_btn != null: multi_max_btn.pressed.connect(func(): _set_multiplier("MAX"))
	if upgrade_btn != null: upgrade_btn.pressed.connect(_on_upgrade_pressed)
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

	if floating_boost_btn != null:
		floating_boost_btn.pressed.connect(_on_boost_pressed)
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
			_toggle_modal(quests_panel, _refresh_quests_panel)
		)
	if side_stats_btn != null:
		side_stats_btn.pressed.connect(func():
			_play_click_sfx()
			if status_ribbons != null:
				status_ribbons.visible = not status_ribbons.visible
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
		if gm.has_signal("world_restaurants_updated"):
			gm.world_restaurants_updated.connect(func():
				if world_map_panel != null and world_map_panel.visible:
					_refresh_world_map()
			)
		gm.menu_updated.connect(func():
			if kitchen_panel != null and kitchen_panel.visible:
				_refresh_kitchen_panel()
		)
		
		displayed_cash = gm.cash
		_update_top_bar(gm.cash, gm.gems, gm.star_rating, gm.restaurant_name, gm.restaurant_level, gm.restaurant_xp, gm.xp_to_next_level)
		_refresh_quest_banner()

func _focus_camera(zone: String) -> void:
	var cam = get_viewport().get_camera_3d()
	if cam != null and cam.has_method("focus_zone"):
		cam.focus_zone(zone)

func _hide_all_modals() -> void:
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

func _open_modal(panel: PanelContainer) -> void:
	if panel == null: return
	_play_click_sfx()
	_hide_all_modals()
	panel.visible = true
	panel.scale = Vector2(0.88, 0.88)
	var tw = create_tween()
	tw.tween_property(panel, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _close_modal(panel: PanelContainer) -> void:
	if panel == null: return
	_play_click_sfx()
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
	if amount >= 1000000.0:
		return "$%.2fM" % (amount / 1000000.0)
	elif amount >= 10000.0:
		return "$%.1fK" % (amount / 1000.0)
	else:
		return "$%d" % round(amount)

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
	var tw = create_tween()
	tw.tween_method(func(val: float):
		displayed_cash = val
		if cash_label != null:
			cash_label.text = _format_money(val)
	, displayed_cash, new_cash, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
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

func _on_gems_changed(new_gems: int) -> void:
	if gem_label != null: gem_label.text = "%d" % new_gems
	if shop_panel != null and shop_panel.visible:
		_refresh_shop_panel()

func _on_cash_rate_updated(rate: float) -> void:
	if cash_rate_label != null: cash_rate_label.text = "+%s/s" % _format_money(rate)

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
	if gm != null and gm.is_boosted:
		var s = ceil(gm.boost_timer)
		if floating_boost_btn != null:
			floating_boost_btn.text = "🔥 2X ACTIVE (%ds)" % s
		if boost_btn != null:
			boost_btn.text = "⚡ 2X (%ds)" % s

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
		quest_claim_btn.text = "CLAIM  +$%d" % round(active_q.get("reward_cash", 100))
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
		btn.text = "CLAIM\n+$%d 💎+%d" % [round(q.get("reward_cash", 100)), q.get("reward_gems", 5)]
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
	if upgrade_income != null: upgrade_income.text = "💵 +$%d / cust   ⚡ +%d" % [round(inc), max(5, actual_level * 2)]
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

func _set_multiplier(mode: String) -> void:
	_play_click_sfx()
	current_multiplier = mode
	if multi_1_btn != null: multi_1_btn.modulate = Color(1, 1, 1, 1) if mode == "1" else Color(0.65, 0.7, 0.8, 0.7)
	if multi_10_btn != null: multi_10_btn.modulate = Color(1, 1, 1, 1) if mode == "10" else Color(0.65, 0.7, 0.8, 0.7)
	if multi_max_btn != null: multi_max_btn.modulate = Color(1, 1, 1, 1) if mode == "MAX" else Color(0.65, 0.7, 0.8, 0.7)
	_refresh_upgrade_btn()

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
		upgrade_btn.text = "UPGRADE +%d LVL\n($%d)" % [info.levels, round(info.cost)]
		upgrade_btn.disabled = not info.can_afford
		if upgrade_max_badge != null:
			upgrade_max_badge.visible = false

func _on_upgrade_pressed() -> void:
	_play_click_sfx()
	var gm = get_node_or_null("/root/GameManager")
	if gm != null and current_station_id != "":
		gm.upgrade_station_multi(current_station_id, current_multiplier)

func _on_station_upgraded(station_id: String, new_lvl: int) -> void:
	if station_id == current_station_id and upgrade_panel != null and upgrade_panel.visible:
		var gm = get_node_or_null("/root/GameManager")
		if gm != null:
			var station_max = gm.get_station_max_level(station_id)
			var is_max = new_lvl >= station_max
			if upgrade_level != null: upgrade_level.text = "Level %d / %d" % [new_lvl, station_max]
			var inc = gm.get_station_income(station_id)
			if upgrade_income != null: upgrade_income.text = "💵 +$%d / cust   ⚡ +%d" % [round(inc), max(5, new_lvl * 2)]
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
			_refresh_upgrade_btn()
			_refresh_upgrade_tiles(gm)
	if dining_panel != null and dining_panel.visible:
		_refresh_dining_panel()
	if kitchen_panel != null and kitchen_panel.visible:
		_refresh_kitchen_panel()
	if terrace_panel != null and terrace_panel.visible:
		_refresh_terrace_panel()

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
		sub_lbl.text = "%s • Level %d (+$%d/dish)" % [gm.get_station_tier_title(table_id, lvl), lvl, round(gm.get_station_income(table_id))]
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
			btn.text = "UPGRADE +%d\n($%d)" % [info.levels, round(info.cost)]
			btn.disabled = not info.can_afford
			btn.pressed.connect(func():
				_play_click_sfx()
				gm.upgrade_station_multi(table_id, current_multiplier)
			)
			btn.add_theme_stylebox_override("normal", _get_green_btn_style())
	else:
		var cost = gm.get_table_unlock_cost(table_id)
		btn.text = "UNLOCK\n($%d)" % round(cost)
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
		btn.text = "UNLOCK TERRACE ($%d)" % round(gm.TERRACE_UNLOCK_COST)
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
			btn.text = "UNLOCK\n($%d)" % round(cost)
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
		desc_lbl.text = "$%d / Order • Active on Table Menus" % round(price_val)
		desc_lbl.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55, 1))
	else:
		desc_lbl.text = "Earns $%d / Order • %s" % [round(price_val), item.get("desc", "")]
		desc_lbl.add_theme_color_override("font_color", Color(0.75, 0.82, 0.9, 0.8))
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(desc_lbl)
	
	var btn = Button.new()
	if is_unlocked:
		btn.text = "SERVING\n($%d)" % round(price_val)
		btn.disabled = true
		btn.add_theme_stylebox_override("normal", _get_green_btn_style())
	else:
		var cost = item.get("unlock_cost", 180.0)
		btn.text = "UNLOCK\n($%d)" % round(cost)
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
		btn.text = "UPGRADE +%d\n($%d)" % [info.levels, round(info.cost)]
		btn.disabled = not info.can_afford
		btn.pressed.connect(func():
			_play_click_sfx()
			gm.upgrade_station_multi(st_id, current_multiplier)
		)
		btn.add_theme_stylebox_override("normal", _get_green_btn_style())
	hbox.add_child(btn)
	return p

# ─── Staff Roster Modal ─────────────────────────────────────────────────────
func _on_staff_updated(_sid: String) -> void:
	if staff_panel != null and staff_panel.visible:
		_refresh_staff_panel()

func _refresh_staff_panel() -> void:
	for c in staff_vbox.get_children():
		c.queue_free()
	var gm = get_node_or_null("/root/GameManager")
	if gm == null:
		return
	for sid in ["waiter_1", "waiter_2", "waiter_3", "chef_stove", "chef_prep", "chef_sous"]:
		if gm.staff_roster.has(sid):
			staff_vbox.add_child(_create_staff_card(gm.staff_roster[sid], gm))

func _create_staff_card(st: Dictionary, gm: Node) -> PanelContainer:
	var p = PanelContainer.new()
	p.add_theme_stylebox_override("panel", _get_card_style())
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	p.add_child(hbox)
	
	var icon = Label.new()
	icon.text = "👔" if st.get("role") == "waiter" else "👨‍🍳"
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
	var spd = gm.get_staff_speed_multiplier(st["id"])
	
	var sub_lbl = Label.new()
	if is_hired:
		sub_lbl.text = "Level %d • Speed: +%d%%" % [lvl, round((spd - 1.0) * 100)]
		sub_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0, 1))
	else:
		sub_lbl.text = "Available for Hire • Expand Capacity"
		sub_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 0.8))
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
		var cost = gm.get_staff_upgrade_cost(st["id"])
		btn.text = "UPGRADE\n($%d)" % round(cost)
		btn.disabled = gm.cash < cost
		btn.pressed.connect(func():
			_play_click_sfx()
			gm.upgrade_staff(st["id"])
		)
		btn.add_theme_stylebox_override("normal", _get_green_btn_style())
	else:
		var cost = st.get("hire_cost", 200.0)
		btn.text = "HIRE\n($%d)" % round(cost)
		btn.disabled = gm.cash < cost
		btn.pressed.connect(func():
			_play_click_sfx()
			gm.hire_staff(st["id"])
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
	for cid in ["flyers", "social_ad", "radio_spot"]:
		if gm.campaigns.has(cid):
			marketing_vbox.add_child(_create_campaign_card(gm.campaigns[cid], gm))

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
		btn.text = "LAUNCH\n($%d)" % round(cost)
		btn.disabled = gm.cash < cost
		btn.pressed.connect(func():
			_play_click_sfx()
			gm.start_campaign(camp["id"])
		)
		btn.add_theme_stylebox_override("normal", _get_green_btn_style())
	hbox.add_child(btn)
	return p

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
			btn.text = "🟢 CURRENT LOCATION"
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
		"+$500 Cash",
		"💎 10 GEMS",
		Color(0.95, 0.65, 0.15, 1.0),
		gm.gems < 10,
		gm
	))

	shop_vbox.add_child(_create_shop_card(
		"cash_medium",
		"💼 Tycoon Briefcase",
		"Substantial stack of cash for multi-level dining upgrades.",
		"+$2,500 Cash",
		"💎 40 GEMS",
		Color(0.95, 0.65, 0.15, 1.0),
		gm.gems < 40,
		gm
	))

	shop_vbox.add_child(_create_shop_card(
		"cash_vault",
		"🏦 Golden Diner Vault",
		"Massive bullion reserve to instantly fund any restaurant purchase.",
		"+$10,000 Cash",
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

	# 4. Currency Exchange
	shop_vbox.add_child(_create_shop_card(
		"buy_gems",
		"💎 Diamond Stash",
		"Exchange bistro earnings for precious premium diamonds.",
		"+50 Gems",
		"$1,000 CASH",
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

