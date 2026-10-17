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
	
	_play_chef_animation()

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
	if to_dest.length() > 0.18:
		var step = min(catering_walk_speed * fever_mult * delta, to_dest.length())
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
