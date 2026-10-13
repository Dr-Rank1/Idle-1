extends Camera3D

@export var pan_speed: float = 0.025
@export var key_pan_speed: float = 12.0
@export var zoom_speed: float = 1.5
@export var min_zoom_dist: float = 8.0
@export var max_zoom_dist: float = 28.0

var is_dragging: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO
var target_position: Vector3 = Vector3.ZERO
var initialized: bool = false

# Camera forward and right vectors projected onto ground XZ plane
var ground_right: Vector3 = Vector3.RIGHT
var ground_forward: Vector3 = Vector3.FORWARD

func _ready() -> void:
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
		move_input = move_input.normalized()
		var move_vec = (ground_right * move_input.x + ground_forward * move_input.y) * key_pan_speed * delta
		target_position += move_vec
		_clamp_target()
	
	# Smoothly interpolate position towards target
	position = position.lerp(target_position, 14.0 * delta)

func _clamp_target() -> void:
	target_position.x = clamp(target_position.x, -2.0, 18.0)
	target_position.z = clamp(target_position.z, 2.0, 22.0)

func _unhandled_input(event: InputEvent) -> void:
	# Mouse button pan (Left drag, Middle drag, or Right drag)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
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
	var cam_dir: Vector3 = transform.basis.z.normalized()
	var new_pos = target_position + cam_dir * amount
	# Check distance to restaurant center (0, 0, 0)
	var dist = new_pos.length()
	if dist >= min_zoom_dist and dist <= max_zoom_dist:
		target_position = new_pos
