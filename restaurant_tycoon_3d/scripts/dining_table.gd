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

# ─── Mobile 3D Floor Idle Widgets ───────────────────────────────────────────
var floor_level_pad: Node3D = null
var floor_lvl_label: Label3D = null
var progress_trough: MeshInstance3D = null
var progress_fill: MeshInstance3D = null
var upgrade_arrow: Node3D = null
var can_upgrade_station: bool = false

# Physical 3D Cash Stacks
var cash_mat: Node3D = null
var cash_bricks_container: Node3D = null
var cash_stack_label: Label3D = null
var current_cash_bricks: int = 0

# Locked Construction Zone
var locked_zone_root: Node3D = null
var locked_price_badge: Node3D = null
var locked_price_label: Label3D = null
var hologram_booth: Node3D = null
var current_unlock_cost: float = 0.0

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
	
	# Idle cash respawn
	if is_unlocked and booth_cash_stack != null and not is_dirty:
		if not booth_cash_stack.visible:
			cash_respawn_timer += delta
			if cash_respawn_timer >= 15.0:
				_populate_cash_bricks(randi_range(3, 6))
				booth_cash_stack.visible = true
				cash_respawn_timer = 0.0
		elif cash_stack_label != null:
			cash_stack_label.position.y = 0.45 + 0.04 * sin(3.0 * time_passed + phi)

	if booth_bubble_root != null and booth_bubble_root.visible:
		booth_bubble_root.position.y = 1.70 + 0.05 * sin(2.8 * time_passed + float(t_idx) * 0.8)

	# Dynamic animation for locked blueprint hologram & build price button
	if not is_unlocked:
		if hologram_booth != null and is_instance_valid(hologram_booth):
			hologram_booth.rotation.y += delta * 0.85
		if locked_price_badge != null and locked_price_badge.visible:
			locked_price_badge.position.y = 1.45 + 0.08 * sin(time_passed * 4.5)
			var gm = get_node_or_null("/root/GameManager")
			var can_afford = (gm != null and gm.cash >= current_unlock_cost)
			if can_afford:
				var pulse = 1.0 + sin(time_passed * 6.0) * 0.06
				locked_price_badge.scale = Vector3(pulse, pulse, pulse)
			else:
				locked_price_badge.scale = Vector3.ONE

	# Dynamic animation for floor level pad & green upgrade arrow
	if is_unlocked and floor_level_pad != null and floor_level_pad.visible:
		if can_upgrade_station and not is_dirty:
			var pad_pulse = 1.0 + sin(time_passed * 5.0) * 0.06
			floor_level_pad.scale = Vector3(pad_pulse, 1.0, pad_pulse)
			if upgrade_arrow != null:
				upgrade_arrow.visible = true
				upgrade_arrow.position.y = 0.42 + 0.08 * sin(time_passed * 6.5)
				upgrade_arrow.rotation.y = sin(time_passed * 2.5) * 0.25
		else:
			floor_level_pad.scale = Vector3.ONE
			if upgrade_arrow != null:
				upgrade_arrow.visible = false

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
		if is_unlocked:
			var lvl = gm.get_station_level(table_id)
			_update_floor_level_pad(lvl)
			if not is_dirty and not is_occupied:
				update_level_display(lvl)
		elif not is_unlocked:
			var cost = gm.get_table_unlock_cost(table_id)
			current_unlock_cost = cost
			var can_afford = (gm.cash >= cost)
			if locked_price_badge != null:
				var bg = locked_price_badge.get_node_or_null("ButtonBg")
				if bg is MeshInstance3D and bg.material_override is StandardMaterial3D:
					bg.material_override.albedo_color = Color(0.22, 0.88, 0.35) if can_afford else Color(0.88, 0.35, 0.25)
				var bev = locked_price_badge.get_node_or_null("ButtonBevel")
				if bev is MeshInstance3D and bev.material_override is StandardMaterial3D:
					bev.material_override.albedo_color = Color(0.10, 0.52, 0.18) if can_afford else Color(0.55, 0.16, 0.12)
			if locked_price_label != null:
				locked_price_label.text = "BUILD  $%d" % round(cost)
				locked_price_label.outline_modulate = Color(0.06, 0.20, 0.08, 0.95) if can_afford else Color(0.20, 0.06, 0.06, 0.95)
			if action_badge != null:
				action_badge.text = "BUILD ($%d)" % round(cost)
				action_badge.modulate = Color(0.35, 1.0, 0.55) if can_afford else Color(1.0, 0.45, 0.45)

func _set_locked_visual(cost: float) -> void:
	is_unlocked = false
	visible = true
	current_unlock_cost = cost
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
	if floor_level_pad != null: floor_level_pad.visible = false
	if badge_root != null:
		badge_root.visible = false
		
	_setup_locked_zone(cost)

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
	red_vinyl.albedo_color = Color(0.85, 0.14, 0.20)
	red_vinyl.roughness = 0.40
	red_vinyl.rim_enabled = true
	red_vinyl.rim = 0.35
	
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
	cyan_mat.albedo_color = Color(0.14, 0.70, 0.60)
	cyan_mat.roughness = 0.38
	cyan_mat.rim_enabled = true
	cyan_mat.rim = 0.35
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
			_apply_toy_mobile_styling_to_character(node)
			
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
	
	# Physical 3D Stacking Cash on Collection Mat (Mobile Idle Style)
	_setup_3d_cash_stack()

func _create_cash_brick() -> Node3D:
	var brick = Node3D.new()
	var bill = MeshInstance3D.new()
	var b_box = BoxMesh.new()
	b_box.size = Vector3(0.20, 0.042, 0.11)
	bill.mesh = b_box
	var bill_mat = StandardMaterial3D.new()
	bill_mat.albedo_color = Color(0.18, 0.68, 0.30)
	bill_mat.roughness = 0.45
	bill.material_override = bill_mat
	brick.add_child(bill)
	
	var band = MeshInstance3D.new()
	var band_box = BoxMesh.new()
	band_box.size = Vector3(0.05, 0.045, 0.114)
	band.mesh = band_box
	var band_mat = StandardMaterial3D.new()
	band_mat.albedo_color = Color(0.96, 0.94, 0.88)
	band.material_override = band_mat
	brick.add_child(band)
	return brick

func _setup_3d_cash_stack() -> void:
	if booth_cash_stack != null and is_instance_valid(booth_cash_stack):
		booth_cash_stack.queue_free()
		
	booth_cash_stack = Node3D.new()
	booth_cash_stack.name = "BoothCashStack"
	booth_cash_stack.position = Vector3(-1.15, 0.02, 0.15)
	add_child(booth_cash_stack)
	
	# Collection Mat
	var mat_mesh = MeshInstance3D.new()
	var m_box = BoxMesh.new()
	m_box.size = Vector3(0.56, 0.02, 0.44)
	mat_mesh.mesh = m_box
	var mat_mat = StandardMaterial3D.new()
	mat_mat.albedo_color = Color(0.08, 0.30, 0.16)
	mat_mat.roughness = 0.6
	mat_mesh.material_override = mat_mat
	booth_cash_stack.add_child(mat_mesh)
	
	# Gold border trim around mat
	var rim_mesh = MeshInstance3D.new()
	var r_box = BoxMesh.new()
	r_box.size = Vector3(0.58, 0.018, 0.46)
	rim_mesh.mesh = r_box
	rim_mesh.position = Vector3(0.0, -0.002, 0.0)
	var rim_mat = StandardMaterial3D.new()
	rim_mat.albedo_color = Color(0.95, 0.82, 0.22)
	rim_mat.metallic = 0.8
	rim_mat.roughness = 0.25
	rim_mesh.material_override = rim_mat
	booth_cash_stack.add_child(rim_mesh)
	
	# Container for the 3D brick grid
	cash_bricks_container = Node3D.new()
	cash_bricks_container.name = "CashBricksContainer"
	booth_cash_stack.add_child(cash_bricks_container)
	
	# Floating cash badge label
	cash_stack_label = Label3D.new()
	cash_stack_label.name = "CashStackLabel"
	cash_stack_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	cash_stack_label.double_sided = false
	cash_stack_label.font_size = 28
	cash_stack_label.outline_size = 7
	cash_stack_label.position = Vector3(0.0, 0.45, 0.0)
	cash_stack_label.modulate = Color(0.35, 1.0, 0.55)
	cash_stack_label.outline_modulate = Color(0.04, 0.16, 0.06, 0.95)
	
	var t_idx = int(table_id.trim_prefix("table_"))
	if t_idx <= 0: t_idx = 1
	var amounts = ["$50", "$120", "$350", "$750"]
	cash_stack_label.text = amounts[(t_idx - 1) % amounts.size()]
	booth_cash_stack.add_child(cash_stack_label)
	
	_populate_cash_bricks(4)

func _populate_cash_bricks(count: int) -> void:
	if cash_bricks_container == null:
		return
	for c in cash_bricks_container.get_children():
		c.queue_free()
	current_cash_bricks = count
	var grid_slots = [
		Vector3(-0.11, 0.0, -0.09),
		Vector3(0.11, 0.0, -0.09),
		Vector3(-0.11, 0.0, 0.09),
		Vector3(0.11, 0.0, 0.09)
	]
	for i in range(count):
		var brick = _create_cash_brick()
		var slot_idx = i % 4
		var layer = i / 4
		var base_p = grid_slots[slot_idx]
		brick.position = Vector3(base_p.x, 0.02 + float(layer) * 0.045, base_p.z)
		brick.rotation.y = randf_range(-0.08, 0.08)
		cash_bricks_container.add_child(brick)

func _setup_floor_level_pad() -> void:
	if floor_level_pad != null and is_instance_valid(floor_level_pad):
		return
	floor_level_pad = Node3D.new()
	floor_level_pad.name = "FloorLevelPad"
	floor_level_pad.position = Vector3(-1.05, 0.02, -0.65)
	add_child(floor_level_pad)
	
	# 1. Rounded Plaque Base
	var plaque_mesh = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.34
	cyl.bottom_radius = 0.36
	cyl.height = 0.032
	cyl.radial_segments = 24
	plaque_mesh.mesh = cyl
	var slate_mat = StandardMaterial3D.new()
	slate_mat.albedo_color = Color(0.12, 0.15, 0.22)
	slate_mat.roughness = 0.4
	plaque_mesh.material_override = slate_mat
	floor_level_pad.add_child(plaque_mesh)
	
	# Plaque Rim Ring
	var rim_mesh = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 0.33
	torus.outer_radius = 0.37
	torus.rings = 24
	torus.ring_segments = 12
	rim_mesh.mesh = torus
	rim_mesh.position = Vector3(0.0, 0.015, 0.0)
	var rim_mat = StandardMaterial3D.new()
	rim_mat.albedo_color = Color(1.0, 0.82, 0.22)
	rim_mat.metallic = 0.85
	rim_mat.roughness = 0.2
	rim_mesh.material_override = rim_mat
	floor_level_pad.add_child(rim_mesh)
	
	# 2. 3D Level Label
	floor_lvl_label = Label3D.new()
	floor_lvl_label.name = "FloorLevelLabel"
	floor_lvl_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	floor_lvl_label.double_sided = false
	floor_lvl_label.position = Vector3(0.0, 0.16, -0.06)
	floor_lvl_label.font_size = 32
	floor_lvl_label.outline_size = 8
	floor_lvl_label.text = "Lv. 1"
	floor_lvl_label.modulate = Color.WHITE
	floor_lvl_label.outline_modulate = Color(0.05, 0.05, 0.10, 0.95)
	floor_level_pad.add_child(floor_lvl_label)
	
	# 3. Thick 3D Progress Bar
	var prog_root = Node3D.new()
	prog_root.position = Vector3(0.0, 0.026, 0.12)
	floor_level_pad.add_child(prog_root)
	
	progress_trough = MeshInstance3D.new()
	var trough_box = BoxMesh.new()
	trough_box.size = Vector3(0.46, 0.024, 0.08)
	progress_trough.mesh = trough_box
	var trough_mat = StandardMaterial3D.new()
	trough_mat.albedo_color = Color(0.08, 0.09, 0.13)
	progress_trough.material_override = trough_mat
	prog_root.add_child(progress_trough)
	
	progress_fill = MeshInstance3D.new()
	var fill_box = BoxMesh.new()
	fill_box.size = Vector3(0.12, 0.028, 0.065)
	progress_fill.mesh = fill_box
	var fill_mat = StandardMaterial3D.new()
	fill_mat.albedo_color = Color(0.12, 0.88, 0.98)
	fill_mat.emission_enabled = true
	fill_mat.emission = Color(0.08, 0.65, 0.75)
	fill_mat.emission_energy_multiplier = 0.5
	progress_fill.material_override = fill_mat
	prog_root.add_child(progress_fill)
	
	# 4. Chunky 3D Green Upward Arrow
	upgrade_arrow = Node3D.new()
	upgrade_arrow.name = "UpgradeArrow"
	upgrade_arrow.position = Vector3(0.0, 0.42, 0.0)
	upgrade_arrow.visible = false
	
	var arrow_head = MeshInstance3D.new()
	var head_prism = PrismMesh.new()
	head_prism.size = Vector3(0.24, 0.22, 0.10)
	arrow_head.mesh = head_prism
	
	var arrow_shaft = MeshInstance3D.new()
	var shaft_box = BoxMesh.new()
	shaft_box.size = Vector3(0.09, 0.12, 0.08)
	arrow_shaft.mesh = shaft_box
	arrow_shaft.position = Vector3(0.0, -0.11, 0.0)
	
	var arrow_mat = StandardMaterial3D.new()
	arrow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	arrow_mat.albedo_color = Color(0.25, 1.0, 0.35)
	arrow_head.material_override = arrow_mat
	arrow_shaft.material_override = arrow_mat
	
	upgrade_arrow.add_child(arrow_head)
	upgrade_arrow.add_child(arrow_shaft)
	floor_level_pad.add_child(upgrade_arrow)

func _update_floor_level_pad(lvl: int) -> void:
	if floor_level_pad == null:
		_setup_floor_level_pad()
	if floor_lvl_label != null:
		floor_lvl_label.text = "Lv. %d" % lvl
		
	var ratio: float = 1.0
	if lvl < 10:
		ratio = float(lvl) / 10.0
	elif lvl < 25:
		ratio = float(lvl - 10) / 15.0
	elif lvl < 50:
		ratio = float(lvl - 25) / 25.0
	ratio = clamp(ratio, 0.08, 1.0)
	
	var fill_width = 0.44 * ratio
	if progress_fill != null and progress_fill.mesh is BoxMesh:
		progress_fill.mesh.size.x = fill_width
		progress_fill.position.x = -0.22 + fill_width * 0.5
		if progress_fill.material_override is StandardMaterial3D:
			var mat = progress_fill.material_override
			if lvl >= 50:
				mat.albedo_color = Color(1.0, 0.84, 0.18)
				mat.emission = Color(0.85, 0.65, 0.10)
			elif lvl >= 25:
				mat.albedo_color = Color(1.0, 0.72, 0.20)
				mat.emission = Color(0.80, 0.50, 0.10)
			else:
				mat.albedo_color = Color(0.12, 0.88, 0.98)
				mat.emission = Color(0.08, 0.65, 0.75)
				
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		var cost = gm.get_upgrade_cost(table_id)
		var max_lvl = gm.get_station_max_level(table_id)
		can_upgrade_station = (gm.cash >= cost and lvl < max_lvl)
	else:
		can_upgrade_station = false
		
	if upgrade_arrow != null:
		upgrade_arrow.visible = can_upgrade_station and is_unlocked and not is_dirty

func _setup_locked_zone(cost: float) -> void:
	if locked_zone_root != null and is_instance_valid(locked_zone_root):
		locked_zone_root.queue_free()
		
	current_unlock_cost = cost
	locked_zone_root = Node3D.new()
	locked_zone_root.name = "LockedZoneRoot"
	add_child(locked_zone_root)
	
	# 1. Glowing Cyan Architectural Blueprint Floor Pad
	var blueprint_pad = MeshInstance3D.new()
	blueprint_pad.name = "BlueprintPad"
	var pad_box = BoxMesh.new()
	pad_box.size = Vector3(2.5, 0.02, 2.1)
	blueprint_pad.mesh = pad_box
	
	var bp_mat = ShaderMaterial.new()
	var bp_shader = Shader.new()
	bp_shader.code = """
	shader_type spatial;
	render_mode unshaded;
	void fragment() {
		vec2 uv = UV * vec2(10.0, 8.4);
		vec2 g = abs(fract(uv - 0.5) - 0.5) / fwidth(uv);
		float line = min(g.x, g.y);
		float grid_line = 1.0 - min(line, 1.0);
		
		float b_dist = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
		float border = step(b_dist, 0.035);
		
		vec3 deep_blue = vec3(0.04, 0.16, 0.32);
		vec3 cyan_glow = vec3(0.0, 0.85, 1.0);
		vec3 white_line = vec3(0.92, 0.98, 1.0);
		
		vec3 col = mix(deep_blue, cyan_glow, grid_line * 0.45);
		col = mix(col, white_line, border * 0.85);
		ALBEDO = col;
	}
	"""
	bp_mat.shader = bp_shader
	blueprint_pad.material_override = bp_mat
	blueprint_pad.position = Vector3(0.0, 0.012, 0.0)
	locked_zone_root.add_child(blueprint_pad)
	
	# 2. Dashed White Measurement Lines & Technical Labels
	var dim_label_front = Label3D.new()
	dim_label_front.name = "DimLabelFront"
	dim_label_front.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	dim_label_front.double_sided = false
	dim_label_front.font_size = 18
	dim_label_front.outline_size = 4
	dim_label_front.text = "📐 2.40m × 2.10m  [BOOTH SPEC]"
	dim_label_front.modulate = Color(0.2, 0.9, 1.0, 0.9)
	dim_label_front.outline_modulate = Color(0.02, 0.08, 0.16, 0.95)
	dim_label_front.position = Vector3(0.0, 0.14, 1.02)
	locked_zone_root.add_child(dim_label_front)
	
	for c_pos in [Vector3(-1.18, 0.02, -0.98), Vector3(1.18, 0.02, -0.98), Vector3(-1.18, 0.02, 0.98), Vector3(1.18, 0.02, 0.98)]:
		var corner_mark = MeshInstance3D.new()
		var c_box = BoxMesh.new()
		c_box.size = Vector3(0.14, 0.01, 0.14)
		corner_mark.mesh = c_box
		var cm_mat = StandardMaterial3D.new()
		cm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		cm_mat.albedo_color = Color(0.0, 0.9, 1.0, 0.95)
		corner_mark.material_override = cm_mat
		corner_mark.position = c_pos
		locked_zone_root.add_child(corner_mark)

	# 3. Rotating 3D Translucent Hologram Preview of the Booth
	hologram_booth = Node3D.new()
	hologram_booth.name = "HologramBooth"
	
	var holo_mat = StandardMaterial3D.new()
	holo_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	holo_mat.albedo_color = Color(0.0, 0.85, 1.0, 0.40)
	holo_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	holo_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	holo_mat.emission_enabled = true
	holo_mat.emission = Color(0.0, 0.65, 0.95)
	holo_mat.emission_energy_multiplier = 0.5
	
	# Hologram Tabletop
	var h_top = MeshInstance3D.new()
	var top_box = BoxMesh.new()
	top_box.size = Vector3(1.2, 0.05, 0.8)
	h_top.mesh = top_box
	h_top.material_override = holo_mat
	h_top.position = Vector3(0.0, 0.72, 0.0)
	hologram_booth.add_child(h_top)
	
	# Hologram Table Pedestal
	var h_ped = MeshInstance3D.new()
	var ped_cyl = CylinderMesh.new()
	ped_cyl.top_radius = 0.06
	ped_cyl.bottom_radius = 0.06
	ped_cyl.height = 0.72
	h_ped.mesh = ped_cyl
	h_ped.material_override = holo_mat
	h_ped.position = Vector3(0.0, 0.36, 0.0)
	hologram_booth.add_child(h_ped)
	
	# Hologram North Bench Seat & Back
	var h_n_seat = MeshInstance3D.new()
	var ns_box = BoxMesh.new()
	ns_box.size = Vector3(1.4, 0.42, 0.4)
	h_n_seat.mesh = ns_box
	h_n_seat.material_override = holo_mat
	h_n_seat.position = Vector3(0.0, 0.21, -0.68)
	hologram_booth.add_child(h_n_seat)
	
	var h_n_back = MeshInstance3D.new()
	var nb_box = BoxMesh.new()
	nb_box.size = Vector3(1.4, 0.75, 0.14)
	h_n_back.mesh = nb_box
	h_n_back.material_override = holo_mat
	h_n_back.position = Vector3(0.0, 0.58, -0.85)
	hologram_booth.add_child(h_n_back)
	
	# Hologram South Bench Seat & Back
	var h_s_seat = MeshInstance3D.new()
	var ss_box = BoxMesh.new()
	ss_box.size = Vector3(1.4, 0.42, 0.4)
	h_s_seat.mesh = ss_box
	h_s_seat.material_override = holo_mat
	h_s_seat.position = Vector3(0.0, 0.21, 0.68)
	hologram_booth.add_child(h_s_seat)
	
	var h_s_back = MeshInstance3D.new()
	var sb_box = BoxMesh.new()
	sb_box.size = Vector3(1.4, 0.75, 0.14)
	h_s_back.mesh = sb_box
	h_s_back.material_override = holo_mat
	h_s_back.position = Vector3(0.0, 0.58, 0.85)
	hologram_booth.add_child(h_s_back)
	
	locked_zone_root.add_child(hologram_booth)

	# 4. Floating 3D Beveled Green Price Button
	locked_price_badge = Node3D.new()
	locked_price_badge.name = "LockedPriceBadge"
	locked_price_badge.position = Vector3(0.0, 1.45, 0.0)
	
	var gm = get_node_or_null("/root/GameManager")
	var can_afford = (gm != null and gm.cash >= cost)
	
	var btn_bg = MeshInstance3D.new()
	btn_bg.name = "ButtonBg"
	var btn_box = BoxMesh.new()
	btn_box.size = Vector3(1.5, 0.38, 0.08)
	btn_bg.mesh = btn_box
	var btn_mat = StandardMaterial3D.new()
	btn_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	btn_mat.albedo_color = Color(0.22, 0.88, 0.35) if can_afford else Color(0.88, 0.35, 0.25)
	btn_bg.material_override = btn_mat
	locked_price_badge.add_child(btn_bg)
	
	var bevel = MeshInstance3D.new()
	bevel.name = "ButtonBevel"
	var bevel_box = BoxMesh.new()
	bevel_box.size = Vector3(1.5, 0.08, 0.082)
	bevel.mesh = bevel_box
	bevel.position = Vector3(0.0, -0.15, 0.0)
	var bev_mat = StandardMaterial3D.new()
	bev_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bev_mat.albedo_color = Color(0.10, 0.52, 0.18) if can_afford else Color(0.55, 0.16, 0.12)
	bevel.material_override = bev_mat
	locked_price_badge.add_child(bevel)
	
	locked_price_label = Label3D.new()
	locked_price_label.name = "LockedPriceLabel"
	locked_price_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	locked_price_label.double_sided = false
	locked_price_label.font_size = 32
	locked_price_label.outline_size = 8
	locked_price_label.text = "BUILD  $%d" % round(cost)
	locked_price_label.modulate = Color.WHITE
	locked_price_label.outline_modulate = Color(0.06, 0.20, 0.08, 0.95) if can_afford else Color(0.20, 0.06, 0.06, 0.95)
	locked_price_label.position = Vector3(0.0, 0.02, 0.05)
	locked_price_badge.add_child(locked_price_label)
	
	locked_zone_root.add_child(locked_price_badge)

func _spawn_unlock_particles() -> void:
	var burst = CPUParticles3D.new()
	burst.name = "UnlockBurstParticles"
	burst.emitting = true
	burst.one_shot = true
	burst.amount = 36
	burst.lifetime = 1.4
	burst.explosiveness = 0.95
	burst.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	burst.emission_sphere_radius = 0.5
	burst.direction = Vector3(0, 1, 0)
	burst.spread = 80.0
	burst.gravity = Vector3(0.0, -3.2, 0.0)
	burst.initial_velocity_min = 3.0
	burst.initial_velocity_max = 6.0
	burst.scale_amount_min = 0.08
	burst.scale_amount_max = 0.24
	burst.color = Color(1.0, 0.88, 0.22)
	burst.position = Vector3(0.0, 0.6, 0.0)
	add_child(burst)
	
	var t = get_tree().create_timer(2.0)
	t.timeout.connect(func():
		if is_instance_valid(burst):
			burst.queue_free()
	)

func _set_unlocked_visual(lvl: int) -> void:
	is_unlocked = true
	visible = true
	if locked_zone_root != null and is_instance_valid(locked_zone_root):
		locked_zone_root.queue_free()
		locked_zone_root = null
		
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
	apply_visual_tier(lvl)
	if booth_bubble_root != null:
		booth_bubble_root.visible = not is_occupied
	if booth_cash_stack != null:
		booth_cash_stack.visible = true
	_setup_floor_level_pad()
	_update_floor_level_pad(lvl)
	update_level_display(lvl)

func update_level_display(lvl: int) -> void:
	if not is_unlocked:
		return
		
	_update_floor_level_pad(lvl)
	
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
		
		# 1. Spawn smoke & star burst particle explosion
		_spawn_unlock_particles()
		
		# 2. Hologram dissolve upward wipe
		if hologram_booth != null and is_instance_valid(hologram_booth):
			var holo = hologram_booth
			hologram_booth = null
			var tw_holo = create_tween()
			tw_holo.tween_property(holo, "position:y", 0.65, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tw_holo.parallel().tween_property(holo, "scale", Vector3(1.1, 0.1, 1.1), 0.22)
			tw_holo.tween_callback(holo.queue_free)
		
		# 3. Pop-shrink locked zone root
		if locked_zone_root != null and is_instance_valid(locked_zone_root):
			var lz = locked_zone_root
			locked_zone_root = null
			var tw_lz = create_tween()
			tw_lz.tween_property(lz, "scale", Vector3(1.15, 1.15, 1.15), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw_lz.tween_property(lz, "scale", Vector3(1.0, 0.0, 1.0), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			tw_lz.tween_callback(lz.queue_free)
			
		_set_unlocked_visual(lvl)
		
		# 4. Bottom-to-top materialization wipe animation as the solid booth spawns in
		scale = Vector3(1.0, 0.02, 1.0)
		var tween: Tween = create_tween()
		tween.tween_property(self, "scale", Vector3(1.14, 1.25, 1.14), 0.26).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "scale", Vector3.ONE, 0.16)
		
		_spawn_floating_text("★ TABLE UNLOCKED! ★", Color(0.25, 1.0, 0.5, 1.0))
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade", 0.0, 3.0)

func _on_station_upgraded(id: String, new_lvl: int) -> void:
	if id == table_id and is_unlocked:
		update_level_display(new_lvl)
		apply_visual_tier(new_lvl)
		if upgrade_particles != null:
			upgrade_particles.restart()
		_spawn_upgrade_text(new_lvl)
		var bounce_scale = Vector3(1.28, 1.28, 1.28) if new_lvl in [10, 25, 50] else \
			(Vector3(1.22, 1.22, 1.22) if (new_lvl == 5) else Vector3(1.14, 1.14, 1.14))
		var tween: Tween = create_tween()
		tween.tween_property(self, "scale", bounce_scale, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "scale", Vector3.ONE, 0.18)
		# Milestone burst at 10, 25, 50
		if new_lvl in [10, 25, 50]:
			_spawn_milestone_star_burst(new_lvl)
			var am = get_node_or_null("/root/AudioManager")
			if am != null and am.has_method("play_milestone_chime"):
				am.play_milestone_chime(new_lvl)

## ── Visual Tier System ──────────────────────────────────────────────────────
## Applies progressive material upgrades at Milestone Levels 10, 25, and 50.
## Called on startup (via update_level_display) and on each upgrade.

func apply_visual_tier(lvl: int) -> void:
	if not is_unlocked:
		return
	if lvl >= 50:
		_apply_tier_max()
	elif lvl >= 25:
		_apply_tier3()
	elif lvl >= 10:
		_apply_tier2()
	# else tier1 is the default set in _setup_booth_materials()

func _apply_tier2() -> void:
	# Level 10-24: polished chrome edge trim + silver candelabra caddy
	var chrome = StandardMaterial3D.new()
	chrome.albedo_color = Color(0.88, 0.92, 0.96)
	chrome.metallic = 0.92
	chrome.roughness = 0.12
	var trim = get_node_or_null("TableChromeTrim")
	if trim is MeshInstance3D:
		trim.material_override = chrome

	# Silver candelabra / condiment caddy centrepiece
	if get_node_or_null("Tier2Caddy") == null:
		var caddy_root = Node3D.new()
		caddy_root.name = "Tier2Caddy"
		caddy_root.position = Vector3(0.0, 0.76, 0.0)
		add_child(caddy_root)
		# Stem
		var stem = MeshInstance3D.new()
		var cyl = CylinderMesh.new()
		cyl.top_radius = 0.018
		cyl.bottom_radius = 0.022
		cyl.height = 0.14
		stem.mesh = cyl
		var silver = StandardMaterial3D.new()
		silver.albedo_color = Color(0.80, 0.82, 0.86)
		silver.metallic = 0.85
		silver.roughness = 0.18
		stem.material_override = silver
		caddy_root.add_child(stem)
		# Candle flame sprite
		var flame = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = 0.025
		sphere.height = 0.05
		flame.mesh = sphere
		var flame_mat = StandardMaterial3D.new()
		flame_mat.albedo_color = Color(1.0, 0.72, 0.12)
		flame_mat.emission_enabled = true
		flame_mat.emission = Color(1.0, 0.55, 0.05)
		flame_mat.emission_energy_multiplier = 2.2
		flame.material_override = flame_mat
		flame.position = Vector3(0.0, 0.09, 0.0)
		caddy_root.add_child(flame)
		# Warm omni glow
		var candle_light = OmniLight3D.new()
		candle_light.light_color = Color(1.0, 0.65, 0.25)
		candle_light.light_energy = 0.6
		candle_light.omni_range = 1.2
		candle_light.position = Vector3(0.0, 0.12, 0.0)
		caddy_root.add_child(candle_light)

func _apply_tier3() -> void:
	_apply_tier2()
	# Level 25-49: brushed brass / gold piping caps + lush floral planter upgrades
	var brass = StandardMaterial3D.new()
	brass.albedo_color = Color(0.80, 0.62, 0.22)
	brass.metallic = 0.78
	brass.roughness = 0.28
	for path in ["BoothDecor/BenchNorthCap", "BoothDecor/BenchSouthCap"]:
		var node = get_node_or_null(path)
		if node is MeshInstance3D:
			node.material_override = brass

	var gold_trim = StandardMaterial3D.new()
	gold_trim.albedo_color = Color(1.0, 0.82, 0.28)
	gold_trim.metallic = 0.90
	gold_trim.roughness = 0.15
	var trim = get_node_or_null("TableChromeTrim")
	if trim is MeshInstance3D:
		trim.material_override = gold_trim

	# Lush floral arrangements: vivid magenta + yellow blooms replace standard reds
	var fl_magenta = StandardMaterial3D.new()
	fl_magenta.albedo_color = Color(0.92, 0.18, 0.65)
	fl_magenta.roughness = 0.55
	var fl_gold = StandardMaterial3D.new()
	fl_gold.albedo_color = Color(1.0, 0.88, 0.05)
	fl_gold.roughness = 0.55
	var fl_white = StandardMaterial3D.new()
	fl_white.albedo_color = Color(0.98, 0.98, 0.96)
	fl_white.roughness = 0.55
	var lush_flowers = [
		{"path": "BoothDecor/PartitionBack/PlanterBack/FlowerB1", "mat": fl_magenta},
		{"path": "BoothDecor/PartitionBack/PlanterBack/FlowerB2", "mat": fl_gold},
		{"path": "BoothDecor/PartitionBack/PlanterBack/FlowerB3", "mat": fl_white},
		{"path": "BoothDecor/PartitionBack/PlanterBack/FlowerB4", "mat": fl_magenta},
		{"path": "BoothDecor/PartitionBack/PlanterBack/FlowerB5", "mat": fl_gold},
		{"path": "BoothDecor/PartitionFront/PlanterFront/FlowerF1", "mat": fl_white},
		{"path": "BoothDecor/PartitionFront/PlanterFront/FlowerF2", "mat": fl_magenta},
		{"path": "BoothDecor/PartitionFront/PlanterFront/FlowerF3", "mat": fl_gold},
		{"path": "BoothDecor/PartitionFront/PlanterFront/FlowerF4", "mat": fl_white},
		{"path": "BoothDecor/PartitionFront/PlanterFront/FlowerF5", "mat": fl_magenta},
	]
	for fc in lush_flowers:
		var f = get_node_or_null(fc["path"])
		if f is MeshInstance3D:
			f.material_override = fc["mat"]

func _apply_toy_mobile_styling_to_character(node: Node) -> void:
	if node == null:
		return
	if node is MeshInstance3D:
		var mi: MeshInstance3D = node
		if mi.material_override != null and mi.material_override is StandardMaterial3D:
			var mat: StandardMaterial3D = mi.material_override
			mat.rim_enabled = true
			mat.rim = 0.35
			mat.roughness = clampf(mat.roughness, 0.35, 0.45)
		elif mi.mesh != null and mi.mesh is ArrayMesh:
			var sc = mi.mesh.get_surface_count()
			for s in range(sc):
				var surf_mat = mi.get_surface_override_material(s)
				if surf_mat == null:
					surf_mat = mi.mesh.surface_get_material(s)
				if surf_mat != null and surf_mat is StandardMaterial3D:
					var dup_mat = surf_mat.duplicate()
					dup_mat.rim_enabled = true
					dup_mat.rim = 0.35
					dup_mat.roughness = clampf(dup_mat.roughness, 0.35, 0.45)
					mi.set_surface_override_material(s, dup_mat)
	for child in node.get_children():
		_apply_toy_mobile_styling_to_character(child)

func _apply_tier_max() -> void:
	_apply_tier3()
	# Level 50 Max: royal crimson velvet benches + gleaming gold rim + warm overhead spot

	# Crimson velvet benches
	var velvet = StandardMaterial3D.new()
	velvet.albedo_color = Color(0.68, 0.06, 0.14)
	velvet.roughness = 0.45
	velvet.rim_enabled = true
	velvet.rim = 0.35
	for path in [
		"BoothDecor/BenchNorthSeat", "BoothDecor/BenchNorthBack",
		"BoothDecor/BenchSouthSeat", "BoothDecor/BenchSouthBack"
	]:
		var node = get_node_or_null(path)
		if node is MeshInstance3D:
			node.material_override = velvet

	# Gleaming gold table rim
	var gold_rim = StandardMaterial3D.new()
	gold_rim.albedo_color = Color(1.0, 0.85, 0.18)
	gold_rim.metallic = 0.98
	gold_rim.roughness = 0.08
	var trim = get_node_or_null("TableChromeTrim")
	if trim is MeshInstance3D:
		trim.material_override = gold_rim

	# Golden table number plaque (floats above table centre)
	if get_node_or_null("GoldPlaque") == null:
		var plaque_lbl = Label3D.new()
		plaque_lbl.name = "GoldPlaque"
		plaque_lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		plaque_lbl.double_sided = false
		plaque_lbl.font_size = 20
		plaque_lbl.outline_size = 5
		var t_idx = int(table_id.trim_prefix("table_"))
		plaque_lbl.text = "♛  TABLE %d  ♛" % max(t_idx, 1)
		plaque_lbl.modulate = Color(1.0, 0.88, 0.2)
		plaque_lbl.outline_modulate = Color(0.15, 0.08, 0.0, 0.95)
		plaque_lbl.position = Vector3(0.0, 0.80, 0.0)
		add_child(plaque_lbl)

	# Warm royal-gold overhead spotlight
	if get_node_or_null("MaxSpotLight") == null:
		var spot = SpotLight3D.new()
		spot.name = "MaxSpotLight"
		spot.light_color = Color(1.0, 0.88, 0.55)
		spot.light_energy = 1.4
		spot.spot_range = 3.0
		spot.spot_angle = 28.0
		spot.position = Vector3(0.0, 2.8, 0.0)
		spot.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
		add_child(spot)

func _spawn_milestone_star_burst(milestone_lvl: int) -> void:
	# Golden star CPUParticles3D burst centred above the table
	var stars = CPUParticles3D.new()
	stars.name = "MilestoneStarBurst"
	stars.emitting = true
	stars.one_shot = true
	stars.amount = 28 if milestone_lvl >= 50 else (20 if milestone_lvl >= 25 else 14)
	stars.lifetime = 1.6
	stars.explosiveness = 0.92
	stars.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	stars.emission_sphere_radius = 0.3
	stars.direction = Vector3(0, 1, 0)
	stars.spread = 80.0
	stars.gravity = Vector3(0.0, -3.0, 0.0)
	stars.initial_velocity_min = 2.0
	stars.initial_velocity_max = 4.5
	stars.scale_amount_min = 0.06
	stars.scale_amount_max = 0.14
	var col = Color(1.0, 0.85, 0.18) if milestone_lvl < 50 else Color(1.0, 0.45, 0.88)
	stars.color = col
	stars.position = Vector3(0.0, 1.2, 0.0)
	add_child(stars)
	# Auto-free after burst finishes
	var t = get_tree().create_timer(2.2)
	t.timeout.connect(func():
		if is_instance_valid(stars):
			stars.queue_free()
	)


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
	"sundae": "res://assets/models/food/sundae.glb",
	"steak_platter": "res://assets/models/food/meat-cooked.glb",
	"cocktail_tapas": "res://assets/models/food/cocktail.glb",
	"michelin_feast": "res://assets/models/food/fish.glb",
	"pasta": "res://assets/models/food/bowl-broth.glb",
	"pizza": "res://assets/models/food/pizza.glb",
	"sushi": "res://assets/models/food/sushi-salmon.glb"
}

func serve_food(dish_id: String = "burger", is_divine: bool = false) -> void:
	_setup_dish_model(dish_id, is_divine)
	if food_dish != null:
		food_dish.visible = true
		food_dish.scale = Vector3(0.1, 0.1, 0.1)
		var tween: Tween = create_tween()
		tween.tween_property(food_dish, "scale", Vector3(0.42, 0.42, 0.42), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if occupying_customer != null and is_instance_valid(occupying_customer):
		if is_divine:
			occupying_customer.set_meta("is_divine", true)
		if occupying_customer.has_method("on_food_delivered"):
			occupying_customer.on_food_delivered()

func _setup_dish_model(dish_id: String, is_divine: bool = false) -> void:
	if food_dish == null:
		return
	for c in food_dish.get_children():
		c.queue_free()
	var cook_script = load("res://scripts/cooking_station.gd")
	var dish_node: Node3D = null
	if cook_script != null and cook_script.has_method("create_dish_3d_model"):
		dish_node = cook_script.create_dish_3d_model(dish_id)
	if dish_node != null:
		food_dish.add_child(dish_node)
	else:
		var scn_path = DISH_SCENES.get(dish_id, DISH_SCENES["burger"])
		var scn = load(scn_path)
		if scn:
			var node = scn.instantiate()
			food_dish.add_child(node)
	if is_divine and food_dish != null:
		var gold_plate = MeshInstance3D.new()
		gold_plate.name = "TableGoldPlatter"
		var cyl = CylinderMesh.new()
		cyl.top_radius = 0.52
		cyl.bottom_radius = 0.55
		cyl.height = 0.05
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(1.0, 0.85, 0.15, 1.0)
		mat.metallic = 0.95
		mat.roughness = 0.18
		mat.emission_enabled = true
		mat.emission = Color(0.9, 0.7, 0.1, 1.0)
		mat.emission_energy_multiplier = 0.4
		gold_plate.mesh = cyl
		gold_plate.material_override = mat
		gold_plate.position = Vector3(0, -0.015, 0)
		food_dish.add_child(gold_plate)

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
	
	# Spawn fresh cash bundle stack on customer payment
	if booth_cash_stack != null:
		_populate_cash_bricks(randi_range(3, 6))
		booth_cash_stack.visible = true
		
	var gm = get_node_or_null("/root/GameManager")
	if gm != null and gm.has_method("record_dirty_table"):
		gm.record_dirty_table()
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
	
	var gm = get_node_or_null("/root/GameManager")
	if gm != null and gm.has_method("record_table_cleaned"):
		gm.record_table_cleaned()
	
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
	return global_position + Vector3(-1.15, 0.02, 0.15)

func _fly_brick_in_arc(brick: Node3D, delay: float) -> void:
	var start_pos = brick.global_position
	var cam = get_viewport().get_camera_3d() if get_viewport() != null else null
	var target_pos = start_pos + Vector3(0.0, 3.2, 1.2)
	if cam != null:
		target_pos = cam.global_position + (cam.global_transform.basis.y * 1.2) - (cam.global_transform.basis.z * 1.5)
		
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(brick, "scale", Vector3(1.2, 1.2, 1.2), 0.12).set_delay(delay)
	tw.tween_property(brick, "scale", Vector3.ZERO, 0.48).set_delay(delay + 0.12)
	
	tw.tween_property(brick, "global_position:x", target_pos.x, 0.6).set_delay(delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(brick, "global_position:z", target_pos.z, 0.6).set_delay(delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	var apex_y = max(start_pos.y, target_pos.y) + 1.8
	tw.tween_method(func(t: float):
		if is_instance_valid(brick):
			brick.global_position.y = lerp(start_pos.y, target_pos.y, t) + 4.0 * t * (1.0 - t) * (apex_y - start_pos.y)
	, 0.0, 1.0, 0.6).set_delay(delay)
	
	tw.tween_property(brick, "rotation:y", brick.rotation.y + randf_range(3.0, 6.0), 0.6).set_delay(delay)
	tw.tween_property(brick, "rotation:x", randf_range(1.0, 3.0), 0.6).set_delay(delay)
	
	tw.set_parallel(false)
	tw.tween_interval(0.62 + delay)
	tw.tween_callback(func():
		if is_instance_valid(brick):
			brick.queue_free()
	)

func collect_booth_cash() -> float:
	if not has_visible_cash_stack():
		return 0.0
		
	var amount: float = 50.0
	var gm = get_node_or_null("/root/GameManager")
	if gm != null and gm.has_method("get_card_tip_multiplier"):
		amount = round(amount * gm.get_card_tip_multiplier())
	var c_pos: Vector3 = get_cash_stack_world_pos()
	
	# Animate physical 3D dollar bill bricks flying in a parabolic arc
	if cash_bricks_container != null:
		var bricks = cash_bricks_container.get_children()
		var delay_idx = 0
		for b in bricks:
			if b is Node3D:
				var gpos = b.global_position
				cash_bricks_container.remove_child(b)
				get_tree().root.add_child(b)
				b.global_position = gpos
				_fly_brick_in_arc(b, float(delay_idx) * 0.04)
				delay_idx += 1
		current_cash_bricks = 0
		
	booth_cash_stack.visible = false
	
	var rest = find_parent("Restaurant")
	if rest != null and rest.has_method("register_cash_collection"):
		rest.register_cash_collection(c_pos, amount)
	else:
		if gm != null:
			gm.add_cash(amount, c_pos)
			if gm.has_method("record_table_cash_collected"):
				gm.record_table_cash_collected()
			if gm.has_method("add_fever_charge"):
				gm.add_fever_charge(8.0)
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
			var success = gm.unlock_table(table_id)
			if not success:
				if locked_price_badge != null:
					var tw = create_tween()
					tw.tween_property(locked_price_badge, "position:x", 0.08, 0.05)
					tw.tween_property(locked_price_badge, "position:x", -0.08, 0.05)
					tw.tween_property(locked_price_badge, "position:x", 0.0, 0.05)
				_spawn_floating_text("Need $%d to Unlock!" % round(current_unlock_cost), Color(1.0, 0.4, 0.4))
			return
		if is_dirty:
			clean_table()
			return
		var lvl: int = gm.get_station_level(table_id)
		var root = get_tree().current_scene if get_tree() != null else null
		var hud = root.find_child("HUD", true, false) if root != null else null
		if hud != null and hud.has_method("show_station_callout"):
			hud.show_station_callout(self, table_id, table_name, lvl)
		else:
			table_clicked.emit(table_id, table_name, lvl)
