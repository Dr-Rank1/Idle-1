class_name SupplyDrone
extends Node3D

signal crate_dropped(impact_pos: Vector3, reward_type: String, reward_value: Variant)
signal drone_departed()

const FLIGHT_Y: float = 6.5
const START_POS: Vector3 = Vector3(-18.0, 6.5, -16.0)
const END_POS: Vector3 = Vector3(22.0, 6.5, 20.0)
const LAWN_Z_MIN: float = 10.5
const LAWN_Z_MAX: float = 13.5
const LAWN_X_MIN: float = -4.0
const LAWN_X_MAX: float = 11.0

var move_speed: float = 2.6
var flight_dir: Vector3 = Vector3.ZERO
var has_dropped_crate: bool = false
var is_departing: bool = false
var time_alive: float = 0.0

var propellers: Array[Node3D] = []
var crate_node: Node3D = null
var shadow_mesh: MeshInstance3D = null
var click_area: Area3D = null

func _ready() -> void:
	name = "SupplyDrone"
	global_position = START_POS
	flight_dir = (END_POS - START_POS).normalized()
	rotation.y = atan2(flight_dir.x, flight_dir.z)
	rotation.x = 0.10
	
	_build_3d_quadcopter_mesh()
	_build_golden_crate_mesh()
	_build_ground_shadow()
	_setup_click_detection()

func _build_3d_quadcopter_mesh() -> void:
	var body_root = Node3D.new()
	body_root.name = "BodyRoot"
	add_child(body_root)
	
	# 1. Central fuselage (Titanium Carbon Sleek Drone Body)
	var fuselage = MeshInstance3D.new()
	var f_box = BoxMesh.new()
	f_box.size = Vector3(0.55, 0.14, 0.55)
	var f_mat = StandardMaterial3D.new()
	f_mat.albedo_color = Color(0.12, 0.16, 0.24)
	f_mat.metallic = 0.90
	f_mat.roughness = 0.25
	fuselage.mesh = f_box
	fuselage.material_override = f_mat
	body_root.add_child(fuselage)
	
	# Top Dome / Sensor Cockpit
	var dome = MeshInstance3D.new()
	var d_cyl = CylinderMesh.new()
	d_cyl.top_radius = 0.12
	d_cyl.bottom_radius = 0.18
	d_cyl.height = 0.09
	var d_mat = StandardMaterial3D.new()
	d_mat.albedo_color = Color(0.1, 0.85, 1.0)
	d_mat.emission_enabled = true
	d_mat.emission = Color(0.2, 0.9, 1.0)
	d_mat.emission_energy_multiplier = 1.4
	dome.mesh = d_cyl
	dome.material_override = d_mat
	dome.position = Vector3(0, 0.09, 0)
	body_root.add_child(dome)
	
	# 2. 4 Quadcopter Carbon Strut Arms & Rotor Pods
	var corner_offsets = [
		Vector3(0.42, 0.0, 0.42),
		Vector3(-0.42, 0.0, 0.42),
		Vector3(-0.42, 0.0, -0.42),
		Vector3(0.42, 0.0, -0.42)
	]
	
	var arm_mat = StandardMaterial3D.new()
	arm_mat.albedo_color = Color(0.08, 0.10, 0.15)
	arm_mat.metallic = 0.8
	arm_mat.roughness = 0.3
	
	var prop_mat = StandardMaterial3D.new()
	prop_mat.albedo_color = Color(0.85, 0.9, 0.98, 0.65)
	prop_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	prop_mat.metallic = 0.3
	prop_mat.roughness = 0.1
	
	for i in range(corner_offsets.size()):
		var c_pos = corner_offsets[i]
		
		# Strut arm connecting center to corner
		var arm = MeshInstance3D.new()
		var a_box = BoxMesh.new()
		a_box.size = Vector3(0.06, 0.04, c_pos.length())
		arm.mesh = a_box
		arm.material_override = arm_mat
		arm.position = c_pos * 0.5
		arm.look_at(c_pos, Vector3.UP)
		body_root.add_child(arm)
		
		# Motor pod cylinder
		var pod = MeshInstance3D.new()
		var p_cyl = CylinderMesh.new()
		p_cyl.top_radius = 0.07
		p_cyl.bottom_radius = 0.07
		p_cyl.height = 0.10
		pod.mesh = p_cyl
		pod.material_override = arm_mat
		pod.position = c_pos
		body_root.add_child(pod)
		
		# Propeller rotor blades
		var prop_hub = Node3D.new()
		prop_hub.position = c_pos + Vector3(0, 0.06, 0)
		body_root.add_child(prop_hub)
		
		var blade1 = MeshInstance3D.new()
		var b_box = BoxMesh.new()
		b_box.size = Vector3(0.36, 0.015, 0.045)
		blade1.mesh = b_box
		blade1.material_override = prop_mat
		prop_hub.add_child(blade1)
		
		var blade2 = MeshInstance3D.new()
		blade2.mesh = b_box
		blade2.material_override = prop_mat
		blade2.rotation.y = PI * 0.5
		prop_hub.add_child(blade2)
		
		propellers.append(prop_hub)
		
		# LED Navigation Lights (front green, rear red)
		var led = MeshInstance3D.new()
		var s_sph = SphereMesh.new()
		s_sph.radius = 0.035
		s_sph.height = 0.07
		var led_mat = StandardMaterial3D.new()
		var is_front = (c_pos.z > 0.0)
		var led_col = Color(0.1, 1.0, 0.45) if is_front else Color(1.0, 0.22, 0.12)
		led_mat.albedo_color = led_col
		led_mat.emission_enabled = true
		led_mat.emission = led_col
		led_mat.emission_energy_multiplier = 2.2
		led.mesh = s_sph
		led.material_override = led_mat
		led.position = c_pos + Vector3(0, -0.06, 0)
		body_root.add_child(led)

func _build_golden_crate_mesh() -> void:
	crate_node = Node3D.new()
	crate_node.name = "GoldenSupplyCrate"
	crate_node.position = Vector3(0, -0.42, 0)
	add_child(crate_node)
	
	# Golden Crate Box
	var crate_mesh = MeshInstance3D.new()
	var c_box = BoxMesh.new()
	c_box.size = Vector3(0.48, 0.48, 0.48)
	var c_mat = StandardMaterial3D.new()
	c_mat.albedo_color = Color(1.0, 0.85, 0.15)
	c_mat.metallic = 0.95
	c_mat.roughness = 0.16
	c_mat.emission_enabled = true
	c_mat.emission = Color(0.9, 0.72, 0.1)
	c_mat.emission_energy_multiplier = 0.45
	crate_mesh.mesh = c_box
	crate_mesh.material_override = c_mat
	crate_node.add_child(crate_mesh)
	
	# Metal Corner Reinforcements & Straps
	var strap_h = MeshInstance3D.new()
	var sh_box = BoxMesh.new()
	sh_box.size = Vector3(0.50, 0.12, 0.50)
	var s_mat = StandardMaterial3D.new()
	s_mat.albedo_color = Color(0.28, 0.22, 0.08)
	s_mat.metallic = 0.9
	s_mat.roughness = 0.3
	strap_h.mesh = sh_box
	strap_h.material_override = s_mat
	crate_node.add_child(strap_h)
	
	var strap_v = MeshInstance3D.new()
	var sv_box = BoxMesh.new()
	sv_box.size = Vector3(0.12, 0.50, 0.50)
	strap_v.mesh = sv_box
	strap_v.material_override = s_mat
	crate_node.add_child(strap_v)
	
	# Parachute / rigging cables
	var cable_mat = StandardMaterial3D.new()
	cable_mat.albedo_color = Color(0.85, 0.85, 0.9)
	cable_mat.metallic = 0.7
	var cable_corners = [
		Vector3(0.25, 0.24, 0.25),
		Vector3(-0.25, 0.24, 0.25),
		Vector3(-0.25, 0.24, -0.25),
		Vector3(0.25, 0.24, -0.25)
	]
	for c_pt in cable_corners:
		var cable = MeshInstance3D.new()
		var c_cyl = CylinderMesh.new()
		c_cyl.top_radius = 0.008
		c_cyl.bottom_radius = 0.008
		c_cyl.height = 0.26
		cable.mesh = c_cyl
		cable.material_override = cable_mat
		cable.position = c_pt * 0.5 + Vector3(0, 0.14, 0)
		crate_node.add_child(cable)

func _build_ground_shadow() -> void:
	shadow_mesh = MeshInstance3D.new()
	shadow_mesh.name = "DroneGroundShadow"
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.58
	cyl.bottom_radius = 0.58
	cyl.height = 0.01
	var s_mat = StandardMaterial3D.new()
	s_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	s_mat.albedo_color = Color(0.0, 0.0, 0.0, 0.42)
	s_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shadow_mesh.mesh = cyl
	shadow_mesh.material_override = s_mat
	shadow_mesh.top_level = true
	shadow_mesh.global_position = Vector3(global_position.x, 0.04, global_position.z)
	add_child(shadow_mesh)

func _setup_click_detection() -> void:
	click_area = Area3D.new()
	click_area.name = "DroneClickArea"
	click_area.input_ray_pickable = true
	
	var shape = CollisionShape3D.new()
	var sph = SphereShape3D.new()
	sph.radius = 1.3
	shape.shape = sph
	shape.position = Vector3(0, -0.2, 0)
	click_area.add_child(shape)
	add_child(click_area)
	
	click_area.input_event.connect(_on_click_area_input_event)

func _on_click_area_input_event(_camera: Camera3D, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) \
		or (event is InputEventScreenTouch and event.pressed) \
		or (event is InputEventScreenDrag) \
		or (event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0):
		drop_crate()

func _process(delta: float) -> void:
	time_alive += delta
	
	# Spin all propeller rotor hubs
	for prop in propellers:
		if is_instance_valid(prop):
			prop.rotation.y += delta * 45.0
			
	# Move drone along diagonal trajectory
	var step = move_speed * delta
	global_position += flight_dir * step
	
	# Gentle hover bobbing
	if not is_departing:
		global_position.y = FLIGHT_Y + sin(time_alive * 3.5) * 0.12
		
	# Update shadow disk directly under drone at ground level
	if shadow_mesh != null and is_instance_valid(shadow_mesh):
		shadow_mesh.global_position = Vector3(global_position.x, 0.04, global_position.z)
		
	# Despawn if reached end coordinates and finished flight
	if global_position.distance_to(END_POS) < 2.0 or (global_position.x > 30.0 or global_position.z > 30.0):
		if shadow_mesh != null and is_instance_valid(shadow_mesh):
			shadow_mesh.queue_free()
		drone_departed.emit()
		queue_free()

func drop_crate() -> void:
	if has_dropped_crate:
		return
	has_dropped_crate = true
	
	var crate = crate_node
	if crate == null or not is_instance_valid(crate):
		return
		
	var start_world_pos = crate.global_position
	crate_node = null
	crate.get_parent().remove_child(crate)
	
	var parent_scene = get_parent() if get_parent() != null else self
	parent_scene.add_child(crate)
	crate.global_position = start_world_pos
	
	# Drone accelerates and departs high into the sky
	is_departing = true
	move_speed = 9.0
	var drone_tw = create_tween()
	if drone_tw != null:
		drone_tw.tween_property(self, "rotation:x", -0.32, 0.35)
		drone_tw.parallel().tween_property(self, "global_position:y", 12.0, 1.8)
		
	# Target impact position on front lawn (Z in [10.5, 13.5])
	var target_x = clampf(start_world_pos.x, LAWN_X_MIN, LAWN_X_MAX)
	var target_z = clampf(start_world_pos.z, LAWN_Z_MIN, LAWN_Z_MAX)
	var impact_pos = Vector3(target_x, 0.0, target_z)
	
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("tap", 0.05, 1.4)
		
	# Fall trajectory with gravity acceleration
	var fall_duration: float = 0.68
	var fall_tw = crate.create_tween()
	if fall_tw != null:
		fall_tw.parallel().tween_property(crate, "global_position:x", impact_pos.x, fall_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		fall_tw.parallel().tween_property(crate, "global_position:z", impact_pos.z, fall_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		fall_tw.parallel().tween_property(crate, "global_position:y", 0.0, fall_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		fall_tw.parallel().tween_property(crate, "rotation:y", crate.rotation.y + 2.5, fall_duration)
		fall_tw.parallel().tween_property(crate, "rotation:z", 0.35, fall_duration)
		fall_tw.tween_callback(func():
			_on_crate_impact(crate, impact_pos)
		)

func _on_crate_impact(crate: Node3D, impact_pos: Vector3) -> void:
	var parent_scene = get_parent() if get_parent() != null else self
	
	# 1. Gold Spark Particle Burst
	var particles = CPUParticles3D.new()
	particles.position = impact_pos + Vector3(0, 0.25, 0)
	particles.amount = 26
	particles.lifetime = 0.9
	particles.explosiveness = 0.95
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 0.25
	particles.gravity = Vector3(0, -6.0, 0)
	particles.initial_velocity_min = 2.8
	particles.initial_velocity_max = 5.2
	particles.color = Color(1.0, 0.88, 0.2, 1.0)
	particles.scale_amount_min = 0.06
	particles.scale_amount_max = 0.14
	var p_mesh = BoxMesh.new()
	p_mesh.size = Vector3(0.08, 0.08, 0.08)
	particles.mesh = p_mesh
	parent_scene.add_child(particles)
	particles.restart()
	
	# 2. Expanding Gold Shockwave Ring
	var ring = MeshInstance3D.new()
	var r_cyl = CylinderMesh.new()
	r_cyl.top_radius = 0.2
	r_cyl.bottom_radius = 0.2
	r_cyl.height = 0.02
	var r_mat = StandardMaterial3D.new()
	r_mat.albedo_color = Color(1.0, 0.88, 0.25, 0.85)
	r_mat.emission_enabled = true
	r_mat.emission = Color(1.0, 0.85, 0.2)
	r_mat.emission_energy_multiplier = 1.6
	ring.mesh = r_cyl
	ring.material_override = r_mat
	ring.position = impact_pos + Vector3(0, 0.03, 0)
	parent_scene.add_child(ring)
	
	var r_tw = ring.create_tween()
	if r_tw != null:
		r_tw.parallel().tween_property(ring, "scale", Vector3(4.8, 1.0, 4.8), 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		r_tw.parallel().tween_property(ring, "material_override:albedo_color:a", 0.0, 0.45)
		r_tw.tween_callback(ring.queue_free)
		
	# 3. Determine and Award 1 of 3 Rewards
	# roll: 0..0.38 => 20x CashPerSecond; 0.38..0.72 => +5 Diamonds; 0.72..1.0 => 30s 2x Kitchen Speed
	var roll = randf()
	var reward_type = ""
	var reward_val: Variant = null
	var gm = get_node_or_null("/root/GameManager")
	var am = get_node_or_null("/root/AudioManager")
	
	if roll < 0.38:
		reward_type = "cash"
		var cps = gm.get_total_income_per_second() if (gm != null and gm.has_method("get_total_income_per_second")) else 20.0
		var cash_reward = max(150.0, cps * 20.0)
		reward_val = cash_reward
		if gm != null:
			gm.add_cash(cash_reward, impact_pos + Vector3(0, 1.5, 0))
		_spawn_floating_text(impact_pos, "📦 AIRDROP: +$%s!" % (gm.format_money(cash_reward) if gm != null else str(round(cash_reward))), Color(1.0, 0.85, 0.2))
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("cash_register", 0.05, 1.1)
	elif roll < 0.72:
		reward_type = "diamonds"
		reward_val = 5
		if gm != null and gm.has_method("add_diamonds"):
			gm.add_diamonds(5)
		_spawn_floating_text(impact_pos, "💎 AIRDROP: +5 DIAMONDS!", Color(0.3, 0.9, 1.0))
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade", 0.0, 2.5)
	else:
		reward_type = "kitchen_speed"
		reward_val = 30.0
		if gm != null and gm.has_method("activate_drone_kitchen_buff"):
			gm.activate_drone_kitchen_buff(30.0, 2.0)
		elif gm != null and gm.has_method("apply_overdrive_boost"):
			gm.apply_overdrive_boost(2.0, 30.0)
		_spawn_floating_text(impact_pos, "⚡ AIRDROP: 2x KITCHEN SPEED (30s)!", Color(1.0, 0.7, 0.15))
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade", 0.0, 3.0)
			
	if gm != null and gm.has_method("increment_fever_combo"):
		gm.increment_fever_combo(8.0)
		
	crate_dropped.emit(impact_pos, reward_type, reward_val)
	
	# Squeeze and free crate
	var c_tw = crate.create_tween()
	if c_tw != null:
		c_tw.tween_property(crate, "scale", Vector3.ZERO, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		c_tw.tween_callback(func():
			if is_instance_valid(crate):
				crate.queue_free()
			var t_free = get_tree().create_timer(1.2)
			t_free.timeout.connect(func():
				if is_instance_valid(particles):
					particles.queue_free()
			)
		)

func _spawn_floating_text(pos: Vector3, text: String, col: Color) -> void:
	var label = Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.double_sided = false
	label.font_size = 28
	label.outline_size = 8
	label.text = text
	label.modulate = col
	label.outline_modulate = Color(0.15, 0.08, 0.0, 0.95)
	label.position = pos + Vector3(0, 1.2, 0)
	
	var parent_scene = get_parent() if get_parent() != null else self
	parent_scene.add_child(label)
	
	var tw = label.create_tween()
	if tw != null:
		tw.tween_property(label, "position:y", pos.y + 2.8, 1.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(label, "scale", Vector3(1.2, 1.2, 1.2), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.4)
		tw.tween_callback(label.queue_free)
