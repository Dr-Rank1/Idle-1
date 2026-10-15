extends StaticBody3D

signal station_clicked(station_id: String, station_name: String, level: int)

@export var station_id: String = "stove"
@export var station_name: String = "Master Chef Range"

@onready var badge_root: Node3D = $BadgeRoot
@onready var level_label: Label3D = $BadgeRoot/LevelLabel
@onready var action_badge: Label3D = get_node_or_null("BadgeRoot/ActionBadge")
@onready var upgrade_particles: CPUParticles3D = get_node_or_null("UpgradeParticles")

var time_passed: float = 0.0
var initial_badge_y: float = 2.4

var highlight_ring: MeshInstance3D = null
var is_highlighted: bool = false
var highlight_time: float = 0.0

func _ready() -> void:
	if badge_root != null:
		initial_badge_y = badge_root.position.y
		if action_badge == null:
			action_badge = Label3D.new()
			action_badge.name = "ActionBadge"
			action_badge.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			action_badge.double_sided = false
			action_badge.font_size = 28
			action_badge.outline_size = 8
			action_badge.position = Vector3(0, 0.45, 0)
			badge_root.add_child(action_badge)
			
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.station_upgraded.connect(_on_station_upgraded)
		gm.cash_changed.connect(_on_cash_changed)
		update_level_display(gm.get_station_level(station_id))

func _process(delta: float) -> void:
	time_passed += delta
	if badge_root != null:
		badge_root.position.y = initial_badge_y + sin(time_passed * 3.8 + 1.0) * 0.08
		if action_badge != null and action_badge.visible:
			var pulse = 1.0 + sin(time_passed * 6.0) * 0.12
			action_badge.scale = Vector3(pulse, pulse, pulse)

	# Subtle pulsing golden floor rim highlight for cooking station
	if is_highlighted and highlight_ring != null and highlight_ring.visible:
		highlight_time += delta
		var pulse_scale = 1.0 + sin(highlight_time * 4.5) * 0.05
		highlight_ring.scale = Vector3(2.0 * pulse_scale, 0.5, 0.75 * pulse_scale)
		if highlight_ring.material_override is StandardMaterial3D:
			var alpha = 0.65 + sin(highlight_time * 4.5) * 0.25
			highlight_ring.material_override.albedo_color = Color(1.0, 0.84, 0.2, alpha)

func set_highlight(active: bool) -> void:
	is_highlighted = active
	if is_highlighted:
		if highlight_ring == null:
			_create_highlight_ring()
		if highlight_ring != null:
			highlight_ring.visible = true
			highlight_time = 0.0
	else:
		if highlight_ring != null:
			highlight_ring.visible = false

func _create_highlight_ring() -> void:
	highlight_ring = MeshInstance3D.new()
	highlight_ring.name = "FloorHighlightRing"
	
	var torus = TorusMesh.new()
	torus.inner_radius = 1.7
	torus.outer_radius = 1.95
	torus.rings = 36
	torus.ring_segments = 16
	highlight_ring.mesh = torus
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(1.0, 0.85, 0.2, 0.8)
	highlight_ring.material_override = mat
	
	highlight_ring.position = Vector3(0.0, 0.04, 0.0)
	highlight_ring.scale = Vector3(2.0, 0.5, 0.75)
	add_child(highlight_ring)

func _on_cash_changed(_val: float) -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		update_level_display(gm.get_station_level(station_id))

func update_level_display(lvl: int) -> void:
	var gm = get_node_or_null("/root/GameManager")
	var can_upgrade: bool = false
	var upgrade_cost: float = 140.0
	if gm != null:
		upgrade_cost = gm.get_upgrade_cost(station_id)
		can_upgrade = gm.cash >= upgrade_cost and lvl < gm.get_station_max_level(station_id)

	if level_label != null:
		level_label.font_size = 22
		level_label.outline_size = 6
		if lvl >= 10:
			level_label.text = "👑 Master Range Lv. %d" % lvl
			level_label.modulate = Color(1.0, 0.45, 0.2, 1)
		elif lvl >= 5:
			level_label.text = "★ Double Range Lv. %d" % lvl
			level_label.modulate = Color(1.0, 0.85, 0.25, 1)
		else:
			level_label.text = "🍳 Line Stove Lv. %d" % lvl
			level_label.modulate = Color(0.35, 1.0, 0.55, 1)

	if action_badge != null:
		if can_upgrade:
			action_badge.visible = true
			action_badge.text = "⬆ UPGRADE  ($%d)" % round(upgrade_cost)
			action_badge.modulate = Color(0.25, 1.0, 0.5, 1.0)
			action_badge.outline_modulate = Color(0.04, 0.25, 0.08, 0.95)
		else:
			action_badge.visible = false

func _on_station_upgraded(id: String, new_lvl: int) -> void:
	if id == station_id:
		update_level_display(new_lvl)
		if upgrade_particles != null:
			upgrade_particles.restart()
		_spawn_upgrade_text(new_lvl)
		var bounce_scale = Vector3(1.22, 1.22, 1.22) if (new_lvl == 5 or new_lvl == 10) else Vector3(1.14, 1.14, 1.14)
		var tween: Tween = create_tween()
		tween.tween_property(self, "scale", bounce_scale, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "scale", Vector3.ONE, 0.16)

func _spawn_upgrade_text(new_lvl: int) -> void:
	var label = Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.double_sided = false
	label.font_size = 26
	label.outline_size = 7
	label.position = Vector3(0, 3.65, 0)
	
	if new_lvl == 5:
		label.text = "★ COMMERCIAL DOUBLE RANGE UNLOCKED! ★"
		label.modulate = Color(1.0, 0.88, 0.2, 1.0)
		label.outline_modulate = Color(0.2, 0.1, 0.0, 0.95)
	elif new_lvl == 10:
		label.text = "👑 MASTER CULINARY SUITE UNLOCKED! 👑"
		label.modulate = Color(1.0, 0.45, 0.2, 1.0)
		label.outline_modulate = Color(0.2, 0.05, 0.0, 0.95)
	else:
		label.text = "+15% Cooking Speed! ⚡"
		label.modulate = Color(1.0, 0.85, 0.25, 1.0)
		label.outline_modulate = Color(0.18, 0.1, 0.02, 0.95)
		
	add_child(label)
	var tw = create_tween()
	tw.tween_property(label, "position:y", 4.65, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.35)
	tw.tween_callback(label.queue_free)

func _on_input_event(_camera: Camera3D, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var gm = get_node_or_null("/root/GameManager")
		var lvl: int = gm.get_station_level(station_id) if gm != null else 1
		station_clicked.emit(station_id, station_name, lvl)
