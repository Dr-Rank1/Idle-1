@tool
extends SceneTree

func _init():
	var p = CPUParticles3D.new()
	p.emitting = false
	p.one_shot = true
	p.explosiveness = 0.95
	p.amount = 18
	p.lifetime = 0.75
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 0.25
	p.direction = Vector3.UP
	p.spread = 45.0
	p.initial_velocity_min = 1.8
	p.initial_velocity_max = 3.2
	p.gravity = Vector3(0, -4.5, 0)
	
	var bm = BoxMesh.new()
	bm.size = Vector3(0.06, 0.06, 0.06)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.85, 0.2, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.85, 0.2, 1.0)
	bm.material = mat
	p.mesh = bm
	
	print("CPUParticles3D created successfully without errors!")
	quit(0)
