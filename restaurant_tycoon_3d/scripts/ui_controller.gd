extends CanvasLayer

# ─── Top Bar Node References ────────────────────────────────────────────────
@onready var profile_panel: PanelContainer = $HUD/TopBar/ProfilePanel
@onready var rest_name_label: Label = $HUD/TopBar/ProfilePanel/VBox/RestNameLabel
@onready var star_label: Label = $HUD/TopBar/ProfilePanel/VBox/HBox/StarLabel
@onready var level_label: Label = $HUD/TopBar/ProfilePanel/VBox/HBox/LevelLabel
@onready var xp_bar: ProgressBar = $HUD/TopBar/ProfilePanel/VBox/XPBar

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
@onready var nav_terrace_btn: Button = get_node_or_null("HUD/BottomDock/HBox/TerraceBtn")
@onready var nav_staff_btn: Button = get_node_or_null("HUD/BottomDock/HBox/StaffBtn")
@onready var nav_promo_btn: Button = get_node_or_null("HUD/BottomDock/HBox/PromoBtn")

# ─── Modals ─────────────────────────────────────────────────────────────────
@onready var upgrade_panel: PanelContainer = $UpgradePanel
@onready var upgrade_title: Label = $UpgradePanel/VBox/TitleLabel
@onready var upgrade_tier: Label = $UpgradePanel/VBox/TierBadgeLabel
@onready var upgrade_milestone_bar: ProgressBar = $UpgradePanel/VBox/MilestoneBar
@onready var upgrade_level: Label = $UpgradePanel/VBox/LevelLabel
@onready var upgrade_income: Label = $UpgradePanel/VBox/IncomeLabel
@onready var upgrade_next_unlock: Label = $UpgradePanel/VBox/NextUnlockLabel
@onready var multi_1_btn: Button = $UpgradePanel/VBox/MultiHBox/Multi1Btn
@onready var multi_10_btn: Button = $UpgradePanel/VBox/MultiHBox/Multi10Btn
@onready var multi_max_btn: Button = $UpgradePanel/VBox/MultiHBox/MultiMaxBtn
@onready var upgrade_btn: Button = $UpgradePanel/VBox/UpgradeBtn
@onready var close_btn: Button = $UpgradePanel/VBox/CloseBtn

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

@onready var staff_panel: PanelContainer = $StaffPanel
@onready var staff_vbox: VBoxContainer = $StaffPanel/VBox/StaffScroll/StaffVBox
@onready var close_staff_btn: Button = $StaffPanel/VBox/CloseStaffBtn

@onready var marketing_panel: PanelContainer = get_node_or_null("MarketingPanel")
@onready var marketing_vbox: VBoxContainer = get_node_or_null("MarketingPanel/VBox/Scroll/VBox")
@onready var close_marketing_btn: Button = get_node_or_null("MarketingPanel/VBox/CloseBtn")

@onready var quests_panel: PanelContainer = $QuestsPanel
@onready var quests_vbox: VBoxContainer = $QuestsPanel/VBox/Scroll/VBox
@onready var close_quests_btn: Button = $QuestsPanel/VBox/CloseBtn

var current_station_id: String = ""
var current_multiplier: String = "1"
var displayed_cash: float = 650.0

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
			_toggle_modal(kitchen_panel, _refresh_kitchen_panel)
		)
	if nav_dining_btn != null:
		nav_dining_btn.pressed.connect(func():
			_focus_camera("dining")
			_toggle_modal(dining_panel, _refresh_dining_panel)
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
	multi_1_btn.pressed.connect(func(): _set_multiplier("1"))
	multi_10_btn.pressed.connect(func(): _set_multiplier("10"))
	multi_max_btn.pressed.connect(func(): _set_multiplier("MAX"))
	upgrade_btn.pressed.connect(_on_upgrade_pressed)
	close_btn.pressed.connect(func(): _close_modal(upgrade_panel))
	
	# Modal Close Buttons
	if close_dining_btn != null: close_dining_btn.pressed.connect(func(): _close_modal(dining_panel))
	if close_kitchen_btn != null: close_kitchen_btn.pressed.connect(func(): _close_modal(kitchen_panel))
	if close_terrace_btn != null: close_terrace_btn.pressed.connect(func(): _close_modal(terrace_panel))
	if close_parking_btn != null: close_parking_btn.pressed.connect(func(): _close_modal(parking_panel))
	if close_staff_btn != null: close_staff_btn.pressed.connect(func(): _close_modal(staff_panel))
	if close_marketing_btn != null: close_marketing_btn.pressed.connect(func(): _close_modal(marketing_panel))
	if close_quests_btn != null: close_quests_btn.pressed.connect(func(): _close_modal(quests_panel))

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
	rest_name_label.text = rest_name
	star_label.text = "★ %.1f" % stars
	level_label.text = "Lv. %d" % lvl
	xp_bar.max_value = next_xp
	xp_bar.value = xp
	gem_label.text = "%d" % g
	cash_label.text = _format_money(c)

func _on_cash_changed(new_cash: float) -> void:
	var tw = create_tween()
	tw.tween_method(func(val: float):
		displayed_cash = val
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

func _on_gems_changed(new_gems: int) -> void:
	gem_label.text = "%d" % new_gems

func _on_cash_rate_updated(rate: float) -> void:
	cash_rate_label.text = "+%s/s" % _format_money(rate)

func _on_level_updated(lvl: int, cur_xp: float, max_xp: float) -> void:
	level_label.text = "Lv. %d" % lvl
	xp_bar.max_value = max_xp
	xp_bar.value = cur_xp

func _on_boost_pressed() -> void:
	_play_click_sfx()
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.toggle_boost()

func _on_boost_toggled(active: bool) -> void:
	if active:
		boost_btn.text = "⚡ 2X ACTIVE!"
		boost_btn.modulate = Color(1.0, 0.85, 0.2, 1.0)
	else:
		boost_btn.text = "⚡ 2X RUSH"
		boost_btn.modulate = Color(1.0, 1.0, 1.0, 1.0)

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
func open_upgrade(station_id: String, station_name: String, level: int) -> void:
	current_station_id = station_id
	var gm = get_node_or_null("/root/GameManager")
	if gm == null:
		return
	
	upgrade_title.text = station_name
	upgrade_tier.text = gm.get_station_tier_title(station_id, level)
	upgrade_level.text = "Level %d / %d" % [level, gm.max_level]
	var inc = gm.get_station_income(station_id)
	upgrade_income.text = "Income: +$%d / customer" % round(inc)
	upgrade_next_unlock.text = gm.get_next_tier_desc(station_id, level)
	
	var next_milestone = 5 if level < 5 else (10 if level < 10 else 25)
	var prev_milestone = 1 if level < 5 else (5 if level < 10 else 10)
	upgrade_milestone_bar.min_value = prev_milestone
	upgrade_milestone_bar.max_value = next_milestone
	upgrade_milestone_bar.value = level
	
	_refresh_upgrade_btn()
	_open_modal(upgrade_panel)

func _set_multiplier(mode: String) -> void:
	_play_click_sfx()
	current_multiplier = mode
	multi_1_btn.modulate = Color(1, 1, 1, 1) if mode == "1" else Color(0.65, 0.7, 0.8, 0.7)
	multi_10_btn.modulate = Color(1, 1, 1, 1) if mode == "10" else Color(0.65, 0.7, 0.8, 0.7)
	multi_max_btn.modulate = Color(1, 1, 1, 1) if mode == "MAX" else Color(0.65, 0.7, 0.8, 0.7)
	_refresh_upgrade_btn()

func _refresh_upgrade_btn() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm == null or current_station_id == "":
		return
	var info = gm.get_upgrade_multi_info(current_station_id, current_multiplier)
	if info.levels <= 0:
		upgrade_btn.text = "MAX LEVEL REACHED"
		upgrade_btn.disabled = true
	else:
		upgrade_btn.text = "UPGRADE +%d LVL  ($%d)" % [info.levels, round(info.cost)]
		upgrade_btn.disabled = not info.can_afford

func _on_upgrade_pressed() -> void:
	_play_click_sfx()
	var gm = get_node_or_null("/root/GameManager")
	if gm != null and current_station_id != "":
		gm.upgrade_station_multi(current_station_id, current_multiplier)

func _on_station_upgraded(station_id: String, new_lvl: int) -> void:
	if station_id == current_station_id and upgrade_panel.visible:
		var gm = get_node_or_null("/root/GameManager")
		if gm != null:
			upgrade_tier.text = gm.get_station_tier_title(station_id, new_lvl)
			upgrade_level.text = "Level %d / %d" % [new_lvl, gm.max_level]
			var inc = gm.get_station_income(station_id)
			upgrade_income.text = "Income: +$%d / customer" % round(inc)
			upgrade_next_unlock.text = gm.get_next_tier_desc(station_id, new_lvl)
			upgrade_milestone_bar.value = new_lvl
			_refresh_upgrade_btn()
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
	
	for i in range(1, 6): # Indoor tables 1 to 5
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
		for tid in ["table_6", "table_7", "table_8"]:
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
	desc.text = "While you were away for %d minutes,\nyour staff kept cooking and earned:" % mins
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
	double_btn.text = "⚡ 2X DOUBLE!"
	double_btn.custom_minimum_size = Vector2(160, 44)
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
