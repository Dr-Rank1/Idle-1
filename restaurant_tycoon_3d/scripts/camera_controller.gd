extends Camera3D

@export var pan_speed: float = 0.025
@export var key_pan_speed: float = 14.0
@export var zoom_speed: float = 1.6
@export var min_zoom_dist: float = 9.0
@export var max_zoom_dist: float = 32.0

var is_dragging: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO
var target_position: Vector3 = Vector3(14.2, 15.0, 16.8)
var initialized: bool = false

# Camera forward and right vectors projected onto ground XZ plane
var ground_right: Vector3 = Vector3.RIGHT
var ground_forward: Vector3 = Vector3.FORWARD

func _ready() -> void:
	projection = PROJECTION_ORTHOGONAL
	size = 18.0
	position = Vector3(14.2, 15.0, 16.8)
	rotation_degrees = Vector3(-30.0, 45.0, 0.0)
	target_position = position
	_update_ground_vectors()
	initialized = true

func _update_ground_vectors() -> void:
	var r = transform.basis.x
	r.y = 0.0
	ground_right = r.normalized()
	
	var f = -transform.basis.z
	f.y = 0.0
	ground_forward = f.normalized()

func _process(delta: float) -> void:
	if not initialized:
		return
	
	# WASD / Arrow Key Smooth Panning
	var move_input = Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		move_input.y += 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		move_input.y -= 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		move_input.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		move_input.x += 1.0
	
	if move_input != Vector2.ZERO:
		if pan_tween != null and pan_tween.is_valid():
			pan_tween.kill()
		move_input = move_input.normalized()
		var move_vec = (ground_right * move_input.x + ground_forward * move_input.y) * key_pan_speed * delta
		target_position += move_vec
		_clamp_target()
	
	# Smoothly interpolate position towards target if not actively tweening
	if pan_tween == null or not pan_tween.is_valid() or not pan_tween.is_running():
		position = position.lerp(target_position, 12.0 * delta)

func _clamp_target() -> void:
	target_position.x = clamp(target_position.x, -8.0, 36.0)
	target_position.z = clamp(target_position.z, 0.0, 38.0)

var pan_tween: Tween = null

func pan_to_position(dest_pos: Vector3, duration: float = 0.35, offset_for_drawer: bool = true) -> void:
	if pan_tween != null and pan_tween.is_valid():
		pan_tween.kill()
		
	var dest = dest_pos
	if offset_for_drawer:
		# Elevates the camera so station centers in the visible space above bottom drawer
		dest += Vector3(2.4, 0.0, 2.4)
		
	dest.x = clamp(dest.x, -8.0, 36.0)
	dest.z = clamp(dest.z, 0.0, 38.0)
	target_position = dest
	
	pan_tween = create_tween()
	pan_tween.tween_property(self, "position", dest, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func focus_zone(zone: String, offset_for_drawer: bool = true) -> void:
	var base_cam = target_position
	match zone.to_lower():
		"parking":
			# Centered on Parking Lot (-5.0, 0, 17.5)
			base_cam = Vector3(13.5, 15.0, 35.5)
		"dining":
			# Centered on Dining Hall (5.0, 0, 4.0)
			base_cam = Vector3(23.4, 15.0, 22.4)
		"kitchen":
			# Centered on Cooking Station (6.5, 0, -9.6)
			base_cam = Vector3(24.9, 15.0, 8.8)
		"milkshake", "milkshake bar":
			# Centered on 50s Milkshake & Soda Diner (-7.5, 0, -7.0)
			base_cam = Vector3(10.9, 15.0, 11.4)
		"terrace":
			# Centered on Garden Terrace (13.25, 0, 4.0)
			base_cam = Vector3(31.6, 15.0, 22.4)
		"lounge", "cocktail lounge":
			# Centered on Cocktail Lounge (-7.5, 0, 3.5)
			base_cam = Vector3(10.9, 15.0, 21.9)
		"reception", "lobby":
			base_cam = Vector3(16.5, 15.0, 25.0)
		"overview":
			base_cam = Vector3(14.2, 15.0, 16.8)
			offset_for_drawer = false
		_:
			base_cam = Vector3(14.2, 15.0, 16.8)
			
	pan_to_position(base_cam, 0.35, offset_for_drawer)

func focus_station(station_id: String) -> void:
	var station_node: Node3D = null
	var root_node = get_tree().current_scene if get_tree() != null else null
	if root_node != null:
		if station_id.begins_with("table_"):
			var t_num = station_id.trim_prefix("table_")
			station_node = root_node.find_child("Table" + t_num, true, false)
			if station_node == null:
				station_node = root_node.find_child("Table_" + t_num, true, false)
		elif station_id == "stove" or station_id == "kitchen_cook":
			station_node = root_node.find_child("CookingStation", true, false)
		elif station_id.begins_with("milkshake"):
			station_node = root_node.find_child("MilkshakeCounter", true, false)
			if station_node == null:
				station_node = root_node.find_child("MilkshakeBar", true, false)
	
	if station_node != null and is_instance_valid(station_node):
		var wp = station_node.global_position
		var cam_pos = Vector3(wp.x + 18.37, 15.0, wp.z + 18.37)
		pan_to_position(cam_pos, 0.35, true)
		return
		
	# Fallback by zone
	if station_id.begins_with("milkshake"):
		focus_zone("milkshake", true)
	elif station_id == "stove" or station_id == "kitchen_cook":
		focus_zone("kitchen", true)
	elif station_id.begins_with("parking"):
		focus_zone("parking", true)
	elif station_id.begins_with("lounge"):
		focus_zone("lounge", true)
	elif station_id in ["table_10", "table_11", "table_12"]:
		focus_zone("terrace", true)
	else:
		focus_zone("dining", true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				if pan_tween != null and pan_tween.is_valid():
					pan_tween.kill()
				is_dragging = true
				last_mouse_pos = event.position
			else:
				is_dragging = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom(-zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(zoom_speed)

	elif event is InputEventMouseMotion and is_dragging:
		var delta_mouse: Vector2 = event.position - last_mouse_pos
		last_mouse_pos = event.position

		var move_vec: Vector3 = (-ground_right * delta_mouse.x + -ground_forward * delta_mouse.y) * pan_speed
		target_position += move_vec
		_clamp_target()

	elif event is InputEventScreenTouch:
		if event.pressed:
			if pan_tween != null and pan_tween.is_valid():
				pan_tween.kill()
			is_dragging = true
			last_mouse_pos = event.position
		else:
			is_dragging = false

	elif event is InputEventScreenDrag and is_dragging:
		var delta_touch: Vector2 = event.relative
		var move_vec: Vector3 = (-ground_right * delta_touch.x + -ground_forward * delta_touch.y) * pan_speed
		target_position += move_vec
		_clamp_target()

func _zoom(amount: float) -> void:
	if projection == PROJECTION_ORTHOGONAL:
		size = clamp(size + amount * 1.5, 14.0, 36.0)
	else:
		var cam_dir: Vector3 = transform.basis.z.normalized()
		var new_pos = target_position + cam_dir * amount
		var dist = new_pos.length()
		if dist >= min_zoom_dist and dist <= max_zoom_dist:
			target_position = new_pos
