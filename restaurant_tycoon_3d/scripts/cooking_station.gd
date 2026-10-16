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

signal catering_meal_cooked()

var catering_active: bool = false
var catering_meals_needed: int = 0
var catering_meals_cooked: int = 0
var catering_cook_accum: float = 0.0
var catering_order_label: Label3D = null

# ─── Mobile 3D Floor Idle Widgets ───────────────────────────────────────────
var floor_level_pad: Node3D = null
var floor_lvl_label: Label3D = null
var progress_trough: MeshInstance3D = null
var progress_fill: MeshInstance3D = null
var upgrade_arrow: Node3D = null
var can_upgrade_station: bool = false

# Physical 3D Cash Stacks
var station_cash_mat: Node3D = null
var station_cash_container: Node3D = null
var station_cash_label: Label3D = null
var cash_respawn_timer: float = 0.0

# Locked Construction Zone
var is_unlocked: bool = true
var locked_zone_root: Node3D = null
var locked_price_badge: Node3D = null
var locked_price_label: Label3D = null
var current_unlock_cost: float = 0.0

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
			
	_setup_floor_level_pad()
	_setup_3d_cash_stack()
	
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.station_upgraded.connect(_on_station_upgraded)
		gm.cash_changed.connect(_on_cash_changed)
		var lvl = gm.get_station_level(station_id)
		update_level_display(lvl)
		_update_floor_level_pad(lvl)

func _process(delta: float) -> void:
	time_passed += delta
	if badge_root != null:
		badge_root.position.y = initial_badge_y + sin(time_passed * 3.8 + 1.0) * 0.08
		if action_badge != null and action_badge.visible:
			var pulse = 1.0 + sin(time_passed * 6.0) * 0.12
			action_badge.scale = Vector3(pulse, pulse, pulse)

	if catering_active:
		_process_catering_cook(delta)

	# Dynamic animation for floor level pad & green upgrade arrow
	if is_unlocked and floor_level_pad != null and floor_level_pad.visible:
		if can_upgrade_station:
			var pad_pulse = 1.0 + sin(time_passed * 5.0) * 0.06
			floor_level_pad.scale = Vector3(pad_pulse, 1.0, pad_pulse)
			if upgrade_arrow != null:
				upgrade_arrow.visible = true
				upgrade_arrow.position.y = 0.44 + 0.08 * sin(time_passed * 6.5)
				upgrade_arrow.rotation.y = sin(time_passed * 2.5) * 0.25
		else:
			floor_level_pad.scale = Vector3.ONE
			if upgrade_arrow != null:
				upgrade_arrow.visible = false

	# Dynamic animation for locked unlock price button
	if not is_unlocked and locked_price_badge != null and locked_price_badge.visible:
		locked_price_badge.position.y = 1.45 + 0.08 * sin(time_passed * 4.5)
		var gm = get_node_or_null("/root/GameManager")
		var can_afford = (gm != null and gm.cash >= current_unlock_cost)
		if can_afford:
			var pulse = 1.0 + sin(time_passed * 6.0) * 0.06
			locked_price_badge.scale = Vector3(pulse, pulse, pulse)
		else:
			locked_price_badge.scale = Vector3.ONE

	# Station cash stack respawn / bob
	if is_unlocked and station_cash_mat != null:
		if not station_cash_mat.visible:
			cash_respawn_timer += delta
			if cash_respawn_timer >= 18.0:
				_populate_station_cash_bricks(4)
				station_cash_mat.visible = true
				cash_respawn_timer = 0.0
		elif station_cash_label != null:
			station_cash_label.position.y = 0.45 + 0.04 * sin(3.2 * time_passed + 1.2)

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

func _setup_floor_level_pad() -> void:
	if floor_level_pad != null and is_instance_valid(floor_level_pad):
		return
	floor_level_pad = Node3D.new()
	floor_level_pad.name = "FloorLevelPad"
	floor_level_pad.position = Vector3(0.0, 0.02, 1.05)
	add_child(floor_level_pad)
	
	# Plaque Base
	var plaque_mesh = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.36
	cyl.bottom_radius = 0.38
	cyl.height = 0.035
	cyl.radial_segments = 24
	plaque_mesh.mesh = cyl
	var slate_mat = StandardMaterial3D.new()
	slate_mat.albedo_color = Color(0.12, 0.15, 0.22)
	slate_mat.roughness = 0.4
	plaque_mesh.material_override = slate_mat
	floor_level_pad.add_child(plaque_mesh)
	
	# Plaque Rim
	var rim_mesh = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 0.35
	torus.outer_radius = 0.39
	torus.rings = 24
	torus.ring_segments = 12
	rim_mesh.mesh = torus
	rim_mesh.position = Vector3(0.0, 0.016, 0.0)
	var rim_mat = StandardMaterial3D.new()
	rim_mat.albedo_color = Color(1.0, 0.82, 0.22)
	rim_mat.metallic = 0.85
	rim_mat.roughness = 0.2
	rim_mesh.material_override = rim_mat
	floor_level_pad.add_child(rim_mesh)
	
	# 3D Level Label
	floor_lvl_label = Label3D.new()
	floor_lvl_label.name = "FloorLevelLabel"
	floor_lvl_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	floor_lvl_label.double_sided = false
	floor_lvl_label.position = Vector3(0.0, 0.18, -0.06)
	floor_lvl_label.font_size = 32
	floor_lvl_label.outline_size = 8
	floor_lvl_label.text = "Lv. 1"
	floor_lvl_label.modulate = Color.WHITE
	floor_lvl_label.outline_modulate = Color(0.05, 0.05, 0.10, 0.95)
	floor_level_pad.add_child(floor_lvl_label)
	
	# 3D Progress Bar
	var prog_root = Node3D.new()
	prog_root.position = Vector3(0.0, 0.026, 0.13)
	floor_level_pad.add_child(prog_root)
	
	progress_trough = MeshInstance3D.new()
	var trough_box = BoxMesh.new()
	trough_box.size = Vector3(0.48, 0.024, 0.08)
	progress_trough.mesh = trough_box
	var trough_mat = StandardMaterial3D.new()
	trough_mat.albedo_color = Color(0.08, 0.09, 0.13)
	progress_trough.material_override = trough_mat
	prog_root.add_child(progress_trough)
	
	progress_fill = MeshInstance3D.new()
	var fill_box = BoxMesh.new()
	fill_box.size = Vector3(0.12, 0.028, 0.065)
	progress_fill.mesh = fill_box
	var fill_mat = StandardMaterial3D.new()
	fill_mat.albedo_color = Color(0.12, 0.88, 0.98)
	fill_mat.emission_enabled = true
	fill_mat.emission = Color(0.08, 0.65, 0.75)
	fill_mat.emission_energy_multiplier = 0.5
	progress_fill.material_override = fill_mat
	prog_root.add_child(progress_fill)
	
	# Chunky 3D Green Upward Arrow
	upgrade_arrow = Node3D.new()
	upgrade_arrow.name = "UpgradeArrow"
	upgrade_arrow.position = Vector3(0.0, 0.44, 0.0)
	upgrade_arrow.visible = false
	
	var arrow_head = MeshInstance3D.new()
	var head_prism = PrismMesh.new()
	head_prism.size = Vector3(0.24, 0.22, 0.10)
	arrow_head.mesh = head_prism
	
	var arrow_shaft = MeshInstance3D.new()
	var shaft_box = BoxMesh.new()
	shaft_box.size = Vector3(0.09, 0.12, 0.08)
	arrow_shaft.mesh = shaft_box
	arrow_shaft.position = Vector3(0.0, -0.11, 0.0)
	
	var arrow_mat = StandardMaterial3D.new()
	arrow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	arrow_mat.albedo_color = Color(0.25, 1.0, 0.35)
	arrow_head.material_override = arrow_mat
	arrow_shaft.material_override = arrow_mat
	
	upgrade_arrow.add_child(arrow_head)
	upgrade_arrow.add_child(arrow_shaft)
	floor_level_pad.add_child(upgrade_arrow)

func _update_floor_level_pad(lvl: int) -> void:
	if floor_level_pad == null:
		_setup_floor_level_pad()
	if floor_lvl_label != null:
		floor_lvl_label.text = "Lv. %d" % lvl
		
	var ratio: float = 1.0
	if lvl < 10:
		ratio = float(lvl) / 10.0
	elif lvl < 25:
		ratio = float(lvl - 10) / 15.0
	elif lvl < 50:
		ratio = float(lvl - 25) / 25.0
	ratio = clamp(ratio, 0.08, 1.0)
	
	var fill_width = 0.46 * ratio
	if progress_fill != null and progress_fill.mesh is BoxMesh:
		progress_fill.mesh.size.x = fill_width
		progress_fill.position.x = -0.23 + fill_width * 0.5
		if progress_fill.material_override is StandardMaterial3D:
			var mat = progress_fill.material_override
			if lvl >= 50:
				mat.albedo_color = Color(1.0, 0.84, 0.18)
				mat.emission = Color(0.85, 0.65, 0.10)
			elif lvl >= 25:
				mat.albedo_color = Color(1.0, 0.72, 0.20)
				mat.emission = Color(0.80, 0.50, 0.10)
			else:
				mat.albedo_color = Color(0.12, 0.88, 0.98)
				mat.emission = Color(0.08, 0.65, 0.75)
				
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		var cost = gm.get_upgrade_cost(station_id)
		var max_lvl = gm.get_station_max_level(station_id)
		can_upgrade_station = (gm.cash >= cost and lvl < max_lvl)
	else:
		can_upgrade_station = false
		
	if upgrade_arrow != null:
		upgrade_arrow.visible = can_upgrade_station and is_unlocked

func _setup_3d_cash_stack() -> void:
	if station_cash_mat != null and is_instance_valid(station_cash_mat):
		station_cash_mat.queue_free()
		
	station_cash_mat = Node3D.new()
	station_cash_mat.name = "StationCashMat"
	station_cash_mat.position = Vector3(1.35, 0.02, 0.85)
	add_child(station_cash_mat)
	
	var mat_mesh = MeshInstance3D.new()
	var m_box = BoxMesh.new()
	m_box.size = Vector3(0.56, 0.02, 0.44)
	mat_mesh.mesh = m_box
	var mat_mat = StandardMaterial3D.new()
	mat_mat.albedo_color = Color(0.08, 0.30, 0.16)
	mat_mat.roughness = 0.6
	mat_mesh.material_override = mat_mat
	station_cash_mat.add_child(mat_mesh)
	
	var rim_mesh = MeshInstance3D.new()
	var r_box = BoxMesh.new()
	r_box.size = Vector3(0.58, 0.018, 0.46)
	rim_mesh.mesh = r_box
	rim_mesh.position = Vector3(0.0, -0.002, 0.0)
	var rim_mat = StandardMaterial3D.new()
	rim_mat.albedo_color = Color(0.95, 0.82, 0.22)
	rim_mat.metallic = 0.8
	rim_mat.roughness = 0.25
	rim_mesh.material_override = rim_mat
	station_cash_mat.add_child(rim_mesh)
	
	station_cash_container = Node3D.new()
	station_cash_container.name = "CashBricksContainer"
	station_cash_mat.add_child(station_cash_container)
	
	station_cash_label = Label3D.new()
	station_cash_label.name = "StationCashLabel"
	station_cash_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	station_cash_label.double_sided = false
	station_cash_label.font_size = 28
	station_cash_label.outline_size = 7
	station_cash_label.position = Vector3(0.0, 0.45, 0.0)
	station_cash_label.modulate = Color(0.35, 1.0, 0.55)
	station_cash_label.outline_modulate = Color(0.04, 0.16, 0.06, 0.95)
	station_cash_label.text = "$120"
	station_cash_mat.add_child(station_cash_label)
	
	_populate_station_cash_bricks(4)

func _create_cash_brick() -> Node3D:
	var brick = Node3D.new()
	var bill = MeshInstance3D.new()
	var b_box = BoxMesh.new()
	b_box.size = Vector3(0.20, 0.042, 0.11)
	bill.mesh = b_box
	var bill_mat = StandardMaterial3D.new()
	bill_mat.albedo_color = Color(0.18, 0.68, 0.30)
	bill_mat.roughness = 0.45
	bill.material_override = bill_mat
	brick.add_child(bill)
	
	var band = MeshInstance3D.new()
	var band_box = BoxMesh.new()
	band_box.size = Vector3(0.05, 0.045, 0.114)
	band.mesh = band_box
	var band_mat = StandardMaterial3D.new()
	band_mat.albedo_color = Color(0.96, 0.94, 0.88)
	band.material_override = band_mat
	brick.add_child(band)
	return brick

func _populate_station_cash_bricks(count: int) -> void:
	if station_cash_container == null:
		return
	for c in station_cash_container.get_children():
		c.queue_free()
	var grid_slots = [
		Vector3(-0.11, 0.0, -0.09),
		Vector3(0.11, 0.0, -0.09),
		Vector3(-0.11, 0.0, 0.09),
		Vector3(0.11, 0.0, 0.09)
	]
	for i in range(count):
		var brick = _create_cash_brick()
		var slot_idx = i % 4
		var layer = i / 4
		var base_p = grid_slots[slot_idx]
		brick.position = Vector3(base_p.x, 0.02 + float(layer) * 0.045, base_p.z)
		brick.rotation.y = randf_range(-0.08, 0.08)
		station_cash_container.add_child(brick)

func has_visible_cash_stack() -> bool:
	return is_unlocked and station_cash_mat != null and station_cash_mat.visible

func get_cash_stack_world_pos() -> Vector3:
	if station_cash_mat != null and is_instance_valid(station_cash_mat):
		return station_cash_mat.global_position
	return global_position + Vector3(1.35, 0.02, 0.85)

func _fly_brick_in_arc(brick: Node3D, delay: float) -> void:
	var start_pos = brick.global_position
	var cam = get_viewport().get_camera_3d() if get_viewport() != null else null
	var target_pos = start_pos + Vector3(0.0, 3.2, 1.2)
	if cam != null:
		target_pos = cam.global_position + (cam.global_transform.basis.y * 1.2) - (cam.global_transform.basis.z * 1.5)
		
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(brick, "scale", Vector3(1.3, 1.3, 1.3), 0.15).set_delay(delay)
	tw.chain().tween_property(brick, "scale", Vector3.ZERO, 0.45)
	
	tw.tween_property(brick, "global_position:x", target_pos.x, 0.6).set_delay(delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(brick, "global_position:z", target_pos.z, 0.6).set_delay(delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	var apex_y = max(start_pos.y, target_pos.y) + 1.8
	tw.tween_method(func(t: float):
		if is_instance_valid(brick):
			brick.global_position.y = lerp(start_pos.y, target_pos.y, t) + 4.0 * t * (1.0 - t) * (apex_y - start_pos.y)
	, 0.0, 1.0, 0.6).set_delay(delay)
	
	tw.tween_property(brick, "rotation:y", brick.rotation.y + randf_range(3.0, 6.0), 0.6).set_delay(delay)
	tw.tween_property(brick, "rotation:x", randf_range(1.0, 3.0), 0.6).set_delay(delay)
	tw.chain().tween_callback(brick.queue_free)

func collect_station_cash() -> float:
	if not has_visible_cash_stack():
		return 0.0
		
	var amount: float = 85.0
	var gm = get_node_or_null("/root/GameManager")
	if gm != null and gm.has_method("get_card_cook_speed_multiplier"):
		amount = round(amount * gm.get_card_cook_speed_multiplier())
	var c_pos: Vector3 = get_cash_stack_world_pos()
	
	if station_cash_container != null:
		var bricks = station_cash_container.get_children()
		var delay_idx = 0
		for b in bricks:
			if b is Node3D:
				var gpos = b.global_position
				station_cash_container.remove_child(b)
				get_tree().root.add_child(b)
				b.global_position = gpos
				_fly_brick_in_arc(b, float(delay_idx) * 0.04)
				delay_idx += 1
				
	station_cash_mat.visible = false
	
	var rest = find_parent("Restaurant")
	if rest != null and rest.has_method("register_cash_collection"):
		rest.register_cash_collection(c_pos, amount)
	else:
		if gm != null:
			gm.add_cash(amount, c_pos)
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("coin", 0.04, 1.0)
			
	_spawn_floating_text("💵 +$%d KITCHEN EARNINGS! ✨" % int(amount), Color(0.35, 1.0, 0.55))
	return amount

func _on_cash_changed(_val: float) -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		var lvl = gm.get_station_level(station_id)
		update_level_display(lvl)
		_update_floor_level_pad(lvl)

func update_level_display(lvl: int) -> void:
	_update_floor_level_pad(lvl)
	
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

func _spawn_floating_text(txt: String, col: Color) -> void:
	var label = Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.double_sided = false
	label.font_size = 26
	label.outline_size = 7
	label.text = txt
	label.modulate = col
	label.outline_modulate = Color(0.1, 0.1, 0.1, 0.95)
	label.position = Vector3(0, 2.5, 0)
	add_child(label)
	
	var tw = create_tween()
	tw.tween_property(label, "position:y", 3.5, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.35)
	tw.tween_callback(label.queue_free)

func _on_input_event(_camera: Camera3D, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) \
		or (event is InputEventScreenTouch and event.pressed) \
		or (event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0) \
		or (event is InputEventScreenDrag):
		if has_visible_cash_stack():
			collect_station_cash()
			return

	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) \
		or (event is InputEventScreenTouch and event.pressed):
		var gm = get_node_or_null("/root/GameManager")
		var lvl: int = gm.get_station_level(station_id) if gm != null else 1
		station_clicked.emit(station_id, station_name, lvl)

func get_cooking_speed_multiplier() -> float:
	var gm = get_node_or_null("/root/GameManager")
	if gm != null and gm.has_method("get_card_cook_speed_multiplier"):
		return gm.get_card_cook_speed_multiplier()
	return 1.0

func start_catering_batch(meals: int) -> void:
	catering_active = true
	catering_meals_needed = max(1, meals)
	catering_meals_cooked = 0
	catering_cook_accum = 0.0
	if catering_order_label == null:
		catering_order_label = Label3D.new()
		catering_order_label.name = "CateringBatchBadge"
		catering_order_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		catering_order_label.double_sided = false
		catering_order_label.font_size = 22
		catering_order_label.outline_size = 6
		catering_order_label.position = Vector3(0.0, 3.35, 0.0)
		add_child(catering_order_label)
	catering_order_label.visible = true
	_refresh_catering_label()

func stop_catering_batch() -> void:
	catering_active = false
	catering_cook_accum = 0.0
	if catering_order_label != null:
		catering_order_label.visible = false

func _process_catering_cook(delta: float) -> void:
	if catering_meals_cooked >= catering_meals_needed:
		_refresh_catering_label()
		return
	var speed = get_cooking_speed_multiplier()
	var gm = get_node_or_null("/root/GameManager")
	if gm != null and gm.has_method("get_staff_cooking_multiplier"):
		speed *= gm.get_staff_cooking_multiplier("chef_stove")
	catering_cook_accum += delta * max(0.35, speed)
	var meal_time := 1.6
	while catering_cook_accum >= meal_time and catering_meals_cooked < catering_meals_needed:
		catering_cook_accum -= meal_time
		catering_meals_cooked += 1
		catering_meal_cooked.emit()
	_refresh_catering_label()

func _refresh_catering_label() -> void:
	if catering_order_label == null:
		return
	catering_order_label.text = "📦 CATERING BATCH  %d/%d" % [catering_meals_cooked, catering_meals_needed]
	catering_order_label.modulate = Color(1.0, 0.82, 0.22, 1.0)
	if action_badge != null and catering_active:
		action_badge.visible = true
		action_badge.text = "🚚 Van crate • Kitchen Pass"
		action_badge.modulate = Color(1.0, 0.85, 0.25, 1.0)
