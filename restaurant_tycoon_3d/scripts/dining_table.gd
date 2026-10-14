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
	else:
		if terrace_decor != null: terrace_decor.visible = false
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
			update_level_display(gm.get_station_level(table_id))
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

func _on_cash_changed(_cash_val: float) -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm != null and is_unlocked and not is_dirty and not is_occupied:
		var lvl = gm.get_station_level(table_id)
		update_level_display(lvl)

func _set_locked_visual(cost: float) -> void:
	is_unlocked = false
	visible = false
	if booth_decor != null: booth_decor.visible = false
	if companion_diners != null: companion_diners.visible = false
	if terrace_decor != null: terrace_decor.visible = false

func _set_unlocked_visual(lvl: int) -> void:
	is_unlocked = true
	visible = true
	if table_mesh != null: table_mesh.visible = true
	if booth_decor != null: booth_decor.visible = not is_terrace_table
	if companion_diners != null: companion_diners.visible = not is_terrace_table
	if terrace_decor != null: terrace_decor.visible = is_terrace_table
	if chair_north != null: chair_north.visible = true
	if chair_south != null: chair_south.visible = true
	if chair_east != null: chair_east.visible = true
	if chair_west != null: chair_west.visible = true
	if chair_left != null: chair_left.visible = true
	if chair_right != null: chair_right.visible = true
	if table_menu != null: table_menu.visible = true
	if salt_shaker != null: salt_shaker.visible = true
	if pepper_shaker != null: pepper_shaker.visible = true
	if pendant_lamp != null: pendant_lamp.visible = not is_terrace_table
	if table_omni_light != null: table_omni_light.visible = true
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
	return seat_pos.global_rotation.y if seat_pos != null else (PI * 0.5)

func occupy(customer: Node) -> Vector3:
	is_occupied = true
	occupying_customer = customer
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
