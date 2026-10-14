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
	Vector3(-6.5, 0.0, 8.2),
	Vector3(-6.5, 0.0, 7.0),
	Vector3(-6.5, 0.0, 5.8)
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

	# Kitchen Commercial Slate Floor
	var slate_path = ProjectSettings.globalize_path("res://assets/textures/kitchen_slate_tiles.png")
	var slate_img = Image.load_from_file(slate_path)
	if slate_img != null:
		var slate_tex = ImageTexture.create_from_image(slate_img)
		var kitchen_floor_node = find_child("KitchenFloor", true, false)
		if kitchen_floor_node != null and kitchen_floor_node is MeshInstance3D:
			var mat_kitchen = StandardMaterial3D.new()
			mat_kitchen.albedo_texture = slate_tex
			mat_kitchen.roughness = 0.85
			mat_kitchen.uv1_scale = Vector3(2.5, 1.25, 1)
			kitchen_floor_node.material_override = mat_kitchen

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
			mat_rec.uv1_scale = Vector3(4, 7, 1)
			reception_floor_node.material_override = mat_rec

	# Red Carpet Runners (Kitchen Pass and Host Desk)
	var runner_path = ProjectSettings.globalize_path("res://assets/textures/red_carpet_runner.png")
	var runner_img = Image.load_from_file(runner_path)
	if runner_img != null:
		var runner_tex = ImageTexture.create_from_image(runner_img)
		for runner_name in ["KitchenPassRedRunner", "HostDeskRedRunner"]:
			var r_node = find_child(runner_name, true, false)
			if r_node != null and r_node is MeshInstance3D:
				var mat_run = StandardMaterial3D.new()
				mat_run.albedo_texture = runner_tex
				mat_run.roughness = 0.65
				r_node.material_override = mat_run

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
		shake_mat.uv1_scale = Vector3(2.5, 2.2, 1)
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
	var sidewalk_pt = Vector3(car_exit_pos.x, 0.0, 11.2)
	cust.set_waypoints([sidewalk_pt, cust.DOOR_POS, cust.HOST_POS])
	cust.order_placed.connect(_on_customer_order_placed)
	return cust
