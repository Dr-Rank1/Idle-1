extends CanvasLayer

@onready var cash_label: Label = $HUD/TopBar/CashPanel/HBox/CashLabel
@onready var gem_label: Label = $HUD/TopBar/GemPanel/HBox/GemLabel
@onready var star_label: Label = $HUD/TopBar/StarPanel/HBox/StarLabel
@onready var name_label: Label = $HUD/TopBar/NamePanel/NameLabel
@onready var boost_btn: Button = $HUD/TopBar/BoostBtn

@onready var menu_nav_btn: Button = $HUD/BottomBar/MenuNavBtn
@onready var staff_nav_btn: Button = $HUD/BottomBar/StaffNavBtn

# Station Upgrade Modal
@onready var upgrade_panel: PanelContainer = $UpgradePanel
@onready var upgrade_title: Label = $UpgradePanel/VBox/TitleLabel
@onready var upgrade_tier: Label = $UpgradePanel/VBox/TierBadgeLabel
@onready var upgrade_level: Label = $UpgradePanel/VBox/LevelLabel
@onready var upgrade_income: Label = $UpgradePanel/VBox/IncomeLabel
@onready var upgrade_next_unlock: Label = $UpgradePanel/VBox/NextUnlockLabel
@onready var upgrade_btn: Button = $UpgradePanel/VBox/UpgradeBtn
@onready var close_btn: Button = $UpgradePanel/VBox/CloseBtn

# Menu Book Modal
@onready var menu_panel: PanelContainer = $MenuPanel
@onready var menu_items_vbox: VBoxContainer = $MenuPanel/VBox/ItemsScroll/ItemsVBox
@onready var close_menu_btn: Button = $MenuPanel/VBox/CloseMenuBtn

# Staff Roster Modal
@onready var staff_panel: PanelContainer = $StaffPanel
@onready var staff_vbox: VBoxContainer = $StaffPanel/VBox/StaffScroll/StaffVBox
@onready var close_staff_btn: Button = $StaffPanel/VBox/CloseStaffBtn

var current_station_id: String = ""

func _ready() -> void:
	upgrade_panel.visible = false
	menu_panel.visible = false
	staff_panel.visible = false
	
	upgrade_btn.pressed.connect(_on_upgrade_pressed)
	close_btn.pressed.connect(_on_close_pressed)
	boost_btn.pressed.connect(_on_boost_pressed)
	
	menu_nav_btn.pressed.connect(_toggle_menu_panel)
	staff_nav_btn.pressed.connect(_toggle_staff_panel)
	close_menu_btn.pressed.connect(func(): menu_panel.visible = false)
	close_staff_btn.pressed.connect(func(): staff_panel.visible = false)

	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.cash_changed.connect(_on_cash_changed)
		gm.station_upgraded.connect(_on_station_upgraded)
		gm.boost_toggled.connect(_on_boost_toggled)
		gm.menu_updated.connect(_refresh_menu_panel)
		gm.staff_updated.connect(_refresh_staff_panel)
		_update_hud(gm.cash, gm.gems, gm.star_rating, gm.restaurant_name)

func _update_hud(cash_val: float, gem_val: int, stars: float, rest_name: String) -> void:
	cash_label.text = "$%d" % round(cash_val)
	gem_label.text = "%d" % gem_val
	star_label.text = "★ %.1f" % stars
	name_label.text = rest_name

func _on_cash_changed(new_cash: float) -> void:
	cash_label.text = "$%d" % round(new_cash)
	_refresh_upgrade_btn()
	if menu_panel.visible:
		_refresh_menu_panel()
	if staff_panel.visible:
		_refresh_staff_panel()

func _on_boost_pressed() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.toggle_boost()

func _on_boost_toggled(active: bool) -> void:
	if active:
		boost_btn.text = "⚡ 2X ACTIVE!"
		boost_btn.modulate = Color(1.0, 0.8, 0.2, 1.0)
	else:
		boost_btn.text = "⚡ BOOST 2X"
		boost_btn.modulate = Color(1.0, 1.0, 1.0, 1.0)

# ─── Station Upgrade Logic ──────────────────────────────────────────────────
func open_upgrade(station_id: String, station_name: String, level: int) -> void:
	menu_panel.visible = false
	staff_panel.visible = false
	
	current_station_id = station_id
	var gm = get_node_or_null("/root/GameManager")
	if gm == null:
		return
	
	upgrade_title.text = station_name
	upgrade_tier.text = gm.get_station_tier_title(station_id, level)
	upgrade_level.text = "Level %d / %d" % [level, gm.max_level]
	var inc = gm.get_station_income(station_id)
	upgrade_income.text = "Revenue: +$%d / customer" % round(inc)
	upgrade_next_unlock.text = gm.get_next_tier_desc(station_id, level)
	_refresh_upgrade_btn()
	
	upgrade_panel.visible = true
	upgrade_panel.scale = Vector2(0.85, 0.85)
	var tween: Tween = create_tween()
	tween.tween_property(upgrade_panel, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _refresh_upgrade_btn() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm == null or current_station_id == "":
		return
	var cost: float = gm.get_upgrade_cost(current_station_id)
	upgrade_btn.text = "UPGRADE  ($%d)" % round(cost)
	upgrade_btn.disabled = gm.cash < cost

func _on_upgrade_pressed() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm != null and current_station_id != "":
		gm.upgrade_station(current_station_id)

func _on_station_upgraded(station_id: String, new_lvl: int) -> void:
	if station_id == current_station_id:
		var gm = get_node_or_null("/root/GameManager")
		if gm != null:
			upgrade_tier.text = gm.get_station_tier_title(station_id, new_lvl)
			upgrade_level.text = "Level %d / %d" % [new_lvl, gm.max_level]
			var inc = gm.get_station_income(station_id)
			upgrade_income.text = "Revenue: +$%d / customer" % round(inc)
			upgrade_next_unlock.text = gm.get_next_tier_desc(station_id, new_lvl)
			_refresh_upgrade_btn()

func _on_close_pressed() -> void:
	upgrade_panel.visible = false

# ─── Menu Book Logic ────────────────────────────────────────────────────────
func _toggle_menu_panel() -> void:
	upgrade_panel.visible = false
	staff_panel.visible = false
	menu_panel.visible = not menu_panel.visible
	if menu_panel.visible:
		_refresh_menu_panel()
		menu_panel.scale = Vector2(0.9, 0.9)
		var tw = create_tween()
		tw.tween_property(menu_panel, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _refresh_menu_panel() -> void:
	for c in menu_items_vbox.get_children():
		c.queue_free()
		
	var gm = get_node_or_null("/root/GameManager")
	if gm == null:
		return
		
	var items = gm.menu_items
	for dish_id in ["burger", "pasta", "pizza", "sushi"]:
		if not items.has(dish_id):
			continue
		var dish = items[dish_id]
		var card = _create_recipe_card(dish, gm)
		menu_items_vbox.add_child(card)

func _create_recipe_card(dish: Dictionary, gm: Node) -> PanelContainer:
	var p = PanelContainer.new()
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.12, 0.16, 0.23, 0.95)
	card_style.set_corner_radius_all(12)
	card_style.set_content_margin_all(10)
	card_style.border_width_left = 1
	card_style.border_width_top = 1
	card_style.border_width_right = 1
	card_style.border_width_bottom = 1
	card_style.border_color = Color(0.3, 0.42, 0.6, 0.5)
	p.add_theme_stylebox_override("panel", card_style)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	p.add_child(hbox)
	
	var icon_lbl = Label.new()
	icon_lbl.text = dish.get("icon", "🍽️")
	icon_lbl.add_theme_font_size_override("font_size", 34)
	hbox.add_child(icon_lbl)
	
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)
	
	var name_lbl = Label.new()
	name_lbl.text = dish.get("name", "Dish")
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	info_vbox.add_child(name_lbl)
	
	var price_lbl = Label.new()
	price_lbl.text = "Dish Price: +$%d / plate" % round(dish.get("price", 0))
	price_lbl.add_theme_font_size_override("font_size", 13)
	price_lbl.add_theme_color_override("font_color", Color(0.4, 0.95, 0.55, 1))
	info_vbox.add_child(price_lbl)
	
	var desc_lbl = Label.new()
	desc_lbl.text = dish.get("desc", "")
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85, 0.8))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vbox.add_child(desc_lbl)
	
	var action_btn = Button.new()
	var is_unlocked = dish.get("unlocked", false)
	var unlock_cost = dish.get("unlock_cost", 0.0)
	
	if is_unlocked:
		action_btn.text = "✓ UNLOCKED"
		action_btn.disabled = true
		action_btn.add_theme_color_override("font_color", Color(0.5, 0.8, 0.6, 0.9))
	else:
		action_btn.text = "UNLOCK  ($%d)" % round(unlock_cost)
		action_btn.disabled = gm.cash < unlock_cost
		action_btn.pressed.connect(func():
			gm.unlock_dish(dish["id"])
		)
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(0.15, 0.75, 0.4, 1.0)
		btn_style.set_corner_radius_all(10)
		btn_style.set_content_margin_all(8)
		action_btn.add_theme_stylebox_override("normal", btn_style)
		
	hbox.add_child(action_btn)
	return p

# ─── Staff Roster Logic ─────────────────────────────────────────────────────
func _toggle_staff_panel() -> void:
	upgrade_panel.visible = false
	menu_panel.visible = false
	staff_panel.visible = not staff_panel.visible
	if staff_panel.visible:
		_refresh_staff_panel()
		staff_panel.scale = Vector2(0.9, 0.9)
		var tw = create_tween()
		tw.tween_property(staff_panel, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _refresh_staff_panel(_staff_id: String = "") -> void:
	for c in staff_vbox.get_children():
		c.queue_free()
		
	var gm = get_node_or_null("/root/GameManager")
	if gm == null:
		return
		
	var staff_order = ["waiter_1", "waiter_2", "waiter_3", "chef_stove", "chef_prep", "chef_sous"]
	for sid in staff_order:
		if gm.staff_roster.has(sid):
			var data = gm.staff_roster[sid]
			var card = _create_staff_card(data, gm)
			staff_vbox.add_child(card)

func _create_staff_card(staff: Dictionary, gm: Node) -> PanelContainer:
	var p = PanelContainer.new()
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.11, 0.15, 0.22, 0.95)
	card_style.set_corner_radius_all(12)
	card_style.set_content_margin_all(10)
	card_style.border_width_left = 1
	card_style.border_width_top = 1
	card_style.border_width_right = 1
	card_style.border_width_bottom = 1
	card_style.border_color = Color(0.25, 0.4, 0.6, 0.5)
	p.add_theme_stylebox_override("panel", card_style)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	p.add_child(hbox)
	
	var icon_lbl = Label.new()
	icon_lbl.text = "🤵" if staff.get("role") == "waiter" else "👨‍🍳"
	icon_lbl.add_theme_font_size_override("font_size", 32)
	hbox.add_child(icon_lbl)
	
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)
	
	var is_hired = staff.get("hired", false)
	var lvl = staff.get("level", 1)
	
	var name_lbl = Label.new()
	name_lbl.text = staff.get("name", "Staff") + (" (Lv. %d)" % lvl if is_hired else " (Available)")
	name_lbl.add_theme_font_size_override("font_size", 15)
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	info_vbox.add_child(name_lbl)
	
	var desc_lbl = Label.new()
	desc_lbl.text = staff.get("desc", "")
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9, 0.8))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vbox.add_child(desc_lbl)
	
	var action_btn = Button.new()
	if not is_hired:
		var hire_cost = staff.get("hire_cost", 200.0)
		action_btn.text = "HIRE ($%d)" % round(hire_cost)
		action_btn.disabled = gm.cash < hire_cost
		action_btn.pressed.connect(func():
			gm.hire_staff(staff["id"])
		)
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(0.2, 0.65, 0.95, 1.0)
		btn_style.set_corner_radius_all(10)
		btn_style.set_content_margin_all(8)
		action_btn.add_theme_stylebox_override("normal", btn_style)
	else:
		var up_cost = gm.get_staff_upgrade_cost(staff["id"])
		action_btn.text = "TRAIN ($%d)" % round(up_cost)
		action_btn.disabled = gm.cash < up_cost
		action_btn.pressed.connect(func():
			gm.upgrade_staff(staff["id"])
		)
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(0.15, 0.75, 0.4, 1.0)
		btn_style.set_corner_radius_all(10)
		btn_style.set_content_margin_all(8)
		action_btn.add_theme_stylebox_override("normal", btn_style)
		
	hbox.add_child(action_btn)
	return p
