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

func _ready() -> void:
	waiter_scene = load("res://scenes/waiter.tscn")
	
	if waiter_1 != null:
		waiters.append(waiter_1)
		
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.spawn_floating_cash.connect(_on_spawn_floating_cash)
		gm.staff_updated.connect(_on_staff_updated)
		_check_spawn_hired_staff()
	
	for table in tables_container.get_children():
		if table.has_signal("table_clicked"):
			table.table_clicked.connect(_on_table_clicked)
			
	if kitchen_container != null:
		for st in kitchen_container.get_children():
			if st.has_signal("station_clicked"):
				st.station_clicked.connect(_on_table_clicked)
				
	_setup_custom_textures()

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

	# Kitchen Floor (Checkered White/Grey Commercial Tiles)
	var k_tile_path = ProjectSettings.globalize_path("res://assets/textures/kitchen_tiles.png")
	var k_tile_img = Image.load_from_file(k_tile_path)
	if k_tile_img != null:
		var k_tile_tex = ImageTexture.create_from_image(k_tile_img)
		var kitchen_floor_node = find_child("KitchenFloor", true, false)
		if kitchen_floor_node != null and kitchen_floor_node is MeshInstance3D:
			var mat_kitchen = StandardMaterial3D.new()
			mat_kitchen.albedo_texture = k_tile_tex
			mat_kitchen.roughness = 0.45
			mat_kitchen.uv1_scale = Vector3(4.0, 3.5, 1)
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
			bmesh.size = Vector3(7.0, 0.02, 2.2)
			k_runner.mesh = bmesh
			k_runner.position = Vector3(6.5, 0.022, -2.1)
			var r_mat = StandardMaterial3D.new()
			r_mat.albedo_texture = pass_rug_tex
			r_mat.roughness = 0.65
			k_runner.material_override = r_mat

	# Host Desk Velvet Red Runner
	var runner_path = ProjectSettings.globalize_path("res://assets/textures/red_carpet_runner.png")
	var runner_img = Image.load_from_file(runner_path)
	if runner_img != null:
		var runner_tex = ImageTexture.create_from_image(runner_img)
		var h_runner = find_child("HostDeskRedRunner", true, false)
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

	# Milkshake Bar Floor Diamond Checkers
	var shake_floor = find_child("MilkshakeFloor", true, false)
	if shake_floor != null and shake_floor is MeshInstance3D and tile_img != null:
		var shake_mat = StandardMaterial3D.new()
		shake_mat.albedo_texture = ImageTexture.create_from_image(tile_img)
		shake_mat.roughness = 0.85
		shake_mat.uv1_scale = Vector3(3.5, 3.0, 1)
		shake_floor.material_override = shake_mat

	# The Milk Shake Neon Sign
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
			neon_node.material_override = mat

	# Vinyl Records on Milkshake Wall
	var vinyl_path = ProjectSettings.globalize_path("res://assets/textures/vinyl_record.png")
	var vinyl_img = Image.load_from_file(vinyl_path)
	if vinyl_img != null:
		var vinyl_tex = ImageTexture.create_from_image(vinyl_img)
		for v_name in ["VinylRecord1", "VinylRecord2", "VinylRecord3"]:
			var v_node = find_child(v_name, true, false)
			if v_node != null and v_node is MeshInstance3D:
				var v_mat = StandardMaterial3D.new()
				v_mat.albedo_texture = vinyl_tex
				v_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				v_mat.roughness = 0.4
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

	# 1. Main Mahogany Bar Counter along back-left wall (1:1 with crop_lounge_08s.jpg)
	var bar_root = rec_room.get_node_or_null("FidelityLoungeBar")
	if bar_root == null:
		bar_root = Node3D.new()
		bar_root.name = "FidelityLoungeBar"
		rec_room.add_child(bar_root)

		# Cyan Runner Mat under bar stools
		var mat_mesh = MeshInstance3D.new()
		var box_mat = BoxMesh.new()
		box_mat.size = Vector3(5.4, 0.015, 1.35)
		var cyan_mat = StandardMaterial3D.new()
		cyan_mat.albedo_color = Color(0.28, 0.65, 0.68, 1.0)
		cyan_mat.roughness = 0.8
		mat_mesh.mesh = box_mat
		mat_mesh.material_override = cyan_mat
		mat_mesh.position = Vector3(-8.15, 0.025, -0.7)
		bar_root.add_child(mat_mesh)

		# Counter Body (Rich dark cherry mahogany wood)
		var body_mesh = CSGBox3D.new()
		body_mesh.size = Vector3(5.2, 0.94, 0.65)
		body_mesh.position = Vector3(-8.15, 0.47, -1.35)
		var wood_mat = StandardMaterial3D.new()
		wood_mat.albedo_color = Color(0.28, 0.10, 0.06, 1.0)
		wood_mat.roughness = 0.4
		body_mesh.material = wood_mat
		bar_root.add_child(body_mesh)

		# Counter Top (Warm cream marble / polished wood)
		var top_mesh = CSGBox3D.new()
		top_mesh.size = Vector3(5.4, 0.06, 0.78)
		top_mesh.position = Vector3(-8.15, 0.97, -1.35)
		var marble_mat = StandardMaterial3D.new()
		marble_mat.albedo_color = Color(0.95, 0.94, 0.90, 1.0)
		marble_mat.roughness = 0.25
		marble_mat.metallic = 0.1
		top_mesh.material = marble_mat
		bar_root.add_child(top_mesh)

		# Polished Brass Foot Rail along base
		var rail_mesh = CSGCylinder3D.new()
		rail_mesh.radius = 0.025
		rail_mesh.height = 5.0
		rail_mesh.rotation_degrees = Vector3(0, 0, 90)
		rail_mesh.position = Vector3(-8.15, 0.15, -0.98)
		var brass_mat = StandardMaterial3D.new()
		brass_mat.albedo_color = Color(0.95, 0.82, 0.28, 1.0)
		brass_mat.metallic = 0.85
		brass_mat.roughness = 0.2
		rail_mesh.material = brass_mat
		bar_root.add_child(rail_mesh)

		# 6 Stools in front of the bar
		var stool_scn = load("res://assets/models/furniture/stoolBar.glb")
		if stool_scn != null:
			for i in range(6):
				var sx = -10.2 + i * 0.82
				var st = stool_scn.instantiate()
				st.position = Vector3(sx, 0.0, -0.65)
				st.scale = Vector3(1.15, 1.15, 1.15)
				bar_root.add_child(st)

		# Glass Wine & Cocktail Glasses on the counter
		var wine_scn = load("res://assets/models/food/glass-wine.glb")
		if wine_scn != null:
			for wx in [-10.0, -8.6, -7.2, -6.0]:
				var wg = wine_scn.instantiate()
				wg.position = Vector3(wx, 1.0, -1.35)
				wg.scale = Vector3(0.4, 0.4, 0.4)
				bar_root.add_child(wg)

		# Multi-Tier Liquor Shelf on the back wall (z = -3.38)
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
			shelf_mat.emission_energy_multiplier = 1.4
			shelf_mesh.material_override = shelf_mat
			shelf_mesh.position = Vector3(-8.15, 1.85, -3.38)
			bar_root.add_child(shelf_mesh)

		# Chalkboard Menu on the right wall (x = -3.36, facing west)
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
			c_mat.roughness = 0.75
			chalk_mesh.material_override = c_mat
			chalk_mesh.position = Vector3(-3.36, 1.75, 1.5)
			chalk_mesh.rotation_degrees = Vector3(0, 90, 0)
			bar_root.add_child(chalk_mesh)

		# Bartender figure behind the counter
		var barman_scn = load("res://assets/models/characters/character-male-d.glb")
		if barman_scn != null:
			var barman = barman_scn.instantiate()
			barman.position = Vector3(-8.0, 0.0, -1.8)
			barman.rotation_degrees = Vector3(0, 0, 0)
			barman.scale = Vector3(1.05, 1.05, 1.05)
			var decor_script = load("res://scripts/decor_character.gd")
			barman.set_script(decor_script)
			barman.set("anim_name", "idle")
			bar_root.add_child(barman)

	# Re-style the 4 round lounge tables & chairs with dark mahogany wood (matching crop_lounge_08s.jpg)
	var wood_tbl_mat = StandardMaterial3D.new()
	wood_tbl_mat.albedo_color = Color(0.24, 0.10, 0.06, 1.0)
	wood_tbl_mat.roughness = 0.35

	var chair_wood_mat = StandardMaterial3D.new()
	chair_wood_mat.albedo_color = Color(0.22, 0.09, 0.05, 1.0)
	chair_wood_mat.roughness = 0.45

	for t_idx in [1, 2, 3, 4]:
		var tbl = rec_room.find_child("WaitingTable%d" % t_idx, true, false)
		if tbl != null:
			for ch in tbl.get_children():
				if ch is MeshInstance3D:
					ch.material_override = wood_tbl_mat
		for c_letter in ["A", "B", "C", "D"]:
			var chair = rec_room.find_child("WaitingChair%d%s" % [t_idx, c_letter], true, false)
			if chair != null:
				for ch in chair.get_children():
					if ch is MeshInstance3D:
						ch.material_override = chair_wood_mat

	# Rotate Jukebox towards isometric camera for full view of neon arch and turntable
	var juke_node = find_child("RetroJukebox", true, false)
	if juke_node != null:
		juke_node.rotation_degrees = Vector3(0, -45, 0)

func _setup_milkshake_fidelity() -> void:
	var shake_bar = find_child("MilkshakeBar", true, false)
	if shake_bar == null:
		return

	# Long Retro Diner Fountain Counter along back wall (matching crop_middle_08s.jpg)
	var f_root = shake_bar.get_node_or_null("FidelityFountainCounter")
	if f_root == null:
		f_root = Node3D.new()
		f_root.name = "FidelityFountainCounter"
		shake_bar.add_child(f_root)

		# Mint Green Counter Body with chrome trim
		var f_body = CSGBox3D.new()
		f_body.size = Vector3(4.8, 0.94, 0.65)
		f_body.position = Vector3(-1.4, 0.47, -2.85)
		var mint_mat = StandardMaterial3D.new()
		mint_mat.albedo_color = Color(0.44, 0.78, 0.72, 1.0)
		mint_mat.roughness = 0.35
		f_body.material = mint_mat
		f_root.add_child(f_body)

		# Polished Stainless Steel Countertop
		var f_top = CSGBox3D.new()
		f_top.size = Vector3(5.0, 0.05, 0.78)
		f_top.position = Vector3(-1.4, 0.965, -2.85)
		var chrome_mat = StandardMaterial3D.new()
		chrome_mat.albedo_color = Color(0.92, 0.94, 0.96, 1.0)
		chrome_mat.metallic = 0.85
		chrome_mat.roughness = 0.2
		f_top.material = chrome_mat
		f_root.add_child(f_top)

		# Stools along the counter
		var stool_scn = load("res://assets/models/furniture/stoolBar.glb")
		if stool_scn != null:
			for i in range(6):
				var sx = -3.2 + i * 0.72
				var st = stool_scn.instantiate()
				st.position = Vector3(sx, 0.0, -2.2)
				st.scale = Vector3(1.1, 1.1, 1.1)
				f_root.add_child(st)

		# Milkshake Drinks on the Counter
		var sundae_scn = load("res://assets/models/food/sundae.glb")
		var frappe_scn = load("res://assets/models/food/frappe.glb")
		var soda_scn = load("res://assets/models/food/soda-glass.glb")
		for i in range(4):
			var dx = -3.0 + i * 1.0
			var item = null
			if i % 3 == 0 and sundae_scn != null: item = sundae_scn.instantiate()
			elif i % 3 == 1 and frappe_scn != null: item = frappe_scn.instantiate()
			elif soda_scn != null: item = soda_scn.instantiate()
			if item != null:
				item.position = Vector3(dx, 0.99, -2.85)
				item.scale = Vector3(0.42, 0.42, 0.42)
				f_root.add_child(item)

		# Retro Pink Cone Pendant Lamps over the 4 diner tables
		var cord_mat = StandardMaterial3D.new()
		cord_mat.albedo_color = Color(0.15, 0.15, 0.18, 1.0)
		cord_mat.metallic = 0.5
		var pink_mat = StandardMaterial3D.new()
		pink_mat.albedo_color = Color(0.96, 0.45, 0.60, 1.0)
		pink_mat.roughness = 0.4
		var bulb_mat = StandardMaterial3D.new()
		bulb_mat.albedo_color = Color(1.0, 0.95, 0.85, 1.0)
		bulb_mat.emission_enabled = true
		bulb_mat.emission = Color(1.0, 0.9, 0.7, 1.0)
		bulb_mat.emission_energy_multiplier = 2.0

		var table_positions = [
			Vector3(0.5, 0.0, -1.6),
			Vector3(2.7, 0.0, -1.6),
			Vector3(0.5, 0.0, 1.2),
			Vector3(2.7, 0.0, 1.2)
		]
		for tp in table_positions:
			var lamp_root = Node3D.new()
			lamp_root.position = Vector3(tp.x, 2.2, tp.z)
			f_root.add_child(lamp_root)

			var cord = CSGCylinder3D.new()
			cord.radius = 0.012
			cord.height = 0.8
			cord.position = Vector3(0, 0.4, 0)
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

			var spot = SpotLight3D.new()
			spot.rotation_degrees = Vector3(-90, 0, 0)
			spot.light_color = Color(1.0, 0.92, 0.8, 1.0)
			spot.light_energy = 0.75
			spot.spot_range = 3.2
			spot.spot_angle = 45.0
			lamp_root.add_child(spot)

func _setup_kitchen_fidelity() -> void:
	# 1. Add Silver Dome Heat Lamps above Pass Counter
	var dining_hall = find_child("DiningHall", true, false)
	if dining_hall != null and dining_hall.get_node_or_null("PassHeatLamps") == null:
		var heat_root = Node3D.new()
		heat_root.name = "PassHeatLamps"
		dining_hall.add_child(heat_root)

		var dome_mat = StandardMaterial3D.new()
		dome_mat.albedo_color = Color(0.90, 0.92, 0.95, 1.0)
		dome_mat.metallic = 0.9
		dome_mat.roughness = 0.15

		for hx in [1.5, 3.5, 5.5]:
			var lamp = Node3D.new()
			lamp.position = Vector3(hx, 2.2, -3.4)
			heat_root.add_child(lamp)

			var cord = CSGCylinder3D.new()
			cord.radius = 0.012
			cord.height = 0.7
			cord.position = Vector3(0, 0.35, 0)
			lamp.add_child(cord)

			var dome = MeshInstance3D.new()
			var dmesh = CylinderMesh.new()
			dmesh.top_radius = 0.08
			dmesh.bottom_radius = 0.26
			dmesh.height = 0.18
			dome.mesh = dmesh
			dome.material_override = dome_mat
			lamp.add_child(dome)

			var light = SpotLight3D.new()
			light.rotation_degrees = Vector3(-90, 0, 0)
			light.light_color = Color(1.0, 0.88, 0.6, 1.0)
			light.light_energy = 0.85
			light.spot_range = 2.8
			light.spot_angle = 40.0
			lamp.add_child(light)

	# 2. Add 4 Commercial Heavy-Duty Gas Stoves with Glowing Orange Burners
	if kitchen_container != null and kitchen_container.get_node_or_null("CommercialStoveLine") == null:
		var stove_root = Node3D.new()
		stove_root.name = "CommercialStoveLine"
		kitchen_container.add_child(stove_root)

		var burner_mat = StandardMaterial3D.new()
		burner_mat.albedo_color = Color(1.0, 0.45, 0.1, 1.0)
		burner_mat.emission_enabled = true
		burner_mat.emission = Color(1.0, 0.4, 0.05, 1.0)
		burner_mat.emission_energy_multiplier = 3.0

		var stove_scn = load("res://assets/models/furniture/kitchenStove.glb")
		var burger_scn = load("res://assets/models/food/burger-cheese.glb")
		for i in range(4):
			var sx = 1.8 + i * 1.5
			if stove_scn != null:
				var stv = stove_scn.instantiate()
				stv.position = Vector3(sx, 0.0, -9.5)
				stv.scale = Vector3(1.2, 1.2, 1.2)
				stove_root.add_child(stv)

			# Glowing orange burner rings on top
			var flame = CSGCylinder3D.new()
			flame.radius = 0.16
			flame.height = 0.02
			flame.position = Vector3(sx, 0.94, -9.5)
			flame.material = burner_mat
			stove_root.add_child(flame)

			# Sizzling food dish on stove
			if burger_scn != null:
				var bg = burger_scn.instantiate()
				bg.position = Vector3(sx, 0.96, -9.5)
				bg.scale = Vector3(0.35, 0.35, 0.35)
				stove_root.add_child(bg)

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
		
	# Check Waiter 3
	if gm.is_staff_hired("waiter_3") and not _has_waiter("waiter_3"):
		var w3 = waiter_scene.instantiate()
		w3.name = "Waiter3"
		w3.staff_id = "waiter_3"
		w3.staff_name = "Lucas"
		w3.position = Vector3(5.2, 0.0, 0.5)
		add_child(w3)
		waiters.append(w3)

	# Check Sous Chef Antoine
	if gm.is_staff_hired("chef_sous") and not _has_sous_chef():
		var chef_scn = load("res://scenes/chef.tscn")
		if chef_scn != null and kitchen_container != null:
			var sc = chef_scn.instantiate()
			sc.name = "ChefSous"
			sc.position = Vector3(5.5, 0.0, -9.0)
			sc.rotation_degrees.y = 180.0
			kitchen_container.add_child(sc)

func _has_waiter(sid: String) -> bool:
	for w in waiters:
		if is_instance_valid(w) and w.get("staff_id") == sid:
			return true
	return false

func _has_sous_chef() -> bool:
	if kitchen_container == null:
		return false
	return kitchen_container.find_child("ChefSous", true, false) != null

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

func _check_seat_waiting_customers() -> void:
	waiting_customers = waiting_customers.filter(func(c): return is_instance_valid(c) and c.current_state == c.State.WAITING_IN_LOBBY)
	if waiting_customers.size() == 0:
		return
	var available = _get_available_tables()
	if available.size() == 0:
		return
	var cust = waiting_customers.pop_front()
	var free_table: Node3D = available.pick_random()
	cust.assign_table_from_lobby(free_table)

func _get_tables_targeted_by_waiters() -> Array[Node3D]:
	var targeted: Array[Node3D] = []
	for w in waiters:
		if is_instance_valid(w) and is_instance_valid(w.get("target_table")):
			targeted.append(w.target_table)
	return targeted

func _find_unclaimed_dirty_table(targeted: Array[Node3D]) -> Node3D:
	for tbl in tables_container.get_children():
		var is_dirty = tbl.get("is_dirty")
		var is_occupied = tbl.get("is_occupied")
		if is_dirty == true and not is_occupied and not tbl in targeted:
			return tbl
	return null

func _dispatch_waiter_tasks() -> void:
	var targeted = _get_tables_targeted_by_waiters()

	# 1. High priority: Orders (serving freshly prepared meals to seated diners)
	if pending_orders.size() > 0:
		for w in waiters:
			if is_instance_valid(w) and w.get("current_state") == w.State.IDLE:
				var target_tbl = pending_orders.pop_front()
				if is_instance_valid(target_tbl) and target_tbl.get("is_occupied") == true:
					w.serve_order(target_tbl)
					targeted.append(target_tbl)
					if pending_orders.size() == 0:
						break

	# 2. Secondary priority: Busboy clearing dirty dishes & resetting tables
	for w in waiters:
		if is_instance_valid(w) and w.get("current_state") == w.State.IDLE:
			var dirty_tbl = _find_unclaimed_dirty_table(targeted)
			if dirty_tbl != null:
				w.clean_dirty_table(dirty_tbl)
				targeted.append(dirty_tbl)

func _get_available_tables() -> Array[Node3D]:
	var available: Array[Node3D] = []
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
	var available = _get_available_tables()
	if available.size() > 0:
		var free_table: Node3D = available.pick_random()
		_spawn_customer_flow(free_table, false)
	elif waiting_customers.size() < MAX_WAITING_CUSTOMERS and customer_scene != null:
		_spawn_waiting_customer_flow()

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
	if is_instance_valid(table) and is_instance_valid(cust) and table.is_occupied:
		_queue_order(table)

func _queue_order(table: Node3D) -> void:
	if not pending_orders.has(table):
		pending_orders.append(table)

func _on_table_clicked(station_id: String, station_name: String, level: int) -> void:
	open_upgrade_ui.emit(station_id, station_name, level)

func _on_spawn_floating_cash(amount: float, world_pos: Vector3) -> void:
	if floating_cash_scene != null:
		var cash_lbl = floating_cash_scene.instantiate()
		add_child(cash_lbl)
		cash_lbl.setup(amount, world_pos)

func spawn_customer_from_car(car_exit_pos: Vector3) -> Node3D:
	var available = _get_available_tables()
	if available.size() == 0:
		return null
	var free_table: Node3D = available.pick_random()
	if customer_scene == null:
		return null
		
	var cust = customer_scene.instantiate()
	customers_container.add_child(cust)
	cust.global_position = car_exit_pos
	
	if free_table.has_method("occupy"):
		free_table.occupy(cust)
	else:
		free_table.is_occupied = true
	cust.assigned_table_id = free_table.table_id
	cust.table_ref = free_table
	
	cust.current_state = cust.State.WALKING_TO_HOST
	var sidewalk_pt = Vector3(car_exit_pos.x, 0.0, 13.8)
	var walkway_entry = Vector3(-1.5, 0.0, 13.8)
	var walkway_approach = Vector3(-1.5, 0.0, 11.5)
	cust.set_waypoints([sidewalk_pt, walkway_entry, walkway_approach, cust.DOOR_POS, cust.HOST_POS])
	cust.order_placed.connect(_on_customer_order_placed)
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

