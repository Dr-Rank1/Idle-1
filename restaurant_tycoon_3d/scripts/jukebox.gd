extends Node3D

@onready var glow_light: OmniLight3D = get_node_or_null("JukeboxGlow")
var time_passed: float = 0.0
var music_note_node: Label3D = null

func _ready() -> void:
	# Load high-resolution 1950s Wurlitzer facade texture
	var juke_path = ProjectSettings.globalize_path("res://assets/textures/jukebox_facade.png")
	var juke_img = Image.load_from_file(juke_path)
	if juke_img != null:
		var tex = ImageTexture.create_from_image(juke_img)
		var facade_mesh = MeshInstance3D.new()
		facade_mesh.name = "WurlitzerFacade"
		var quad = QuadMesh.new()
		quad.size = Vector2(0.92, 1.38)
		facade_mesh.mesh = quad
		
		var mat = StandardMaterial3D.new()
		mat.albedo_texture = tex
		mat.emission_enabled = true
		mat.emission_texture = tex
		mat.emission_energy_multiplier = 1.8
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		facade_mesh.material_override = mat
		
		facade_mesh.position = Vector3(0, 0.72, 0.27)
		add_child(facade_mesh)

	# Floating animated music notes
	music_note_node = Label3D.new()
	music_note_node.name = "MusicNotes"
	music_note_node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	music_note_node.double_sided = false
	music_note_node.text = "🎵  🎶"
	music_note_node.font_size = 28
	music_note_node.modulate = Color(1.0, 0.85, 0.2, 1.0)
	music_note_node.outline_modulate = Color(0.2, 0.05, 0.25, 0.9)
	music_note_node.outline_size = 6
	music_note_node.position = Vector3(0, 1.7, 0)
	add_child(music_note_node)

func _process(delta: float) -> void:
	time_passed += delta
	if music_note_node != null:
		var float_y = 1.68 + sin(time_passed * 3.5) * 0.08
		var sway_x = sin(time_passed * 2.2) * 0.06
		music_note_node.position = Vector3(sway_x, float_y, 0)
	if glow_light != null:
		# Vibrant rainbow neon color pulse
		var hue = fmod(time_passed * 0.25, 1.0)
		glow_light.light_color = Color.from_hsv(hue, 0.85, 1.0)
		glow_light.light_energy = 0.9 + sin(time_passed * 5.0) * 0.25
