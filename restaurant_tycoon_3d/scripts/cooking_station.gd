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
		apply_station_visual_tier(new_lvl)
		if upgrade_particles != null:
			upgrade_particles.restart()
		_spawn_upgrade_text(new_lvl)
		var bounce_scale = Vector3(1.28, 1.28, 1.28) if new_lvl in [10, 25, 50] else \
			(Vector3(1.22, 1.22, 1.22) if new_lvl == 5 else Vector3(1.14, 1.14, 1.14))
		var tween: Tween = create_tween()
		tween.tween_property(self, "scale", bounce_scale, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "scale", Vector3.ONE, 0.18)
		if new_lvl in [10, 25, 50]:
			_spawn_milestone_star_burst(new_lvl)
			var am = get_node_or_null("/root/AudioManager")
			if am != null and am.has_method("play_milestone_chime"):
				am.play_milestone_chime(new_lvl)

## ── Kitchen/Bar Visual Tier System ─────────────────────────────────────────
## Tier 1 (Lv 1-24):  brushed stainless steel hood + cool white burner glow
## Tier 2 (Lv 25-49): copper-trimmed hood accent + amber burner intensification
## Tier 3 (Lv 50):    gold-trimmed commercial suite + red-gold high-output burner

func apply_station_visual_tier(lvl: int) -> void:
	if lvl >= 50:
		_apply_station_tier_max()
	elif lvl >= 25:
		_apply_station_tier_copper()
	elif lvl >= 10:
		_apply_station_tier_stainless()

func _apply_station_tier_stainless() -> void:
	# Refined stainless steel at level 10: slightly more metallic
	var steel = StandardMaterial3D.new()
	steel.albedo_color = Color(0.82, 0.84, 0.88)
	steel.metallic = 0.78
	steel.roughness = 0.30
	for part_name in ["StoveHood", "HoodTrim", "CounterTop", "CounterFront"]:
		var node = find_child(part_name, true, false)
		if node is MeshInstance3D:
			node.material_override = steel
	# Increase burner glow brightness
	_set_burner_glow(Color(0.55, 0.75, 1.0), 1.4)

func _apply_station_tier_copper() -> void:
	_apply_station_tier_stainless()
	# Copper accent trim on hood
	var copper = StandardMaterial3D.new()
	copper.albedo_color = Color(0.78, 0.44, 0.22)
	copper.metallic = 0.82
	copper.roughness = 0.22
	for part_name in ["HoodTrim", "BurnerRing", "KnobRow"]:
		var node = find_child(part_name, true, false)
		if node is MeshInstance3D:
			node.material_override = copper
	# Amber intensified burner
	_set_burner_glow(Color(1.0, 0.55, 0.12), 2.2)

func _apply_station_tier_max() -> void:
	_apply_station_tier_copper()
	# Gold-trimmed high-output commercial suite
	var gold = StandardMaterial3D.new()
	gold.albedo_color = Color(1.0, 0.82, 0.18)
	gold.metallic = 0.95
	gold.roughness = 0.10
	for part_name in ["HoodTrim", "BurnerRing", "KnobRow", "HandleBar"]:
		var node = find_child(part_name, true, false)
		if node is MeshInstance3D:
			node.material_override = gold
	# Deep red-gold high-output burner
	_set_burner_glow(Color(1.0, 0.28, 0.08), 3.5)
	# Prestige label
	if get_node_or_null("PrestigePlaque") == null:
		var plaque = Label3D.new()
		plaque.name = "PrestigePlaque"
		plaque.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		plaque.double_sided = false
		plaque.font_size = 18
		plaque.outline_size = 5
		plaque.text = "♛ MASTER CULINARY SUITE Lv.50 ♛"
		plaque.modulate = Color(1.0, 0.88, 0.2)
		plaque.outline_modulate = Color(0.15, 0.06, 0.0, 0.95)
		plaque.position = Vector3(0.0, 3.1, 0.0)
		add_child(plaque)

func _set_burner_glow(col: Color, energy: float) -> void:
	# Find any OmniLight3D children used for burner glow and update them
	for child in get_children():
		if child is OmniLight3D:
			child.light_color = col
			child.light_energy = energy
			return
	# If none found, create one
	var glow = OmniLight3D.new()
	glow.name = "BurnerGlow"
	glow.light_color = col
	glow.light_energy = energy
	glow.omni_range = 1.8
	glow.position = Vector3(0.0, 0.65, 0.0)
	add_child(glow)

func _spawn_milestone_star_burst(milestone_lvl: int) -> void:
	var stars = CPUParticles3D.new()
	stars.name = "MilestoneStarBurst"
	stars.emitting = true
	stars.one_shot = true
	stars.amount = 28 if milestone_lvl >= 50 else (20 if milestone_lvl >= 25 else 14)
	stars.lifetime = 1.6
	stars.explosiveness = 0.92
	stars.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	stars.emission_sphere_radius = 0.4
	stars.direction = Vector3(0, 1, 0)
	stars.spread = 75.0
	stars.gravity = Vector3(0.0, -3.0, 0.0)
	stars.initial_velocity_min = 2.5
	stars.initial_velocity_max = 5.0
	stars.scale_amount_min = 0.06
	stars.scale_amount_max = 0.16
	stars.color = Color(1.0, 0.85, 0.18) if milestone_lvl < 50 else Color(1.0, 0.45, 0.88)
	stars.position = Vector3(0.0, 2.0, 0.0)
	add_child(stars)
	var t = get_tree().create_timer(2.2)
	t.timeout.connect(func():
		if is_instance_valid(stars):
			stars.queue_free()
	)


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

func get_cooking_speed_multiplier() -> float:
	var gm = get_node_or_null("/root/GameManager")
	if gm != null and gm.has_method("get_card_cook_speed_multiplier"):
		return gm.get_card_cook_speed_multiplier()
	return 1.0
