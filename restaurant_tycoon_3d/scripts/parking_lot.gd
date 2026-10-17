extends Node3D

signal car_parked(stall_index: int, customer_node: Node3D)
signal car_departed(stall_index: int)
signal vip_helicopter_landed()
signal vip_helicopter_departed()
signal catering_order_started(van_node: Node3D, meals_needed: int, time_limit: float)
signal catering_order_updated(van_node: Node3D, delivered: int, needed: int, time_left: float)
signal catering_order_finished(van_node: Node3D, success: bool)

@export var car_scenes: Array[PackedScene] = []

const STALL_POSITIONS: Array[Vector3] = [
	Vector3(-8.2, 0.0, 15.0), # West group bay 1
	Vector3(-4.8, 0.0, 15.0), # West group bay 2
	Vector3(1.8, 0.0, 15.0),  # East group bay 3
	Vector3(5.2, 0.0, 15.0),  # East group bay 4
	Vector3(8.6, 0.0, 15.0)   # East group bay 5
]

const STALL_ROTATIONS: Array[float] = [
	deg_to_rad(155.0),
	deg_to_rad(155.0),
	deg_to_rad(155.0),
	deg_to_rad(155.0),
	deg_to_rad(155.0)
]

const ROAD_Z: float = 18.2
const SPAWN_X: float = -22.0
const EXIT_X: float = 22.0

const HELIPAD_POS: Vector3 = Vector3(-15.0, 0.0, 16.0)
const HELI_APPROACH_POS: Vector3 = Vector3(-32.0, 16.0, 28.0)
const HELI_HOVER_POS: Vector3 = Vector3(-15.0, 4.5, 16.0)
const HELI_LANDED_POS: Vector3 = Vector3(-15.0, 0.45, 16.0)
const HELI_DEPART_POS: Vector3 = Vector3(-36.0, 22.0, 34.0)

var helicopter_node: Node3D = null
var helicopter_state: String = "IDLE" # IDLE, APPROACHING, LANDING, DISEMBARKING, TAKEOFF, DEPARTING
var helicopter_timer: float = 12.0
var helicopter_main_rotor: Node3D = null
var helicopter_tail_rotor: Node3D = null
var helicopter_beacon: OmniLight3D = null
var helicopter_state_timer: float = 0.0
var helipad_light: OmniLight3D = null

# Stall states: null if empty, or CarInstance if occupied (5 bays)
var stalls: Array = [null, null, null, null, null]
var active_cars: Array = []
var car_spawn_timer: float = 2.0
var car_cycle_index: int = 0

const CATERING_TIME_LIMIT: float = 45.0
const CATERING_MEALS_MIN: int = 6
const CATERING_MEALS_MAX: int = 10

class CarInstance:
	var node: Node3D
	var stall_index: int = -1
	var state: String = "DRIVING_IN" # DRIVING_IN, TURNING, PARKED, BACKING_OUT, DRIVING_AWAY
	var target_stall_pos: Vector3
	var speed: float = 8.0
	var driver_node: Node3D = null
	var is_delivery_van: bool = false
	var is_catering: bool = false
	var catering_meals_needed: int = 0
	var catering_meals_delivered: int = 0
	var catering_time_left: float = 0.0
	var catering_badge: Label3D = null

func _ready() -> void:
	# Load all 5 distinct vehicle classes matching the reference gameplay
	var car_paths = [
		"res://assets/models/cars/taxi.glb",
		"res://assets/models/cars/sedan.glb",
		"res://assets/models/cars/suv.glb",
		"res://assets/models/cars/delivery.glb",
		"res://assets/models/cars/hatchback-sports.glb"
	]
	for p in car_paths:
		var scn = load(p)
		if scn:
			car_scenes.append(scn)
			
	# Remove any legacy static placeholder cars
	for child in get_children():
		if child.name in ["Taxi", "Sedan", "SUV", "Delivery", "Hatchback"]:
			child.queue_free()
			
	# Spawn initial parked cars cycling through the vehicle classes so the lot is active from frame 1
	_spawn_initial_parked_car(0)
	_spawn_initial_parked_car(1)
	_spawn_initial_parked_car(2)
	_spawn_initial_parked_car(3)
	
	helipad_light = find_child("HelipadLight", true, false)

func _get_next_car_scene() -> PackedScene:
	if car_scenes.size() == 0:
		return null
	var scn = car_scenes[car_cycle_index % car_scenes.size()]
	car_cycle_index += 1
	return scn

func _spawn_initial_parked_car(stall_idx: int) -> void:
	if stall_idx < 0 or stall_idx >= STALL_POSITIONS.size() or car_scenes.size() == 0:
		return
	var scn = _get_next_car_scene()
	if scn == null:
		return
	var car_node = scn.instantiate()
	car_node.scale = Vector3(1.15, 1.15, 1.15)
	car_node.position = STALL_POSITIONS[stall_idx]
	var rot = STALL_ROTATIONS[stall_idx] if stall_idx < STALL_ROTATIONS.size() else PI
	car_node.rotation.y = rot
	add_child(car_node)
	
	var inst = CarInstance.new()
	inst.node = car_node
	inst.stall_index = stall_idx
	inst.state = "PARKED"
	inst.target_stall_pos = STALL_POSITIONS[stall_idx]
	inst.is_delivery_van = _is_delivery_van(car_node)
	stalls[stall_idx] = inst
	active_cars.append(inst)

	if inst.is_delivery_van:
		_start_catering_contract(inst)
	else:
		# Stagger departures of initial parked cars so bays open up sequentially for dynamic street traffic
		var initial_stay = randf_range(8.0 + stall_idx * 4.5, 14.0 + stall_idx * 5.0)
		get_tree().create_timer(initial_stay).timeout.connect(func():
			_on_passenger_entered_doors(inst)
		, CONNECT_ONE_SHOT)

func _process(delta: float) -> void:
	car_spawn_timer -= delta
	if car_spawn_timer <= 0.0:
		var gm = get_node_or_null("/root/GameManager")
		var mult: float = 1.0
		if gm != null and gm.has_method("get_spawn_rate_multiplier"):
			mult = gm.get_spawn_rate_multiplier()
		if gm != null and gm.has_method("get_vehicle_arrival_multiplier"):
			mult *= gm.get_vehicle_arrival_multiplier()
		elif gm != null and gm.has_method("is_rush_hour_active") and gm.is_rush_hour_active():
			mult *= 2.0
		car_spawn_timer = randf_range(4.0, 7.0) / max(0.15, mult)
		_try_spawn_car()
		
	_update_cars(delta)
	_update_catering_orders(delta)
	_update_helicopter(delta)

func _get_free_stall_index() -> int:
	var gm = get_node_or_null("/root/GameManager")
	var max_stalls = 5
	if gm != null and "unlocked_stalls" in gm:
		max_stalls = gm.unlocked_stalls
		
	for i in range(min(max_stalls, STALL_POSITIONS.size())):
		if stalls[i] == null:
			return i
	return -1

func _try_spawn_car() -> void:
	var free_idx = _get_free_stall_index()
	if free_idx == -1 or car_scenes.size() == 0:
		return
		
	var scn = _get_next_car_scene()
	if scn == null:
		return
	var car_node = scn.instantiate()
	car_node.scale = Vector3(1.15, 1.15, 1.15)
	car_node.position = Vector3(SPAWN_X, 0.0, ROAD_Z)
	car_node.rotation.y = -PI * 0.5 # Facing +X along highway
	add_child(car_node)
	
	var inst = CarInstance.new()
	inst.node = car_node
	inst.stall_index = free_idx
	inst.state = "DRIVING_IN"
	inst.target_stall_pos = STALL_POSITIONS[free_idx]
	inst.speed = randf_range(8.0, 10.0)
	inst.is_delivery_van = _is_delivery_van(car_node)
	
	stalls[free_idx] = inst
	active_cars.append(inst)

func _update_cars(delta: float) -> void:
	for i in range(active_cars.size() - 1, -1, -1):
		var car = active_cars[i]
		if not is_instance_valid(car.node):
			active_cars.remove_at(i)
			continue
			
		match car.state:
			"DRIVING_IN":
				# Move along road until reaching stall's X position
				var target_x = car.target_stall_pos.x
				car.node.position.x = move_toward(car.node.position.x, target_x, car.speed * delta)
				if abs(car.node.position.x - target_x) < 0.25:
					car.state = "TURNING"
					
			"TURNING":
				# Rotate to face angled parking stall and drive smoothly into stall
				var target_rot = STALL_ROTATIONS[car.stall_index] if car.stall_index >= 0 and car.stall_index < STALL_ROTATIONS.size() else PI
				car.node.rotation.y = lerp_angle(car.node.rotation.y, target_rot, 10.0 * delta)
				car.node.position.z = move_toward(car.node.position.z, car.target_stall_pos.z, car.speed * 0.65 * delta)
				car.node.position.x = move_toward(car.node.position.x, car.target_stall_pos.x, car.speed * 0.45 * delta)
				if abs(car.node.position.z - car.target_stall_pos.z) < 0.15:
					car.node.position = car.target_stall_pos
					car.node.rotation.y = target_rot
					car.state = "PARKED"
					_on_car_parked(car)
					
			"PARKED":
				# Parked in stall while customer exits, crosses zebra crossing, and enters doors
				pass
				
			"BACKING_OUT":
				# Smoothly reverse out of the angled stall into the highway road
				car.node.position.z = move_toward(car.node.position.z, ROAD_Z, car.speed * 0.5 * delta)
				car.node.position.x = move_toward(car.node.position.x, car.target_stall_pos.x - 0.4, car.speed * 0.25 * delta)
				car.node.rotation.y = lerp_angle(car.node.rotation.y, -PI * 0.5, 6.0 * delta)
				if abs(car.node.position.z - ROAD_Z) < 0.2:
					car.node.position.z = ROAD_Z
					car.node.rotation.y = -PI * 0.5
					car.state = "DRIVING_AWAY"
					if car.stall_index >= 0 and car.stall_index < stalls.size():
						stalls[car.stall_index] = null
						car_departed.emit(car.stall_index)
						
			"DRIVING_AWAY":
				# Accelerate along highway to exit boundary
				car.node.position.x = move_toward(car.node.position.x, EXIT_X, car.speed * delta)
				if car.node.position.x >= EXIT_X - 0.5:
					car.node.queue_free()
					active_cars.remove_at(i)

func _is_delivery_van(node: Node) -> bool:
	if node == null:
		return false
	var path := str(node.scene_file_path).to_lower()
	if path.contains("delivery"):
		return true
	return str(node.name).to_lower().contains("delivery")

func _on_car_parked(car: CarInstance) -> void:
	# Award parking fee
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		var fee: float = gm.get_station_income("parking_lot") if gm.has_method("get_station_income") else 25.0
		gm.add_cash(fee, car.node.global_position + Vector3(0, 1.5, 0))
		
	if car.is_delivery_van or _is_delivery_van(car.node):
		car.is_delivery_van = true
		_start_catering_contract(car)
		return
		
	# Spawn customer walking out of passenger side toward zebra crosswalk and front entrance!
	var rest = get_parent()
	var cust: Node3D = null
	if rest != null and rest.has_method("spawn_customer_from_car"):
		cust = rest.spawn_customer_from_car(car.node.global_position + Vector3(0.9, 0, 0))
		
	if cust != null:
		car.driver_node = cust
		# Synchronize vehicle departure with customer reaching the front sliding glass doors
		if cust.has_signal("entered_restaurant"):
			cust.entered_restaurant.connect(func(_c):
				_on_passenger_entered_doors(car)
			, CONNECT_ONE_SHOT)
		else:
			get_tree().create_timer(5.5).timeout.connect(func():
				_on_passenger_entered_doors(car)
			, CONNECT_ONE_SHOT)
	else:
		# If restaurant is currently full, wait briefly before departing to yield the bay
		get_tree().create_timer(4.0).timeout.connect(func():
			_on_passenger_entered_doors(car)
		, CONNECT_ONE_SHOT)

func _start_catering_contract(car: CarInstance) -> void:
	if car == null or not is_instance_valid(car.node) or car.is_catering:
		return
	car.is_catering = true
	car.catering_meals_needed = randi_range(CATERING_MEALS_MIN, CATERING_MEALS_MAX)
	car.catering_meals_delivered = 0
	car.catering_time_left = CATERING_TIME_LIMIT
	_spawn_catering_badge(car)
	catering_order_started.emit(car.node, car.catering_meals_needed, CATERING_TIME_LIMIT)
	var rest = get_parent()
	if rest != null and rest.has_method("begin_catering_order"):
		rest.begin_catering_order(car.node, car.catering_meals_needed, CATERING_TIME_LIMIT)

func _spawn_catering_badge(car: CarInstance) -> void:
	if car.catering_badge != null and is_instance_valid(car.catering_badge):
		car.catering_badge.queue_free()
	var badge = Label3D.new()
	badge.name = "CateringOrderBadge"
	badge.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	badge.double_sided = false
	badge.font_size = 22
	badge.outline_size = 7
	badge.modulate = Color(1.0, 0.88, 0.22, 1.0)
	badge.outline_modulate = Color(0.18, 0.08, 0.0, 0.95)
	badge.position = Vector3(0.0, 2.55, 0.0)
	car.node.add_child(badge)
	car.catering_badge = badge
	_refresh_catering_badge(car)

func _refresh_catering_badge(car: CarInstance) -> void:
	if car.catering_badge == null or not is_instance_valid(car.catering_badge):
		return
	var secs = max(0, int(ceil(car.catering_time_left)))
	car.catering_badge.text = "📦 CATERING  %d/%d  •  %ds" % [car.catering_meals_delivered, car.catering_meals_needed, secs]
	if car.catering_time_left <= 10.0:
		car.catering_badge.modulate = Color(1.0, 0.38, 0.28, 1.0)
	else:
		car.catering_badge.modulate = Color(1.0, 0.88, 0.22, 1.0)

func _update_catering_orders(delta: float) -> void:
	for i in range(active_cars.size() - 1, -1, -1):
		var car: CarInstance = active_cars[i]
		if not car.is_catering:
			continue
		if not is_instance_valid(car.node):
			car.is_catering = false
			continue
		if car.catering_badge != null and is_instance_valid(car.catering_badge):
			car.catering_badge.position.y = 2.55 + sin(Time.get_ticks_msec() / 280.0) * 0.08
		car.catering_time_left -= delta
		_refresh_catering_badge(car)
		catering_order_updated.emit(car.node, car.catering_meals_delivered, car.catering_meals_needed, car.catering_time_left)
		if car.catering_meals_delivered >= car.catering_meals_needed:
			_finish_catering_contract(car, true)
		elif car.catering_time_left <= 0.0:
			_finish_catering_contract(car, false)

func deliver_catering_meals(van_node: Node3D, meal_count: int) -> int:
	if van_node == null or meal_count <= 0:
		return 0
	for car in active_cars:
		if car.node == van_node and car.is_catering:
			var remaining = car.catering_meals_needed - car.catering_meals_delivered
			var accepted = mini(meal_count, remaining)
			car.catering_meals_delivered += accepted
			_refresh_catering_badge(car)
			catering_order_updated.emit(car.node, car.catering_meals_delivered, car.catering_meals_needed, car.catering_time_left)
			if car.catering_meals_delivered >= car.catering_meals_needed:
				_finish_catering_contract(car, true)
			return accepted
	return 0

func get_open_catering_vans() -> Array:
	var vans: Array = []
	for car in active_cars:
		if car.is_catering and is_instance_valid(car.node) and car.state == "PARKED":
			vans.append(car.node)
	return vans

func _finish_catering_contract(car: CarInstance, success: bool) -> void:
	if not car.is_catering:
		return
	car.is_catering = false
	if car.catering_badge != null and is_instance_valid(car.catering_badge):
		car.catering_badge.queue_free()
		car.catering_badge = null
	var van_pos: Vector3 = car.node.global_position if is_instance_valid(car.node) else Vector3.ZERO
	if success:
		var gm = get_node_or_null("/root/GameManager")
		var station_rev: float = 15.0
		if gm != null and gm.has_method("get_station_income"):
			station_rev = gm.get_station_income("kitchen_cook")
		var payout: float = station_rev * 5.0
		var coins: int = 25 + car.catering_meals_needed
		if gm != null:
			gm.add_cash(payout, van_pos + Vector3(0, 1.8, 0))
			if gm.has_method("add_golden_coins"):
				gm.add_golden_coins(coins, van_pos + Vector3(0, 2.2, 0))
		var rest = get_parent()
		if rest != null and rest.has_method("on_catering_order_completed"):
			rest.on_catering_order_completed(car.node, true, payout, coins)
	else:
		var rest_fail = get_parent()
		if rest_fail != null and rest_fail.has_method("on_catering_order_completed"):
			rest_fail.on_catering_order_completed(car.node, false, 0.0, 0)
	catering_order_finished.emit(car.node if is_instance_valid(car.node) else null, success)
	_on_passenger_entered_doors(car)

func _on_passenger_entered_doors(car: CarInstance) -> void:
	if car.is_catering:
		return
	if is_instance_valid(car.node) and car.state == "PARKED":
		# Pause 1.2s after passenger enters doors, then smoothly back out
		await get_tree().create_timer(1.2).timeout
		if is_instance_valid(car.node) and car.state == "PARKED" and not car.is_catering:
			car.state = "BACKING_OUT"

# ─── Executive VIP Helicopter & Helipad System ──────────────────────────────
func _spawn_helicopter() -> void:
	if helicopter_node != null:
		return
	helicopter_node = _build_helicopter()
	helicopter_node.position = HELI_APPROACH_POS
	add_child(helicopter_node)
	helicopter_state = "APPROACHING"

func _build_helicopter() -> Node3D:
	var heli = Node3D.new()
	heli.name = "ExecutiveHelicopter"
	
	# Obsidian & Gold metallic materials
	var body_mat = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.08, 0.09, 0.12, 1.0)
	body_mat.metallic = 0.92
	body_mat.roughness = 0.22
	
	var gold_mat = StandardMaterial3D.new()
	gold_mat.albedo_color = Color(1.0, 0.82, 0.2, 1.0)
	gold_mat.metallic = 0.95
	gold_mat.roughness = 0.2
	gold_mat.emission_enabled = true
	gold_mat.emission = Color(1.0, 0.82, 0.2, 1.0)
	gold_mat.emission_energy_multiplier = 0.5
	
	var glass_mat = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.2, 0.72, 0.9, 0.7)
	glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_mat.metallic = 0.15
	glass_mat.roughness = 0.05
	
	var chrome_mat = StandardMaterial3D.new()
	chrome_mat.albedo_color = Color(0.85, 0.88, 0.92, 1.0)
	chrome_mat.metallic = 0.98
	chrome_mat.roughness = 0.12
	
	var carbon_mat = StandardMaterial3D.new()
	carbon_mat.albedo_color = Color(0.12, 0.13, 0.15, 1.0)
	carbon_mat.roughness = 0.4
	
	# 1. Main Fuselage Cabin
	var cabin = MeshInstance3D.new()
	var c_box = BoxMesh.new()
	c_box.size = Vector3(1.35, 1.25, 2.75)
	cabin.mesh = c_box
	cabin.material_override = body_mat
	cabin.position = Vector3(0.0, 0.48, 0.0)
	heli.add_child(cabin)
	
	# Gold luxury side pinstripes
	var stripe = MeshInstance3D.new()
	var s_box = BoxMesh.new()
	s_box.size = Vector3(1.38, 0.09, 2.4)
	stripe.mesh = s_box
	stripe.material_override = gold_mat
	stripe.position = Vector3(0.0, 0.48, 0.0)
	heli.add_child(stripe)
	
	# 2. Cockpit Canopy (tinted cyan glass)
	var cockpit = MeshInstance3D.new()
	var cp_box = BoxMesh.new()
	cp_box.size = Vector3(1.22, 0.85, 1.15)
	cockpit.mesh = cp_box
	cockpit.material_override = glass_mat
	cockpit.position = Vector3(0.0, 0.62, -0.95)
	heli.add_child(cockpit)
	
	# 3. Tail Boom
	var boom = MeshInstance3D.new()
	var b_cyl = CylinderMesh.new()
	b_cyl.top_radius = 0.11
	b_cyl.bottom_radius = 0.18
	b_cyl.height = 2.4
	boom.mesh = b_cyl
	boom.material_override = body_mat
	boom.rotation.x = PI * 0.5
	boom.position = Vector3(0.0, 0.55, 2.2)
	heli.add_child(boom)
	
	# 4. Tail Vertical Fin & Stabilizer
	var vfin = MeshInstance3D.new()
	var vf_box = BoxMesh.new()
	vf_box.size = Vector3(0.08, 0.95, 0.65)
	vfin.mesh = vf_box
	vfin.material_override = body_mat
	vfin.position = Vector3(0.0, 1.05, 3.2)
	heli.add_child(vfin)
	
	var hstab = MeshInstance3D.new()
	var hs_box = BoxMesh.new()
	hs_box.size = Vector3(1.2, 0.04, 0.35)
	hstab.mesh = hs_box
	hstab.material_override = gold_mat
	hstab.position = Vector3(0.0, 0.72, 2.85)
	heli.add_child(hstab)
	
	# 5. Tail Rotor
	helicopter_tail_rotor = Node3D.new()
	helicopter_tail_rotor.name = "TailRotor"
	helicopter_tail_rotor.position = Vector3(0.11, 1.35, 3.35)
	var tr_blade = MeshInstance3D.new()
	var tr_box = BoxMesh.new()
	tr_box.size = Vector3(0.02, 0.75, 0.08)
	tr_blade.mesh = tr_box
	tr_blade.material_override = carbon_mat
	helicopter_tail_rotor.add_child(tr_blade)
	heli.add_child(helicopter_tail_rotor)
	
	# 6. Main Rotor Mast & 4 Blades
	var mast = MeshInstance3D.new()
	var m_cyl = CylinderMesh.new()
	m_cyl.top_radius = 0.07
	m_cyl.bottom_radius = 0.09
	m_cyl.height = 0.35
	mast.mesh = m_cyl
	mast.material_override = chrome_mat
	mast.position = Vector3(0.0, 1.25, -0.1)
	heli.add_child(mast)
	
	helicopter_main_rotor = Node3D.new()
	helicopter_main_rotor.name = "MainRotor"
	helicopter_main_rotor.position = Vector3(0.0, 1.42, -0.1)
	
	for rot_idx in range(4):
		var blade = MeshInstance3D.new()
		var b_box = BoxMesh.new()
		b_box.size = Vector3(0.14, 0.02, 2.05)
		blade.mesh = b_box
		blade.material_override = carbon_mat
		blade.position = Vector3(0.0, 0.0, 1.05)
		
		var tip = MeshInstance3D.new()
		var t_box = BoxMesh.new()
		t_box.size = Vector3(0.145, 0.025, 0.35)
		tip.mesh = t_box
		tip.material_override = gold_mat
		tip.position = Vector3(0.0, 0.0, 0.88)
		blade.add_child(tip)
		
		var pivot = Node3D.new()
		pivot.rotation.y = rot_idx * (PI * 0.5)
		pivot.add_child(blade)
		helicopter_main_rotor.add_child(pivot)
		
	heli.add_child(helicopter_main_rotor)
	
	# 7. Chrome Landing Skids
	for side in [-1.0, 1.0]:
		var skid = MeshInstance3D.new()
		var s_cyl = CylinderMesh.new()
		s_cyl.top_radius = 0.045
		s_cyl.bottom_radius = 0.045
		s_cyl.height = 2.7
		skid.mesh = s_cyl
		skid.material_override = chrome_mat
		skid.rotation.x = PI * 0.5
		skid.position = Vector3(side * 0.65, -0.05, 0.0)
		heli.add_child(skid)
		
		for strut_z in [-0.65, 0.65]:
			var strut = MeshInstance3D.new()
			var st_cyl = CylinderMesh.new()
			st_cyl.top_radius = 0.035
			st_cyl.bottom_radius = 0.035
			st_cyl.height = 0.55
			strut.mesh = st_cyl
			strut.material_override = chrome_mat
			strut.position = Vector3(side * 0.45, 0.18, strut_z)
			strut.rotation.z = -side * 0.35
			heli.add_child(strut)
			
	# 8. Underbelly Spotlight
	var spot = SpotLight3D.new()
	spot.rotation.x = -PI * 0.5
	spot.position = Vector3(0.0, 0.0, -0.3)
	spot.light_color = Color(1.0, 0.96, 0.85, 1.0)
	spot.spot_angle = 35.0
	spot.spot_range = 20.0
	spot.light_energy = 3.5
	heli.add_child(spot)
	
	# 9. Flashing Beacon Light
	helicopter_beacon = OmniLight3D.new()
	helicopter_beacon.position = Vector3(0.0, 1.55, 3.2)
	helicopter_beacon.light_color = Color(1.0, 0.25, 0.15, 1.0)
	helicopter_beacon.omni_range = 5.0
	helicopter_beacon.light_energy = 2.0
	heli.add_child(helicopter_beacon)
	
	return heli

func _update_helicopter(delta: float) -> void:
	if helicopter_node == null:
		helicopter_timer -= delta
		if helicopter_timer <= 0.0:
			_spawn_helicopter()
		return
		
	if helicopter_main_rotor != null:
		var spin_speed = 36.0 if helicopter_state != "DISEMBARKING" else 18.0
		helicopter_main_rotor.rotation.y += delta * spin_speed
	if helicopter_tail_rotor != null:
		var tail_spin = 48.0 if helicopter_state != "DISEMBARKING" else 24.0
		helicopter_tail_rotor.rotation.x += delta * tail_spin
	if helicopter_beacon != null:
		helicopter_beacon.light_energy = 1.8 if fmod(Time.get_ticks_msec() / 600.0, 1.0) < 0.25 else 0.2

	match helicopter_state:
		"APPROACHING":
			helicopter_node.position = helicopter_node.position.move_toward(HELI_HOVER_POS, 10.5 * delta)
			var to_pad = (HELI_HOVER_POS - helicopter_node.position)
			to_pad.y = 0.0
			if to_pad.length() > 0.5:
				var target_rot = atan2(to_pad.x, to_pad.z)
				helicopter_node.rotation.y = lerp_angle(helicopter_node.rotation.y, target_rot, 5.0 * delta)
				helicopter_node.rotation.z = lerp_angle(helicopter_node.rotation.z, -0.15, 4.0 * delta)
			if helicopter_node.position.distance_to(HELI_HOVER_POS) < 0.3:
				helicopter_node.position = HELI_HOVER_POS
				helicopter_node.rotation = Vector3.ZERO
				helicopter_state = "LANDING"

		"LANDING":
			helicopter_node.position = helicopter_node.position.move_toward(HELI_LANDED_POS, 2.2 * delta)
			if abs(helicopter_node.position.y - HELI_LANDED_POS.y) < 0.08:
				helicopter_node.position = HELI_LANDED_POS
				helicopter_state = "DISEMBARKING"
				helicopter_state_timer = 4.0
				_on_helicopter_touchdown()

		"DISEMBARKING":
			helicopter_state_timer -= delta
			if helicopter_state_timer <= 0.0:
				helicopter_state = "TAKEOFF"
				var am = get_node_or_null("/root/AudioManager")
				if am != null and am.has_method("play_sfx"):
					am.play_sfx("upgrade", 0.05, 1.8)

		"TAKEOFF":
			helicopter_node.position = helicopter_node.position.move_toward(HELI_HOVER_POS, 2.6 * delta)
			if abs(helicopter_node.position.y - HELI_HOVER_POS.y) < 0.15:
				helicopter_node.position = HELI_HOVER_POS
				helicopter_state = "DEPARTING"
				vip_helicopter_departed.emit()

		"DEPARTING":
			helicopter_node.position = helicopter_node.position.move_toward(HELI_DEPART_POS, 12.0 * delta)
			var to_dep = (HELI_DEPART_POS - helicopter_node.position)
			to_dep.y = 0.0
			if to_dep.length() > 0.5:
				var target_rot = atan2(to_dep.x, to_dep.z)
				helicopter_node.rotation.y = lerp_angle(helicopter_node.rotation.y, target_rot, 4.0 * delta)
				helicopter_node.rotation.x = lerp_angle(helicopter_node.rotation.x, -0.12, 4.0 * delta)
			if helicopter_node.position.distance_to(HELI_DEPART_POS) < 1.0:
				helicopter_node.queue_free()
				helicopter_node = null
				helicopter_state = "IDLE"
				var vip_mult: float = 1.0
				var gm_heli = get_node_or_null("/root/GameManager")
				if gm_heli != null and gm_heli.has_method("get_card_vip_spawn_multiplier"):
					vip_mult = gm_heli.get_card_vip_spawn_multiplier()
				helicopter_timer = randf_range(60.0, 90.0) / vip_mult

func _on_helicopter_touchdown() -> void:
	vip_helicopter_landed.emit()
	if helipad_light != null:
		helipad_light.light_energy = 3.2
		var tw = create_tween()
		tw.tween_property(helipad_light, "light_energy", 0.8, 2.5)
		
	var rest = get_parent()
	var vip_spawn_pos = HELIPAD_POS + Vector3(1.4, 0.0, 0.0)
	if rest != null and rest.has_method("spawn_vip_investor"):
		rest.spawn_vip_investor(vip_spawn_pos)
	else:
		var cust_scn = load("res://scenes/customer.tscn")
		if cust_scn != null:
			var cust = cust_scn.instantiate()
			add_child(cust)
			cust.position = vip_spawn_pos
			if cust.has_method("set_as_vip_investor"):
				cust.set_as_vip_investor(true)
				
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("claim", 0.05, 1.5)

func get_helicopter_state() -> String:
	return helicopter_state

func force_spawn_vip_helicopter() -> void:
	if helicopter_node != null:
		helicopter_node.queue_free()
		helicopter_node = null
	helicopter_timer = 0.0
	_spawn_helicopter()

func get_active_supply_drone() -> Node3D:
	var rest = get_parent()
	if rest != null and rest.has_method("get_active_supply_drone"):
		return rest.get_active_supply_drone()
	var root = get_tree().current_scene if get_tree() != null else null
	if root != null:
		return root.find_child("SupplyDrone", true, false)
	return null

func trigger_supply_drone() -> Node3D:
	var rest = get_parent()
	if rest != null and rest.has_method("spawn_supply_drone"):
		return rest.spawn_supply_drone()
	return null

