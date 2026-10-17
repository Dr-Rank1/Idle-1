extends Node3D

@export var is_prep_chef: bool = false
@export var chef_index: int = 0
@export var has_pan: bool = true

@onready var flame_light: OmniLight3D = $StoveFlameGlow
@onready var steam_particles: CPUParticles3D = $SteamParticles
@onready var pan: Node3D = $Pan
@onready var cooking_ring: MeshInstance3D = get_node_or_null("CookingTimerRing")

signal catering_plated()

const KITCHEN_PASS_POS: Vector3 = Vector3(6.5, 0.0, -3.4)

var anim_player: AnimationPlayer = null
var time_passed: float = 0.0
var catering_busy: bool = false
var catering_returning: bool = false
var catering_target: Vector3 = Vector3.ZERO
var catering_home: Vector3 = Vector3.ZERO
var catering_home_yaw: float = 0.0
var catering_walk_speed: float = 3.4

const CHEF_NAMES: Array[String] = ["Chef Pierre", "Chef Gordon", "Chef Julia", "Chef Marco", "Chef Antoine", "Chef Gaston"]

func _ready() -> void:
	anim_player = find_child("AnimationPlayer", true, false)
	
	if is_prep_chef:
		if flame_light != null: flame_light.visible = false
		if steam_particles != null: steam_particles.visible = false
		if pan != null: pan.visible = false
	else:
		if flame_light != null: flame_light.visible = true
		if steam_particles != null: steam_particles.visible = true
		if pan != null: pan.visible = has_pan
	
	if cooking_ring != null:
		if cooking_ring.material_override != null:
			cooking_ring.material_override = cooking_ring.material_override.duplicate()
		elif cooking_ring.mesh != null and cooking_ring.mesh.material != null:
			cooking_ring.material_override = cooking_ring.mesh.material.duplicate()
	
	var click_area = Area3D.new()
	click_area.name = "ClickArea"
	var shape = CollisionShape3D.new()
	var cap = CapsuleShape3D.new()
	cap.radius = 0.45
	cap.height = 1.8
	shape.shape = cap
	shape.position = Vector3(0, 0.9, 0)
	click_area.add_child(shape)
	add_child(click_area)
	click_area.input_ray_pickable = true
	click_area.input_event.connect(_on_click_area_input_event)
	
	_play_chef_animation()
	
	update_equipped_gear_visuals()
	var gm = get_node_or_null("/root/GameManager")
	if gm != null and gm.has_signal("gear_updated"):
		gm.gear_updated.connect(update_equipped_gear_visuals)

func _on_click_area_input_event(_camera: Camera3D, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var ui = get_tree().root.find_child("UIController", true, false) if get_tree() != null else null
		if ui != null and ui.has_method("show_character_inspector"):
			ui.show_character_inspector(self)

func get_inspector_info() -> Dictionary:
	var c_name = CHEF_NAMES[chef_index % CHEF_NAMES.size()]
	var role_str = "Prep Chef" if is_prep_chef else "Line Chef"
	var status = "Sizzling at Range 🍳"
	if catering_busy:
		status = "Plating Catering Order 📦"
	elif is_prep_chef:
		status = "Prepping Fresh Ingredients 🥗"

	var gm = get_node_or_null("/root/GameManager")
	var cook_mult: float = 1.0
	var staff_key: String = "chef_prep" if is_prep_chef else ("chef_sous" if chef_index == 1 else "chef_stove")
	if gm != null:
		if gm.has_method("get_staff_cooking_multiplier"):
			cook_mult = gm.get_staff_cooking_multiplier(staff_key)
		if gm.has_method("get_fever_speed_multiplier"):
			cook_mult *= gm.get_fever_speed_multiplier()
	var speed = (0.28 + (chef_index % 3) * 0.05) * cook_mult
	var offset = float(chef_index) * 0.27 + (0.15 if is_prep_chef else 0.0)
	var cycle_prog = fmod(time_passed * speed + offset, 1.0)

	return {
		"name": c_name,
		"role": role_str,
		"role_icon": "👨‍🍳",
		"role_color": Color(1.0, 0.55, 0.15),
		"status_text": status,
		"progress_ratio": cycle_prog,
		"progress_label": "Cook Cycle: %d%%" % round(cycle_prog * 100.0),
		"progress_color": Color(1.0, 0.6, 0.15),
		"can_boost": true,
		"boost_label": "Rush Sizzle 🔥"
	}

func apply_inspector_boost() -> Dictionary:
	time_passed += 2.5
	if flame_light != null:
		flame_light.light_energy = 2.4
	if steam_particles != null:
		steam_particles.restart()
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("sizzle", 0.0, 0.0)
	var gm = get_node_or_null("/root/GameManager")
	if gm != null and gm.has_method("increment_fever_combo"):
		gm.increment_fever_combo(3.0)
	return {"success": true, "message": "Cook Cycle Rushed!"}

func _play_chef_animation() -> void:
	if anim_player != null:
		if anim_player.has_animation("interact-right"):
			anim_player.play("interact-right")
		elif anim_player.has_animation("idle"):
			anim_player.play("idle")

func is_idle_for_catering() -> bool:
	return not catering_busy

func send_to_kitchen_pass(pass_pos: Vector3 = KITCHEN_PASS_POS) -> bool:
	if catering_busy:
		return false
	catering_busy = true
	catering_returning = false
	catering_home = global_position
	catering_home_yaw = rotation.y
	catering_target = pass_pos
	if flame_light != null:
		flame_light.visible = false
	if steam_particles != null:
		steam_particles.visible = false
	_play_anim_named("walk")
	return true

func _play_anim_named(anim_name: String) -> void:
	if anim_player != null and anim_player.has_animation(anim_name):
		var anim = anim_player.get_animation(anim_name)
		if anim != null and anim_name in ["idle", "walk"]:
			anim.loop_mode = Animation.LOOP_LINEAR
		anim_player.play(anim_name)
	elif anim_name == "idle":
		_play_chef_animation()

func _process(delta: float) -> void:
	time_passed += delta
	if catering_busy:
		_process_catering_walk(delta)
		return
	# Sizzling flame flicker effect for cooking chef
	if flame_light != null and not is_prep_chef:
		flame_light.light_energy = 1.1 + sin(time_passed * 14.0 + float(chef_index)) * 0.35 + randf_range(-0.1, 0.1)
		# Trigger occasional sizzle sound effect for active cooking stoves
		if chef_index == 0 and fmod(time_passed, 5.5) < delta:
			var am = get_node_or_null("/root/AudioManager")
			if am != null and am.has_method("play_sfx"):
				am.play_sfx("sizzle", 0.08, -6.0)
	
	# Animated cooking progress arc over chef's head (matching res1_38s.jpg)
	if cooking_ring != null:
		var gm = get_node_or_null("/root/GameManager")
		var cook_mult: float = 1.0
		var staff_key: String = "chef_stove"
		if is_prep_chef:
			staff_key = "chef_prep"
		elif chef_index == 1:
			staff_key = "chef_sous"
		elif chef_index == 3:
			staff_key = "chef_pastry"
		if gm != null:
			if gm.has_method("get_staff_cooking_multiplier"):
				cook_mult = gm.get_staff_cooking_multiplier(staff_key)
			if gm.get("is_manager_inspection_active") == true:
				cook_mult *= 1.25
			if gm.has_method("get_fever_speed_multiplier"):
				cook_mult *= gm.get_fever_speed_multiplier()
		var speed = (0.28 + (chef_index % 3) * 0.05) * cook_mult
		var offset = float(chef_index) * 0.27 + (0.15 if is_prep_chef else 0.0)
		var cook_progress = fmod(time_passed * speed + offset, 1.0)
		var mat = cooking_ring.material_override
		if mat is ShaderMaterial:
			mat.set_shader_parameter("progress", cook_progress)

func _process_catering_walk(delta: float) -> void:
	var dest: Vector3 = catering_home if catering_returning else catering_target
	var pos: Vector3 = global_position
	dest.y = pos.y
	var to_dest: Vector3 = dest - pos
	to_dest.y = 0.0
	var fever_mult: float = 1.0
	var gm_ref = get_node_or_null("/root/GameManager")
	if gm_ref != null and gm_ref.has_method("get_fever_speed_multiplier"):
		fever_mult = gm_ref.get_fever_speed_multiplier()
	var gear_mult: float = 1.0
	if gm_ref != null and gm_ref.has_method("get_gear_staff_walk_speed_multiplier"):
		gear_mult = gm_ref.get_gear_staff_walk_speed_multiplier()
	if to_dest.length() > 0.18:
		var step = min(catering_walk_speed * fever_mult * gear_mult * delta, to_dest.length())
		global_position = pos + to_dest.normalized() * step
		rotation.y = lerp_angle(rotation.y, atan2(to_dest.x, to_dest.z), 10.0 * delta)
		return
	global_position = dest
	if not catering_returning:
		rotation.y = PI
		_play_anim_named("interact-right")
		catering_plated.emit()
		catering_returning = true
		catering_target = catering_home
		_play_anim_named("walk")
	else:
		rotation.y = catering_home_yaw
		catering_busy = false
		catering_returning = false
		if not is_prep_chef:
			if flame_light != null:
				flame_light.visible = true
			if steam_particles != null:
				steam_particles.visible = true
		_play_chef_animation()

func update_equipped_gear_visuals() -> void:
	var gm = get_node_or_null("/root/GameManager")
	var equipped: Dictionary = gm.get_equipped_gear() if gm != null and gm.has_method("get_equipped_gear") else {"head": "toque", "body": "apron", "tool": "skillet"}
	
	# Clean existing dynamic gear nodes
	var existing_gear = get_node_or_null("GearDynamicRoot")
	if existing_gear != null:
		existing_gear.queue_free()
	
	var gear_root = Node3D.new()
	gear_root.name = "GearDynamicRoot"
	add_child(gear_root)
	
	# Head Slot
	var head_item = equipped.get("head", "toque")
	var default_hat = get_node_or_null("ChefHat")
	if head_item == "toque":
		if default_hat != null:
			default_hat.visible = true
	else:
		if default_hat != null:
			default_hat.visible = false
		if head_item == "crown":
			var crown = MeshInstance3D.new()
			crown.name = "RoyalCrown"
			var cyl = CylinderMesh.new()
			cyl.top_radius = 0.25
			cyl.bottom_radius = 0.22
			cyl.height = 0.14
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color(1.0, 0.82, 0.15)
			mat.metallic = 0.95
			mat.roughness = 0.15
			mat.emission_enabled = true
			mat.emission = Color(0.9, 0.7, 0.1)
			mat.emission_energy_multiplier = 0.4
			crown.mesh = cyl
			crown.material_override = mat
			crown.position = Vector3(0, 0.95, 0)
			gear_root.add_child(crown)
		elif head_item == "visor":
			var visor = MeshInstance3D.new()
			visor.name = "NeonVisor"
			var box = BoxMesh.new()
			box.size = Vector3(0.38, 0.08, 0.12)
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color(0.1, 0.85, 1.0)
			mat.emission_enabled = true
			mat.emission = Color(0.15, 0.9, 1.0)
			mat.emission_energy_multiplier = 1.2
			mat.roughness = 0.2
			visor.mesh = box
			visor.material_override = mat
			visor.position = Vector3(0, 0.86, 0.14)
			gear_root.add_child(visor)
			
	# Body Slot
	var body_item = equipped.get("body", "apron")
	var body_mesh = MeshInstance3D.new()
	body_mesh.name = "BodyGearOverlay"
	var b_box = BoxMesh.new()
	b_box.size = Vector3(0.46, 0.52, 0.28)
	body_mesh.mesh = b_box
	var b_mat = StandardMaterial3D.new()
	match body_item:
		"apron":
			b_mat.albedo_color = Color(0.78, 0.22, 0.22) # Butcher crimson apron
			b_mat.roughness = 0.6
		"vest":
			b_mat.albedo_color = Color(0.12, 0.14, 0.24) # Silk navy vest
			b_mat.metallic = 0.4
			b_mat.roughness = 0.35
		"jacket":
			b_mat.albedo_color = Color(0.98, 0.84, 0.25) # Michelin Gold jacket
			b_mat.metallic = 0.85
			b_mat.roughness = 0.25
			b_mat.emission_enabled = true
			b_mat.emission = Color(0.85, 0.7, 0.1)
			b_mat.emission_energy_multiplier = 0.3
	body_mesh.material_override = b_mat
	body_mesh.position = Vector3(0, 0.48, 0.02)
	gear_root.add_child(body_mesh)
	
	# Hand Tool Slot
	var tool_item = equipped.get("tool", "skillet")
	if pan != null:
		if tool_item == "skillet":
			pan.visible = (not is_prep_chef) and has_pan
		else:
			pan.visible = false
	if tool_item != "skillet" and not is_prep_chef:
		var tool_mesh = MeshInstance3D.new()
		tool_mesh.name = "HandToolOverlay"
		if tool_item == "spatula":
			var spat = BoxMesh.new()
			spat.size = Vector3(0.08, 0.02, 0.36)
			var s_mat = StandardMaterial3D.new()
			s_mat.albedo_color = Color(1.0, 0.85, 0.18)
			s_mat.metallic = 0.95
			s_mat.roughness = 0.15
			tool_mesh.mesh = spat
			tool_mesh.material_override = s_mat
		elif tool_item == "tray":
			var cyl = CylinderMesh.new()
			cyl.top_radius = 0.26
			cyl.bottom_radius = 0.26
			cyl.height = 0.03
			var t_mat = StandardMaterial3D.new()
			t_mat.albedo_color = Color(0.85, 0.9, 0.98)
			t_mat.metallic = 0.8
			t_mat.roughness = 0.2
			tool_mesh.mesh = cyl
			tool_mesh.material_override = t_mat
		tool_mesh.position = Vector3(0.12, 0.56, 0.48)
		gear_root.add_child(tool_mesh)

