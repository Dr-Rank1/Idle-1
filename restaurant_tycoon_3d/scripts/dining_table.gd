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
var booth_cash_stack: Node3D = null
var cash_respawn_timer: float = 0.0

var highlight_ring: MeshInstance3D = null
var is_highlighted: bool = false
var highlight_time: float = 0.0

func _ready() -> void:
	if food_dish != null: food_dish.visible = false
	if dirty_dishes != null: dirty_dishes.visible = false
	if timer_ring != null: timer_ring.visible = false
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
		
	_setup_booth_materials()
	
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
	else:
		_set_unlocked_visual(1)

func _process(delta: float) -> void:
	time_passed += delta
	if badge_root != null:
		var bob = sin(time_passed * 4.0) * 0.08
		badge_root.position.y = initial_badge_y + bob
		if action_badge != null and action_badge.visible:
			var pulse = 1.0 + sin(time_passed * 6.0) * 0.12
			action_badge.scale = Vector3(pulse, pulse, pulse)
	
	var t_idx = int(table_id.trim_prefix("table_"))
	if t_idx <= 0:
		t_idx = 1
	var phi = float(t_idx) * 0.72
	if booth_cash_stack != null and booth_cash_stack.visible:
		booth_cash_stack.position.y = 1.65 + 0.05 * sin(3.2 * time_passed + phi)
	elif is_unlocked and booth_cash_stack != null and not is_dirty:
		cash_respawn_timer += delta
		if cash_respawn_timer >= 15.0:
			booth_cash_stack.visible = true
			cash_respawn_timer = 0.0

	if booth_bubble_root != null and booth_bubble_root.visible:
		booth_bubble_root.position.y = 1.70 + 0.05 * sin(2.8 * time_passed + float(t_idx) * 0.8)

	# Subtle pulsing golden floor ring highlight
	if is_highlighted and highlight_ring != null and highlight_ring.visible:
		highlight_time += delta
		var pulse_scale = 1.0 + sin(highlight_time * 4.5) * 0.05
		highlight_ring.scale = Vector3(1.25 * pulse_scale, 0.5, 1.1 * pulse_scale)
		if highlight_ring.material_override is StandardMaterial3D:
			var alpha = 0.65 + sin(highlight_time * 4.5) * 0.25
			highlight_ring.material_override.albedo_color = Color(1.0, 0.84, 0.2, alpha)

func set_highlight(active: bool) -> void:
	is_highlighted = active
	if is_highlighted:
		if highlight_ring == null:
			_create_highlight_ring()
		if highlight_ring != null:
			highlight_ring.visible = true
			highlight_time = 0.0
	else:
		if highlight_ring != null:
			highlight_ring.visible = false

func _create_highlight_ring() -> void:
	highlight_ring = MeshInstance3D.new()
	highlight_ring.name = "FloorHighlightRing"
	
	var torus = TorusMesh.new()
	torus.inner_radius = 1.35
	torus.outer_radius = 1.55
	torus.rings = 32
	torus.ring_segments = 16
	highlight_ring.mesh = torus
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(1.0, 0.84, 0.2, 0.8)
	highlight_ring.material_override = mat
	
	highlight_ring.position = Vector3(0.0, 0.04, 0.0)
	highlight_ring.scale = Vector3(1.25, 0.5, 1.1)
	add_child(highlight_ring)

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
	if booth_bubble_root != null: booth_bubble_root.visible = false
	if booth_cash_stack != null: booth_cash_stack.visible = false
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
	],
	"table_10": [
		"res://assets/models/characters/character-female-b.glb",
		"res://assets/models/characters/character-male-c.glb",
		"res://assets/models/characters/character-female-e.glb",
		"res://assets/models/characters/character-male-a.glb"
	],
	"table_11": [
		"res://assets/models/characters/character-female-d.glb",
		"res://assets/models/characters/character-male-f.glb",
		"res://assets/models/characters/character-male-b.glb",
		"res://assets/models/characters/character-female-a.glb"
	],
	"table_12": [
		"res://assets/models/characters/character-female-c.glb",
		"res://assets/models/characters/character-male-e.glb",
		"res://assets/models/characters/character-female-f.glb",
		"res://assets/models/characters/character-male-d.glb"
	]
}

var _booth_chars_setup: bool = false

func _setup_booth_materials() -> void:
	# 1. Burgundy/red vinyl benches
	var red_vinyl = StandardMaterial3D.new()
	red_vinyl.albedo_color = Color(0.82, 0.12, 0.18)
	red_vinyl.roughness = 0.45
	
	for path in [
		"BoothDecor/BenchNorthSeat",
		"BoothDecor/BenchNorthBack",
		"BoothDecor/BenchSouthSeat",
		"BoothDecor/BenchSouthBack"
	]:
		var node = get_node_or_null(path)
		if node is MeshInstance3D:
			node.material_override = red_vinyl
			
	# 2. White retro piping caps
	var white_cap = StandardMaterial3D.new()
	white_cap.albedo_color = Color(0.96, 0.96, 0.96)
	white_cap.roughness = 0.4
	
	for path in ["BoothDecor/BenchNorthCap", "BoothDecor/BenchSouthCap"]:
		var node = get_node_or_null(path)
		if node is MeshInstance3D:
			node.material_override = white_cap
			
	# 3. Cyan tabletop cloth
	var cyan_mat = StandardMaterial3D.new()
	cyan_mat.albedo_color = Color(0.12, 0.65, 0.55)
	cyan_mat.roughness = 0.5
	var cloth_node = get_node_or_null("TableCloth")
	if cloth_node is MeshInstance3D:
		cloth_node.material_override = cyan_mat
		
	# 4. Chrome rim
	var chrome_mat = StandardMaterial3D.new()
	chrome_mat.albedo_color = Color(0.92, 0.94, 0.96)
	chrome_mat.metallic = 0.85
	chrome_mat.roughness = 0.2
	var trim_node = get_node_or_null("TableChromeTrim")
	if trim_node is MeshInstance3D:
		trim_node.material_override = chrome_mat
		
	# 5. Low white divider partitions and green planters
	var partition_mat = StandardMaterial3D.new()
	partition_mat.albedo_color = Color(0.96, 0.96, 0.96)
	partition_mat.roughness = 0.55
	
	var planter_mat = StandardMaterial3D.new()
	planter_mat.albedo_color = Color(0.18, 0.48, 0.15)
	planter_mat.roughness = 0.8
	
	for p_path in ["BoothDecor/PartitionBack", "BoothDecor/PartitionFront"]:
		var p_node = get_node_or_null(p_path)
		if p_node is CSGBox3D:
			p_node.material = partition_mat
			
	for pl_path in ["BoothDecor/PartitionBack/PlanterBack", "BoothDecor/PartitionFront/PlanterFront"]:
		var pl_node = get_node_or_null(pl_path)
		if pl_node is CSGBox3D:
			pl_node.material = planter_mat
			
	# 6. Flower blossoms: red, white, yellow
	var fl_red = StandardMaterial3D.new()
	fl_red.albedo_color = Color(0.88, 0.15, 0.22)
	fl_red.roughness = 0.7
	
	var fl_white = StandardMaterial3D.new()
	fl_white.albedo_color = Color(0.98, 0.98, 0.96)
	fl_white.roughness = 0.7
	
	var fl_yellow = StandardMaterial3D.new()
	fl_yellow.albedo_color = Color(1.0, 0.82, 0.18)
	fl_yellow.roughness = 0.7
	
	var flowers_config = [
		{"path": "BoothDecor/PartitionBack/PlanterBack/FlowerB1", "mat": fl_red},
		{"path": "BoothDecor/PartitionBack/PlanterBack/FlowerB2", "mat": fl_white},
		{"path": "BoothDecor/PartitionBack/PlanterBack/FlowerB3", "mat": fl_yellow},
		{"path": "BoothDecor/PartitionBack/PlanterBack/FlowerB4", "mat": fl_red},
		{"path": "BoothDecor/PartitionBack/PlanterBack/FlowerB5", "mat": fl_white},
		{"path": "BoothDecor/PartitionFront/PlanterFront/FlowerF1", "mat": fl_white},
		{"path": "BoothDecor/PartitionFront/PlanterFront/FlowerF2", "mat": fl_red},
		{"path": "BoothDecor/PartitionFront/PlanterFront/FlowerF3", "mat": fl_yellow},
		{"path": "BoothDecor/PartitionFront/PlanterFront/FlowerF4", "mat": fl_white},
		{"path": "BoothDecor/PartitionFront/PlanterFront/FlowerF5", "mat": fl_red}
	]
	for fc in flowers_config:
		var f_node = get_node_or_null(fc["path"])
		if f_node is MeshInstance3D:
			f_node.material_override = fc["mat"]

func _setup_unique_booth_diners() -> void:
	if _booth_chars_setup or companion_diners == null:
		return
	_booth_chars_setup = true
	var chars = BOOTH_CHARACTERS.get(table_id, [
		"res://assets/models/characters/character-female-a.glb",
		"res://assets/models/characters/character-male-a.glb",
		"res://assets/models/characters/character-female-b.glb",
		"res://assets/models/characters/character-male-b.glb"
	])
	
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
	
	# Ambient Tycoon Diner Speech Bubble (Matching crop_dining_08s.jpg)
	var t_idx = int(table_id.trim_prefix("table_"))
	if t_idx <= 0:
		t_idx = 1
	var bubble_pos = Vector3(0.0, 1.70, -0.32 if (t_idx % 2 != 0) else 0.32)
	
	if booth_bubble_root == null:
		booth_bubble_root = Node3D.new()
		booth_bubble_root.name = "BoothBubble"
		add_child(booth_bubble_root)
	booth_bubble_root.position = bubble_pos
	
	for c in booth_bubble_root.get_children():
		c.queue_free()
		
	# Circular Icon Bubble (Fork & Knife or Hourglass matching crop_dining_08s.jpg)
	var b_spr = Sprite3D.new()
	b_spr.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	b_spr.double_sided = false
	b_spr.pixel_size = 0.0030
	var icon_name = "bubble_fork_knife.png" if (t_idx % 2 != 0) else "bubble_hourglass.png"
	var b_path = ProjectSettings.globalize_path("res://assets/textures/" + icon_name)
	var b_img = Image.load_from_file(b_path)
	if b_img != null:
		b_spr.texture = ImageTexture.create_from_image(b_img)
	booth_bubble_root.add_child(b_spr)
	
	# Floating Green Cash Stack Graphic at the aisle edge (matching crop_dining_08s.jpg)
	if booth_cash_stack == null:
		booth_cash_stack = Node3D.new()
		booth_cash_stack.name = "BoothCashStack"
		add_child(booth_cash_stack)
	booth_cash_stack.position = Vector3(-1.15, 1.65, 0.0)
	
	for c in booth_cash_stack.get_children():
		c.queue_free()
		
	var cash_spr = Sprite3D.new()
	cash_spr.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	cash_spr.double_sided = false
	cash_spr.pixel_size = 0.0022
	cash_spr.position = Vector3(-0.25, 0.0, 0.0)
	var c_path = ProjectSettings.globalize_path("res://assets/textures/bubble_cash_stack.png")
	var c_img = Image.load_from_file(c_path)
	if c_img != null:
		cash_spr.texture = ImageTexture.create_from_image(c_img)
	booth_cash_stack.add_child(cash_spr)
	
	var cash_lbl = Label3D.new()
	cash_lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	cash_lbl.double_sided = false
	cash_lbl.position = Vector3(0.35, 0.0, 0.01)
	var amounts = ["$100", "$2.8T", "$172T", "$1.03T"]
	cash_lbl.text = amounts[(t_idx - 1) % amounts.size()]
	cash_lbl.font_size = 28
	cash_lbl.outline_size = 7
	cash_lbl.modulate = Color(1.0, 1.0, 1.0, 1.0)
	cash_lbl.outline_modulate = Color(0.06, 0.14, 0.06, 0.95)
	booth_cash_stack.add_child(cash_lbl)

func _set_unlocked_visual(lvl: int) -> void:
	is_unlocked = true
	visible = true
	if table_mesh != null: table_mesh.visible = true
	if booth_decor != null: booth_decor.visible = true
	if companion_diners != null:
		companion_diners.visible = true
		for c in companion_diners.get_children():
			if c.name == "DinerSouthRight" and is_occupied:
				c.visible = false
			else:
				c.visible = true
	if terrace_decor != null: terrace_decor.visible = false
	if chair_north != null: chair_north.visible = false
	if chair_south != null: chair_south.visible = false
	if chair_east != null: chair_east.visible = false
	if chair_west != null: chair_west.visible = false
	if chair_left != null: chair_left.visible = false
	if chair_right != null: chair_right.visible = false
	if table_menu != null: table_menu.visible = true
	if salt_shaker != null: salt_shaker.visible = true
	if pepper_shaker != null: pepper_shaker.visible = true
	if pendant_lamp != null: pendant_lamp.visible = true
	if table_omni_light != null: table_omni_light.visible = true
	if food_dish != null:
		food_dish.visible = true
	_setup_booth_materials()
	_setup_unique_booth_diners()
	if booth_bubble_root != null:
		booth_bubble_root.visible = not is_occupied
	if booth_cash_stack != null:
		booth_cash_stack.visible = true
	update_level_display(lvl)

func update_level_display(lvl: int) -> void:
	if not is_unlocked:
		return
		
	var gm = get_node_or_null("/root/GameManager")
	var can_upgrade: bool = false
	var upgrade_cost: float = 90.0
	if gm != null:
		upgrade_cost = gm.get_upgrade_cost(table_id)
		can_upgrade = gm.cash >= upgrade_cost and lvl < gm.get_station_max_level(table_id)
		
	if is_dirty:
		if badge_root != null:
			badge_root.visible = true
			badge_root.position.y = initial_badge_y
		if level_label != null:
			level_label.visible = true
			level_label.text = "🧽 Dirty Table"
			level_label.font_size = 24
			level_label.outline_size = 6
			level_label.modulate = Color(1.0, 0.72, 0.2, 1.0)
			level_label.outline_modulate = Color(0.2, 0.1, 0.0, 0.95)
		if action_badge != null:
			action_badge.visible = true
			action_badge.text = "🧽 Clean Table"
			action_badge.font_size = 18
			action_badge.outline_size = 5
			action_badge.modulate = Color(1.0, 0.85, 0.35, 1.0)
			action_badge.position = Vector3(0, -0.32, 0)
		return

	if action_badge != null:
		action_badge.visible = false

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
	if booth_bubble_root != null:
		booth_bubble_root.visible = false
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
	if diner_sr != null:
		diner_sr.visible = true
	var diner_s = get_node_or_null("CompanionDiners/DinerSouth")
	if diner_s != null:
		diner_s.visible = true
	if booth_bubble_root != null:
		booth_bubble_root.visible = false
	
	is_dirty = true
	_spawn_dirty_dishes()
		
	var gm = get_node_or_null("/root/GameManager")
	var lvl = gm.get_station_level(table_id) if gm != null else 1
	update_level_display(lvl)

func _spawn_dirty_dishes() -> void:
	if dirty_dishes == null:
		var dirty_scn = load("res://assets/kaykit_restaurant/gltf/plate_dirty.gltf")
		if dirty_scn != null:
			dirty_dishes = dirty_scn.instantiate()
			dirty_dishes.name = "DirtyDishes"
			dirty_dishes.position = Vector3(0, 0.73, 0)
			add_child(dirty_dishes)
	if dirty_dishes != null:
		dirty_dishes.visible = true
		dirty_dishes.position = Vector3(0, 0.73, 0)
		dirty_dishes.scale = Vector3(0.08, 0.08, 0.08)
		var tw = create_tween()
		tw.tween_property(dirty_dishes, "scale", Vector3(0.44, 0.44, 0.44), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func clean_table() -> void:
	if not is_dirty:
		return
	is_dirty = false
	
	if dirty_dishes != null:
		var tw = create_tween()
		tw.tween_property(dirty_dishes, "scale", Vector3(0.05, 0.05, 0.05), 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_callback(func():
			if is_instance_valid(dirty_dishes):
				dirty_dishes.visible = false
		)
	
	if badge_root != null:
		badge_root.visible = false
	if action_badge != null:
		action_badge.visible = false
	if booth_bubble_root != null:
		booth_bubble_root.visible = true
	if booth_cash_stack != null:
		booth_cash_stack.visible = true
	
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.add_cash(10.0, global_position + Vector3(0, 1.6, 0)) # Bussing revenue
		var lvl = gm.get_station_level(table_id)
		update_level_display(lvl)
		
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("coin", 0.05, 1.15)
	_spawn_floating_text("✨ Table Reset! +$10 ✨", Color(0.35, 1.0, 0.55, 1.0))

func has_visible_cash_stack() -> bool:
	return is_unlocked and booth_cash_stack != null and booth_cash_stack.visible

func get_cash_stack_world_pos() -> Vector3:
	if booth_cash_stack != null and is_instance_valid(booth_cash_stack):
		return booth_cash_stack.global_position
	return global_position + Vector3(-1.15, 1.65, 0.0)

func collect_booth_cash() -> float:
	if not has_visible_cash_stack():
		return 0.0
	booth_cash_stack.visible = false
	var amount: float = 50.0
	var gm = get_node_or_null("/root/GameManager")
	if gm != null and gm.has_method("get_card_tip_multiplier"):
		amount = round(amount * gm.get_card_tip_multiplier())
	var c_pos: Vector3 = get_cash_stack_world_pos()
	
	var rest = find_parent("Restaurant")
	if rest != null and rest.has_method("register_cash_collection"):
		rest.register_cash_collection(c_pos, amount)
	else:
		if gm != null:
			gm.add_cash(amount, c_pos)
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("coin", 0.04, 1.0)
			
	_spawn_floating_text("💵 +$%d COLLECTED! ✨" % int(amount), Color(0.35, 1.0, 0.55))
	return amount

func _on_input_event(_camera: Camera3D, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) \
		or (event is InputEventScreenTouch and event.pressed) \
		or (event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0) \
		or (event is InputEventScreenDrag):
		if has_visible_cash_stack():
			collect_booth_cash()
			return

	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) \
		or (event is InputEventScreenTouch and event.pressed):
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
