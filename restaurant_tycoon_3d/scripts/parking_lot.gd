extends Node3D

signal car_parked(stall_index: int, customer_node: Node3D)
signal car_departed(stall_index: int)

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

# Stall states: null if empty, or CarInstance if occupied (5 bays)
var stalls: Array = [null, null, null, null, null]
var active_cars: Array = []
var car_spawn_timer: float = 2.0
var car_cycle_index: int = 0

class CarInstance:
	var node: Node3D
	var stall_index: int = -1
	var state: String = "DRIVING_IN" # DRIVING_IN, TURNING, PARKED, BACKING_OUT, DRIVING_AWAY
	var target_stall_pos: Vector3
	var speed: float = 8.0
	var driver_node: Node3D = null

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
	stalls[stall_idx] = inst
	active_cars.append(inst)

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
		car_spawn_timer = randf_range(4.0, 7.0) / mult
		_try_spawn_car()
		
	_update_cars(delta)

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

func _on_car_parked(car: CarInstance) -> void:
	# Award parking fee
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.add_cash(25.0, car.node.global_position + Vector3(0, 1.5, 0))
		
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

func _on_passenger_entered_doors(car: CarInstance) -> void:
	if is_instance_valid(car.node) and car.state == "PARKED":
		# Pause 1.2s after passenger enters doors, then smoothly back out
		await get_tree().create_timer(1.2).timeout
		if is_instance_valid(car.node) and car.state == "PARKED":
			car.state = "BACKING_OUT"
