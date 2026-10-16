extends CharacterBody3D

enum State {
	IDLE,
	WALKING_TO_KITCHEN,
	WALKING_TO_TABLE,
	SERVING,
	RETURNING,
	ON_BREAK,
	CATERING_PICKUP,
	CATERING_DELIVER
}

@export var staff_id: String = "waiter_1"
@export var staff_name: String = "Marco"

var current_state: State = State.IDLE
var base_speed: float = 3.6
var move_speed: float = 3.6
var walk_cycle: float = 0.0

var waypoints: Array = []
var target_table: Node3D = null
var is_cleaning_job: bool = false
var speed_buff_timer: float = 0.0
var is_break_sofa: bool = false
var break_spot: Vector3 = Vector3.ZERO

@onready var mesh_root: Node3D = $MeshRoot
@onready var serving_tray: Node3D = $ServingTray
@onready var status_bubble: Label3D = $StatusLabel

var anim_player: AnimationPlayer = null

# Kitchen Pass counter is located at Z = -3.4m under silver dome heat lamps (X = 6.5)
const KITCHEN_PASS_POS: Vector3 = Vector3(6.5, 0.0, -3.4)
const NORTH_CROSS_AISLE_Z: float = -1.0
const DOOR_POS: Vector3 = Vector3(-1.5, 0.0, 10.5)
var home_pos: Vector3 = Vector3(3.5, 0.0, 0.5)
var catering_van: Node3D = null
var catering_meals: int = 0
var catering_lot: Node = null

func _ready() -> void:
	home_pos = position
	home_pos.y = 0.0
	serving_tray.visible = false
	if status_bubble != null:
		status_bubble.visible = false
	anim_player = _find_anim_player(self)
	_play_anim("idle")
	
	_update_speed()
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.staff_updated.connect(_on_staff_updated)
		if gm.has_signal("cards_updated"):
			gm.cards_updated.connect(_update_speed)

func _find_anim_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found = _find_anim_player(child)
		if found != null:
			return found
	return null

func _update_speed() -> void:
	var gm = get_node_or_null("/root/GameManager")
	var mult: float = 1.0
	if gm != null and gm.has_method("get_staff_speed_multiplier"):
		mult = gm.get_staff_speed_multiplier(staff_id)
	if gm != null and gm.has_method("get_card_waiter_speed_multiplier"):
		mult *= gm.get_card_waiter_speed_multiplier()
	if speed_buff_timer > 0.0:
		mult *= 1.30
	move_speed = base_speed * mult

func _on_staff_updated(id: String) -> void:
	if id == staff_id:
		_update_speed()

func _play_anim(anim_name: String, loop: bool = false) -> void:
	if anim_player != null and anim_player.has_animation(anim_name):
		var anim = anim_player.get_animation(anim_name)
		if anim != null:
			if loop or anim_name in ["idle", "sit", "walk"]:
				anim.loop_mode = Animation.LOOP_LINEAR
			else:
				anim.loop_mode = Animation.LOOP_NONE
		anim_player.play(anim_name)

func _get_aisle_x(x_val: float) -> float:
	if x_val > 10.0:
		return 11.2
	elif x_val > 6.0:
		return 6.9
	elif x_val > 0.0:
		return 3.3
	else:
		return -4.5

func _get_table_aisle_and_approach(table: Node3D) -> Dictionary:
	var tx = table.global_position.x
	var tz = table.global_position.z
	var aisle_x: float = 3.3
	var approach_x: float = 2.6
	
	if tx < -3.0:
		# West sectors: Cocktail Lounge & 50s Milkshake Diner
		aisle_x = -4.5
		approach_x = tx + (0.75 if tx < -4.5 else -0.75)
	elif tx <= 3.0:
		# Col 1 (Tables 1, 2, 3 at X = 1.2): aisle on the right
		aisle_x = 3.3
		approach_x = 2.6
	elif tx <= 6.8:
		# Col 2 (Tables 4, 5, 6 at X = 5.0): central transit aisle
		aisle_x = 3.5
		approach_x = 3.6
	elif tx <= 10.8:
		# Col 3 (Tables 7, 8, 9 at X = 8.8): east transit aisle
		aisle_x = 6.9
		approach_x = 7.3
	else:
		# Col 4 (Tables 10, 11, 12 at X = 13.25): expansion aisle
		aisle_x = 11.2
		approach_x = 11.8
		
	return {
		"aisle_x": aisle_x,
		"approach_pos": Vector3(approach_x, 0.0, tz)
	}

func _get_waypoints_to_pass(from_pos: Vector3) -> Array:
	var pts: Array = []
	var cur_aisle_x = _get_aisle_x(from_pos.x)
	if cur_aisle_x < -3.0:
		pts.append(Vector3(-4.5, 0.0, from_pos.z))
		pts.append(Vector3(-4.5, 0.0, -0.5))
		pts.append(Vector3(-3.2, 0.0, -0.5))
		pts.append(Vector3(3.3, 0.0, NORTH_CROSS_AISLE_Z))
		pts.append(Vector3(6.5, 0.0, NORTH_CROSS_AISLE_Z))
	else:
		if abs(from_pos.x - cur_aisle_x) > 0.35:
			pts.append(Vector3(cur_aisle_x, 0.0, from_pos.z))
		if from_pos.z > NORTH_CROSS_AISLE_Z + 0.2:
			pts.append(Vector3(cur_aisle_x, 0.0, NORTH_CROSS_AISLE_Z))
		if abs(cur_aisle_x - 6.5) > 0.35:
			pts.append(Vector3(6.5, 0.0, NORTH_CROSS_AISLE_Z))
	pts.append(KITCHEN_PASS_POS)
	return pts

func _get_waypoints_from_pass_to_table(table: Node3D) -> Array:
	var pts: Array = []
	var info = _get_table_aisle_and_approach(table)
	var dest_aisle_x: float = info["aisle_x"]
	var approach: Vector3 = info["approach_pos"]
	
	pts.append(Vector3(6.5, 0.0, NORTH_CROSS_AISLE_Z))
	if dest_aisle_x < -3.0:
		pts.append(Vector3(3.3, 0.0, NORTH_CROSS_AISLE_Z))
		pts.append(Vector3(-3.2, 0.0, -0.5))
		pts.append(Vector3(-4.5, 0.0, -0.5))
		pts.append(Vector3(-4.5, 0.0, approach.z))
	else:
		if abs(dest_aisle_x - 6.5) > 0.35:
			pts.append(Vector3(dest_aisle_x, 0.0, NORTH_CROSS_AISLE_Z))
		pts.append(Vector3(dest_aisle_x, 0.0, approach.z))
	pts.append(approach)
	return pts

func _get_waypoints_to_clean_table(from_pos: Vector3, table: Node3D) -> Array:
	var pts: Array = []
	var cur_aisle_x = _get_aisle_x(from_pos.x)
	var info = _get_table_aisle_and_approach(table)
	var dest_aisle_x: float = info["aisle_x"]
	var approach: Vector3 = info["approach_pos"]
	
	if abs(cur_aisle_x - dest_aisle_x) < 0.4:
		pts.append(Vector3(cur_aisle_x, 0.0, approach.z))
		pts.append(approach)
	else:
		if cur_aisle_x < -3.0 and dest_aisle_x >= -3.0:
			pts.append(Vector3(-4.5, 0.0, from_pos.z))
			pts.append(Vector3(-4.5, 0.0, -0.5))
			pts.append(Vector3(-3.2, 0.0, -0.5))
			pts.append(Vector3(dest_aisle_x, 0.0, NORTH_CROSS_AISLE_Z))
			pts.append(Vector3(dest_aisle_x, 0.0, approach.z))
			pts.append(approach)
		elif cur_aisle_x >= -3.0 and dest_aisle_x < -3.0:
			pts.append(Vector3(cur_aisle_x, 0.0, from_pos.z))
			pts.append(Vector3(cur_aisle_x, 0.0, NORTH_CROSS_AISLE_Z))
			pts.append(Vector3(3.3, 0.0, NORTH_CROSS_AISLE_Z))
			pts.append(Vector3(-3.2, 0.0, -0.5))
			pts.append(Vector3(-4.5, 0.0, -0.5))
			pts.append(Vector3(-4.5, 0.0, approach.z))
			pts.append(approach)
		else:
			if abs(from_pos.x - cur_aisle_x) > 0.35:
				pts.append(Vector3(cur_aisle_x, 0.0, from_pos.z))
			if from_pos.z > NORTH_CROSS_AISLE_Z + 0.2:
				pts.append(Vector3(cur_aisle_x, 0.0, NORTH_CROSS_AISLE_Z))
			pts.append(Vector3(dest_aisle_x, 0.0, NORTH_CROSS_AISLE_Z))
			pts.append(Vector3(dest_aisle_x, 0.0, approach.z))
			pts.append(approach)
	return pts

func _get_waypoints_to_home(from_pos: Vector3) -> Array:
	var pts: Array = []
	var cur_aisle_x = _get_aisle_x(from_pos.x)
	var home_aisle_x = _get_aisle_x(home_pos.x)
	
	if abs(cur_aisle_x - home_aisle_x) < 0.4:
		pts.append(Vector3(home_aisle_x, 0.0, from_pos.z))
		pts.append(home_pos)
	else:
		if cur_aisle_x < -3.0 and home_aisle_x >= -3.0:
			pts.append(Vector3(-4.5, 0.0, from_pos.z))
			pts.append(Vector3(-4.5, 0.0, -0.5))
			pts.append(Vector3(-3.2, 0.0, -0.5))
			pts.append(Vector3(home_aisle_x, 0.0, NORTH_CROSS_AISLE_Z))
			pts.append(home_pos)
		else:
			pts.append(Vector3(cur_aisle_x, 0.0, from_pos.z))
			pts.append(Vector3(cur_aisle_x, 0.0, NORTH_CROSS_AISLE_Z))
			pts.append(Vector3(home_aisle_x, 0.0, NORTH_CROSS_AISLE_Z))
			pts.append(home_pos)
	return pts

func deliver_catering_crate(van: Node3D, meals: int, lot: Node = null) -> bool:
	if current_state != State.IDLE or van == null or meals <= 0:
		return false
	catering_van = van
	catering_meals = meals
	catering_lot = lot
	target_table = null
	is_cleaning_job = false
	current_state = State.CATERING_PICKUP
	waypoints = _get_waypoints_to_pass(position)
	serving_tray.visible = false
	if status_bubble != null:
		status_bubble.text = "📦 Catering crate"
		status_bubble.visible = true
	_play_anim("walk")
	return true

func _get_waypoints_to_van(from_pos: Vector3, van_pos: Vector3) -> Array:
	var pts: Array = []
	pts.append(Vector3(6.5, 0.0, NORTH_CROSS_AISLE_Z))
	pts.append(Vector3(3.3, 0.0, NORTH_CROSS_AISLE_Z))
	pts.append(Vector3(-1.5, 0.0, 7.0))
	pts.append(DOOR_POS)
	pts.append(Vector3(-1.5, 0.0, 13.8))
	var drop := Vector3(van_pos.x, 0.0, van_pos.z)
	if abs(drop.x + 1.5) > 0.4:
		pts.append(Vector3(drop.x, 0.0, 13.8))
	pts.append(drop + Vector3(0.85, 0.0, 0.35))
	return pts

func serve_order(table: Node3D) -> void:
	if current_state != State.IDLE:
		return
	target_table = table
	is_cleaning_job = false
	current_state = State.WALKING_TO_KITCHEN
	waypoints = _get_waypoints_to_pass(position)
	serving_tray.visible = false
	_play_anim("walk")

func clean_dirty_table(table: Node3D) -> void:
	if current_state != State.IDLE:
		return
	target_table = table
	is_cleaning_job = true
	current_state = State.WALKING_TO_TABLE
	serving_tray.visible = false
	waypoints = _get_waypoints_to_clean_table(position, table)
	_play_anim("walk")

func _get_waypoints_to_breakroom(from_pos: Vector3, target_spot: Vector3) -> Array:
	var pts: Array = []
	var cur_aisle_x = _get_aisle_x(from_pos.x)
	pts.append(Vector3(cur_aisle_x, 0.0, from_pos.z))
	pts.append(Vector3(cur_aisle_x, 0.0, NORTH_CROSS_AISLE_Z))
	pts.append(Vector3(10.5, 0.0, NORTH_CROSS_AISLE_Z))
	pts.append(Vector3(11.5, 0.0, -1.5))
	pts.append(target_spot)
	return pts

func _get_waypoints_from_breakroom_to_home(_from_pos: Vector3) -> Array:
	var pts: Array = []
	var home_aisle_x = _get_aisle_x(home_pos.x)
	pts.append(Vector3(11.5, 0.0, -1.5))
	pts.append(Vector3(10.5, 0.0, NORTH_CROSS_AISLE_Z))
	pts.append(Vector3(home_aisle_x, 0.0, NORTH_CROSS_AISLE_Z))
	pts.append(home_pos)
	return pts

func take_breakroom_rest(spot: Vector3, is_sofa: bool) -> void:
	if current_state != State.IDLE:
		return
	is_cleaning_job = false
	current_state = State.ON_BREAK
	is_break_sofa = is_sofa
	break_spot = spot
	serving_tray.visible = false
	waypoints = _get_waypoints_to_breakroom(position, break_spot)
	_play_anim("walk")
	if status_bubble != null:
		status_bubble.text = "☕ Sofa Rest" if is_sofa else "☕ Coffee Break"
		status_bubble.visible = true

func _physics_process(delta: float) -> void:
	if speed_buff_timer > 0.0:
		speed_buff_timer -= delta
		if speed_buff_timer <= 0.0:
			_update_speed()

	if waypoints.size() > 0:
		var target: Vector3 = waypoints[0]
		var to_target: Vector3 = target - position
		to_target.y = 0.0
		var dist: float = to_target.length()
		
		if dist > 0.24:
			var dir: Vector3 = to_target.normalized()
			var desired_vel: Vector3 = dir * move_speed
			velocity = velocity.move_toward(desired_vel, 14.0 * delta)
			
			var target_yaw: float = atan2(dir.x, dir.z)
			rotation.y = lerp_angle(rotation.y, target_yaw, 11.0 * delta)
			
			walk_cycle += delta * (13.0 * (move_speed / base_speed))
			if mesh_root != null:
				mesh_root.position.y = abs(sin(walk_cycle)) * 0.05
				mesh_root.rotation.z = sin(walk_cycle) * 0.04
		else:
			waypoints.remove_at(0)
			if waypoints.size() == 0:
				velocity = Vector3.ZERO
				if mesh_root != null:
					mesh_root.position.y = 0.0
					mesh_root.rotation.z = 0.0
				_on_all_waypoints_reached()
	else:
		velocity = velocity.move_toward(Vector3.ZERO, 16.0 * delta)
		if mesh_root != null:
			mesh_root.position.y = move_toward(mesh_root.position.y, 0.0, delta * 0.2)
			mesh_root.rotation.z = move_toward(mesh_root.rotation.z, 0.0, delta * 0.5)

	move_and_slide()

func _on_all_waypoints_reached() -> void:
	match current_state:
		State.WALKING_TO_KITCHEN:
			# Look directly North into the kitchen pass counter at Z = -3.4m under silver heat lamps
			rotation.y = PI
			serving_tray.visible = true
			serving_tray.scale = Vector3(0.2, 0.2, 0.2)
			var tw = create_tween()
			tw.tween_property(serving_tray, "scale", Vector3.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			
			var am = get_node_or_null("/root/AudioManager")
			if am != null and am.has_method("play_sfx"):
				am.play_sfx("bell", 0.04, -2.0)
			
			await get_tree().create_timer(0.35).timeout
			
			if not is_instance_valid(target_table) or target_table.get("is_occupied") != true:
				# Order cancelled or table vacated
				serving_tray.visible = false
				current_state = State.RETURNING
				waypoints = _get_waypoints_to_home(position)
				_play_anim("walk")
				return
				
			current_state = State.WALKING_TO_TABLE
			waypoints = _get_waypoints_from_pass_to_table(target_table)
			_play_anim("walk")
			
		State.WALKING_TO_TABLE:
			current_state = State.SERVING
			_play_anim("idle")
			
			if is_instance_valid(target_table):
				var to_tbl = target_table.global_position - position
				rotation.y = atan2(to_tbl.x, to_tbl.z)
				if is_cleaning_job:
					# Play table-wiping animation, despawn dirty plates, reset is_dirty = false
					_play_anim("interact-right", true)
					var wipe_dur: float = 1.8
					var gm_ref = get_node_or_null("/root/GameManager")
					if gm_ref != null and gm_ref.has_method("get_card_waiter_speed_multiplier"):
						wipe_dur /= gm_ref.get_card_waiter_speed_multiplier()
					await get_tree().create_timer(wipe_dur).timeout
					if is_instance_valid(target_table) and target_table.has_method("clean_table"):
						target_table.clean_table()
					is_cleaning_job = false
				else:
					var dish_id: String = "burger"
					if "occupying_customer" in target_table and is_instance_valid(target_table.occupying_customer):
						var cust = target_table.occupying_customer
						if "ordered_dish" in cust and typeof(cust.ordered_dish) == TYPE_DICTIONARY:
							dish_id = cust.ordered_dish.get("id", "burger")
					if target_table.has_method("serve_food"):
						target_table.serve_food(dish_id)
					await get_tree().create_timer(0.45).timeout
					serving_tray.visible = false
			else:
				is_cleaning_job = false
				serving_tray.visible = false
			
			current_state = State.RETURNING
			waypoints = _get_waypoints_to_home(position)
			_play_anim("walk")
			
		State.RETURNING:
			current_state = State.IDLE
			_play_anim("idle")
			rotation.y = 0.0

		State.CATERING_PICKUP:
			rotation.y = PI
			serving_tray.visible = true
			serving_tray.scale = Vector3(0.2, 0.2, 0.2)
			var crate_tw = create_tween()
			crate_tw.tween_property(serving_tray, "scale", Vector3(1.15, 1.15, 1.15), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			var am_cat = get_node_or_null("/root/AudioManager")
			if am_cat != null and am_cat.has_method("play_sfx"):
				am_cat.play_sfx("bell", 0.04, -2.0)
			await get_tree().create_timer(0.28).timeout
			if not is_instance_valid(catering_van):
				serving_tray.visible = false
				if status_bubble != null:
					status_bubble.visible = false
				current_state = State.RETURNING
				waypoints = _get_waypoints_to_home(position)
				_play_anim("walk")
				return
			current_state = State.CATERING_DELIVER
			waypoints = _get_waypoints_to_van(position, catering_van.global_position)
			_play_anim("walk")

		State.CATERING_DELIVER:
			if is_instance_valid(catering_van) and catering_lot != null and catering_lot.has_method("deliver_catering_meals"):
				catering_lot.deliver_catering_meals(catering_van, catering_meals)
			elif is_instance_valid(catering_van):
				var lot_node = get_tree().get_root().find_child("ParkingLot", true, false)
				if lot_node != null and lot_node.has_method("deliver_catering_meals"):
					lot_node.deliver_catering_meals(catering_van, catering_meals)
			serving_tray.visible = false
			catering_van = null
			catering_meals = 0
			catering_lot = null
			if status_bubble != null:
				status_bubble.visible = false
			current_state = State.RETURNING
			waypoints = _get_waypoints_to_home(position)
			_play_anim("walk")

		State.ON_BREAK:
			if status_bubble != null:
				status_bubble.text = "☕ Relaxing..." if is_break_sofa else "☕ Fresh Coffee..."
			_play_anim("sit" if is_break_sofa else "idle")
			if is_break_sofa:
				rotation.y = 0.0
			await get_tree().create_timer(4.5).timeout
			speed_buff_timer = 40.0
			_update_speed()
			if status_bubble != null:
				status_bubble.text = "☕ Refreshed! +30% Speed"
				var tw = create_tween()
				tw.tween_interval(2.2)
				tw.tween_callback(func():
					if is_instance_valid(status_bubble) and current_state != State.ON_BREAK:
						status_bubble.visible = false
				)
			current_state = State.RETURNING
			waypoints = _get_waypoints_from_breakroom_to_home(position)
			_play_anim("walk")
