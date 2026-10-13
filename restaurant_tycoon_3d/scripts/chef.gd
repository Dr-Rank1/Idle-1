extends Node3D

@export var is_prep_chef: bool = false

@onready var flame_light: OmniLight3D = $StoveFlameGlow
@onready var steam_particles: CPUParticles3D = $SteamParticles
@onready var pan: Node3D = $Pan

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
		if pan != null: pan.visible = true
	
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
		flame_light.light_energy = 1.1 + sin(time_passed * 14.0) * 0.35 + randf_range(-0.1, 0.1)
