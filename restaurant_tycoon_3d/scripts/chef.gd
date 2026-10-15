extends Node3D

@export var is_prep_chef: bool = false
@export var chef_index: int = 0
@export var has_pan: bool = true

@onready var flame_light: OmniLight3D = $StoveFlameGlow
@onready var steam_particles: CPUParticles3D = $SteamParticles
@onready var pan: Node3D = $Pan
@onready var cooking_ring: MeshInstance3D = get_node_or_null("CookingTimerRing")

var anim_player: AnimationPlayer = null
var time_passed: float = 0.0

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

func _process(delta: float) -> void:
	time_passed += delta
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
		var speed = (0.28 + (chef_index % 3) * 0.05) * cook_mult
		var offset = float(chef_index) * 0.27 + (0.15 if is_prep_chef else 0.0)
		var cook_progress = fmod(time_passed * speed + offset, 1.0)
		var mat = cooking_ring.material_override
		if mat is ShaderMaterial:
			mat.set_shader_parameter("progress", cook_progress)
