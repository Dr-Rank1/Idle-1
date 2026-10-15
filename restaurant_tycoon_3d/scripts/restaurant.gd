extends Node3D

signal open_upgrade_ui(station_id: String, station_name: String, level: int)

@export var customer_scene: PackedScene
@export var floating_cash_scene: PackedScene

@onready var tables_container: Node3D = $Tables
@onready var kitchen_container: Node3D = $Kitchen
@onready var customers_container: Node3D = $Customers
@onready var waiter_1: Node3D = $Waiter
@onready var host_marker: Marker3D = $HostMarker
@onready var spawn_marker: Marker3D = $SpawnMarker

var spawn_timer: float = 0.5
var spawn_interval: float = 2.0

var waiters: Array[Node3D] = []
var pending_orders: Array[Node3D] = []
var waiter_scene: PackedScene = null

var waiting_customers: Array[Node3D] = []
const MAX_WAITING_CUSTOMERS: int = 3
const WAITING_SPOTS: Array[Vector3] = [
	Vector3(-1.5, 0.0, 7.0),
	Vector3(-1.5, 0.0, 8.2),
	Vector3(-1.5, 0.0, 9.4)
]

# Active Service Sectors: Cocktail Lounge & 50s Milkshake Diner
var lounge_seats: Array[Dictionary] = []
var diner_seats: Array[Dictionary] = []
var pending_lounge_orders: Array[Dictionary] = []
var pending_diner_orders: Array[Dictionary] = []

var lounge_bartender: Node3D = null
var diner_barista: Node3D = null

enum StaffState { IDLE, PREPARING, SERVING }
var bartender_state: StaffState = StaffState.IDLE
var barista_state: StaffState = StaffState.IDLE

var barista_radial_mesh: MeshInstance3D = null
var bartender_shaker_prop: Node3D = null
var milkshake_badge_label: Label3D = null

var floor_manager: Node3D = null
var manager_tour_timer: float = 35.0
var manager_is_touring: bool = false
var manager_tour_waypoints: Array = []
var manager_aura_light: OmniLight3D = null
var manager_status_label: Label3D = null

var janitor_character: Node3D = null
var janitor_patrol_timer: float = 12.0
var janitor_waypoints: Array = []
var janitor_status_label: Label3D = null
var janitor_on_break: bool = false
var janitor_speed: float = 3.2

var breakroom_routine_timer: float = 28.0
var sign_board_mat: StandardMaterial3D = null

# ─── Swipe-to-Collect & Combo Tracking ──────────────────────────────────────
var active_counter_stacks: Array[Dictionary] = []
var last_cash_collect_time: float = -999.0
var cash_collect_combo: int = 0

# Front sliding entrance door controller
const SLIDE_DOOR_POS: Vector3 = Vector3(-1.5, 0.0, 10.5)
const SLIDE_DOOR_MAX_OFFSET: float = 0.85
var _door_open_ratio: float = 0.0
var _sliding_door_left: Node3D = null
var _sliding_door_right: Node3D = null
var _door_pane_left: Node3D = null
var _door_pane_right: Node3D = null
var _door_handle_left: Node3D = null
var _door_handle_right: Node3D = null
var _door_left_base_x: float = -2.08
var _door_right_base_x: float = -0.92
var _handle_left_base_x: float = -1.56
var _handle_right_base_x: float = -1.44

func _ready() -> void:
	_init_sliding_doors()
	waiter_scene = load("res://scenes/waiter.tscn")
	if floating_cash_scene == null:
		floating_cash_scene = load("res://scenes/floating_cash.tscn")
	
	if waiter_1 != null:
		waiters.append(waiter_1)
		
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		if gm.has_method("register_restaurant"):
			gm.register_restaurant(self)
		gm.spawn_floating_cash.connect(_on_spawn_floating_cash)
		gm.staff_updated.connect(_on_staff_updated)
		gm.station_upgraded.connect(_on_station_upgraded)
		_check_spawn_hired_staff()
	
	if tables_container != null:
		for table in tables_container.get_children():
			if table.has_signal("table_clicked"):
				table.table_clicked.connect(_on_table_clicked)
			
	# Remove any legacy static queue guests so dynamic queuing is unobstructed
	for node_name in ["HostQueueGuest1", "HostQueueGuest2", "HostQueueGuest3", "WaitingGuest", "WaitingGuest1A", "WaitingGuest1B"]:
		var static_guest = find_child(node_name, true, false)
		if static_guest:
			static_guest.queue_free()
			
	if kitchen_container != null:
		for st in kitchen_container.get_children():
			if st.has_signal("station_clicked"):
				st.station_clicked.connect(_on_table_clicked)
				
	_setup_custom_textures()
	_setup_active_service_sectors()


func _setup_custom_textures() -> void:
	print(">>> _setup_custom_textures RUNNING!")
	# Disable shadow casting on all building walls and ceilings so interior lighting is bright and clean
	var walls_node = find_child("BuildingWalls", true, false)
	if walls_node != null:
		for wall in walls_node.get_children():
			if wall is GeometryInstance3D:
				wall.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var roof_node = find_child("IndustrialRoof", true, false)
	if roof_node != null:
		roof_node.visible = false

	# Dining Hall Diamond Checkerboard Floor
	var tile_path = ProjectSettings.globalize_path("res://assets/textures/diner_diamond_tiles.png")
	var tile_img = Image.load_from_file(tile_path)
	if tile_img != null:
		var tile_tex = ImageTexture.create_from_image(tile_img)
		var dining_floor_node = find_child("DiningFloor", true, false)
		if dining_floor_node != null and dining_floor_node is MeshInstance3D:
			var mat = StandardMaterial3D.new()
			mat.albedo_texture = tile_tex
			mat.roughness = 0.88
			# 2.5 repeats across 14m gives ~20 diamond tiles (0.7m each), matching video exactly
			mat.uv1_scale = Vector3(2.5, 2.5, 1)
			dining_floor_node.material_override = mat

	# South-East Expansion Warm Cream-and-Tan Diamond Checkerboard Floor
	var exp_tile_path = ProjectSettings.globalize_path("res://assets/textures/expansion_diamond_tiles.png")
	var exp_tile_img = Image.load_from_file(exp_tile_path)
	if exp_tile_img != null:
		var exp_tex = ImageTexture.create_from_image(exp_tile_img)
		var exp_floor_node = find_child("TerraceFloor", true, false)
		if exp_floor_node != null and exp_floor_node is MeshInstance3D:
			var exp_mat = StandardMaterial3D.new()
			exp_mat.albedo_texture = exp_tex
			exp_mat.roughness = 0.85
			# 5.5m width x 11.0m length -> 1.0 repeat in X and 2.0 in Z gives ~0.69m tiles matching dining room exactly
			exp_mat.uv1_scale = Vector3(1.0, 2.0, 1.0)
			exp_floor_node.material_override = exp_mat

	# Kitchen Floor (High-Contrast Slate-Grey Quarry Tiles 1:1 with reference)
	var k_tile_path = ProjectSettings.globalize_path("res://assets/textures/kitchen_slate_tiles.png")
	var k_tile_img = Image.load_from_file(k_tile_path)
	if k_tile_img != null:
		var k_tile_tex = ImageTexture.create_from_image(k_tile_img)
		var kitchen_floor_node = find_child("KitchenFloor", true, false)
		if kitchen_floor_node != null and kitchen_floor_node is MeshInstance3D:
			var mat_kitchen = StandardMaterial3D.new()
			mat_kitchen.albedo_texture = k_tile_tex
			mat_kitchen.roughness = 0.55
			mat_kitchen.uv1_scale = Vector3(4.0, 3.5, 1.0)
			kitchen_floor_node.material_override = mat_kitchen

	# Restroom Cool Blue-Grey Square Tiles
	var rest_path = ProjectSettings.globalize_path("res://assets/textures/restroom_tiles.png")
	var rest_img = Image.load_from_file(rest_path)
	if rest_img != null:
		var rest_tex = ImageTexture.create_from_image(rest_img)
		var rest_floor_node = find_child("RestroomFloor", true, false)
		if rest_floor_node != null and rest_floor_node is MeshInstance3D:
			var rest_mat = StandardMaterial3D.new()
			rest_mat.albedo_texture = rest_tex
			rest_mat.roughness = 0.5
			rest_mat.uv1_scale = Vector3(3.0, 3.5, 1.0)
			rest_floor_node.material_override = rest_mat

	# Staff Breakroom Slate-Grey Tiles
	var slate_path = ProjectSettings.globalize_path("res://assets/textures/kitchen_slate_tiles.png")
	var slate_img = Image.load_from_file(slate_path)
	if slate_img != null:
		var slate_tex = ImageTexture.create_from_image(slate_img)
		var break_floor_node = find_child("BreakroomFloor", true, false)
		if break_floor_node != null and break_floor_node is MeshInstance3D:
			var break_mat = StandardMaterial3D.new()
			break_mat.albedo_texture = slate_tex
			break_mat.roughness = 0.65
			break_mat.uv1_scale = Vector3(4.0, 1.5, 1.0)
			break_floor_node.material_override = break_mat

	# Staff Breakroom Employee Lockers
	var lock_path = ProjectSettings.globalize_path("res://assets/textures/lockers_wall.png")
	var lock_img = Image.load_from_file(lock_path)
	if lock_img != null:
		var lock_tex = ImageTexture.create_from_image(lock_img)
		var lock_mesh = find_child("BreakroomLockers", true, false)
		if lock_mesh != null and lock_mesh is MeshInstance3D:
			var mat = StandardMaterial3D.new()
			mat.albedo_texture = lock_tex
			mat.roughness = 0.65
			lock_mesh.material_override = mat

	# Manager's Office Warm Terracotta Floor
	var terra_path = ProjectSettings.globalize_path("res://assets/textures/kitchen_terracotta.png")
	var terra_img = Image.load_from_file(terra_path)
	if terra_img != null:
		var terra_tex = ImageTexture.create_from_image(terra_img)
		var office_floor_node = find_child("ManagerOfficeFloor", true, false)
		if office_floor_node != null and office_floor_node is MeshInstance3D:
			var mat_terra = StandardMaterial3D.new()
			mat_terra.albedo_texture = terra_tex
			mat_terra.roughness = 0.55
			mat_terra.uv1_scale = Vector3(4.0, 3.5, 1.0)
			office_floor_node.material_override = mat_terra

	# Front Lawn Idle Diner Neon Sign
	var neon_path = ProjectSettings.globalize_path("res://assets/textures/idle_diner_neon.png")
	var neon_img = Image.load_from_file(neon_path)
	if neon_img != null:
		var neon_tex = ImageTexture.create_from_image(neon_img)
		var sign_board_node = get_node_or_null("IdleDinerSign/SignBoard")
		if sign_board_node == null:
			sign_board_node = find_child("SignBoard", true, false)
		if sign_board_node != null and sign_board_node is MeshInstance3D:
			var sign_mat = StandardMaterial3D.new()
			sign_mat.albedo_texture = neon_tex
			sign_mat.emission_enabled = true
			sign_mat.emission_texture = neon_tex
			sign_mat.emission_energy_multiplier = 4.0
			sign_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			sign_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
			sign_board_node.material_override = sign_mat
			sign_board_mat = sign_mat

	# Reception & Waiting Room Elegant Cream Cabochon Floor
	var rec_tile_path = ProjectSettings.globalize_path("res://assets/textures/reception_tiles.png")
	var rec_tile_img = Image.load_from_file(rec_tile_path)
	if rec_tile_img != null:
		var rec_tex = ImageTexture.create_from_image(rec_tile_img)
		var reception_floor_node = find_child("ReceptionFloor", true, false)
		if reception_floor_node != null and reception_floor_node is MeshInstance3D:
			var mat_rec = StandardMaterial3D.new()
			mat_rec.albedo_texture = rec_tex
			mat_rec.roughness = 0.55
			mat_rec.uv1_scale = Vector3(1.5, 2.625, 1)
			reception_floor_node.material_override = mat_rec

	# Kitchen Pass Large Red Runner Rug (1:1 with crop_kitchen_08s.jpg)
	var pass_rug_path = ProjectSettings.globalize_path("res://assets/textures/kitchen_pass_rug.png")
	var pass_rug_img = Image.load_from_file(pass_rug_path)
	if pass_rug_img != null:
		var pass_rug_tex = ImageTexture.create_from_image(pass_rug_img)
		var k_runner = find_child("KitchenPassRedRunner", true, false)
		if k_runner != null and k_runner is MeshInstance3D:
			var bmesh = BoxMesh.new()
			bmesh.size = Vector3(8.5, 0.02, 2.4)
			k_runner.mesh = bmesh
			k_runner.position = Vector3(6.5, 0.022, -2.15)
			var r_mat = StandardMaterial3D.new()
			r_mat.albedo_texture = pass_rug_tex
			r_mat.roughness = 0.65
			k_runner.material_override = r_mat

	# Host Desk Velvet Red Runner
	var runner_path = ProjectSettings.globalize_path("res://assets/textures/red_carpet_runner.png")
	var runner_img = Image.load_from_file(runner_path)
	if runner_img != null:
		runner_img.rotate_90(CLOCKWISE)
		var runner_tex = ImageTexture.create_from_image(runner_img)
		var h_runner = get_node_or_null("ReceptionRoom/RedCarpetRunner")
		if h_runner == null:
			h_runner = find_child("HostDeskRedRunner", true, false)
		if h_runner != null and h_runner is MeshInstance3D:
			var mat_run = StandardMaterial3D.new()
			mat_run.albedo_texture = runner_tex
			mat_run.roughness = 0.65
			h_runner.material_override = mat_run

	# Entrance Chair Status Bubble
	var chair_bubble_path = ProjectSettings.globalize_path("res://assets/textures/entrance_chair_bubble.png")
	var chair_bubble_img = Image.load_from_file(chair_bubble_path)
	if chair_bubble_img != null:
		var chair_bubble_tex = ImageTexture.create_from_image(chair_bubble_img)
		var bubble_node = find_child("EntranceChairBubble", true, false)
		if bubble_node != null and bubble_node is Sprite3D:
			bubble_node.texture = chair_bubble_tex

	# Milkshake Bar High-Contrast Diamond Checkerboard Floor
	var shake_floor = find_child("MilkshakeFloor", true, false)
	var shake_tile_path = ProjectSettings.globalize_path("res://assets/textures/diner_diamond_tiles.png")
	var shake_tile_img = Image.load_from_file(shake_tile_path)
	if shake_floor != null and shake_floor is MeshInstance3D and shake_tile_img != null:
		# Process pixels to make dark squares rich dark charcoal/slate for authentic high-contrast 50s diner look
		for y in range(shake_tile_img.get_height()):
			for x in range(shake_tile_img.get_width()):
				var col = shake_tile_img.get_pixel(x, y)
				if col.get_luminance() < 0.85:
					shake_tile_img.set_pixel(x, y, Color(0.24, 0.27, 0.30, 1.0))
				else:
					shake_tile_img.set_pixel(x, y, Color(0.96, 0.98, 0.98, 1.0))
		var shake_tex = ImageTexture.create_from_image(shake_tile_img)
		var shake_mat = StandardMaterial3D.new()
		shake_mat.albedo_texture = shake_tex
		shake_mat.roughness = 0.35
		shake_mat.uv1_scale = Vector3(1.8, 1.6, 1.0)
		shake_floor.material_override = shake_mat

	# The Milk Shake Neon Sign (Emission multiplier 3.5)
	var shake_neon_path = ProjectSettings.globalize_path("res://assets/textures/the_milk_shake_neon.png")
	var shake_neon_img = Image.load_from_file(shake_neon_path)
	if shake_neon_img != null:
		var shake_neon_tex = ImageTexture.create_from_image(shake_neon_img)
		var neon_node = find_child("TheMilkShakeNeon", true, false)
		if neon_node != null and neon_node is MeshInstance3D:
			var mat = StandardMaterial3D.new()
			mat.albedo_texture = shake_neon_tex
			mat.emission_enabled = true
			mat.emission_texture = shake_neon_tex
			mat.emission_energy_multiplier = 3.5
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			mat.cull_mode = BaseMaterial3D.CULL_DISABLED
			neon_node.material_override = mat

	# Decorative Vinyl Records on North and West Walls
	var vinyl_path = ProjectSettings.globalize_path("res://assets/textures/vinyl_record.png")
	var vinyl_img = Image.load_from_file(vinyl_path)
	if vinyl_img != null:
		var vinyl_tex = ImageTexture.create_from_image(vinyl_img)
		for v_name in ["VinylRecord1", "VinylRecord2", "VinylRecord3", "VinylRecord4", "VinylRecordWest1", "VinylRecordWest2"]:
			var v_node = find_child(v_name, true, false)
			if v_node != null and v_node is MeshInstance3D:
				var v_mat = StandardMaterial3D.new()
				v_mat.albedo_texture = vinyl_tex
				v_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				v_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
				v_mat.roughness = 0.25
				v_mat.metallic = 0.4
				v_node.material_override = v_mat

	_setup_lounge_fidelity()
	_setup_milkshake_fidelity()
	_setup_kitchen_fidelity()
	_setup_breakroom_fidelity()
	_setup_manager_office_fidelity()
	_setup_courtyard_fidelity()

func _setup_lounge_fidelity() -> void:
	var rec_room = find_child("ReceptionRoom", true, false)
	if rec_room == null:
		return

	# 1. Main Mahogany Bar Counter along north wall (1:1 with crop_lounge_08s.jpg)
	var bar_root = rec_room.get_node_or_null("FidelityLoungeBar")
	if bar_root == null:
		bar_root = Node3D.new()
		bar_root.name = "FidelityLoungeBar"
		rec_room.add_child(bar_root)

		# Cyan Runner Mat under bar stools
		var mat_mesh = MeshInstance3D.new()
		var box_mat = BoxMesh.new()
		box_mat.size = Vector3(5.4, 0.015, 1.25)
		var cyan_mat = StandardMaterial3D.new()
		cyan_mat.albedo_color = Color(0.28, 0.68, 0.72, 1.0)
		cyan_mat.roughness = 0.75
		mat_mesh.mesh = box_mat
		mat_mesh.material_override = cyan_mat
		mat_mesh.position = Vector3(-7.2, 0.025, -1.25)
		bar_root.add_child(mat_mesh)

		# Counter Body (Rich dark cherry mahogany wood)
		var body_mesh = CSGBox3D.new()
		body_mesh.size = Vector3(5.2, 0.82, 0.65)
		body_mesh.position = Vector3(-7.2, 0.41, -2.2)
		var wood_mat = StandardMaterial3D.new()
		wood_mat.albedo_color = Color(0.28, 0.10, 0.06, 1.0)
		wood_mat.roughness = 0.35
		body_mesh.material = wood_mat
		bar_root.add_child(body_mesh)

		# Counter Top (Warm cream marble / polished wood)
		var top_mesh = CSGBox3D.new()
		top_mesh.size = Vector3(5.4, 0.06, 0.78)
		top_mesh.position = Vector3(-7.2, 0.85, -2.2)
		var marble_mat = StandardMaterial3D.new()
		marble_mat.albedo_color = Color(0.95, 0.94, 0.90, 1.0)
		marble_mat.roughness = 0.2
		marble_mat.metallic = 0.1
		top_mesh.material = marble_mat
		bar_root.add_child(top_mesh)

		# Polished Brass Foot Rail along base
		var rail_mesh = CSGCylinder3D.new()
		rail_mesh.radius = 0.025
		rail_mesh.height = 5.0
		rail_mesh.rotation_degrees = Vector3(0, 0, 90)
		rail_mesh.position = Vector3(-7.2, 0.15, -1.825)
		var brass_mat = StandardMaterial3D.new()
		brass_mat.albedo_color = Color(0.95, 0.82, 0.28, 1.0)
		brass_mat.metallic = 0.85
		brass_mat.roughness = 0.2
		rail_mesh.material = brass_mat
		bar_root.add_child(rail_mesh)

		# 6 Stools in front of the bar on the cyan mat
		var stool_scn = load("res://assets/models/furniture/stoolBar.glb")
		if stool_scn != null:
			for i in range(6):
				var sx = -9.2 + i * 0.8
				var st = stool_scn.instantiate()
				st.position = Vector3(sx, 0.0, -1.25)
				st.scale = Vector3(1.15, 1.15, 1.15)
				bar_root.add_child(st)

		# Glass Wine & Cocktail Glasses on the counter
		var wine_scn = load("res://assets/models/food/glass-wine.glb")
		if wine_scn != null:
			for wx in [-9.0, -8.0, -6.4, -5.6]:
				var wg = wine_scn.instantiate()
				wg.position = Vector3(wx, 0.88, -2.2)
				wg.scale = Vector3(0.4, 0.4, 0.4)
				bar_root.add_child(wg)

		# Coffee / Espresso Machine on right end of counter
		var coffee_scn = load("res://assets/models/furniture/kitchenCoffeeMachine.glb")
		if coffee_scn != null:
			var cm = coffee_scn.instantiate()
			cm.position = Vector3(-4.8, 0.88, -2.2)
			cm.scale = Vector3(0.9, 0.9, 0.9)
			bar_root.add_child(cm)

		# Multi-Tier Backlit Liquor Shelf on the North wall
		var shelf_img_path = ProjectSettings.globalize_path("res://assets/textures/lounge_shelf_bottles.png")
		var shelf_img = Image.load_from_file(shelf_img_path)
		if shelf_img != null:
			var shelf_tex = ImageTexture.create_from_image(shelf_img)
			var shelf_mesh = MeshInstance3D.new()
			var quad = QuadMesh.new()
			quad.size = Vector2(3.6, 1.9)
			shelf_mesh.mesh = quad
			var shelf_mat = StandardMaterial3D.new()
			shelf_mat.albedo_texture = shelf_tex
			shelf_mat.emission_enabled = true
			shelf_mat.emission_texture = shelf_tex
			shelf_mat.emission_energy_multiplier = 2.0
			shelf_mesh.material_override = shelf_mat
			shelf_mesh.position = Vector3(-7.2, 1.85, -3.36)
			bar_root.add_child(shelf_mesh)

		# Chalkboard Menu on the East divider wall (x = -3.46, facing west)
		var chalk_img_path = ProjectSettings.globalize_path("res://assets/textures/chalkboard_menu.png")
		var chalk_img = Image.load_from_file(chalk_img_path)
		if chalk_img != null:
			var chalk_tex = ImageTexture.create_from_image(chalk_img)
			var chalk_mesh = MeshInstance3D.new()
			var quad_c = QuadMesh.new()
			quad_c.size = Vector2(1.8, 1.35)
			chalk_mesh.mesh = quad_c
			var c_mat = StandardMaterial3D.new()
			c_mat.albedo_texture = chalk_tex
			c_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
			c_mat.roughness = 0.75
			chalk_mesh.material_override = c_mat
			chalk_mesh.position = Vector3(-3.46, 1.75, 0.6)
			chalk_mesh.rotation_degrees = Vector3(0, -90, 0)
			bar_root.add_child(chalk_mesh)

		# Round Topiary Plant in the corner
		var plant_scn = load("res://assets/models/furniture/pottedPlant.glb")
		if plant_scn != null:
			var corner_plant = plant_scn.instantiate()
			corner_plant.position = Vector3(-4.0, 0.0, -2.8)
			corner_plant.scale = Vector3(1.4, 1.4, 1.4)
			bar_root.add_child(corner_plant)

		# Bartender figure behind the counter
		var barman_scn = load("res://assets/models/characters/character-male-d.glb")
		if barman_scn != null:
			var barman = barman_scn.instantiate()
			barman.name = "LoungeBartender"
			barman.position = Vector3(-8.2, 0.0, -2.75)
			barman.rotation_degrees = Vector3(0, 0, 0)
			barman.scale = Vector3(1.15, 1.15, 1.15)
			var decor_script = load("res://scripts/decor_character.gd")
			barman.set_script(decor_script)
			barman.set("anim_name", "idle")
			bar_root.add_child(barman)
			lounge_bartender = barman
			
			# Cocktail shaker prop on mahogany counter
			var shaker_mesh = CSGCylinder3D.new()
			shaker_mesh.name = "CocktailShaker"
			shaker_mesh.radius = 0.05
			shaker_mesh.height = 0.20
			shaker_mesh.position = Vector3(-8.2, 0.95, -2.2)
			var s_mat = StandardMaterial3D.new()
			s_mat.albedo_color = Color(0.92, 0.94, 0.96, 1.0)
			s_mat.metallic = 0.95
			s_mat.roughness = 0.15
			shaker_mesh.material = s_mat
			bar_root.add_child(shaker_mesh)
			bartender_shaker_prop = shaker_mesh

	# Re-style the 4 round lounge tables & chairs with dark mahogany wood and padded cushions (matching crop_lounge_08s.jpg)
	var wood_tbl_mat = StandardMaterial3D.new()
	wood_tbl_mat.albedo_color = Color(0.24, 0.10, 0.06, 1.0)
	wood_tbl_mat.roughness = 0.35

	var chair_wood_mat = StandardMaterial3D.new()
	chair_wood_mat.albedo_color = Color(0.22, 0.09, 0.05, 1.0)
	chair_wood_mat.roughness = 0.45

	var red_cushion_mat = StandardMaterial3D.new()
	red_cushion_mat.albedo_color = Color(0.72, 0.14, 0.18, 1.0)
	red_cushion_mat.roughness = 0.5

	var wine_scn_tbl = load("res://assets/models/food/glass-wine.glb")

	for t_idx in [1, 2, 3, 4]:
		var tbl = rec_room.find_child("WaitingTable%d" % t_idx, true, false)
		if tbl != null:
			for ch in tbl.get_children():
				if ch is MeshInstance3D:
					ch.material_override = wood_tbl_mat

			# Add wine glasses on each table
			if wine_scn_tbl != null and tbl.get_node_or_null("WineGlass1") == null:
				for w_idx in range(2):
					var wg = wine_scn_tbl.instantiate()
					wg.name = "WineGlass%d" % (w_idx + 1)
					var w_offset = Vector3(0.12, 0.78, 0.12) if w_idx == 0 else Vector3(-0.12, 0.78, -0.12)
					wg.position = tbl.position + w_offset
					wg.scale = Vector3(0.35, 0.35, 0.35)
					rec_room.add_child(wg)

		for c_letter in ["A", "B", "C", "D"]:
			var chair = rec_room.find_child("WaitingChair%d%s" % [t_idx, c_letter], true, false)
			if chair != null:
				for ch in chair.get_children():
					if ch is MeshInstance3D:
						ch.material_override = chair_wood_mat
				# Add padded red vinyl cushion
				if chair.get_node_or_null("PaddedCushion") == null:
					var cushion = MeshInstance3D.new()
					cushion.name = "PaddedCushion"
					var c_box = BoxMesh.new()
					c_box.size = Vector3(0.42, 0.06, 0.42)
					cushion.mesh = c_box
					cushion.material_override = red_cushion_mat
					cushion.position = Vector3(0, 0.45, 0)
					chair.add_child(cushion)

	# Position & rotate Jukebox towards isometric camera for full view of neon arch and turntable
	var juke_node = find_child("RetroJukebox", true, false)
	if juke_node != null:
		juke_node.position = Vector3(-3.4, 0, 5.8)
		juke_node.rotation_degrees = Vector3(0, -45, 0)

func _setup_milkshake_fidelity() -> void:
	var shake_bar = find_child("MilkshakeBar", true, false)
	if shake_bar == null:
		return

	# Remove any old conflicting or mock-up children except MilkshakeFloor
	for child in shake_bar.get_children():
		if child.name != "MilkshakeFloor" and child.name != "FidelityMilkshakeDiner":
			child.queue_free()

	var f_root = shake_bar.get_node_or_null("FidelityMilkshakeDiner")
	if f_root != null:
		f_root.queue_free()

	f_root = Node3D.new()
	f_root.name = "FidelityMilkshakeDiner"
	shake_bar.add_child(f_root)

	# Shared materials
	var mint_mat = StandardMaterial3D.new()
	mint_mat.albedo_color = Color(0.44, 0.78, 0.72, 1.0)
	mint_mat.roughness = 0.35

	var chrome_mat = StandardMaterial3D.new()
	chrome_mat.albedo_color = Color(0.92, 0.94, 0.96, 1.0)
	chrome_mat.metallic = 0.95
	chrome_mat.roughness = 0.15

	var dark_chrome_mat = StandardMaterial3D.new()
	dark_chrome_mat.albedo_color = Color(0.25, 0.26, 0.28, 1.0)
	dark_chrome_mat.metallic = 0.85
	dark_chrome_mat.roughness = 0.3

	# 1. Long Mint-Green Soda Fountain Counter along West Wall (oriented along Z-axis)
	# Center at local X = -2.2, Z = 0.0 (world X = -9.7, Z = -7.0)
	var counter_body = CSGBox3D.new()
	counter_body.size = Vector3(0.68, 0.92, 5.2)
	counter_body.position = Vector3(-2.2, 0.46, 0.0)
	counter_body.material = mint_mat
	f_root.add_child(counter_body)

	# Horizontal Chrome Trim Bands
	var trim_lower = CSGBox3D.new()
	trim_lower.size = Vector3(0.72, 0.05, 5.24)
	trim_lower.position = Vector3(-2.2, 0.22, 0.0)
	trim_lower.material = chrome_mat
	f_root.add_child(trim_lower)

	var trim_upper = CSGBox3D.new()
	trim_upper.size = Vector3(0.72, 0.05, 5.24)
	trim_upper.position = Vector3(-2.2, 0.68, 0.0)
	trim_upper.material = chrome_mat
	f_root.add_child(trim_upper)

	var kickplate = CSGBox3D.new()
	kickplate.size = Vector3(0.70, 0.08, 5.21)
	kickplate.position = Vector3(-2.2, 0.04, 0.0)
	kickplate.material = dark_chrome_mat
	f_root.add_child(kickplate)

	# Polished Stainless Steel Countertop
	var counter_top = CSGBox3D.new()
	counter_top.size = Vector3(0.82, 0.06, 5.36)
	counter_top.position = Vector3(-2.2, 0.95, 0.0)
	counter_top.material = chrome_mat
	f_root.add_child(counter_top)

	# Polished Chrome Foot Rail along customer base
	var foot_rail = CSGCylinder3D.new()
	foot_rail.radius = 0.025
	foot_rail.height = 5.0
	foot_rail.rotation_degrees = Vector3(90, 0, 0)
	foot_rail.position = Vector3(-1.82, 0.14, 0.0)
	foot_rail.material = chrome_mat
	f_root.add_child(foot_rail)

	# Back preparation counter along West wall (local X = -3.5)
	var back_counter = CSGBox3D.new()
	back_counter.size = Vector3(0.50, 0.88, 5.0)
	back_counter.position = Vector3(-3.5, 0.44, 0.0)
	back_counter.material = mint_mat
	f_root.add_child(back_counter)

	var back_top = CSGBox3D.new()
	back_top.size = Vector3(0.56, 0.05, 5.1)
	back_top.position = Vector3(-3.5, 0.905, 0.0)
	back_top.material = chrome_mat
	f_root.add_child(back_top)

	# Chrome Wall Shelving behind counter
	for sy in [1.40, 1.85]:
		var shelf = CSGBox3D.new()
		shelf.size = Vector3(0.28, 0.035, 3.2)
		shelf.position = Vector3(-3.65, sy, 0.0)
		shelf.material = chrome_mat
		f_root.add_child(shelf)

	# 6 Bar Stools along customer aisle (local X = -1.35)
	var stool_scn = load("res://assets/models/furniture/stoolBar.glb")
	var stool_z_list = [-2.1, -1.25, -0.4, 0.45, 1.3, 2.15]
	if stool_scn != null:
		for i in range(stool_z_list.size()):
			var sz = stool_z_list[i]
			var st = stool_scn.instantiate()
			st.position = Vector3(-1.35, 0.0, sz)
			st.rotation_degrees = Vector3(0, -90, 0)
			st.scale = Vector3(1.15, 1.15, 1.15)
			f_root.add_child(st)

	# Diner Attendant behind the counter
	var staff_scn = load("res://assets/models/characters/character-male-d.glb")
	if staff_scn != null:
		var staff = staff_scn.instantiate()
		staff.name = "DinerBarista"
		staff.position = Vector3(-2.85, 0.0, 0.0)
		staff.rotation_degrees = Vector3(0, 90, 0)
		staff.scale = Vector3(1.15, 1.15, 1.15)
		var decor_script = load("res://scripts/decor_character.gd")
		staff.set_script(decor_script)
		staff.set("anim_name", "idle")
		f_root.add_child(staff)
		diner_barista = staff

	# Interactive click area for Milkshake Bar station upgrades
	var click_body = StaticBody3D.new()
	click_body.name = "MilkshakeClickArea"
	click_body.position = Vector3(-2.2, 0.6, 0.0)
	var col_shape = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(1.8, 1.5, 5.6)
	col_shape.shape = box
	click_body.add_child(col_shape)
	f_root.add_child(click_body)
	click_body.input_event.connect(_on_milkshake_bar_clicked)

	# 3D Floating Badge over Milkshake Diner Counter
	var badge_node = Node3D.new()
	badge_node.name = "MilkshakeBadgeRoot"
	badge_node.position = Vector3(-2.2, 2.15, 0.0)
	f_root.add_child(badge_node)
	
	var badge_lbl = Label3D.new()
	badge_lbl.name = "MilkshakeBadgeLabel"
	badge_lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	badge_lbl.font_size = 26
	badge_lbl.modulate = Color(0.44, 0.95, 0.85, 1.0)
	badge_lbl.outline_modulate = Color(0.05, 0.15, 0.15, 1.0)
	badge_lbl.outline_size = 6
	var gm_ref = get_node_or_null("/root/GameManager")
	var m_lvl = gm_ref.get_station_level("milkshake_bar") if gm_ref != null else 1
	badge_lbl.text = "🍦 50s SODA FOUNTAIN • Lv. %d" % m_lvl
	badge_node.add_child(badge_lbl)
	milkshake_badge_label = badge_lbl

	# Radial Timer progress ring above blenders
	barista_radial_mesh = MeshInstance3D.new()
	barista_radial_mesh.name = "BaristaRadialTimer"
	var qm = QuadMesh.new()
	qm.size = Vector2(0.65, 0.65)
	barista_radial_mesh.mesh = qm
	var s_mat = ShaderMaterial.new()
	s_mat.shader = load("res://shaders/radial_timer.gdshader")
	s_mat.set_shader_parameter("progress", 0.0)
	s_mat.set_shader_parameter("bg_color", Color(0.12, 0.15, 0.20, 0.75))
	s_mat.set_shader_parameter("fill_color", Color(0.35, 0.95, 0.85, 1.0))
	barista_radial_mesh.material_override = s_mat
	barista_radial_mesh.position = Vector3(-2.2, 1.65, -1.6)
	barista_radial_mesh.visible = false
	f_root.add_child(barista_radial_mesh)

	# 2 Chrome Milkshake Blenders on Counter
	for bz in [-1.9, -1.3]:
		var blender = Node3D.new()
		blender.name = "Blender_%s" % str(bz)
		blender.position = Vector3(-2.2, 0.98, bz)
		f_root.add_child(blender)

		var b_base = CSGCylinder3D.new()
		b_base.radius = 0.08
		b_base.height = 0.12
		b_base.position = Vector3(0, 0.06, 0)
		b_base.material = chrome_mat
		blender.add_child(b_base)

		var b_cup = CSGCylinder3D.new()
		b_cup.radius = 0.06
		b_cup.height = 0.22
		b_cup.position = Vector3(0, 0.23, 0)
		b_cup.material = chrome_mat
		blender.add_child(b_cup)

		var b_lid = CSGCylinder3D.new()
		b_lid.radius = 0.065
		b_lid.height = 0.03
		b_lid.position = Vector3(0, 0.355, 0)
		b_lid.material = dark_chrome_mat
		blender.add_child(b_lid)

	# Soda Taps Dispenser on Counter
	var tap_root = Node3D.new()
	tap_root.position = Vector3(-2.2, 0.98, 0.0)
	f_root.add_child(tap_root)

	var tap_tower = CSGCylinder3D.new()
	tap_tower.radius = 0.07
	tap_tower.height = 0.35
	tap_tower.position = Vector3(0, 0.175, 0)
	tap_tower.material = chrome_mat
	tap_root.add_child(tap_tower)

	var tap_head = CSGBox3D.new()
	tap_head.size = Vector3(0.12, 0.10, 0.32)
	tap_head.position = Vector3(0.04, 0.32, 0)
	tap_head.material = chrome_mat
	tap_root.add_child(tap_head)

	for ti in range(3):
		var handle = CSGCylinder3D.new()
		handle.radius = 0.015
		handle.height = 0.12
		handle.position = Vector3(0.08, 0.40, -0.09 + ti * 0.09)
		handle.rotation_degrees = Vector3(0, 0, -25)
		var h_mat = StandardMaterial3D.new()
		h_mat.albedo_color = Color(0.9, 0.2, 0.2) if ti == 0 else (Color(0.2, 0.8, 0.6) if ti == 1 else Color(0.95, 0.8, 0.2))
		handle.material = h_mat
		tap_root.add_child(handle)

	# Cake Dome Display on Counter
	var dome_root = Node3D.new()
	dome_root.position = Vector3(-2.2, 0.98, 1.4)
	f_root.add_child(dome_root)

	var dome_base = CSGCylinder3D.new()
	dome_base.radius = 0.16
	dome_base.height = 0.03
	dome_base.position = Vector3(0, 0.015, 0)
	dome_base.material = chrome_mat
	dome_root.add_child(dome_base)

	var cake_mesh = CSGCylinder3D.new()
	cake_mesh.radius = 0.12
	cake_mesh.height = 0.10
	cake_mesh.position = Vector3(0, 0.08, 0)
	var cake_mat = StandardMaterial3D.new()
	cake_mat.albedo_color = Color(0.95, 0.55, 0.65, 1.0)
	cake_mesh.material = cake_mat
	dome_root.add_child(cake_mesh)

	var glass_dome = CSGSphere3D.new()
	glass_dome.radius = 0.15
	glass_dome.position = Vector3(0, 0.14, 0)
	var glass_mat = StandardMaterial3D.new()
	glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_mat.albedo_color = Color(0.85, 0.95, 1.0, 0.3)
	glass_mat.roughness = 0.1
	glass_dome.material = glass_mat
	dome_root.add_child(glass_dome)

	# Sundaes and Frappes on Counter
	var sundae_scn = load("res://assets/models/food/sundae.glb")
	var frappe_scn = load("res://assets/models/food/frappe.glb")
	var soda_scn = load("res://assets/models/food/soda-glass.glb")

	if sundae_scn != null:
		var sd1 = sundae_scn.instantiate()
		sd1.position = Vector3(-2.2, 0.98, -0.7)
		sd1.scale = Vector3(0.42, 0.42, 0.42)
		f_root.add_child(sd1)

		var sd2 = sundae_scn.instantiate()
		sd2.position = Vector3(-2.2, 0.98, 2.3)
		sd2.scale = Vector3(0.42, 0.42, 0.42)
		f_root.add_child(sd2)

	if frappe_scn != null:
		var fr1 = frappe_scn.instantiate()
		fr1.position = Vector3(-2.2, 0.98, 0.7)
		fr1.scale = Vector3(0.42, 0.42, 0.42)
		f_root.add_child(fr1)

	if soda_scn != null:
		var so1 = soda_scn.instantiate()
		so1.position = Vector3(-2.2, 0.98, -2.4)
		so1.scale = Vector3(0.42, 0.42, 0.42)
		f_root.add_child(so1)

	# 2. The 4 Square Diner Tables in 2x2 Grid with Mint Tablecloths & Chrome Rims
	var chair_scn = load("res://assets/kaykit_restaurant/gltf/chair_A.gltf")
	var diner_chair_mat = StandardMaterial3D.new()
	diner_chair_mat.albedo_color = Color(0.18, 0.20, 0.22, 1.0)
	diner_chair_mat.metallic = 0.8
	diner_chair_mat.roughness = 0.3

	var diner_cushion_mat = StandardMaterial3D.new()
	diner_cushion_mat.albedo_color = Color(0.44, 0.78, 0.72, 1.0)
	diner_cushion_mat.roughness = 0.4

	# Overhead Lamp materials
	var cord_mat = StandardMaterial3D.new()
	cord_mat.albedo_color = Color(0.15, 0.15, 0.18, 1.0)
	cord_mat.metallic = 0.7
	var pink_mat = StandardMaterial3D.new()
	pink_mat.albedo_color = Color(0.96, 0.45, 0.60, 1.0)
	pink_mat.roughness = 0.35
	var bulb_mat = StandardMaterial3D.new()
	bulb_mat.albedo_color = Color(1.0, 0.95, 0.85, 1.0)
	bulb_mat.emission_enabled = true
	bulb_mat.emission = Color(1.0, 0.92, 0.8, 1.0)
	bulb_mat.emission_energy_multiplier = 2.5

	var table_positions = [
		Vector3(0.5, 0.0, -1.9),
		Vector3(2.6, 0.0, -1.9),
		Vector3(0.5, 0.0, 0.8),
		Vector3(2.6, 0.0, 0.8)
	]

	for t_idx in range(table_positions.size()):
		var tp = table_positions[t_idx]
		var tbl = Node3D.new()
		tbl.name = "DinerTable%d" % (t_idx + 1)
		tbl.position = tp
		f_root.add_child(tbl)

		# Chrome Pedestal Base
		var base_disc = CSGCylinder3D.new()
		base_disc.radius = 0.28
		base_disc.height = 0.03
		base_disc.position = Vector3(0, 0.015, 0)
		base_disc.material = chrome_mat
		tbl.add_child(base_disc)

		var pillar = CSGCylinder3D.new()
		pillar.radius = 0.05
		pillar.height = 0.72
		pillar.position = Vector3(0, 0.36, 0)
		pillar.material = chrome_mat
		tbl.add_child(pillar)

		# Square Tabletop with Mint Tablecloth
		var top_cloth = CSGBox3D.new()
		top_cloth.size = Vector3(1.15, 0.04, 1.15)
		top_cloth.position = Vector3(0, 0.73, 0)
		top_cloth.material = mint_mat
		tbl.add_child(top_cloth)

		# Chrome Edge Rim surrounding tabletop
		var chrome_rim = CSGBox3D.new()
		chrome_rim.size = Vector3(1.18, 0.048, 1.18)
		chrome_rim.position = Vector3(0, 0.73, 0)
		chrome_rim.material = chrome_mat
		var rim_cut = CSGBox3D.new()
		rim_cut.operation = CSGBox3D.OPERATION_SUBTRACTION
		rim_cut.size = Vector3(1.12, 0.06, 1.12)
		chrome_rim.add_child(rim_cut)
		tbl.add_child(chrome_rim)

		# Table Dessert
		var dessert_item = null
		if t_idx == 0 and sundae_scn != null: dessert_item = sundae_scn.instantiate()
		elif t_idx == 1 and frappe_scn != null: dessert_item = frappe_scn.instantiate()
		elif t_idx == 2 and sundae_scn != null: dessert_item = sundae_scn.instantiate()
		elif soda_scn != null: dessert_item = soda_scn.instantiate()
		if dessert_item != null:
			dessert_item.position = Vector3(0, 0.76, 0)
			dessert_item.scale = Vector3(0.42, 0.42, 0.42)
			tbl.add_child(dessert_item)

		# 4 Diner Chairs around table
		if chair_scn != null:
			var chair_offsets = [
				Vector3(0, 0, -0.68),
				Vector3(0, 0, 0.68),
				Vector3(-0.68, 0, 0),
				Vector3(0.68, 0, 0)
			]
			var chair_rots = [0, 180, -90, 90]
			for c_i in range(4):
				var ch = chair_scn.instantiate()
				ch.position = chair_offsets[c_i]
				ch.rotation_degrees = Vector3(0, chair_rots[c_i], 0)
				ch.scale = Vector3(0.9, 0.9, 0.9)
				tbl.add_child(ch)

				# Style chair frame dark charcoal / chrome
				for child in ch.get_children():
					if child is MeshInstance3D:
						child.material_override = diner_chair_mat
					for grand in child.get_children():
						if grand is MeshInstance3D:
							grand.material_override = diner_chair_mat

				# Mint vinyl seat cushion
				var cushion = CSGBox3D.new()
				cushion.size = Vector3(0.42, 0.06, 0.42)
				cushion.position = Vector3(0, 0.46, 0)
				cushion.material = diner_cushion_mat
				ch.add_child(cushion)

				# Mint vinyl backrest
				var backrest = CSGBox3D.new()
				backrest.size = Vector3(0.38, 0.28, 0.05)
				backrest.position = Vector3(0, 0.72, -0.18)
				backrest.material = diner_cushion_mat
				ch.add_child(backrest)

		# Overhead Pastel Pink Cone Pendant Lamp
		var lamp_root = Node3D.new()
		lamp_root.position = Vector3(tp.x, 2.25, tp.z)
		f_root.add_child(lamp_root)

		var cord = CSGCylinder3D.new()
		cord.radius = 0.012
		cord.height = 0.75
		cord.position = Vector3(0, 0.375, 0)
		cord.material = cord_mat
		lamp_root.add_child(cord)

		var cone = MeshInstance3D.new()
		var cmesh = CylinderMesh.new()
		cmesh.top_radius = 0.06
		cmesh.bottom_radius = 0.28
		cmesh.height = 0.18
		cone.mesh = cmesh
		cone.position = Vector3(0, 0.0, 0)
		cone.material_override = pink_mat
		lamp_root.add_child(cone)

		var bulb = MeshInstance3D.new()
		var bmesh = SphereMesh.new()
		bmesh.radius = 0.06
		bmesh.height = 0.12
		bulb.mesh = bmesh
		bulb.position = Vector3(0, -0.05, 0)
		bulb.material_override = bulb_mat
		lamp_root.add_child(bulb)

		var spot = SpotLight3D.new()
		spot.rotation_degrees = Vector3(-90, 0, 0)
		spot.light_color = Color(1.0, 0.92, 0.80, 1.0)
		spot.light_energy = 0.9
		spot.spot_range = 3.5
		spot.spot_angle = 45.0
		lamp_root.add_child(spot)

	# Seated diner guests at tables
	var guest_scn1 = load("res://assets/models/characters/character-female-c.glb")
	if guest_scn1 != null:
		var g1 = guest_scn1.instantiate()
		g1.position = Vector3(0.5, 0.42, -2.58)
		g1.rotation_degrees = Vector3(0, 0, 0)
		g1.scale = Vector3(0.95, 0.95, 0.95)
		var decor_script = load("res://scripts/decor_character.gd")
		g1.set_script(decor_script)
		g1.set("anim_name", "sit")
		f_root.add_child(g1)

	var guest_scn2 = load("res://assets/models/characters/character-male-b.glb")
	if guest_scn2 != null:
		var g2 = guest_scn2.instantiate()
		g2.position = Vector3(0.5, 0.42, 1.48)
		g2.rotation_degrees = Vector3(0, 180, 0)
		g2.scale = Vector3(0.95, 0.95, 0.95)
		var decor_script = load("res://scripts/decor_character.gd")
		g2.set_script(decor_script)
		g2.set("anim_name", "sit")
		f_root.add_child(g2)

	# Decorative Potted Plants in Corners
	var plant_scn = load("res://assets/models/furniture/pottedPlant.glb")
	if plant_scn != null:
		var p1 = plant_scn.instantiate()
		p1.position = Vector3(-3.3, 0.0, -2.8)
		p1.scale = Vector3(1.4, 1.4, 1.4)
		f_root.add_child(p1)

		var p2 = plant_scn.instantiate()
		p2.position = Vector3(3.5, 0.0, -2.8)
		p2.scale = Vector3(1.4, 1.4, 1.4)
		f_root.add_child(p2)

func _setup_kitchen_fidelity() -> void:
	# 1. Silver Dome Heat Lamps & Pass Elements above Pass Counter (1:1 with reference)
	var dining_hall = find_child("DiningHall", true, false)
	if dining_hall != null:
		var old_heat = dining_hall.get_node_or_null("PassHeatLamps")
		if old_heat != null:
			old_heat.name = "PassHeatLamps_Old"
			old_heat.queue_free()

		var heat_root = Node3D.new()
		heat_root.name = "PassHeatLamps"
		dining_hall.add_child(heat_root)

		var dome_mat = StandardMaterial3D.new()
		dome_mat.albedo_color = Color(0.92, 0.95, 0.98, 1.0)
		dome_mat.metallic = 0.95
		dome_mat.roughness = 0.15

		var cord_mat = StandardMaterial3D.new()
		cord_mat.albedo_color = Color(0.18, 0.18, 0.20, 1.0)
		cord_mat.metallic = 0.8
		cord_mat.roughness = 0.3

		var bulb_mat = StandardMaterial3D.new()
		bulb_mat.albedo_color = Color(1.0, 0.85, 0.45, 1.0)
		bulb_mat.emission_enabled = true
		bulb_mat.emission = Color(1.0, 0.78, 0.32, 1.0)
		bulb_mat.emission_energy_multiplier = 3.0

		for hx in [4.6, 6.5, 8.4]:
			var lamp = Node3D.new()
			lamp.position = Vector3(hx, 2.25, -3.4)
			heat_root.add_child(lamp)

			var cord = CSGCylinder3D.new()
			cord.radius = 0.012
			cord.height = 0.55
			cord.position = Vector3(0, 0.275, 0)
			cord.material = cord_mat
			lamp.add_child(cord)

			var dome = MeshInstance3D.new()
			var dmesh = CylinderMesh.new()
			dmesh.top_radius = 0.08
			dmesh.bottom_radius = 0.28
			dmesh.height = 0.18
			dome.mesh = dmesh
			dome.material_override = dome_mat
			lamp.add_child(dome)

			var bulb = MeshInstance3D.new()
			var bmesh = SphereMesh.new()
			bmesh.radius = 0.05
			bmesh.height = 0.10
			bulb.mesh = bmesh
			bulb.position = Vector3(0, -0.05, 0)
			bulb.material_override = bulb_mat
			lamp.add_child(bulb)

			var light = SpotLight3D.new()
			light.rotation_degrees = Vector3(-90, 0, 0)
			light.light_color = Color(1.0, 0.78, 0.32, 1.0)
			light.light_energy = 1.3
			light.spot_range = 3.2
			light.spot_angle = 45.0
			lamp.add_child(light)

		# Ceramic Plate Stacks along the pass counter
		var plate_mat = StandardMaterial3D.new()
		plate_mat.albedo_color = Color(0.96, 0.96, 0.94, 1.0)
		plate_mat.roughness = 0.2
		for px in [4.8, 8.2]:
			var stack_root = Node3D.new()
			stack_root.position = Vector3(px, 0.92, -3.4)
			heat_root.add_child(stack_root)
			for pi in range(8):
				var pmesh = CSGCylinder3D.new()
				pmesh.radius = 0.16
				pmesh.height = 0.018
				pmesh.position = Vector3(0, 0.009 + pi * 0.02, 0)
				pmesh.material = plate_mat
				stack_root.add_child(pmesh)

	if kitchen_container == null:
		return

	# Clean up previous fidelity root if reloading
	var old_f = kitchen_container.get_node_or_null("FidelityKitchenRoot")
	if old_f != null:
		old_f.name = "FidelityKitchenRoot_Old"
		old_f.queue_free()

	var f_root = Node3D.new()
	f_root.name = "FidelityKitchenRoot"
	kitchen_container.add_child(f_root)

	# --- Reusable Commercial Kitchen Materials ---
	var steel_mat = StandardMaterial3D.new()
	steel_mat.albedo_color = Color(0.85, 0.88, 0.90, 1.0)
	steel_mat.metallic = 0.90
	steel_mat.roughness = 0.25

	var dark_cast_mat = StandardMaterial3D.new()
	dark_cast_mat.albedo_color = Color(0.12, 0.12, 0.14, 1.0)
	dark_cast_mat.metallic = 0.82
	dark_cast_mat.roughness = 0.45

	var chrome_mat = StandardMaterial3D.new()
	chrome_mat.albedo_color = Color(0.92, 0.95, 0.98, 1.0)
	chrome_mat.metallic = 0.96
	chrome_mat.roughness = 0.15

	var oven_glass_mat = StandardMaterial3D.new()
	oven_glass_mat.albedo_color = Color(0.1, 0.12, 0.14, 0.85)
	oven_glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	oven_glass_mat.roughness = 0.1

	var flame_ring_mat = StandardMaterial3D.new()
	flame_ring_mat.albedo_color = Color(1.0, 0.48, 0.08, 1.0)
	flame_ring_mat.emission_enabled = true
	flame_ring_mat.emission = Color(1.0, 0.45, 0.05, 1.0)
	flame_ring_mat.emission_energy_multiplier = 3.8
	flame_ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	var steam_mat = StandardMaterial3D.new()
	steam_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	steam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	steam_mat.albedo_color = Color(1.0, 1.0, 1.0, 0.35)

	var steam_sphere = SphereMesh.new()
	steam_sphere.material = steam_mat
	steam_sphere.radius = 0.05
	steam_sphere.height = 0.10

	var sizzle_mat = StandardMaterial3D.new()
	sizzle_mat.albedo_color = Color(1.0, 0.65, 0.12, 1.0)
	sizzle_mat.emission_enabled = true
	sizzle_mat.emission = Color(1.0, 0.55, 0.05, 1.0)
	sizzle_mat.emission_energy_multiplier = 2.8

	var sizzle_mesh = BoxMesh.new()
	sizzle_mesh.material = sizzle_mat
	sizzle_mesh.size = Vector3(0.025, 0.025, 0.025)

	# --- 2. The 4 Heavy-Duty Commercial Stainless Steel Gas Stoves (CommercialStoveLine) ---
	var stove_root = Node3D.new()
	stove_root.name = "CommercialStoveLine"
	f_root.add_child(stove_root)

	var pan_scn = load("res://assets/kaykit_restaurant/gltf/pan_A.gltf")
	var burger_scn = load("res://assets/models/food/burger-cheese.glb")
	var chef_scn = load("res://scenes/chef.tscn")

	var stove_x_list = [4.25, 5.75, 7.25, 8.75]
	var stove_z = -9.6

	for i in range(4):
		var sx = stove_x_list[i]
		var stove_unit = Node3D.new()
		stove_unit.name = "StoveUnit_%d" % i
		stove_root.add_child(stove_unit)

		# Stainless steel cabinet body
		var body = CSGBox3D.new()
		body.size = Vector3(1.22, 0.88, 0.95)
		body.position = Vector3(sx, 0.44, stove_z)
		body.material = steel_mat
		stove_unit.add_child(body)

		# Dark cast-iron kickplate at base
		var kickplate = CSGBox3D.new()
		kickplate.size = Vector3(1.22, 0.08, 0.96)
		kickplate.position = Vector3(sx, 0.04, stove_z)
		kickplate.material = dark_cast_mat
		stove_unit.add_child(kickplate)

		# Front oven door frame
		var door = CSGBox3D.new()
		door.size = Vector3(1.06, 0.52, 0.04)
		door.position = Vector3(sx, 0.36, stove_z + 0.48)
		door.material = steel_mat
		stove_unit.add_child(door)

		# Oven window (tinted dark glass)
		var window = CSGBox3D.new()
		window.size = Vector3(0.72, 0.32, 0.05)
		window.position = Vector3(sx, 0.36, stove_z + 0.485)
		window.material = oven_glass_mat
		stove_unit.add_child(window)

		# Oven door chrome handle
		var handle = CSGCylinder3D.new()
		handle.radius = 0.016
		handle.height = 0.65
		handle.position = Vector3(sx, 0.54, stove_z + 0.51)
		handle.rotation_degrees = Vector3(0, 0, 90)
		handle.material = chrome_mat
		stove_unit.add_child(handle)

		# Front control panel band
		var ctrl_panel = CSGBox3D.new()
		ctrl_panel.size = Vector3(1.22, 0.16, 0.04)
		ctrl_panel.position = Vector3(sx, 0.74, stove_z + 0.48)
		ctrl_panel.material = steel_mat
		stove_unit.add_child(ctrl_panel)

		# 4 rotary burner control knobs
		for ki in range(4):
			var knob = CSGCylinder3D.new()
			knob.radius = 0.024
			knob.height = 0.025
			knob.position = Vector3(sx - 0.36 + ki * 0.24, 0.74, stove_z + 0.51)
			knob.rotation_degrees = Vector3(90, 0, 0)
			knob.material = dark_cast_mat
			stove_unit.add_child(knob)

		# Cast-iron top cooktop surface
		var cooktop = CSGBox3D.new()
		cooktop.size = Vector3(1.22, 0.04, 0.95)
		cooktop.position = Vector3(sx, 0.89, stove_z)
		cooktop.material = dark_cast_mat
		stove_unit.add_child(cooktop)

		# Cast-iron grates on cooktop
		for gi in range(2):
			var grate = CSGBox3D.new()
			grate.size = Vector3(0.50, 0.025, 0.40)
			var gz_offset = -0.20 if gi == 0 else 0.20
			grate.position = Vector3(sx, 0.915, stove_z + gz_offset)
			grate.material = dark_cast_mat
			stove_unit.add_child(grate)

		# Front active glowing orange flame ring
		var flame = CSGCylinder3D.new()
		flame.radius = 0.17
		flame.height = 0.015
		flame.position = Vector3(sx, 0.915, stove_z + 0.20)
		flame.material = flame_ring_mat
		stove_unit.add_child(flame)

		# Warm flame glow light
		var flame_glow = OmniLight3D.new()
		flame_glow.position = Vector3(sx, 0.96, stove_z + 0.20)
		flame_glow.light_color = Color(1.0, 0.52, 0.12, 1.0)
		flame_glow.light_energy = 0.85
		flame_glow.omni_range = 1.3
		stove_unit.add_child(flame_glow)

		# Alternating Cookware: Stoves 0 & 2 have sizzling frying pans; Stoves 1 & 3 have simmering stockpots
		if (i % 2) == 0:
			# Sizzling Frying Pan
			if pan_scn != null:
				var pan_inst = pan_scn.instantiate()
				pan_inst.position = Vector3(sx, 0.925, stove_z + 0.20)
				pan_inst.scale = Vector3(0.65, 0.65, 0.65)
				stove_unit.add_child(pan_inst)

			if burger_scn != null:
				var patty = burger_scn.instantiate()
				patty.position = Vector3(sx, 0.95, stove_z + 0.20)
				patty.scale = Vector3(0.40, 0.40, 0.40)
				stove_unit.add_child(patty)

			# Sizzle sparks
			var sparks = CPUParticles3D.new()
			sparks.position = Vector3(sx, 0.98, stove_z + 0.20)
			sparks.amount = 8
			sparks.lifetime = 0.4
			sparks.mesh = sizzle_mesh
			sparks.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
			sparks.emission_sphere_radius = 0.12
			sparks.direction = Vector3(0, 1, 0)
			sparks.spread = 55.0
			sparks.gravity = Vector3(0, -2.5, 0)
			sparks.initial_velocity_min = 0.6
			sparks.initial_velocity_max = 1.1
			stove_unit.add_child(sparks)

			# Simmering steam
			var steam = CPUParticles3D.new()
			steam.position = Vector3(sx, 0.98, stove_z + 0.20)
			steam.amount = 12
			steam.lifetime = 1.2
			steam.mesh = steam_sphere
			steam.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
			steam.emission_sphere_radius = 0.14
			steam.direction = Vector3(0, 1, 0)
			steam.spread = 20.0
			steam.gravity = Vector3(0, 0.5, 0)
			steam.initial_velocity_min = 0.25
			steam.initial_velocity_max = 0.55
			stove_unit.add_child(steam)
		else:
			# Large Stainless Stockpot with Dual Chrome Loop Handles
			var pot = CSGCylinder3D.new()
			pot.radius = 0.22
			pot.height = 0.36
			pot.position = Vector3(sx, 1.09, stove_z + 0.20)
			pot.material = steel_mat
			stove_unit.add_child(pot)

			# Simmering stew surface inside the pot
			var stew = CSGCylinder3D.new()
			stew.radius = 0.20
			stew.height = 0.02
			stew.position = Vector3(sx, 1.24, stove_z + 0.20)
			var stew_mat = StandardMaterial3D.new()
			stew_mat.albedo_color = Color(0.85, 0.35, 0.12, 1.0) if i == 1 else Color(0.25, 0.65, 0.35, 1.0)
			stew_mat.roughness = 0.3
			stew.material = stew_mat
			stove_unit.add_child(stew)

			# Chrome loop handles
			for side in [-1, 1]:
				var handle_loop = CSGTorus3D.new()
				handle_loop.inner_radius = 0.025
				handle_loop.outer_radius = 0.045
				handle_loop.position = Vector3(sx + side * 0.23, 1.18, stove_z + 0.20)
				handle_loop.rotation_degrees = Vector3(90, 0, 0)
				handle_loop.material = chrome_mat
				stove_unit.add_child(handle_loop)

			# Simmering steam rising into the exhaust hood
			var pot_steam = CPUParticles3D.new()
			pot_steam.position = Vector3(sx, 1.28, stove_z + 0.20)
			pot_steam.amount = 16
			pot_steam.lifetime = 1.3
			pot_steam.mesh = steam_sphere
			pot_steam.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
			pot_steam.emission_sphere_radius = 0.16
			pot_steam.direction = Vector3(0, 1, 0)
			pot_steam.spread = 18.0
			pot_steam.gravity = Vector3(0, 0.6, 0)
			pot_steam.initial_velocity_min = 0.3
			pot_steam.initial_velocity_max = 0.65
			stove_unit.add_child(pot_steam)

	# --- 3. Continuous Overhead Stainless Exhaust Hood Canopy and Ducts ---
	var hood_canopy = CSGBox3D.new()
	hood_canopy.size = Vector3(6.0, 0.46, 1.15)
	hood_canopy.position = Vector3(6.5, 2.45, stove_z)
	hood_canopy.material = steel_mat
	stove_root.add_child(hood_canopy)

	# Tapered lower lip of hood canopy
	var hood_lip = CSGBox3D.new()
	hood_lip.size = Vector3(6.08, 0.08, 1.22)
	hood_lip.position = Vector3(6.5, 2.22, stove_z)
	hood_lip.material = chrome_mat
	stove_root.add_child(hood_lip)

	# 4 Vertical Silver Ducts rising from canopy into ceiling
	for sx in stove_x_list:
		var duct = CSGCylinder3D.new()
		duct.radius = 0.13
		duct.height = 0.85
		duct.position = Vector3(sx, 2.88, stove_z)
		duct.material = chrome_mat
		stove_root.add_child(duct)

		# Under-hood task spotlights illuminating the stoves
		var task_light = SpotLight3D.new()
		task_light.position = Vector3(sx, 2.18, stove_z + 0.10)
		task_light.rotation_degrees = Vector3(-90, 0, 0)
		task_light.light_color = Color(1.0, 0.94, 0.82, 1.0)
		task_light.light_energy = 0.75
		task_light.spot_range = 2.0
		task_light.spot_angle = 50.0
		stove_root.add_child(task_light)

	# --- 4. The 4 Active Line Chefs Stationed at the Stoves ---
	if chef_scn != null:
		for i in range(4):
			var sx = stove_x_list[i]
			var c = chef_scn.instantiate()
			c.name = "KitchenLineChef_%d" % i
			c.position = Vector3(sx, 0.0, -8.65)
			c.rotation_degrees = Vector3(0, 180, 0)
			c.set("chef_index", i)
			c.set("has_pan", (i % 2) == 0)
			stove_root.add_child(c)

	# --- 5. Center Prep Island & Fresh Produce Crates ---
	var prep_tbl_scn = load("res://assets/kaykit_restaurant/gltf/kitchentable_A_large_decorated.gltf")
	if prep_tbl_scn != null:
		var ptable = prep_tbl_scn.instantiate()
		ptable.position = Vector3(6.0, 0.0, -6.1)
		ptable.scale = Vector3(1.15, 1.15, 1.15)
		f_root.add_child(ptable)

	# Produce crates beside prep table
	var carrot_scn = load("res://assets/kaykit_restaurant/gltf/crate_carrots.gltf")
	if carrot_scn != null:
		var c_crate = carrot_scn.instantiate()
		c_crate.position = Vector3(4.55, 0.0, -6.1)
		c_crate.scale = Vector3(1.0, 1.0, 1.0)
		f_root.add_child(c_crate)

	var tomato_scn = load("res://assets/kaykit_restaurant/gltf/crate_tomatoes.gltf")
	if tomato_scn != null:
		var t_crate = tomato_scn.instantiate()
		t_crate.position = Vector3(7.45, 0.0, -6.1)
		t_crate.scale = Vector3(1.0, 1.0, 1.0)
		f_root.add_child(t_crate)

	# Prep Chef at Island
	if chef_scn != null:
		var pchef = chef_scn.instantiate()
		pchef.name = "KitchenPrepChef"
		pchef.position = Vector3(6.0, 0.0, -5.25)
		pchef.rotation_degrees = Vector3(0, 180, 0)
		pchef.set("is_prep_chef", true)
		pchef.set("chef_index", 4)
		f_root.add_child(pchef)

	# --- 6. Dual Commercial Refrigerators (Along West Divider Wall at X = 2.88) ---
	var fridge_scn = load("res://assets/models/furniture/kitchenFridgeLarge.glb")
	if fridge_scn != null:
		var fr1 = fridge_scn.instantiate()
		fr1.position = Vector3(2.88, 0.0, -9.2)
		fr1.rotation_degrees = Vector3(0, -90, 0)
		fr1.scale = Vector3(1.25, 1.25, 1.25)
		f_root.add_child(fr1)

		var fr2 = fridge_scn.instantiate()
		fr2.position = Vector3(2.88, 0.0, -7.6)
		fr2.rotation_degrees = Vector3(0, -90, 0)
		fr2.scale = Vector3(1.25, 1.25, 1.25)
		f_root.add_child(fr2)

	# --- 7. Double Dishwashing Sinks & Plate Rack (Along East Divider Wall at X = 10.1) ---
	var sink_scn = load("res://assets/kaykit_restaurant/gltf/kitchencounter_sink_backsplash.gltf")
	if sink_scn != null:
		var sk1 = sink_scn.instantiate()
		sk1.position = Vector3(10.1, 0.0, -8.6)
		sk1.rotation_degrees = Vector3(0, 90, 0)
		sk1.scale = Vector3(1.15, 1.15, 1.15)
		f_root.add_child(sk1)

		var sk2 = sink_scn.instantiate()
		sk2.position = Vector3(10.1, 0.0, -7.2)
		sk2.rotation_degrees = Vector3(0, 90, 0)
		sk2.scale = Vector3(1.15, 1.15, 1.15)
		f_root.add_child(sk2)

	# Counter table with Plate Dishrack at Z = -5.8
	var counter_straight_scn = load("res://assets/kaykit_restaurant/gltf/kitchencounter_straight_A.gltf")
	if counter_straight_scn != null:
		var c_straight = counter_straight_scn.instantiate()
		c_straight.position = Vector3(10.1, 0.0, -5.8)
		c_straight.rotation_degrees = Vector3(0, 90, 0)
		c_straight.scale = Vector3(1.15, 1.15, 1.15)
		f_root.add_child(c_straight)

	var dishrack_scn = load("res://assets/kaykit_restaurant/gltf/dishrack_plates.gltf")
	if dishrack_scn != null:
		var dr = dishrack_scn.instantiate()
		dr.position = Vector3(10.1, 0.88, -5.8)
		dr.rotation_degrees = Vector3(0, 90, 0)
		dr.scale = Vector3(1.15, 1.15, 1.15)
		f_root.add_child(dr)


func _check_spawn_hired_staff() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm == null or waiter_scene == null:
		return
		
	# Check Waiter 2 (Sophia active on floor for bustling 2-server workflow)
	if not _has_waiter("waiter_2"):
		var w2 = waiter_scene.instantiate()
		w2.name = "Waiter2"
		w2.staff_id = "waiter_2"
		w2.staff_name = "Sophia"
		w2.position = Vector3(1.8, 0.0, 0.5)
		add_child(w2)
		waiters.append(w2)
		
	# Check Waiter 3 (Lucas - VIP Concierge)
	if gm.is_staff_hired("waiter_3") and not _has_waiter("waiter_3"):
		var w3 = waiter_scene.instantiate()
		w3.name = "Waiter3"
		w3.staff_id = "waiter_3"
		w3.staff_name = "Lucas"
		w3.position = Vector3(5.2, 0.0, 0.5)
		add_child(w3)
		waiters.append(w3)

	# Check Waiter 4 (Elena - Banquet Server)
	if gm.is_staff_hired("waiter_4") and not _has_waiter("waiter_4"):
		var w4 = waiter_scene.instantiate()
		w4.name = "Waiter4"
		w4.staff_id = "waiter_4"
		w4.staff_name = "Elena"
		w4.position = Vector3(8.6, 0.0, 0.5)
		add_child(w4)
		waiters.append(w4)

	# Check Sous Chef Antoine
	if gm.is_staff_hired("chef_sous") and not _has_sous_chef():
		var chef_scn = load("res://scenes/chef.tscn")
		if chef_scn != null and kitchen_container != null:
			var sc = chef_scn.instantiate()
			sc.name = "ChefSous"
			sc.position = Vector3(5.5, 0.0, -9.0)
			sc.rotation_degrees.y = 180.0
			sc.set("chef_index", 1)
			kitchen_container.add_child(sc)

	# Check Pastry Chef Marcel
	if gm.is_staff_hired("chef_pastry") and not _has_pastry_chef():
		var chef_scn = load("res://scenes/chef.tscn")
		if chef_scn != null and kitchen_container != null:
			var pc = chef_scn.instantiate()
			pc.name = "ChefPastry"
			pc.position = Vector3(8.5, 0.0, -8.65)
			pc.rotation_degrees.y = 180.0
			pc.set("chef_index", 3)
			kitchen_container.add_child(pc)

	# Check Floor Manager Arthur
	if gm.is_staff_hired("manager") and not _has_floor_manager():
		_spawn_floor_manager()

	# Check Janitor Otis
	if gm.is_staff_hired("janitor") and not _has_janitor():
		_spawn_janitor()

func _has_waiter(sid: String) -> bool:
	for w in waiters:
		if is_instance_valid(w) and w.get("staff_id") == sid:
			return true
	return false

func _has_sous_chef() -> bool:
	if kitchen_container == null:
		return false
	return kitchen_container.find_child("ChefSous", true, false) != null

func _has_pastry_chef() -> bool:
	if kitchen_container == null:
		return false
	return kitchen_container.find_child("ChefPastry", true, false) != null

func _has_floor_manager() -> bool:
	return floor_manager != null and is_instance_valid(floor_manager)

func _has_janitor() -> bool:
	return janitor_character != null and is_instance_valid(janitor_character)

func _spawn_floor_manager() -> void:
	if _has_floor_manager():
		return
	var char_scn = load("res://assets/models/characters/character-male-d.glb")
	if char_scn == null:
		return
	var mgr = char_scn.instantiate()
	mgr.name = "FloorManager"
	mgr.position = Vector3(14.5, 0.0, -8.05)
	mgr.rotation_degrees = Vector3(0, 0, 0)
	mgr.scale = Vector3(1.15, 1.15, 1.15)
	
	var lbl = Label3D.new()
	lbl.name = "ManagerStatus"
	lbl.text = "💼 Arthur (GM)"
	lbl.font_size = 18
	lbl.pixel_size = 0.004
	lbl.position = Vector3(0, 1.85, 0)
	lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lbl.modulate = Color(1.0, 0.85, 0.3, 1.0)
	mgr.add_child(lbl)
	manager_status_label = lbl
	
	var light = OmniLight3D.new()
	light.name = "InspectionAuraLight"
	light.light_color = Color(1.0, 0.84, 0.25, 1.0)
	light.light_energy = 0.0
	light.omni_range = 3.5
	light.position = Vector3(0, 1.2, 0)
	mgr.add_child(light)
	manager_aura_light = light
	
	var anim = _find_anim_player_in(mgr)
	if anim != null and anim.has_animation("sit"):
		anim.play("sit")
	elif anim != null and anim.has_animation("idle"):
		anim.play("idle")
		
	add_child(mgr)
	floor_manager = mgr

func _spawn_janitor() -> void:
	if _has_janitor():
		return
	var char_scn = load("res://assets/models/characters/character-male-b.glb")
	if char_scn == null:
		return
	var jan = char_scn.instantiate()
	jan.name = "JanitorOtis"
	jan.position = Vector3(10.2, 0.0, 0.5)
	jan.rotation_degrees = Vector3(0, 180, 0)
	jan.scale = Vector3(1.15, 1.15, 1.15)
	
	var lbl = Label3D.new()
	lbl.name = "JanitorStatus"
	lbl.text = "🧹 Otis (Custodian)"
	lbl.font_size = 18
	lbl.pixel_size = 0.004
	lbl.position = Vector3(0, 1.85, 0)
	lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lbl.modulate = Color(0.4, 0.8, 1.0, 1.0)
	jan.add_child(lbl)
	janitor_status_label = lbl
	
	var broom = CSGCylinder3D.new()
	broom.name = "BroomProp"
	broom.radius = 0.02
	broom.height = 1.1
	broom.position = Vector3(0.25, 0.55, 0.2)
	broom.rotation_degrees = Vector3(15, 0, -10)
	var b_mat = StandardMaterial3D.new()
	b_mat.albedo_color = Color(0.72, 0.52, 0.28, 1.0)
	broom.material = b_mat
	jan.add_child(broom)
	
	add_child(jan)
	janitor_character = jan

func _start_manager_inspection_tour() -> void:
	if floor_manager == null or manager_is_touring:
		return
	manager_is_touring = true
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.set_manager_inspection_active(true)
		
	if manager_status_label != null:
		manager_status_label.text = "📋 Floor Inspection Active (+25% Boost!)"
		manager_status_label.modulate = Color(0.2, 1.0, 0.5, 1.0)
		
	if manager_aura_light != null:
		var tw = create_tween()
		tw.tween_property(manager_aura_light, "light_energy", 1.8, 0.5)
		
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("chime", 0.0, 1.0)
		
	manager_tour_waypoints = [
		Vector3(14.5, 0.0, -6.5),
		Vector3(12.0, 0.0, -6.5),
		Vector3(10.5, 0.0, -5.5),
		Vector3(7.5, 0.0, -5.5),
		Vector3(6.5, 0.0, -3.2),
		Vector3(6.9, 0.0, -1.0),
		Vector3(6.9, 0.0, 2.0),
		Vector3(3.3, 0.0, 2.0),
		Vector3(3.3, 0.0, -1.0),
		Vector3(10.5, 0.0, -1.0),
		Vector3(12.0, 0.0, -6.5),
		Vector3(14.5, 0.0, -6.5),
		Vector3(14.5, 0.0, -8.05)
	]
	
	var anim = _find_anim_player_in(floor_manager)
	if anim != null and anim.has_animation("walk"):
		var a = anim.get_animation("walk")
		if a != null: a.loop_mode = Animation.LOOP_LINEAR
		anim.play("walk")

func _process_floor_manager(delta: float) -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm == null or not gm.is_staff_hired("manager"):
		return
	if floor_manager == null:
		_spawn_floor_manager()
		return
		
	if not manager_is_touring:
		manager_tour_timer -= delta
		if manager_tour_timer <= 0.0:
			_start_manager_inspection_tour()
	else:
		if manager_tour_waypoints.size() > 0:
			var target = manager_tour_waypoints[0]
			var to_tgt = target - floor_manager.position
			to_tgt.y = 0.0
			var dist = to_tgt.length()
			if dist > 0.25:
				var dir = to_tgt.normalized()
				var mgr_spd = 2.8 * gm.get_staff_speed_multiplier("manager")
				floor_manager.position += dir * mgr_spd * delta
				var yaw = atan2(dir.x, dir.z)
				floor_manager.rotation.y = lerp_angle(floor_manager.rotation.y, yaw, 10.0 * delta)
			else:
				manager_tour_waypoints.remove_at(0)
				if manager_tour_waypoints.size() == 0:
					manager_is_touring = false
					floor_manager.position = Vector3(14.5, 0.0, -8.05)
					floor_manager.rotation.y = 0.0
					gm.set_manager_inspection_active(false)
					if manager_status_label != null:
						manager_status_label.text = "💼 Arthur (GM)"
						manager_status_label.modulate = Color(1.0, 0.85, 0.3, 1.0)
					if manager_aura_light != null:
						var tw = create_tween()
						tw.tween_property(manager_aura_light, "light_energy", 0.0, 0.5)
					var anim = _find_anim_player_in(floor_manager)
					if anim != null and anim.has_animation("sit"):
						anim.play("sit")
					elif anim != null and anim.has_animation("idle"):
						anim.play("idle")
					manager_tour_timer = randf_range(45.0, 65.0)

func _process_janitor(delta: float) -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm == null or not gm.is_staff_hired("janitor"):
		return
	if janitor_character == null:
		_spawn_janitor()
		return
		
	if janitor_on_break:
		return
		
	if janitor_waypoints.size() > 0:
		var target = janitor_waypoints[0]
		var to_tgt = target - janitor_character.position
		to_tgt.y = 0.0
		var dist = to_tgt.length()
		if dist > 0.25:
			var dir = to_tgt.normalized()
			var spd = janitor_speed * gm.get_staff_speed_multiplier("janitor")
			if gm.has_method("get_card_cleaning_multiplier"):
				spd *= gm.get_card_cleaning_multiplier()
			janitor_character.position += dir * spd * delta
			var yaw = atan2(dir.x, dir.z)
			janitor_character.rotation.y = lerp_angle(janitor_character.rotation.y, yaw, 10.0 * delta)
		else:
			janitor_waypoints.remove_at(0)
			if janitor_waypoints.size() == 0:
				var anim = _find_anim_player_in(janitor_character)
				if anim != null and anim.has_animation("idle"):
					anim.play("idle")
	else:
		janitor_patrol_timer -= delta
		if janitor_patrol_timer <= 0.0:
			janitor_patrol_timer = randf_range(12.0, 20.0)
			var dirty_tbl: Node3D = null
			if tables_container != null:
				for tbl in tables_container.get_children():
					if tbl.get("is_dirty") == true:
						dirty_tbl = tbl
						break
			if dirty_tbl != null:
				if janitor_status_label != null:
					janitor_status_label.text = "🧹 Sanitizing Table..."
				janitor_waypoints = [
					Vector3(dirty_tbl.global_position.x + 0.8, 0.0, dirty_tbl.global_position.z)
				]
				var anim = _find_anim_player_in(janitor_character)
				if anim != null and anim.has_animation("walk"):
					var a = anim.get_animation("walk")
					if a != null: a.loop_mode = Animation.LOOP_LINEAR
					anim.play("walk")
				get_tree().create_timer(3.5).timeout.connect(func():
					if is_instance_valid(dirty_tbl) and dirty_tbl.has_method("clean_table"):
						dirty_tbl.clean_table()
						if janitor_status_label != null:
							janitor_status_label.text = "🧹 Table Cleaned! ⭐"
				)
			else:
				var patrol_spots = [
					Vector3(3.3, 0.0, 2.5),
					Vector3(6.9, 0.0, 1.5),
					Vector3(10.2, 0.0, 0.5),
					Vector3(6.9, 0.0, -1.0)
				]
				var next_spot = patrol_spots.pick_random()
				janitor_waypoints = [next_spot]
				var anim = _find_anim_player_in(janitor_character)
				if anim != null and anim.has_animation("walk"):
					var a = anim.get_animation("walk")
					if a != null: a.loop_mode = Animation.LOOP_LINEAR
					anim.play("walk")
				if janitor_status_label != null:
					janitor_status_label.text = "🧹 Sweeping Aisles"

func _process_breakroom_routine(delta: float) -> void:
	breakroom_routine_timer -= delta
	if breakroom_routine_timer <= 0.0:
		breakroom_routine_timer = randf_range(48.0, 72.0)
		_dispatch_breakroom_routine()

func _dispatch_breakroom_routine() -> void:
	var idle_waiters: Array[Node3D] = []
	for w in waiters:
		if is_instance_valid(w) and w.get("current_state") == 0:
			idle_waiters.append(w)
			
	if idle_waiters.size() > 0:
		var chosen_w = idle_waiters.pick_random()
		var use_sofa = randf() > 0.45
		var spot = Vector3(14.6, 0.0, -2.2) if use_sofa else Vector3(12.6, 0.0, -2.8)
		if chosen_w.has_method("take_breakroom_rest"):
			chosen_w.take_breakroom_rest(spot, use_sofa)
		return
		
	if is_instance_valid(janitor_character) and not janitor_on_break:
		_send_janitor_to_breakroom()

func _send_janitor_to_breakroom() -> void:
	if not is_instance_valid(janitor_character) or janitor_on_break:
		return
	janitor_on_break = true
	var use_armchair = randf() > 0.5
	var target_spot = Vector3(13.2, 0.0, -1.5) if use_armchair else Vector3(11.8, 0.0, -2.7)
	if janitor_status_label != null:
		janitor_status_label.text = "☕ Coffee Break..." if not use_armchair else "☕ Sofa Rest..."
	janitor_waypoints = [
		Vector3(10.5, 0.0, -1.0),
		Vector3(11.5, 0.0, -1.5),
		target_spot
	]
	var anim = _find_anim_player_in(janitor_character)
	if anim != null and anim.has_animation("walk"):
		var a = anim.get_animation("walk")
		if a != null: a.loop_mode = Animation.LOOP_LINEAR
		anim.play("walk")
		
	get_tree().create_timer(6.5).timeout.connect(func():
		if is_instance_valid(janitor_character):
			if janitor_status_label != null:
				janitor_status_label.text = "☕ Refreshed! +30% Speed"
			janitor_waypoints = [
				Vector3(11.5, 0.0, -1.5),
				Vector3(10.5, 0.0, -1.0),
				Vector3(10.2, 0.0, 0.5)
			]
			var a2 = _find_anim_player_in(janitor_character)
			if a2 != null and a2.has_animation("walk"):
				a2.play("walk")
			get_tree().create_timer(3.5).timeout.connect(func():
				janitor_on_break = false
				if janitor_status_label != null:
					janitor_status_label.text = "🧹 Otis (Custodian)"
			)
	)

func _find_anim_player_in(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found = _find_anim_player_in(child)
		if found != null:
			return found
	return null

func _on_staff_updated(staff_id: String) -> void:
	_check_spawn_hired_staff()

var critic_timer: float = 35.0

func _process(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		var gm = get_node_or_null("/root/GameManager")
		var mult: float = 1.0
		if gm != null and gm.has_method("get_spawn_rate_multiplier"):
			mult = gm.get_spawn_rate_multiplier()
		spawn_timer = spawn_interval / mult
		_try_spawn_customer()
		
	critic_timer -= delta
	if critic_timer <= 0.0:
		critic_timer = randf_range(38.0, 52.0)
		_try_spawn_critic()
		
	_check_seat_waiting_customers()
	_dispatch_waiter_tasks()
	_process_lounge_bartender(delta)
	_process_diner_barista(delta)
	_process_floor_manager(delta)
	_process_janitor(delta)
	_process_breakroom_routine(delta)
	_process_sliding_doors(delta)

	# VIP Auto-Collector: automatically sweeps up floating cash stacks without tapping
	var gm_ref = get_node_or_null("/root/GameManager")
	if gm_ref != null and gm_ref.has_method("is_vip_auto_collector_active") and gm_ref.is_vip_auto_collector_active():
		if tables_container != null:
			for t in tables_container.get_children():
				if is_instance_valid(t) and t.has_method("has_visible_cash_stack") and t.has_visible_cash_stack():
					t.collect_booth_cash()

	if sign_board_mat != null:
		var gm = get_node_or_null("/root/GameManager")
		var m_lvl = gm.get_marketing_level() if gm != null else 1
		var m_bonus = (m_lvl - 1) * 0.16
		var pulse = sin(Time.get_ticks_msec() * 0.0035) * 0.75
		sign_board_mat.emission_energy_multiplier = clamp(4.0 + m_bonus + pulse, 3.2, 9.5)

func _init_sliding_doors() -> void:
	_sliding_door_left = get_node_or_null("BuildingWalls/SlidingDoorLeft")
	_sliding_door_right = get_node_or_null("BuildingWalls/SlidingDoorRight")
	_door_pane_left = get_node_or_null("BuildingWalls/DoorPaneLeft")
	_door_pane_right = get_node_or_null("BuildingWalls/DoorPaneRight")
	_door_handle_left = get_node_or_null("BuildingWalls/DoorHandleLeft")
	_door_handle_right = get_node_or_null("BuildingWalls/DoorHandleRight")

func _process_sliding_doors(delta: float) -> void:
	if _sliding_door_left == null and _door_pane_left == null:
		_init_sliding_doors()
		if _sliding_door_left == null and _door_pane_left == null:
			return

	var should_open: bool = false
	# Check approaching / passing customers
	if customers_container != null:
		for cust in customers_container.get_children():
			if is_instance_valid(cust) and cust is Node3D:
				var dist = cust.global_position.distance_to(SLIDE_DOOR_POS)
				if dist < 3.2:
					should_open = true
					break

	# Check approaching staff or janitor
	if not should_open:
		for staff_node in get_tree().get_nodes_in_group("staff"):
			if is_instance_valid(staff_node):
				if staff_node.global_position.distance_to(SLIDE_DOOR_POS) < 2.5:
					should_open = true
					break

	var target_ratio: float = 1.0 if should_open else 0.0
	_door_open_ratio = move_toward(_door_open_ratio, target_ratio, delta * 3.2)

	if _sliding_door_left != null:
		_sliding_door_left.position.x = -SLIDE_DOOR_MAX_OFFSET * _door_open_ratio
	elif _door_pane_left != null:
		_door_pane_left.position.x = _door_left_base_x - SLIDE_DOOR_MAX_OFFSET * _door_open_ratio
		if _door_handle_left != null:
			_door_handle_left.position.x = _handle_left_base_x - SLIDE_DOOR_MAX_OFFSET * _door_open_ratio

	if _sliding_door_right != null:
		_sliding_door_right.position.x = SLIDE_DOOR_MAX_OFFSET * _door_open_ratio
	elif _door_pane_right != null:
		_door_pane_right.position.x = _door_right_base_x + SLIDE_DOOR_MAX_OFFSET * _door_open_ratio
		if _door_handle_right != null:
			_door_handle_right.position.x = _handle_right_base_x + SLIDE_DOOR_MAX_OFFSET * _door_open_ratio

func _setup_active_service_sectors() -> void:
	lounge_seats.clear()
	diner_seats.clear()
	pending_lounge_orders.clear()
	pending_diner_orders.clear()

	# Remove legacy static patrons so all seats are dynamically occupied
	for static_name in ["WaitingGuest", "WaitingGuest1A", "WaitingGuest1B"]:
		var static_g = find_child(static_name, true, false)
		if static_g != null:
			static_g.queue_free()

	# 1. Cocktail Lounge Seats (6 mahogany bar stools + 4 round mahogany tables)
	for i in range(6):
		var sx = -9.2 + i * 0.8
		lounge_seats.append({
			"id": "lounge_stool_%d" % i,
			"type": "stool",
			"seat_pos": Vector3(sx, 0.45, -1.25),
			"seat_rot_y": PI,
			"counter_pos": Vector3(sx, 0.88, -2.15),
			"is_occupied": false,
			"customer": null,
			"dish_instance": null,
			"table_node": null
		})

	var rec_room = find_child("ReceptionRoom", true, false)
	var lounge_tbl_coords = [
		{"name": "WaitingTable1", "pos": Vector3(-6.2, 0.0, 0.6), "seat": Vector3(-6.2, 0.45, 1.25), "c_pos": Vector3(-6.2, 0.78, 0.6)},
		{"name": "WaitingTable2", "pos": Vector3(-9.2, 0.0, 1.8), "seat": Vector3(-9.2, 0.45, 2.45), "c_pos": Vector3(-9.2, 0.78, 1.8)},
		{"name": "WaitingTable3", "pos": Vector3(-5.6, 0.0, 3.4), "seat": Vector3(-5.6, 0.45, 4.05), "c_pos": Vector3(-5.6, 0.78, 3.4)},
		{"name": "WaitingTable4", "pos": Vector3(-8.6, 0.0, 4.8), "seat": Vector3(-8.6, 0.45, 5.45), "c_pos": Vector3(-8.6, 0.78, 4.8)}
	]
	for t_info in lounge_tbl_coords:
		var tbl_node = rec_room.find_child(t_info["name"], true, false) if rec_room != null else null
		lounge_seats.append({
			"id": "lounge_" + t_info["name"],
			"type": "table",
			"seat_pos": t_info["seat"],
			"seat_rot_y": PI,
			"counter_pos": t_info["c_pos"],
			"is_occupied": false,
			"customer": null,
			"dish_instance": null,
			"table_node": tbl_node
		})

	# 2. 50s Milkshake & Soda Diner Seats (6 soda stools + 4 diner tables)
	var stool_z_list = [-2.1, -1.25, -0.4, 0.45, 1.3, 2.15]
	for i in range(stool_z_list.size()):
		var sz = stool_z_list[i]
		diner_seats.append({
			"id": "diner_stool_%d" % i,
			"type": "stool",
			"seat_pos": Vector3(-8.85, 0.42, -7.0 + sz),
			"seat_rot_y": -PI * 0.5,
			"counter_pos": Vector3(-9.7, 0.95, -7.0 + sz),
			"is_occupied": false,
			"customer": null,
			"dish_instance": null,
			"table_node": null
		})

	var diner_tbl_coords = [
		{"name": "DinerTable1", "pos": Vector3(-7.0, 0.0, -8.9), "seat": Vector3(-7.0, 0.42, -8.22), "c_pos": Vector3(-7.0, 0.76, -8.9)},
		{"name": "DinerTable2", "pos": Vector3(-4.9, 0.0, -8.9), "seat": Vector3(-4.9, 0.42, -8.22), "c_pos": Vector3(-4.9, 0.76, -8.9)},
		{"name": "DinerTable3", "pos": Vector3(-7.0, 0.0, -6.2), "seat": Vector3(-7.0, 0.42, -5.52), "c_pos": Vector3(-7.0, 0.76, -6.2)},
		{"name": "DinerTable4", "pos": Vector3(-4.9, 0.0, -6.2), "seat": Vector3(-4.9, 0.42, -5.52), "c_pos": Vector3(-4.9, 0.76, -6.2)}
	]
	var shake_bar = find_child("MilkshakeBar", true, false)
	for dt_info in diner_tbl_coords:
		var tbl_node = shake_bar.find_child(dt_info["name"], true, false) if shake_bar != null else null
		diner_seats.append({
			"id": "diner_" + dt_info["name"],
			"type": "table",
			"seat_pos": dt_info["seat"],
			"seat_rot_y": PI,
			"counter_pos": dt_info["c_pos"],
			"is_occupied": false,
			"customer": null,
			"dish_instance": null,
			"table_node": tbl_node
		})

func _get_available_lounge_seats() -> Array[Dictionary]:
	var avail: Array[Dictionary] = []
	for s in lounge_seats:
		if not s["is_occupied"]:
			avail.append(s)
	return avail

func _get_available_diner_seats() -> Array[Dictionary]:
	var avail: Array[Dictionary] = []
	for s in diner_seats:
		if not s["is_occupied"]:
			avail.append(s)
	return avail

func _seat_customer_in_lounge(cust: Node3D, seat: Dictionary) -> void:
	seat["is_occupied"] = true
	seat["customer"] = cust
	cust.lounge_drink_finished.connect(_on_lounge_drink_finished)
	cust.order_placed.connect(_on_customer_order_placed)
	cust.assign_lounge_seat(seat["seat_pos"], seat["seat_rot_y"], seat["id"], seat.get("table_node"))

func _seat_customer_in_diner(cust: Node3D, seat: Dictionary) -> void:
	seat["is_occupied"] = true
	seat["customer"] = cust
	cust.diner_treat_finished.connect(_on_diner_treat_finished)
	cust.order_placed.connect(_on_customer_order_placed)
	cust.assign_milkshake_seat(seat["seat_pos"], seat["seat_rot_y"], seat["id"], seat.get("table_node"))

func _check_seat_waiting_customers() -> void:
	waiting_customers = waiting_customers.filter(func(c): return is_instance_valid(c) and c.current_state == c.State.WAITING_IN_LOBBY)
	if waiting_customers.size() == 0:
		return
		
	var avail_tables = _get_available_tables()
	var avail_lounge = _get_available_lounge_seats()
	var avail_diner = _get_available_diner_seats()
	
	if avail_tables.size() == 0 and avail_lounge.size() == 0 and avail_diner.size() == 0:
		return
		
	var cust = waiting_customers.pop_front()
	var hostess = find_child("Hostess", true, false)
	if hostess != null and hostess.has_method("greet_customer"):
		hostess.greet_customer()
		
	var roll = randf()
	if avail_tables.size() > 0 and (avail_lounge.size() == 0 and avail_diner.size() == 0 or roll < 0.5):
		var free_table: Node3D = avail_tables.pick_random()
		cust.assign_table_from_lobby(free_table)
	elif avail_lounge.size() > 0 and (avail_diner.size() == 0 or roll < 0.75):
		var free_seat = avail_lounge.pick_random()
		_seat_customer_in_lounge(cust, free_seat)
	elif avail_diner.size() > 0:
		var free_seat = avail_diner.pick_random()
		_seat_customer_in_diner(cust, free_seat)
	elif avail_tables.size() > 0:
		var free_table: Node3D = avail_tables.pick_random()
		cust.assign_table_from_lobby(free_table)

func _get_tables_targeted_by_waiters() -> Array[Node3D]:
	var targeted: Array[Node3D] = []
	for w in waiters:
		if is_instance_valid(w) and is_instance_valid(w.get("target_table")):
			targeted.append(w.target_table)
	return targeted

func _find_unclaimed_dirty_table(targeted: Array[Node3D]) -> Node3D:
	if tables_container == null:
		return null
	for tbl in tables_container.get_children():
		var is_dirty = tbl.get("is_dirty")
		var is_occupied = tbl.get("is_occupied")
		if is_dirty == true and not is_occupied and not tbl in targeted:
			return tbl
	return null

func _dispatch_waiter_tasks() -> void:
	var targeted = _get_tables_targeted_by_waiters()

	# 1. Top priority: Busboy clearing dirty tables & wiping booths to return them to active seating
	for w in waiters:
		if is_instance_valid(w) and w.get("current_state") == w.State.IDLE:
			var dirty_tbl = _find_unclaimed_dirty_table(targeted)
			if dirty_tbl != null:
				w.clean_dirty_table(dirty_tbl)
				targeted.append(dirty_tbl)

	# 2. Secondary priority: Serving freshly prepared meals from kitchen pass to seated diners
	if pending_orders.size() > 0:
		for w in waiters:
			if is_instance_valid(w) and w.get("current_state") == w.State.IDLE:
				var target_tbl = pending_orders.pop_front()
				if is_instance_valid(target_tbl) and target_tbl.get("is_occupied") == true:
					w.serve_order(target_tbl)
					targeted.append(target_tbl)
					if pending_orders.size() == 0:
						break

func _get_available_tables() -> Array[Node3D]:
	var available: Array[Node3D] = []
	if tables_container == null:
		return available
	for table in tables_container.get_children():
		var is_unlocked = table.get("is_unlocked")
		if is_unlocked == null:
			is_unlocked = true
		var is_occupied = table.get("is_occupied")
		var is_dirty = table.get("is_dirty")
		if is_unlocked and not is_occupied and not is_dirty:
			available.append(table)
	return available

func _try_spawn_customer() -> void:
	var avail_tables = _get_available_tables()
	var avail_lounge = _get_available_lounge_seats()
	var avail_diner = _get_available_diner_seats()
	var total_avail = avail_tables.size() + avail_lounge.size() + avail_diner.size()

	if total_avail > 0:
		var roll = randf()
		# 50% dining tables, 25% cocktail lounge, 25% milkshake diner
		if roll < 0.25 and avail_lounge.size() > 0:
			var free_seat = avail_lounge.pick_random()
			_spawn_customer_flow_lounge(free_seat)
		elif roll < 0.50 and avail_diner.size() > 0:
			var free_seat = avail_diner.pick_random()
			_spawn_customer_flow_diner(free_seat)
		elif avail_tables.size() > 0:
			var free_table: Node3D = avail_tables.pick_random()
			_spawn_customer_flow(free_table, false)
		elif avail_lounge.size() > 0:
			var free_seat = avail_lounge.pick_random()
			_spawn_customer_flow_lounge(free_seat)
		elif avail_diner.size() > 0:
			var free_seat = avail_diner.pick_random()
			_spawn_customer_flow_diner(free_seat)
	elif waiting_customers.size() < MAX_WAITING_CUSTOMERS and customer_scene != null:
		_spawn_waiting_customer_flow()

func _spawn_customer_flow_lounge(seat: Dictionary) -> void:
	if customer_scene == null: return
	var cust = customer_scene.instantiate()
	customers_container.add_child(cust)
	var spawn_pos: Vector3 = Vector3(-5.5, 0.0, 9.5)
	if spawn_marker != null: spawn_pos = spawn_marker.global_position
	cust.global_position = spawn_pos
	_seat_customer_in_lounge(cust, seat)

func _spawn_customer_flow_diner(seat: Dictionary) -> void:
	if customer_scene == null: return
	var cust = customer_scene.instantiate()
	customers_container.add_child(cust)
	var spawn_pos: Vector3 = Vector3(-5.5, 0.0, 9.5)
	if spawn_marker != null: spawn_pos = spawn_marker.global_position
	cust.global_position = spawn_pos
	_seat_customer_in_diner(cust, seat)

func _spawn_waiting_customer_flow() -> void:
	var cust = customer_scene.instantiate()
	customers_container.add_child(cust)
	
	var spawn_pos: Vector3 = Vector3(-5.5, 0.0, 9.5)
	if spawn_marker != null:
		spawn_pos = spawn_marker.global_position
	cust.global_position = spawn_pos
	
	var spot_idx = waiting_customers.size() % WAITING_SPOTS.size()
	var wait_spot = WAITING_SPOTS[spot_idx]
	cust.set_as_waiting_in_lobby(wait_spot)
	cust.order_placed.connect(_on_customer_order_placed)
	cust.lobby_wait_timeout.connect(func(c): waiting_customers.erase(c))
	waiting_customers.append(cust)

func _try_spawn_critic() -> void:
	var available = _get_available_tables()
	if available.size() == 0:
		return
		
	var free_table: Node3D = available.pick_random()
	_spawn_customer_flow(free_table, true)

func _spawn_customer_flow(table: Node3D, is_critic: bool = false) -> void:
	if customer_scene == null:
		return
	
	var cust = customer_scene.instantiate()
	customers_container.add_child(cust)
	
	var spawn_pos: Vector3 = Vector3(-5.5, 0.0, 9.5)
	if spawn_marker != null:
		spawn_pos = spawn_marker.global_position
	cust.global_position = spawn_pos
	
	if is_critic and cust.has_method("set_as_critic"):
		cust.set_as_critic(true)
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("bell", 0.05, 3.0)
	
	# Reserve table and assign
	if table.has_method("occupy"):
		table.occupy(cust)
	else:
		table.is_occupied = true
	cust.assigned_table_id = table.table_id
	cust.table_ref = table
	
	cust.current_state = cust.State.WALKING_TO_HOST
	cust.set_waypoints([cust.DOOR_POS, cust.HOST_POS])
	cust.order_placed.connect(_on_customer_order_placed)

func _on_customer_order_placed(table: Node3D, cust: Node3D) -> void:
	if not is_instance_valid(cust):
		return
	if cust.get("sector_type") == "lounge":
		for s in lounge_seats:
			if s["id"] == cust.get("seat_identifier") or s["customer"] == cust:
				var order_entry = {"customer": cust, "seat": s}
				if not pending_lounge_orders.has(order_entry):
					pending_lounge_orders.append(order_entry)
				break
		return
	elif cust.get("sector_type") == "milkshake":
		for s in diner_seats:
			if s["id"] == cust.get("seat_identifier") or s["customer"] == cust:
				var order_entry = {"customer": cust, "seat": s}
				if not pending_diner_orders.has(order_entry):
					pending_diner_orders.append(order_entry)
				break
		return

	if is_instance_valid(table) and table.is_occupied:
		_queue_order(table)

func _queue_order(table: Node3D) -> void:
	if not pending_orders.has(table):
		pending_orders.append(table)

func _process_lounge_bartender(_delta: float) -> void:
	if bartender_state != StaffState.IDLE or pending_lounge_orders.size() == 0:
		return
	var order = pending_lounge_orders.pop_front()
	if not is_instance_valid(order.get("customer")) or order["customer"].current_state != order["customer"].State.SEATED_ORDERING:
		return
	_run_bartender_service(order)

func _run_bartender_service(order: Dictionary) -> void:
	bartender_state = StaffState.PREPARING
	var cust = order["customer"]
	var seat = order["seat"]
	
	if lounge_bartender == null:
		var bar_root = find_child("FidelityLoungeBar", true, false)
		if bar_root != null:
			lounge_bartender = bar_root.get_node_or_null("LoungeBartender")
	
	var b_node = lounge_bartender
	if b_node != null:
		var target_x = clamp(seat["counter_pos"].x, -8.8, -5.0)
		var target_pos = Vector3(target_x, 0.0, -2.75)
		var ap: AnimationPlayer = _find_char_anim_player(b_node)
		if ap != null and ap.has_animation("walk"):
			ap.play("walk")
			
		var tw_walk = create_tween()
		tw_walk.tween_property(b_node, "position", target_pos, 0.45)
		await tw_walk.finished
		
		if ap != null and ap.has_animation("interact-right"):
			ap.play("interact-right")
			
		if bartender_shaker_prop != null:
			var tw_shaker = create_tween()
			tw_shaker.tween_property(bartender_shaker_prop, "position:y", 1.15, 0.25)
			tw_shaker.tween_property(bartender_shaker_prop, "position:y", 0.95, 0.25)
			tw_shaker.tween_property(bartender_shaker_prop, "position:y", 1.15, 0.25)
			tw_shaker.tween_property(bartender_shaker_prop, "position:y", 0.95, 0.25)
	
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("bell", 0.03, 1.2)
		
	await get_tree().create_timer(1.6).timeout
	if not is_instance_valid(cust) or cust.current_state != cust.State.SEATED_ORDERING:
		bartender_state = StaffState.IDLE
		if b_node != null:
			var ap = _find_char_anim_player(b_node)
			if ap != null: ap.play("idle")
		return
		
	# Serve wine goblet / cocktail glass on counter/table
	var wine_scn = load("res://assets/models/food/glass-wine.glb")
	if wine_scn != null:
		var goblet = wine_scn.instantiate()
		goblet.position = seat["counter_pos"]
		goblet.scale = Vector3(0.4, 0.4, 0.4)
		add_child(goblet)
		seat["dish_instance"] = goblet
		
	# Floating cash stack along bar counter edge
	var gm = get_node_or_null("/root/GameManager")
	var price: float = cust.ordered_dish.get("price", 42.0)
	var price_mult: float = gm.get_dish_price_multiplier() if gm != null and gm.has_method("get_dish_price_multiplier") else 1.0
	if gm != null and gm.has_method("get_card_cocktail_revenue_multiplier"):
		price_mult *= gm.get_card_cocktail_revenue_multiplier()
	var total_revenue: float = price * price_mult
	if gm != null:
		gm.add_cash(total_revenue)
	_spawn_counter_cash_stack(Vector3(seat["counter_pos"].x, 1.15, -2.15), total_revenue)
	
	var drink_id = cust.ordered_dish.get("id", "wine_merlot")
	cust.on_lounge_drink_served(drink_id)
	
	if b_node != null:
		var ap = _find_char_anim_player(b_node)
		if ap != null and ap.has_animation("idle"):
			ap.play("idle")
	bartender_state = StaffState.IDLE

func _process_diner_barista(_delta: float) -> void:
	if barista_state != StaffState.IDLE or pending_diner_orders.size() == 0:
		return
	var order = pending_diner_orders.pop_front()
	if not is_instance_valid(order.get("customer")) or order["customer"].current_state != order["customer"].State.SEATED_ORDERING:
		return
	_run_barista_service(order)

func _run_barista_service(order: Dictionary) -> void:
	barista_state = StaffState.PREPARING
	var cust = order["customer"]
	var seat = order["seat"]
	
	if diner_barista == null:
		var shake_bar = find_child("MilkshakeBar", true, false)
		if shake_bar != null:
			diner_barista = shake_bar.find_child("DinerBarista", true, false)
			
	var b_node = diner_barista
	
	# Move to blenders
	if b_node != null:
		var ap: AnimationPlayer = _find_char_anim_player(b_node)
		if ap != null and ap.has_animation("walk"):
			ap.play("walk")
		var tw_walk = create_tween()
		tw_walk.tween_property(b_node, "position", Vector3(-2.85, 0.0, -1.6), 0.35)
		await tw_walk.finished
		if ap != null and ap.has_animation("interact-right"):
			ap.play("interact-right")
			
	# Radial Timer ring operation over chrome blenders
	var gm = get_node_or_null("/root/GameManager")
	var lvl = gm.get_station_level("milkshake_bar") if gm != null else 1
	var prep_time = max(1.0, 2.8 - (lvl - 1) * 0.04)
	
	if barista_radial_mesh != null and barista_radial_mesh.material_override is ShaderMaterial:
		barista_radial_mesh.visible = true
		var sm: ShaderMaterial = barista_radial_mesh.material_override
		sm.set_shader_parameter("progress", 0.0)
		var tw_ring = create_tween()
		tw_ring.tween_property(sm, "shader_parameter/progress", 1.0, prep_time)
		await tw_ring.finished
		barista_radial_mesh.visible = false
	else:
		await get_tree().create_timer(prep_time).timeout
		
	if not is_instance_valid(cust) or cust.current_state != cust.State.SEATED_ORDERING:
		barista_state = StaffState.IDLE
		if b_node != null:
			var ap = _find_char_anim_player(b_node)
			if ap != null: ap.play("idle")
		return
		
	# Move to customer counter position
	if b_node != null:
		var ap = _find_char_anim_player(b_node)
		if ap != null and ap.has_animation("walk"):
			ap.play("walk")
		var local_target_z = clamp(seat["seat_pos"].z - (-7.0), -2.4, 2.4)
		var tw_serve = create_tween()
		tw_serve.tween_property(b_node, "position", Vector3(-2.85, 0.0, local_target_z), 0.35)
		await tw_serve.finished
		if ap != null and ap.has_animation("interact-right"):
			ap.play("interact-right")
			
	# Serve sundae or frappe model
	var dish_id = cust.ordered_dish.get("id", "sundae")
	var dessert_scn = null
	if dish_id == "sundae":
		dessert_scn = load("res://assets/models/food/sundae.glb")
	else:
		dessert_scn = load("res://assets/models/food/frappe.glb")
	if dessert_scn != null:
		var dessert_node = dessert_scn.instantiate()
		dessert_node.position = seat["counter_pos"]
		dessert_node.scale = Vector3(0.42, 0.42, 0.42)
		add_child(dessert_node)
		seat["dish_instance"] = dessert_node
		
	# Calculate revenue linked to milkshake_bar upgrades:
	var station_inc: float = gm.get_station_income("milkshake_bar") if gm != null else 45.0
	var treat_price: float = cust.ordered_dish.get("price", 48.0)
	var total_revenue: float = station_inc + treat_price
	if gm != null and gm.has_method("get_card_milkshake_revenue_multiplier"):
		total_revenue = round(total_revenue * gm.get_card_milkshake_revenue_multiplier())
	if gm != null:
		gm.add_cash(total_revenue)
	_spawn_counter_cash_stack(Vector3(-9.7, 1.15, seat["counter_pos"].z), total_revenue)
	
	cust.on_milkshake_served(dish_id)
	
	if b_node != null:
		var ap = _find_char_anim_player(b_node)
		if ap != null and ap.has_animation("idle"):
			ap.play("idle")
	barista_state = StaffState.IDLE

func _find_char_anim_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found = _find_char_anim_player(child)
		if found != null:
			return found
	return null

func _on_lounge_drink_finished(_cust: Node3D, seat_id: String) -> void:
	for s in lounge_seats:
		if s["id"] == seat_id:
			s["is_occupied"] = false
			s["customer"] = null
			if s["dish_instance"] != null and is_instance_valid(s["dish_instance"]):
				var d = s["dish_instance"]
				var tw = create_tween()
				tw.tween_property(d, "scale", Vector3.ZERO, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
				tw.tween_callback(d.queue_free)
				s["dish_instance"] = null
			break
	_check_seat_waiting_customers()

func _on_diner_treat_finished(_cust: Node3D, seat_id: String) -> void:
	for s in diner_seats:
		if s["id"] == seat_id:
			s["is_occupied"] = false
			s["customer"] = null
			if s["dish_instance"] != null and is_instance_valid(s["dish_instance"]):
				var d = s["dish_instance"]
				var tw = create_tween()
				tw.tween_property(d, "scale", Vector3.ZERO, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
				tw.tween_callback(d.queue_free)
				s["dish_instance"] = null
			break
	_check_seat_waiting_customers()

func _spawn_counter_cash_stack(pos: Vector3, amount: float) -> void:
	var stack_root = Node3D.new()
	stack_root.position = pos
	add_child(stack_root)
	
	var sprite = Sprite3D.new()
	var tex = load("res://assets/textures/bubble_cash_stack.png")
	if tex != null:
		sprite.texture = tex
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.scale = Vector3(0.01, 0.01, 0.01)
	stack_root.add_child(sprite)
	
	var lbl = Label3D.new()
	lbl.text = "+$%d" % round(amount)
	lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lbl.font_size = 28
	lbl.modulate = Color(0.35, 1.0, 0.55, 1.0)
	lbl.outline_modulate = Color(0.05, 0.15, 0.05, 1.0)
	lbl.outline_size = 6
	lbl.position = Vector3(0, 0.35, 0)
	stack_root.add_child(lbl)
	
	var stack_data = {
		"node": stack_root,
		"pos": pos,
		"amount": amount,
		"collected": false
	}
	active_counter_stacks.append(stack_data)
		
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(sprite, "scale", Vector3(0.5, 0.5, 0.5), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(stack_root, "position:y", pos.y + 0.45, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.chain().tween_property(sprite, "modulate:a", 0.0, 0.4)
	tw.set_parallel(true)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.4)
	tw.chain().tween_callback(func():
		active_counter_stacks.erase(stack_data)
		if is_instance_valid(stack_root):
			stack_root.queue_free()
	)

func collect_counter_stack(item: Dictionary) -> void:
	if item.get("collected", false):
		return
	item["collected"] = true
	active_counter_stacks.erase(item)
	var pos: Vector3 = item.get("pos", Vector3.ZERO)
	var amount: float = item.get("amount", 25.0)
	var node: Node3D = item.get("node", null)
	
	register_cash_collection(pos, amount)
	
	if is_instance_valid(node):
		var tw = create_tween()
		tw.tween_property(node, "scale", Vector3.ZERO, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tw.tween_callback(node.queue_free)

func register_cash_collection(pos: Vector3, base_amount: float) -> void:
	var now: float = Time.get_ticks_msec() / 1000.0
	if (now - last_cash_collect_time) <= 1.0:
		cash_collect_combo += 1
	else:
		cash_collect_combo = 1
	last_cash_collect_time = now
	
	var multiplier: int = 1
	if cash_collect_combo >= 3:
		multiplier = cash_collect_combo - 1
		_spawn_combo_floating_text(pos, multiplier)
		
	var final_amount: float = base_amount * float(multiplier)
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.add_cash(final_amount, pos)
			
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		var pitch = clamp(1.0 + float(cash_collect_combo - 1) * 0.08, 1.0, 1.8)
		am.play_sfx("coin", 0.04, pitch)

func _spawn_combo_floating_text(world_pos: Vector3, multiplier: int) -> void:
	var label = Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.double_sided = false
	label.text = "x%d COMBO!" % multiplier
	label.font_size = 36
	label.outline_size = 9
	label.modulate = Color(1.0, 0.88, 0.15, 1.0)
	label.outline_modulate = Color(0.65, 0.22, 0.0, 0.95)
	label.position = world_pos + Vector3(0.0, 0.6, 0.0)
	add_child(label)
	
	label.scale = Vector3(0.5, 0.5, 0.5)
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(label, "scale", Vector3(1.3, 1.3, 1.3), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(label, "position:y", label.position.y + 1.1, 0.85).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.chain().tween_property(label, "scale", Vector3.ONE, 0.2)
	tw.parallel().tween_property(label, "modulate:a", 0.0, 0.4).set_delay(0.3)
	tw.chain().tween_callback(label.queue_free)

func _check_swipe_cash_collection(screen_pos: Vector2) -> void:
	var cam: Camera3D = get_viewport().get_camera_3d() if get_viewport() != null else null
	if cam == null:
		return
		
	# 1. Check dining tables
	if tables_container != null:
		for table in tables_container.get_children():
			if table.has_method("has_visible_cash_stack") and table.has_visible_cash_stack():
				var stack_pos: Vector3 = table.get_cash_stack_world_pos()
				if not cam.is_position_behind(stack_pos):
					var screen_pt: Vector2 = cam.unproject_position(stack_pos)
					if screen_pt.distance_to(screen_pos) <= 52.0:
						table.collect_booth_cash()
						
	# 2. Check active counter stacks
	for i in range(active_counter_stacks.size() - 1, -1, -1):
		var item = active_counter_stacks[i]
		if not item.get("collected", false) and is_instance_valid(item.get("node", null)):
			var stack_pos: Vector3 = item.get("pos", Vector3.ZERO)
			if not cam.is_position_behind(stack_pos):
				var screen_pt: Vector2 = cam.unproject_position(stack_pos)
				if screen_pt.distance_to(screen_pos) <= 52.0:
					collect_counter_stack(item)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		_check_swipe_cash_collection(event.position)
	elif event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
		_check_swipe_cash_collection(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_check_swipe_cash_collection(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_check_swipe_cash_collection(event.position)

func _on_milkshake_bar_clicked(_cam: Node, event: InputEvent, _pos: Vector3, _normal: Vector3, _idx: int) -> void:
	if (event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == 1) and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		var gm = get_node_or_null("/root/GameManager")
		var lvl = gm.get_station_level("milkshake_bar") if gm != null else 1
		open_upgrade_ui.emit("milkshake_bar", "50s Milkshake & Soda Diner", lvl)

func _on_station_upgraded(station_id: String, new_level: int) -> void:
	if station_id == "milkshake_bar" and milkshake_badge_label != null:
		milkshake_badge_label.text = "🍦 50s SODA FOUNTAIN • Lv. %d" % new_level
		var tw = create_tween()
		tw.tween_property(milkshake_badge_label, "scale", Vector3(1.25, 1.25, 1.25), 0.15)
		tw.tween_property(milkshake_badge_label, "scale", Vector3.ONE, 0.2)

func _on_table_clicked(station_id: String, station_name: String, level: int) -> void:
	open_upgrade_ui.emit(station_id, station_name, level)

func _on_spawn_floating_cash(amount: float, world_pos: Vector3) -> void:
	if floating_cash_scene != null:
		var cash_lbl = floating_cash_scene.instantiate()
		add_child(cash_lbl)
		cash_lbl.setup(amount, world_pos)

func spawn_customer_from_car(car_exit_pos: Vector3) -> Node3D:
	if customer_scene == null:
		return null
		
	var avail_tables = _get_available_tables()
	var avail_lounge = _get_available_lounge_seats()
	var avail_diner = _get_available_diner_seats()
	var total_avail = avail_tables.size() + avail_lounge.size() + avail_diner.size()
	
	if total_avail == 0 and waiting_customers.size() >= MAX_WAITING_CUSTOMERS:
		return null
		
	var cust = customer_scene.instantiate()
	customers_container.add_child(cust)
	cust.global_position = car_exit_pos
	
	var crosswalk_road_pt = Vector3(car_exit_pos.x, 0.0, 16.5)
	var crosswalk_start = Vector3(-1.5, 0.0, 16.5)
	var crosswalk_end = Vector3(-1.5, 0.0, 13.8)
	var garden_path = Vector3(-1.5, 0.0, 12.0)
	var approach_pts = [
		crosswalk_road_pt,
		crosswalk_start,
		crosswalk_end,
		garden_path,
		cust.DOOR_POS
	]
	
	if total_avail > 0:
		var roll = randf()
		if roll < 0.25 and avail_lounge.size() > 0:
			var free_seat = avail_lounge.pick_random()
			free_seat["is_occupied"] = true
			free_seat["customer"] = cust
			cust.lounge_drink_finished.connect(_on_lounge_drink_finished)
			cust.order_placed.connect(_on_customer_order_placed)
			cust.sector_type = "lounge"
			cust.seat_target_pos = free_seat["seat_pos"]
			cust.seat_target_rot_y = free_seat["seat_rot_y"]
			cust.seat_identifier = free_seat["id"]
			cust.assigned_table_id = free_seat["id"]
			cust.ordered_dish = cust.LOUNGE_DRINKS.pick_random()
			cust.current_state = cust.State.WALKING_TO_HOST
			approach_pts.append(cust.HOST_POS)
			approach_pts.append(Vector3(-5.5, 0.0, 2.5))
			approach_pts.append(free_seat["seat_pos"])
			cust.set_waypoints(approach_pts)
		elif roll < 0.50 and avail_diner.size() > 0:
			var free_seat = avail_diner.pick_random()
			free_seat["is_occupied"] = true
			free_seat["customer"] = cust
			cust.diner_treat_finished.connect(_on_diner_treat_finished)
			cust.order_placed.connect(_on_customer_order_placed)
			cust.sector_type = "milkshake"
			cust.seat_target_pos = free_seat["seat_pos"]
			cust.seat_target_rot_y = free_seat["seat_rot_y"]
			cust.seat_identifier = free_seat["id"]
			cust.assigned_table_id = free_seat["id"]
			cust.ordered_dish = cust.DINER_TREATS.pick_random()
			cust.current_state = cust.State.WALKING_TO_HOST
			approach_pts.append(cust.HOST_POS)
			approach_pts.append(Vector3(-4.5, 0.0, -0.5))
			approach_pts.append(Vector3(-4.5, 0.0, -4.5))
			approach_pts.append(free_seat["seat_pos"])
			cust.set_waypoints(approach_pts)
		elif avail_tables.size() > 0:
			var free_table: Node3D = avail_tables.pick_random()
			if free_table.has_method("occupy"):
				free_table.occupy(cust)
			else:
				free_table.is_occupied = true
			cust.assigned_table_id = free_table.table_id
			cust.table_ref = free_table
			cust.current_state = cust.State.WALKING_TO_HOST
			approach_pts.append(cust.HOST_POS)
			cust.set_waypoints(approach_pts)
			cust.order_placed.connect(_on_customer_order_placed)
		elif avail_lounge.size() > 0:
			var free_seat = avail_lounge.pick_random()
			_seat_customer_in_lounge(cust, free_seat)
		elif avail_diner.size() > 0:
			var free_seat = avail_diner.pick_random()
			_seat_customer_in_diner(cust, free_seat)
	else:
		var spot_idx = waiting_customers.size()
		var spot = WAITING_SPOTS[spot_idx] if spot_idx < WAITING_SPOTS.size() else Vector3(-1.5, 0.0, 7.0 + spot_idx * 1.2)
		waiting_customers.append(cust)
		cust.current_state = cust.State.WAITING_IN_LOBBY
		cust.max_patience = 28.0
		cust.current_patience = 28.0
		cust.is_waiting_for_food = true
		cust.set_bubble_text("⏳ 🍽️")
		approach_pts.append(spot)
		cust.set_waypoints(approach_pts)
		cust.lobby_wait_timeout.connect(func(c): waiting_customers.erase(c))
		
	return cust

func _setup_courtyard_fidelity() -> void:
	var courtyard = find_child("EntranceCourtyard", true, false)
	if courtyard == null:
		return

	var warm_wood = StandardMaterial3D.new()
	warm_wood.albedo_color = Color(0.48, 0.28, 0.16, 1.0)
	warm_wood.roughness = 0.5

	for b_name in ["CourtyardBenchWest", "CourtyardBenchEast"]:
		var bench = courtyard.get_node_or_null(b_name)
		if bench != null:
			_apply_material_to_node(bench, warm_wood)

func _setup_breakroom_fidelity() -> void:
	var breakroom = find_child("StaffBreakroom", true, false)
	if breakroom == null:
		return

	# Red Vinyl material for L-shaped lounge sofa and armchair
	var red_vinyl = StandardMaterial3D.new()
	red_vinyl.albedo_color = Color(0.82, 0.16, 0.16, 1.0) # vibrant lounge red
	red_vinyl.roughness = 0.4

	for node_name in ["BreakroomSofaMain", "BreakroomSofaCorner", "BreakroomSofaSide", "BreakroomArmchair"]:
		var sofa_node = breakroom.get_node_or_null(node_name)
		if sofa_node != null:
			_apply_material_to_node(sofa_node, red_vinyl)

	# Dark wood coffee table
	var coffee_tbl = breakroom.get_node_or_null("BreakroomCoffeeTable")
	if coffee_tbl != null:
		var dark_wood = StandardMaterial3D.new()
		dark_wood.albedo_color = Color(0.24, 0.15, 0.10, 1.0)
		dark_wood.roughness = 0.45
		_apply_material_to_node(coffee_tbl, dark_wood)

func _setup_manager_office_fidelity() -> void:
	var office = find_child("ManagerOffice", true, false)
	if office == null:
		return

	# Two red guest chairs in front of executive desk
	var red_vinyl = StandardMaterial3D.new()
	red_vinyl.albedo_color = Color(0.82, 0.16, 0.16, 1.0)
	red_vinyl.roughness = 0.4

	for node_name in ["GuestChairLeft", "GuestChairRight"]:
		var chair_node = office.get_node_or_null(node_name)
		if chair_node != null:
			_apply_material_to_node(chair_node, red_vinyl)

func _apply_material_to_node(node: Node, mat: Material) -> void:
	if node is MeshInstance3D:
		node.material_override = mat
	for child in node.get_children():
		_apply_material_to_node(child, mat)

func spawn_vip_investor(spawn_pos: Vector3) -> Node3D:
	if customer_scene == null:
		customer_scene = load("res://scenes/customer.tscn")
	if customer_scene == null:
		return null
		
	var cust = customer_scene.instantiate()
	customers_container.add_child(cust)
	cust.global_position = spawn_pos
	if cust.has_method("set_as_vip_investor"):
		cust.set_as_vip_investor(true)
	
	var waypoints: Array[Vector3] = [
		Vector3(-6.0, 0.0, 16.5),
		Vector3(-1.5, 0.0, 16.5),
		Vector3(-1.5, 0.0, 13.8),
		Vector3(-1.5, 0.0, 12.0),
		cust.DOOR_POS,
		cust.HOST_POS
	]
	
	var avail_tables = _get_available_tables()
	if avail_tables.size() > 0:
		var target_table = avail_tables[0]
		for t in avail_tables:
			if t.table_id in ["table_10", "table_11", "table_12", "table_7", "table_8", "table_9"]:
				target_table = t
				break
		target_table.occupy(cust)
		cust.assigned_table_id = target_table.table_id
		cust.table_ref = target_table
		cust.seat_target_pos = target_table.get_seat_position()
		cust.seat_target_rot_y = target_table.get_seat_rotation_y()
		cust.seat_identifier = target_table.table_id
		cust.order_placed.connect(_on_customer_order_placed)
		cust.current_state = cust.State.WALKING_TO_HOST
		waypoints.append(cust.AISLE_POS)
		waypoints.append(target_table.get_seat_position())
		cust.set_waypoints(waypoints)
	else:
		cust.current_state = cust.State.WALKING_TO_HOST
		cust.set_waypoints(waypoints)
		
	return cust

func get_sector_bottleneck_status() -> Dictionary:
	# 1. Lobby Queue Full (red)
	waiting_customers = waiting_customers.filter(func(c): return is_instance_valid(c))
	if waiting_customers.size() >= MAX_WAITING_CUSTOMERS:
		return {
			"text": "Lobby Queue Full",
			"color": Color(0.95, 0.28, 0.28, 1.0),
			"code": "LOBBY_FULL",
			"icon": "🔴"
		}
	
	# 2. Kitchen Backlogged (red)
	var total_backlog = pending_orders.size() + pending_diner_orders.size() + pending_lounge_orders.size()
	if pending_orders.size() >= 3 or total_backlog >= 4:
		return {
			"text": "Kitchen Backlogged",
			"color": Color(0.95, 0.28, 0.28, 1.0),
			"code": "KITCHEN_BACKLOGGED",
			"icon": "🔴"
		}
		
	# 3. Waiters Busy (amber)
	var active_waiters = waiters.filter(func(w): return is_instance_valid(w))
	var dirty_tables_count = 0
	if tables_container != null:
		for tbl in tables_container.get_children():
			if tbl.get("is_dirty") == true and not tbl.get("is_occupied"):
				dirty_tables_count += 1
				
	var idle_waiters_count = 0
	for w in active_waiters:
		if w.get("current_state") == 0: # State.IDLE
			idle_waiters_count += 1
			
	var has_waiter_work = pending_orders.size() > 0 or dirty_tables_count > 0
	if active_waiters.size() > 0 and idle_waiters_count == 0 and has_waiter_work:
		return {
			"text": "Waiters Busy",
			"color": Color(0.96, 0.65, 0.12, 1.0),
			"code": "WAITERS_BUSY",
			"icon": "🟡"
		}
	
	# 4. Optimal Flow (green)
	return {
		"text": "Optimal Flow",
		"color": Color(0.18, 0.78, 0.35, 1.0),
		"code": "OPTIMAL",
		"icon": "🟢"
	}


