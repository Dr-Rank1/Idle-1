extends Camera3D

signal cinematic_reveal_completed

@export var pan_speed: float = 0.025
@export var key_pan_speed: float = 14.0
@export var zoom_speed: float = 1.4
@export var default_ortho_size: float = 12.5
@export var min_ortho_size: float = 9.0
@export var max_ortho_size: float = 16.0
@export var min_zoom_dist: float = 9.0
@export var max_zoom_dist: float = 32.0
@export var inertia_friction: float = 5.5
@export var max_drag_velocity: float = 38.0
@export var auto_start_cinematic_reveal: bool = true

const SIGN_ENTRANCE_CAM_POS: Vector3 = Vector3(13.5, 15.0, 29.6)
const STANDARD_GAMEPLAY_CAM_POS: Vector3 = Vector3(23.2, 15.0, 19.5)
const SIGN_ENTRANCE_SIZE: float = 8.5

var is_dragging: bool = false
var is_performing_cinematic_reveal: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO
var target_position: Vector3 = STANDARD_GAMEPLAY_CAM_POS
var initialized: bool = false

# Touch and Drag Inertia / Momentum
var drag_velocity: Vector3 = Vector3.ZERO
var pan_velocity: Vector3 = Vector3.ZERO
var last_drag_time: float = 0.0

# Multi-touch pinch zoom & Tap raycasting state
var _active_touches: Dictionary = {}
var _initial_pinch_dist: float = 0.0
var _initial_pinch_size: float = 12.0
var _touch_start_pos: Vector2 = Vector2.ZERO
var _touch_start_time: float = 0.0
var _total_touch_move: float = 0.0

# Camera forward and right vectors projected onto ground XZ plane
var ground_right: Vector3 = Vector3.RIGHT
var ground_forward: Vector3 = Vector3.FORWARD

func should_skip_cinematic_reveal() -> bool:
	if DisplayServer.get_name() == "headless":
		return true
	var gm = get_node_or_null("/root/GameManager")
	if gm != null and gm.get("skip_boot_splash") == true:
		return true
	for arg in OS.get_cmdline_args():
		if "capture_game.gd" in arg or "run_all_tests.gd" in arg:
			return true
	return false

func _ready() -> void:
	projection = PROJECTION_ORTHOGONAL
	size = default_ortho_size
	position = STANDARD_GAMEPLAY_CAM_POS
	rotation_degrees = Vector3(-30.0, 45.0, 0.0)
	target_position = position
	_update_ground_vectors()
	initialized = true

	if should_skip_cinematic_reveal():
		is_performing_cinematic_reveal = false
		position = STANDARD_GAMEPLAY_CAM_POS
		target_position = STANDARD_GAMEPLAY_CAM_POS
		size = default_ortho_size
		call_deferred("emit_signal", "cinematic_reveal_completed")
		return

	# When launched inside a full game scene (parent is Main, not isolated root runner),
	# start focused on front roadside neon sign and entrance, then smoothly reveal
	if auto_start_cinematic_reveal and get_parent() != null and get_parent().name != "root":
		is_performing_cinematic_reveal = true
		position = SIGN_ENTRANCE_CAM_POS
		size = SIGN_ENTRANCE_SIZE
		call_deferred("start_cinematic_reveal", 1.4)

func start_cinematic_reveal(duration: float = 1.4) -> void:
	if should_skip_cinematic_reveal():
		is_performing_cinematic_reveal = false
		position = STANDARD_GAMEPLAY_CAM_POS
		target_position = STANDARD_GAMEPLAY_CAM_POS
		size = default_ortho_size
		emit_signal("cinematic_reveal_completed")
		return
	if pan_tween != null and pan_tween.is_valid():
		pan_tween.kill()

	is_performing_cinematic_reveal = true
	position = SIGN_ENTRANCE_CAM_POS
	target_position = STANDARD_GAMEPLAY_CAM_POS
	size = SIGN_ENTRANCE_SIZE

	pan_tween = create_tween()
	pan_tween.parallel().tween_property(self, "position", STANDARD_GAMEPLAY_CAM_POS, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	pan_tween.parallel().tween_property(self, "size", default_ortho_size, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	pan_tween.tween_callback(func():
		is_performing_cinematic_reveal = false
		target_position = STANDARD_GAMEPLAY_CAM_POS
		emit_signal("cinematic_reveal_completed")
	)

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
		pan_velocity = Vector3.ZERO
		move_input = move_input.normalized()
		var move_vec = (ground_right * move_input.x + ground_forward * move_input.y) * key_pan_speed * delta
		target_position += move_vec
		_clamp_target()
	
	# Inertia / momentum damping when releasing drag gesture
	if not is_dragging and pan_velocity.length_squared() > 0.005:
		target_position += pan_velocity * delta
		_clamp_target()
		
		# Smooth deceleration damping
		pan_velocity = pan_velocity.lerp(Vector3.ZERO, inertia_friction * delta)
		if pan_velocity.length() < 0.04:
			pan_velocity = Vector3.ZERO
	
	# Smoothly interpolate position towards target if not actively tweening
	if pan_tween == null or not pan_tween.is_valid() or not pan_tween.is_running():
		position = position.lerp(target_position, 14.0 * delta)

func _clamp_target() -> void:
	var prev_x = target_position.x
	var prev_z = target_position.z
	target_position.x = clamp(target_position.x, -8.0, 36.0)
	target_position.z = clamp(target_position.z, 0.0, 38.0)
	if target_position.x != prev_x:
		pan_velocity.x = 0.0
	if target_position.z != prev_z:
		pan_velocity.z = 0.0

var pan_tween: Tween = null

func pan_to_position(dest_pos: Vector3, duration: float = 0.35, offset_for_drawer: bool = true) -> void:
	if pan_tween != null and pan_tween.is_valid():
		pan_tween.kill()
	pan_velocity = Vector3.ZERO
	drag_velocity = Vector3.ZERO
		
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
			base_cam = STANDARD_GAMEPLAY_CAM_POS
			offset_for_drawer = false
		_:
			base_cam = STANDARD_GAMEPLAY_CAM_POS
			
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

func focus_target_node(target: Node3D, duration: float = 0.45) -> void:
	if target != null and is_instance_valid(target):
		pan_to_world_coordinate(target.global_position, duration)

func pan_to_world_coordinate(world_pos: Vector3, duration: float = 0.45) -> void:
	var cam_pos = Vector3(world_pos.x + 18.37, 15.0, world_pos.z + 18.37)
	pan_to_position(cam_pos, duration, false)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				if pan_tween != null and pan_tween.is_valid():
					pan_tween.kill()
				is_dragging = true
				last_mouse_pos = event.position
				_touch_start_pos = event.position
				_touch_start_time = Time.get_ticks_usec() / 1000000.0
				_total_touch_move = 0.0
				pan_velocity = Vector3.ZERO
				drag_velocity = Vector3.ZERO
				last_drag_time = Time.get_ticks_usec() / 1000000.0
			else:
				is_dragging = false
				var now = Time.get_ticks_usec() / 1000000.0
				if _total_touch_move < 12.0 and (now - _touch_start_time < 0.35):
					_raycast_tap(event.position)
				elif now - last_drag_time < 0.08:
					pan_velocity = drag_velocity.limit_length(max_drag_velocity)
				else:
					pan_velocity = Vector3.ZERO
				drag_velocity = Vector3.ZERO
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom(-zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(zoom_speed)

	elif event is InputEventMouseMotion and is_dragging:
		var now: float = Time.get_ticks_usec() / 1000000.0
		var dt: float = now - last_drag_time
		last_drag_time = now

		var delta_mouse: Vector2 = event.position - last_mouse_pos
		last_mouse_pos = event.position
		_total_touch_move += delta_mouse.length()

		var move_vec: Vector3 = (-ground_right * delta_mouse.x + -ground_forward * delta_mouse.y) * pan_speed
		target_position += move_vec
		_clamp_target()

		if dt > 0.0001:
			var inst_vel = move_vec / dt
			drag_velocity = drag_velocity.lerp(inst_vel, 0.55)

	elif event is InputEventScreenTouch:
		if event.pressed:
			if pan_tween != null and pan_tween.is_valid():
				pan_tween.kill()
			_active_touches[event.index] = event.position
			last_drag_time = Time.get_ticks_usec() / 1000000.0
			pan_velocity = Vector3.ZERO
			drag_velocity = Vector3.ZERO
			
			if _active_touches.size() == 1:
				is_dragging = true
				last_mouse_pos = event.position
				_touch_start_pos = event.position
				_touch_start_time = last_drag_time
				_total_touch_move = 0.0
			elif _active_touches.size() == 2:
				is_dragging = false
				var t_keys = _active_touches.keys()
				_initial_pinch_dist = _active_touches[t_keys[0]].distance_to(_active_touches[t_keys[1]])
				_initial_pinch_size = size
		else:
			var now = Time.get_ticks_usec() / 1000000.0
			if _active_touches.size() == 1 and _total_touch_move < 14.0 and (now - _touch_start_time < 0.40):
				_raycast_tap(event.position)
			elif now - last_drag_time < 0.08:
				pan_velocity = drag_velocity.limit_length(max_drag_velocity)
			else:
				pan_velocity = Vector3.ZERO
			drag_velocity = Vector3.ZERO
			
			_active_touches.erase(event.index)
			if _active_touches.is_empty():
				is_dragging = false
			elif _active_touches.size() == 1:
				var rem_key = _active_touches.keys()[0]
				last_mouse_pos = _active_touches[rem_key]
				last_drag_time = now
				is_dragging = true

	elif event is InputEventScreenDrag:
		_active_touches[event.index] = event.position
		var now: float = Time.get_ticks_usec() / 1000000.0
		var dt: float = now - last_drag_time
		last_drag_time = now
		
		if _active_touches.size() >= 2:
			# Two-finger pinch-to-zoom between size = 9.0 and size = 16.0
			var t_keys = _active_touches.keys()
			var current_dist = _active_touches[t_keys[0]].distance_to(_active_touches[t_keys[1]])
			if _initial_pinch_dist > 8.0 and current_dist > 8.0:
				var scale_factor = _initial_pinch_dist / current_dist
				size = clamp(_initial_pinch_size * scale_factor, min_ortho_size, max_ortho_size)
		elif is_dragging and _active_touches.size() == 1:
			# Single-finger drag pans camera
			var delta_touch: Vector2 = event.relative
			last_mouse_pos = event.position
			_total_touch_move += delta_touch.length()

			var move_vec: Vector3 = (-ground_right * delta_touch.x + -ground_forward * delta_touch.y) * pan_speed
			target_position += move_vec
			_clamp_target()

			if dt > 0.0001:
				var inst_vel = move_vec / dt
				drag_velocity = drag_velocity.lerp(inst_vel, 0.55)

	elif event is InputEventMagnifyGesture:
		_zoom(-(event.factor - 1.0) * 10.0)

func _zoom(amount: float) -> void:
	if projection == PROJECTION_ORTHOGONAL:
		size = clamp(size + amount * 1.2, min_ortho_size, max_ortho_size)
	else:
		var cam_dir: Vector3 = transform.basis.z.normalized()
		var new_pos = target_position + cam_dir * amount
		var dist = new_pos.length()
		if dist >= min_zoom_dist and dist <= max_zoom_dist:
			target_position = new_pos

func _raycast_tap(screen_pos: Vector2) -> void:
	var space_state = get_world_3d().direct_space_state if get_world_3d() != null else null
	if space_state == null:
		return
	var ray_origin = project_ray_origin(screen_pos)
	var ray_normal = project_ray_normal(screen_pos)
	var ray_params = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_normal * 120.0)
	ray_params.collide_with_areas = true
	ray_params.collide_with_bodies = true
	var hit = space_state.intersect_ray(ray_params)
	if hit.is_empty() or not hit.has("collider"):
		return
		
	var collider = hit["collider"]
	var curr = collider
	var target_entity = null
	while curr != null and curr != get_tree().current_scene:
		if curr.has_method("collect_booth_cash") or curr.has_method("collect_station_cash") or curr.has_method("show_station_callout") or curr.get("table_id") != null or curr.get("station_id") != null or curr.has_method("get_inspector_info") or curr.has_method("drop_supply_crate"):
			target_entity = curr
			break
		curr = curr.get_parent()
		
	if target_entity == null:
		target_entity = collider
		
	var gm = get_node_or_null("/root/GameManager")
	var root = get_tree().current_scene if get_tree() != null else null
	var hud = root.find_child("HUD", true, false) if root != null else null

	# 1. Supply Drone
	if target_entity.has_method("drop_supply_crate"):
		target_entity.drop_supply_crate()
		return
		
	# 2. Dining Table / Booth
	if target_entity.get("table_id") != null:
		if target_entity.has_method("has_visible_cash_stack") and target_entity.has_visible_cash_stack():
			target_entity.collect_booth_cash()
			return
		if target_entity.get("is_unlocked") == false and gm != null:
			var success = gm.unlock_table(target_entity.table_id)
			if not success:
				if target_entity.has_method("_spawn_floating_text"):
					target_entity._spawn_floating_text("Need $%d to Unlock!" % round(target_entity.current_unlock_cost), Color(1.0, 0.4, 0.4))
			return
		if target_entity.get("is_dirty") == true and target_entity.has_method("clean_table"):
			target_entity.clean_table()
			return
		var tid = target_entity.table_id
		var tname = target_entity.get("table_name") if target_entity.get("table_name") != null else "Booth " + tid.capitalize()
		var lvl = gm.get_station_level(tid) if gm != null else 1
		if hud != null and hud.has_method("show_station_callout"):
			hud.show_station_callout(target_entity, tid, tname, lvl)
		elif hud != null and hud.has_method("open_upgrade"):
			hud.open_upgrade(tid, tname, lvl)
		return

	# 3. Cooking Station / Stove
	if target_entity.get("station_id") != null or target_entity.name.begins_with("CookingStation") or target_entity.name.begins_with("Stove"):
		var sid = target_entity.get("station_id") if target_entity.get("station_id") != null else "stove"
		var sname = target_entity.get("station_name") if target_entity.get("station_name") != null else "Master Range Stoves"
		if target_entity.has_method("has_visible_cash_stack") and target_entity.has_visible_cash_stack():
			target_entity.collect_station_cash()
			return
		var slvl = gm.get_station_level(sid) if gm != null else 1
		if hud != null and hud.has_method("show_station_callout"):
			hud.show_station_callout(target_entity, sid, sname, slvl)
		elif hud != null and hud.has_method("open_upgrade"):
			hud.open_upgrade(sid, sname, slvl)
		return

	# 4. Character Inspector (Customer / Chef / Waiter)
	if target_entity.has_method("get_inspector_info") and hud != null and hud.has_method("show_character_inspector"):
		hud.show_character_inspector(target_entity)
		return
