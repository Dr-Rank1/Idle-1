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
	if floating_cash_scene == null:
		floating_cash_scene = load("res://scenes/floating_cash.tscn")
	
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
			
	# Remove any legacy static queue guests so dynamic queuing is unobstructed
	for node_name in ["HostQueueGuest1", "HostQueueGuest2", "HostQueueGuest3"]:
		var static_guest = find_child(node_name, true, false)
		if static_guest:
			static_guest.queue_free()
			
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
			barman.position = Vector3(-8.2, 0.0, -2.75)
			barman.rotation_degrees = Vector3(0, 0, 0)
			barman.scale = Vector3(1.15, 1.15, 1.15)
			var decor_script = load("res://scripts/decor_character.gd")
			barman.set_script(decor_script)
			barman.set("anim_name", "idle")
			bar_root.add_child(barman)

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
		staff.position = Vector3(-2.85, 0.0, 0.0)
		staff.rotation_degrees = Vector3(0, 90, 0)
		staff.scale = Vector3(1.15, 1.15, 1.15)
		var decor_script = load("res://scripts/decor_character.gd")
		staff.set_script(decor_script)
		staff.set("anim_name", "idle")
		f_root.add_child(staff)

	# Seated customer at the bar (on Stool 2)
	var bar_guest_scn = load("res://assets/models/characters/character-female-b.glb")
	if bar_guest_scn != null:
		var bguest = bar_guest_scn.instantiate()
		bguest.position = Vector3(-1.35, 0.42, -1.25)
		bguest.rotation_degrees = Vector3(0, -90, 0)
		bguest.scale = Vector3(0.95, 0.95, 0.95)
		var decor_script = load("res://scripts/decor_character.gd")
		bguest.set_script(decor_script)
		bguest.set("anim_name", "sit")
		f_root.add_child(bguest)

	# 2 Chrome Milkshake Blenders on Counter
	for bz in [-1.9, -1.3]:
		var blender = Node3D.new()
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
	var hostess = find_child("Hostess", true, false)
	if hostess != null and hostess.has_method("greet_customer"):
		hostess.greet_customer()

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

