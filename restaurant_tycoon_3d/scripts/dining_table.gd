extends StaticBody3D

signal table_clicked(table_id: String, table_name: String, level: int)

@export var table_id: String = "table_1"
@export var table_name: String = "Dining Table 1"
@export var is_terrace_table: bool = false

var is_unlocked: bool = true
var is_occupied: bool = false
var is_dirty: bool = false
var occupying_customer: Node = null

@onready var seat_pos: Marker3D = $SeatMarker
@onready var badge_root: Node3D = $BadgeRoot
@onready var level_label: Label3D = $BadgeRoot/LevelLabel
@onready var action_badge: Label3D = get_node_or_null("BadgeRoot/ActionBadge")

@onready var food_dish: Node3D = $FoodDish
@onready var dirty_dishes: Node3D = get_node_or_null("DirtyDishes")
@onready var table_mesh: Node3D = $TableMesh
@onready var booth_decor: Node3D = get_node_or_null("BoothDecor")
@onready var companion_diners: Node3D = get_node_or_null("CompanionDiners")
@onready var terrace_decor: Node3D = get_node_or_null("TerraceDecor")
@onready var chair_north: Node3D = get_node_or_null("ChairNorth")
@onready var chair_south: Node3D = get_node_or_null("ChairSouth")
@onready var chair_east: Node3D = get_node_or_null("ChairEast")
@onready var chair_west: Node3D = get_node_or_null("ChairWest")
@onready var chair_left: Node3D = get_node_or_null("ChairLeft")
@onready var chair_right: Node3D = get_node_or_null("ChairRight")
@onready var table_menu: Node3D = get_node_or_null("TableMenu")
@onready var salt_shaker: Node3D = get_node_or_null("SaltShaker")
@onready var pepper_shaker: Node3D = get_node_or_null("PepperShaker")
@onready var pendant_lamp: Node3D = get_node_or_null("PendantLamp")
@onready var table_omni_light: OmniLight3D = get_node_or_null("TableOmniLight")

@onready var tier2_decor: Node3D = get_node_or_null("Tier2Decor")
@onready var tier3_decor: Node3D = get_node_or_null("Tier3Decor")
@onready var upgrade_particles: CPUParticles3D = get_node_or_null("UpgradeParticles")
@onready var timer_ring: MeshInstance3D = get_node_or_null("TimerRing")

var time_passed: float = 0.0
var initial_badge_y: float = 1.35
var pending_cash_amount: float = 0.0
var booth_bubble_root: Node3D = null

func _ready() -> void:
	if food_dish != null: food_dish.visible = false
	if dirty_dishes != null: dirty_dishes.visible = false
	if timer_ring != null: timer_ring.visible = false
	if is_terrace_table and pendant_lamp != null:
		pendant_lamp.visible = false
	if is_terrace_table:
		if booth_decor != null: booth_decor.visible = false
		if companion_diners != null: companion_diners.visible = false
		if terrace_decor != null: terrace_decor.visible = is_unlocked
		if chair_north != null: chair_north.visible = true
		if chair_south != null: chair_south.visible = true
		if chair_east != null: chair_east.visible = true
		if chair_west != null: chair_west.visible = true
	else:
		if booth_decor != null: booth_decor.visible = true
		if companion_diners != null: companion_diners.visible = true
		if terrace_decor != null: terrace_decor.visible = false
		if chair_north != null: chair_north.visible = false
		if chair_south != null: chair_south.visible = false
		if chair_east != null: chair_east.visible = false
		if chair_west != null: chair_west.visible = false
		if chair_left != null: chair_left.visible = false
		if chair_right != null: chair_right.visible = false
	if timer_ring != null and timer_ring.mesh != null and timer_ring.mesh.material != null:
		var ring_mat = timer_ring.mesh.material.duplicate()
		timer_ring.material_override = ring_mat
	if badge_root != null: initial_badge_y = badge_root.position.y
	
	if action_badge == null and badge_root != null:
		action_badge = Label3D.new()
		action_badge.name = "ActionBadge"
		action_badge.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		action_badge.double_sided = false
		action_badge.font_size = 28
		action_badge.outline_size = 8
		action_badge.position = Vector3(0, 0.45, 0)
		badge_root.add_child(action_badge)
	
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.station_upgraded.connect(_on_station_upgraded)
		gm.table_unlocked.connect(_on_table_unlocked)
		gm.cash_changed.connect(_on_cash_changed)
		is_unlocked = gm.is_table_unlocked(table_id)
		if is_unlocked:
			_set_unlocked_visual(gm.get_station_level(table_id))
		else:
			_set_locked_visual(gm.get_table_unlock_cost(table_id))

func _process(delta: float) -> void:
	time_passed += delta
	if badge_root != null:
		var bob = sin(time_passed * 4.0) * 0.08
		badge_root.position.y = initial_badge_y + bob
		if action_badge != null and action_badge.visible:
			var pulse = 1.0 + sin(time_passed * 6.0) * 0.12
			action_badge.scale = Vector3(pulse, pulse, pulse)
	if booth_bubble_root != null:
		var offset = float(abs(table_id.hash()) % 10)
		booth_bubble_root.position.y = 1.38 + sin(time_passed * 3.2 + offset) * 0.05

func _on_cash_changed(_cash_val: float) -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		if is_unlocked and not is_dirty and not is_occupied:
			var lvl = gm.get_station_level(table_id)
			update_level_display(lvl)
		elif not is_unlocked:
			var cost = gm.get_table_unlock_cost(table_id)
			if action_badge != null:
				action_badge.text = "TAP TO UNLOCK ($%d)" % round(cost)
				action_badge.modulate = Color(0.35, 1.0, 0.55) if gm.cash >= cost else Color(1.0, 0.45, 0.45)

func _set_locked_visual(cost: float) -> void:
	is_unlocked = false
	visible = true
	if table_mesh != null: table_mesh.visible = false
	if booth_decor != null: booth_decor.visible = false
	if companion_diners != null: companion_diners.visible = false
	if terrace_decor != null: terrace_decor.visible = false
	if chair_north != null: chair_north.visible = false
	if chair_south != null: chair_south.visible = false
	if chair_east != null: chair_east.visible = false
	if chair_west != null: chair_west.visible = false
	if chair_left != null: chair_left.visible = false
	if chair_right != null: chair_right.visible = false
	if table_menu != null: table_menu.visible = false
	if salt_shaker != null: salt_shaker.visible = false
	if pepper_shaker != null: pepper_shaker.visible = false
	if pendant_lamp != null: pendant_lamp.visible = false
	if table_omni_light != null: table_omni_light.visible = false
	if food_dish != null:
		food_dish.visible = false
		for c in food_dish.get_children():
			c.visible = false
	if badge_root != null:
		badge_root.visible = true
	if level_label != null:
		level_label.visible = true
		level_label.text = "🔒 " + table_name
		level_label.font_size = 18
		level_label.modulate = Color(0.9, 0.9, 0.9, 0.85)
	if action_badge != null:
		action_badge.visible = true
		var gm = get_node_or_null("/root/GameManager")
		var can_afford: bool = gm != null and gm.cash >= cost
		action_badge.text = "TAP TO UNLOCK ($%d)" % round(cost)
		action_badge.modulate = Color(0.35, 1.0, 0.55) if can_afford else Color(1.0, 0.45, 0.45)

const BOOTH_CHARACTERS: Dictionary = {
	"table_1": [
		"res://assets/models/characters/character-female-a.glb",
		"res://assets/models/characters/character-male-b.glb",
		"res://assets/models/characters/character-male-c.glb",
		"res://assets/models/characters/character-female-b.glb"
	],
	"table_2": [
		"res://assets/models/characters/character-female-c.glb",
		"res://assets/models/characters/character-male-d.glb",
		"res://assets/models/characters/character-male-a.glb",
		"res://assets/models/characters/character-female-d.glb"
	],
	"table_3": [
		"res://assets/models/characters/character-female-e.glb",
		"res://assets/models/characters/character-male-e.glb",
		"res://assets/models/characters/character-female-a.glb",
		"res://assets/models/characters/character-male-f.glb"
	],
	"table_4": [
		"res://assets/models/characters/character-male-f.glb",
		"res://assets/models/characters/character-female-f.glb",
		"res://assets/models/characters/character-female-c.glb",
		"res://assets/models/characters/character-male-c.glb"
	],
	"table_5": [
		"res://assets/models/characters/character-male-b.glb",
		"res://assets/models/characters/character-female-d.glb",
		"res://assets/models/characters/character-female-b.glb",
		"res://assets/models/characters/character-male-e.glb"
	],
	"table_6": [
		"res://assets/models/characters/character-female-e.glb",
		"res://assets/models/characters/character-male-a.glb",
		"res://assets/models/characters/character-male-d.glb",
		"res://assets/models/characters/character-female-f.glb"
	],
	"table_7": [
		"res://assets/models/characters/character-female-a.glb",
		"res://assets/models/characters/character-male-c.glb",
		"res://assets/models/characters/character-female-d.glb",
		"res://assets/models/characters/character-male-b.glb"
	],
	"table_8": [
		"res://assets/models/characters/character-female-b.glb",
		"res://assets/models/characters/character-male-a.glb",
		"res://assets/models/characters/character-female-e.glb",
		"res://assets/models/characters/character-male-e.glb"
	],
	"table_9": [
		"res://assets/models/characters/character-male-d.glb",
		"res://assets/models/characters/character-female-c.glb",
		"res://assets/models/characters/character-male-f.glb",
		"res://assets/models/characters/character-female-f.glb"
	]
}

var _booth_chars_setup: bool = false

func _setup_unique_booth_diners() -> void:
	if _booth_chars_setup or is_terrace_table or companion_diners == null:
		return
	_booth_chars_setup = true
	var chars = BOOTH_CHARACTERS.get(table_id, [])
	if chars.size() < 4:
		return
	
	for child in companion_diners.get_children():
		child.queue_free()
		
	var decor_script = load("res://scripts/decor_character.gd")
	var configs = [
		{"name": "DinerNorthLeft", "path": chars[0], "pos": Vector3(-0.42, 0.36, -0.68), "rot": Vector3(0, 180, 0)},
		{"name": "DinerNorthRight", "path": chars[1], "pos": Vector3(0.42, 0.36, -0.68), "rot": Vector3(0, 180, 0)},
		{"name": "DinerSouthLeft", "path": chars[2], "pos": Vector3(-0.42, 0.36, 0.68), "rot": Vector3(0, 0, 0)},
		{"name": "DinerSouthRight", "path": chars[3], "pos": Vector3(0.42, 0.36, 0.68), "rot": Vector3(0, 0, 0)}
	]
	
	for cfg in configs:
		var scn = load(cfg["path"])
		if scn != null:
			var node = scn.instantiate()
			node.name = cfg["name"]
			node.position = cfg["pos"]
			node.rotation_degrees = cfg["rot"]
			node.scale = Vector3(0.88, 0.88, 0.88)
			node.set_script(decor_script)
			node.set("anim_name", "sit")
			companion_diners.add_child(node)
			
	var plate_scn = load("res://assets/models/food/burger-cheese.glb")
	if plate_scn != null:
		var extra_plate = plate_scn.instantiate()
		extra_plate.name = "TablePlateNorth"
		extra_plate.position = Vector3(-0.25, 0.73, -0.20)
		extra_plate.scale = Vector3(0.38, 0.38, 0.38)
		add_child(extra_plate)
		
		var extra_plate2 = plate_scn.instantiate()
		extra_plate2.name = "TablePlateSouth"
		extra_plate2.position = Vector3(-0.25, 0.73, 0.20)
		extra_plate2.scale = Vector3(0.38, 0.38, 0.38)
		add_child(extra_plate2)
	
	# Ambient Tycoon Diner Speech Bubble (Matching res1_08s.jpg & res1_12s.jpg)
	var t_idx = int(table_id.trim_prefix("table_"))
	var bubble_icon = "⏳ 🍽️" if (t_idx % 2 != 0) else "⏳ 💵"
	var bubble_pos = Vector3(-0.35, 1.38, -0.65) if (t_idx % 2 != 0) else Vector3(0.35, 1.38, 0.65)
	
	booth_bubble_root = Node3D.new()
	booth_bubble_root.name = "BoothBubble"
	booth_bubble_root.position = bubble_pos
	add_child(booth_bubble_root)
	
	var b_spr = Sprite3D.new()
	b_spr.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	b_spr.double_sided = false
	b_spr.pixel_size = 0.0036
	var b_path = ProjectSettings.globalize_path("res://assets/textures/speech_bubble_pill.png")
	var b_img = Image.load_from_file(b_path)
	if b_img != null:
		b_spr.texture = ImageTexture.create_from_image(b_img)
	booth_bubble_root.add_child(b_spr)
	
	var b_lbl = Label3D.new()
	b_lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	b_lbl.double_sided = false
	b_lbl.position = Vector3(0, 0.04, 0.01)
	b_lbl.text = bubble_icon
	b_lbl.font_size = 28
	b_lbl.outline_size = 0
	b_lbl.modulate = Color(0.12, 0.14, 0.18, 1)
	booth_bubble_root.add_child(b_lbl)

func _set_unlocked_visual(lvl: int) -> void:
	is_unlocked = true
	visible = true
	if table_mesh != null: table_mesh.visible = true
	if booth_decor != null: booth_decor.visible = not is_terrace_table
	if companion_diners != null:
		companion_diners.visible = not is_terrace_table
		for c in companion_diners.get_children():
			if c.name == "DinerSouthRight" and is_occupied:
				c.visible = false
			else:
				c.visible = true
	if terrace_decor != null: terrace_decor.visible = is_terrace_table
	var show_chairs: bool = is_terrace_table
	if chair_north != null: chair_north.visible = show_chairs
	if chair_south != null: chair_south.visible = show_chairs
	if chair_east != null: chair_east.visible = show_chairs
	if chair_west != null: chair_west.visible = show_chairs
	if chair_left != null: chair_left.visible = show_chairs
	if chair_right != null: chair_right.visible = show_chairs
	if table_menu != null: table_menu.visible = true
	if salt_shaker != null: salt_shaker.visible = true
	if pepper_shaker != null: pepper_shaker.visible = true
	if pendant_lamp != null: pendant_lamp.visible = not is_terrace_table
	if table_omni_light != null: table_omni_light.visible = true
	if not is_terrace_table and food_dish != null:
		food_dish.visible = true
	_setup_unique_booth_diners()
	update_level_display(lvl)

func update_level_display(lvl: int) -> void:
	if not is_unlocked:
		return
		
	var gm = get_node_or_null("/root/GameManager")
	var can_upgrade: bool = false
	var upgrade_cost: float = 90.0
	if gm != null:
		upgrade_cost = gm.get_upgrade_cost(table_id)
		can_upgrade = gm.cash >= upgrade_cost and lvl < gm.max_level
		
	if is_dirty:
		if badge_root != null: badge_root.visible = true
		if level_label != null:
			level_label.visible = true
			level_label.text = "🧽 Dirty Table"
			level_label.font_size = 20
			level_label.modulate = Color(0.95, 0.6, 0.2, 1.0)
		if action_badge != null:
			action_badge.visible = true
			action_badge.text = "🧽 TAP TO CLEAN!"
			action_badge.modulate = Color(1.0, 0.8, 0.25, 1.0)
		return

	if is_occupied:
		if badge_root != null: badge_root.visible = false
		return

	# Idle & ready table
	if tier2_decor != null: tier2_decor.visible = lvl >= 5
	if tier3_decor != null: tier3_decor.visible = lvl >= 10
	
	if badge_root != null:
		badge_root.visible = false

func _on_table_unlocked(id: String) -> void:
	if id == table_id:
		var gm = get_node_or_null("/root/GameManager")
		var lvl = gm.get_station_level(table_id) if gm != null else 1
		_set_unlocked_visual(lvl)
		if upgrade_particles != null:
			upgrade_particles.restart()
		var tween: Tween = create_tween()
		scale = Vector3(0.3, 0.3, 0.3)
		tween.tween_property(self, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_spawn_floating_text("★ TABLE UNLOCKED! ★", Color(0.25, 1.0, 0.5, 1.0))

func _on_station_upgraded(id: String, new_lvl: int) -> void:
	if id == table_id and is_unlocked:
		update_level_display(new_lvl)
		if upgrade_particles != null:
			upgrade_particles.restart()
		_spawn_upgrade_text(new_lvl)
		var bounce_scale = Vector3(1.22, 1.22, 1.22) if (new_lvl == 5 or new_lvl == 10) else Vector3(1.14, 1.14, 1.14)
		var tween: Tween = create_tween()
		tween.tween_property(self, "scale", bounce_scale, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "scale", Vector3.ONE, 0.16)

func _spawn_upgrade_text(new_lvl: int) -> void:
	if new_lvl == 5:
		_spawn_floating_text("★ GOURMET SUITE UNLOCKED! ★", Color(1.0, 0.88, 0.2, 1.0))
	elif new_lvl == 10:
		_spawn_floating_text("👑 ROYAL VIP TABLE UNLOCKED! 👑", Color(0.95, 0.45, 1.0, 1.0))
	else:
		_spawn_floating_text("+$14 / Order! ⬆", Color(0.35, 1.0, 0.55, 1.0))

func _spawn_floating_text(txt: String, col: Color) -> void:
	var label = Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.double_sided = false
	label.font_size = 26
	label.outline_size = 7
	label.text = txt
	label.modulate = col
	label.outline_modulate = Color(0.1, 0.1, 0.1, 0.95)
	label.position = Vector3(0, 1.6, 0)
	add_child(label)
	
	var tw = create_tween()
	tw.tween_property(label, "position:y", 2.6, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.35)
	tw.tween_callback(label.queue_free)

func get_seat_position() -> Vector3:
	return seat_pos.global_position if seat_pos != null else global_position

func get_seat_rotation_y() -> float:
	return seat_pos.global_rotation.y if seat_pos != null else 0.0

func occupy(customer: Node) -> Vector3:
	is_occupied = true
	occupying_customer = customer
	var diner_sr = get_node_or_null("CompanionDiners/DinerSouthRight")
	if diner_sr != null:
		diner_sr.visible = false
	var diner_s = get_node_or_null("CompanionDiners/DinerSouth")
	if diner_s != null:
		diner_s.visible = false
	var gm = get_node_or_null("/root/GameManager")
	var lvl = gm.get_station_level(table_id) if gm != null else 1
	update_level_display(lvl)
	return get_seat_position()

const DISH_SCENES: Dictionary = {
	"burger": "res://assets/models/food/burger-cheese.glb",
	"pasta": "res://assets/models/food/bowl-broth.glb",
	"pizza": "res://assets/models/food/pizza.glb",
	"sushi": "res://assets/models/food/sushi-salmon.glb"
}

func serve_food(dish_id: String = "burger") -> void:
	_setup_dish_model(dish_id)
	if food_dish != null:
		food_dish.visible = true
		food_dish.scale = Vector3(0.1, 0.1, 0.1)
		var tween: Tween = create_tween()
		tween.tween_property(food_dish, "scale", Vector3(0.42, 0.42, 0.42), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if occupying_customer != null and is_instance_valid(occupying_customer) and occupying_customer.has_method("on_food_delivered"):
		occupying_customer.on_food_delivered()

func _setup_dish_model(dish_id: String) -> void:
	if food_dish == null:
		return
	var scn_path = DISH_SCENES.get(dish_id, DISH_SCENES["burger"])
	for c in food_dish.get_children():
		c.queue_free()
	var scn = load(scn_path)
	if scn:
		var node = scn.instantiate()
		food_dish.add_child(node)

func clear_food() -> void:
	if food_dish != null:
		food_dish.visible = false

func set_eating_progress(progress_val: float) -> void:
	if timer_ring != null:
		timer_ring.visible = true
		var mat = timer_ring.material_override
		if mat == null:
			mat = timer_ring.get_active_material(0)
		if mat is ShaderMaterial:
			mat.set_shader_parameter("progress", clamp(progress_val, 0.0, 1.0))

func hide_timer_ring() -> void:
	if timer_ring != null:
		timer_ring.visible = false

func vacate() -> void:
	hide_timer_ring()
	is_occupied = false
	occupying_customer = null
	clear_food()
	var diner_sr = get_node_or_null("CompanionDiners/DinerSouthRight")
	if diner_sr != null and not is_terrace_table:
		diner_sr.visible = true
	var diner_s = get_node_or_null("CompanionDiners/DinerSouth")
	if diner_s != null and not is_terrace_table:
		diner_s.visible = true
	
	is_dirty = true
	if dirty_dishes != null:
		dirty_dishes.visible = true
		dirty_dishes.scale = Vector3(0.1, 0.1, 0.1)
		var tw = create_tween()
		tw.tween_property(dirty_dishes, "scale", Vector3(0.44, 0.44, 0.44), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
	var gm = get_node_or_null("/root/GameManager")
	var lvl = gm.get_station_level(table_id) if gm != null else 1
	update_level_display(lvl)

func clean_table() -> void:
	if not is_dirty:
		return
	is_dirty = false
	if dirty_dishes != null:
		dirty_dishes.visible = false
	
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.add_cash(5.0, global_position + Vector3(0, 1.4, 0)) # Tap bonus!
		var lvl = gm.get_station_level(table_id)
		update_level_display(lvl)
		
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("coin", 0.05)
	_spawn_floating_text("✨ Clean & Ready! +$5 ✨", Color(0.4, 0.9, 1.0, 1.0))

func _on_input_event(_camera: Camera3D, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var gm = get_node_or_null("/root/GameManager")
		if gm == null:
			return
		if not is_unlocked:
			gm.unlock_table(table_id)
			return
		if is_dirty:
			clean_table()
			return
		var lvl: int = gm.get_station_level(table_id)
		table_clicked.emit(table_id, table_name, lvl)
