extends CharacterBody3D

signal order_placed(table_node: Node3D, customer_node: Node3D)
signal lobby_wait_timeout(customer_node: Node3D)
signal entered_restaurant(customer_node: Node3D)

enum State {
	SPAWNING,
	WALKING_TO_HOST,
	AT_HOST,
	WAITING_IN_LOBBY,
	WALKING_TO_TABLE,
	SEATED_ORDERING,
	EATING,
	CHEERING,
	WALKING_TO_EXIT
}

var current_state: State = State.SPAWNING
var assigned_table_id: String = ""
var move_speed: float = 3.4
var state_timer: float = 0.0
var walk_cycle: float = 0.0
var time_passed: float = 0.0
var initial_bubble_y: float = 1.35

var waypoints: Array = []

@onready var bubble_label: Label3D = $StatusBubble/BubbleLabel
@onready var bubble_bg: Sprite3D = get_node_or_null("StatusBubble/BubbleBg")
@onready var status_bubble: Node3D = $StatusBubble
@onready var mesh_root: Node3D = $MeshRoot
@onready var patience_root: Node3D = $PatienceRoot
@onready var patience_fill: MeshInstance3D = $PatienceRoot/PatienceFill
@onready var radial_ring: MeshInstance3D = get_node_or_null("RadialRing")
@onready var celebration_particles: CPUParticles3D = get_node_or_null("CelebrationParticles")

var anim_player: AnimationPlayer = null
var table_ref: Node3D = null
var fill_material: StandardMaterial3D = null
var badge_sprite: Sprite3D = null
static var _bubble_texture: ImageTexture = null
static var _fork_knife_tex: ImageTexture = null
static var _hourglass_tex: ImageTexture = null

static func _get_fork_knife_texture() -> ImageTexture:
	if _fork_knife_tex == null:
		var path = ProjectSettings.globalize_path("res://assets/textures/bubble_fork_knife.png")
		var img = Image.load_from_file(path)
		if img != null:
			_fork_knife_tex = ImageTexture.create_from_image(img)
	return _fork_knife_tex

static func _get_hourglass_texture() -> ImageTexture:
	if _hourglass_tex == null:
		var path = ProjectSettings.globalize_path("res://assets/textures/bubble_hourglass.png")
		var img = Image.load_from_file(path)
		if img != null:
			_hourglass_tex = ImageTexture.create_from_image(img)
	return _hourglass_tex

var max_patience: float = 34.0
var current_patience: float = 34.0
var is_waiting_for_food: bool = false
var ordered_dish: Dictionary = {}
var is_vip_critic: bool = false
var critic_badge: Label3D = null

# Landmark Waypoints for clean dining hall entrance navigation (matching res1_30s.jpg & res1_08s.jpg)
const DOOR_POS: Vector3 = Vector3(-1.5, 0.0, 10.5)
const HOST_POS: Vector3 = Vector3(-1.5, 0.0, 6.8)
const ARCH_POS: Vector3 = Vector3(-1.5, 0.0, 4.5)
const AISLE_POS: Vector3 = Vector3(3.5, 0.0, 4.5)
const EXIT_POS: Vector3 = Vector3(-1.5, 0.0, 14.5)

const CHARACTER_MODELS: Array[String] = [
	"res://assets/models/characters/character-male-a.glb",
	"res://assets/models/characters/character-male-b.glb",
	"res://assets/models/characters/character-male-c.glb",
	"res://assets/models/characters/character-male-d.glb",
	"res://assets/models/characters/character-male-e.glb",
	"res://assets/models/characters/character-male-f.glb",
	"res://assets/models/characters/character-female-a.glb",
	"res://assets/models/characters/character-female-b.glb",
	"res://assets/models/characters/character-female-c.glb",
	"res://assets/models/characters/character-female-d.glb",
	"res://assets/models/characters/character-female-e.glb",
	"res://assets/models/characters/character-female-f.glb"
]

func _ready() -> void:
	initial_bubble_y = status_bubble.position.y
	_setup_bubble_bg()
	if status_bubble != null:
		badge_sprite = status_bubble.get_node_or_null("BadgeSprite")
		if badge_sprite == null:
			badge_sprite = Sprite3D.new()
			badge_sprite.name = "BadgeSprite"
			badge_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			badge_sprite.double_sided = false
			badge_sprite.pixel_size = 0.0030
			badge_sprite.position = Vector3(0, 0.05, 0)
			status_bubble.add_child(badge_sprite)
	_setup_random_character()
	_play_anim("walk")
	set_bubble_text("💭")
	
	if patience_fill != null and patience_fill.mesh != null:
		var orig_mat = patience_fill.mesh.material
		if orig_mat != null:
			fill_material = orig_mat.duplicate()
			patience_fill.material_override = fill_material
	
	if radial_ring != null and radial_ring.mesh != null and radial_ring.mesh.material != null:
		radial_ring.material_override = radial_ring.mesh.material.duplicate()

func _setup_bubble_bg() -> void:
	if bubble_bg == null:
		return
	if _bubble_texture == null:
		var path = ProjectSettings.globalize_path("res://assets/textures/speech_bubble_pill.png")
		var img = Image.load_from_file(path)
		if img != null:
			_bubble_texture = ImageTexture.create_from_image(img)
	if _bubble_texture != null:
		bubble_bg.texture = _bubble_texture


func set_as_critic(is_critic: bool = true) -> void:
	is_vip_critic = is_critic
	if is_vip_critic:
		max_patience = 26.0
		current_patience = 26.0
		move_speed = 3.6
		if critic_badge == null:
			critic_badge = Label3D.new()
			critic_badge.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			critic_badge.double_sided = false
			critic_badge.font_size = 20
			critic_badge.outline_size = 6
			critic_badge.text = "👑 MICHELIN CRITIC ⭐"
			critic_badge.modulate = Color(1.0, 0.88, 0.2, 1.0)
			critic_badge.outline_modulate = Color(0.25, 0.08, 0.0, 0.95)
			critic_badge.position = Vector3(0, 1.85, 0)
			add_child(critic_badge)

func _setup_random_character() -> void:
	var model_path = CHARACTER_MODELS.pick_random()
	var scn = load(model_path)
	if scn:
		for c in mesh_root.get_children():
			c.queue_free()
		
		var inst = scn.instantiate()
		mesh_root.add_child(inst)
		anim_player = inst.find_child("AnimationPlayer", true, false)

func _play_anim(anim_name: String) -> void:
	if anim_player != null and anim_player.has_animation(anim_name):
		var anim = anim_player.get_animation(anim_name)
		if anim != null and anim_name in ["sit", "idle", "walk"]:
			anim.loop_mode = Animation.LOOP_LINEAR
		anim_player.play(anim_name)

func set_bubble_badge(badge_type: String) -> void:
	if badge_type == "":
		if status_bubble != null:
			status_bubble.visible = false
		return
	if status_bubble != null:
		status_bubble.visible = true
	if badge_sprite == null and status_bubble != null:
		badge_sprite = status_bubble.get_node_or_null("BadgeSprite")
	
	if badge_type == "hourglass":
		if badge_sprite != null:
			badge_sprite.texture = _get_hourglass_texture()
			badge_sprite.visible = true
		if bubble_bg != null:
			bubble_bg.visible = false
		if bubble_label != null:
			bubble_label.visible = false
	elif badge_type == "fork_knife":
		if badge_sprite != null:
			badge_sprite.texture = _get_fork_knife_texture()
			badge_sprite.visible = true
		if bubble_bg != null:
			bubble_bg.visible = false
		if bubble_label != null:
			bubble_label.visible = false
	else:
		if badge_sprite != null:
			badge_sprite.visible = false
		if bubble_bg != null:
			bubble_bg.visible = true
		if bubble_label != null:
			bubble_label.visible = true
			bubble_label.text = badge_type

func set_bubble_text(text: String, show: bool = true) -> void:
	if text == "" or not show:
		if status_bubble != null:
			status_bubble.visible = false
		return
	if text in ["⏳", "⏳ 🍽️", "hourglass"]:
		set_bubble_badge("hourglass")
		return
	elif text in ["🍽️", "fork_knife", "🍴", "😋"]:
		set_bubble_badge("fork_knife")
		return
	set_bubble_badge(text)


func set_waypoints(new_points: Array) -> void:
	waypoints.clear()
	for p in new_points:
		waypoints.append(p)
	_play_anim("walk")

func _physics_process(delta: float) -> void:
	time_passed += delta
	
	# Gentle status bubble bobbing
	if status_bubble != null and status_bubble.visible:
		var base_y = 1.35 if (current_state == State.SEATED_ORDERING or current_state == State.EATING) else initial_bubble_y
		status_bubble.position.y = base_y + sin(time_passed * 3.2) * 0.06
	
	# Handle Patience Timer depletion while customer is seated waiting for order
	if is_waiting_for_food:
		current_patience -= delta
		_update_patience_bar()
		
		if current_patience <= 0.0:
			_handle_customer_walkout()
			return
	
	if waypoints.size() > 0:
		var target: Vector3 = waypoints[0]
		var to_target: Vector3 = target - position
		to_target.y = 0.0
		var dist: float = to_target.length()
		
		var arrival_thresh: float = 0.32 if waypoints.size() == 1 else 0.24
		if dist > arrival_thresh:
			var dir: Vector3 = to_target.normalized()
			var desired_vel: Vector3 = dir * move_speed
			velocity = velocity.move_toward(desired_vel, 14.0 * delta)
			
			var target_yaw: float = atan2(dir.x, dir.z)
			rotation.y = lerp_angle(rotation.y, target_yaw, 11.0 * delta)
			
			walk_cycle += delta * 13.0
			if mesh_root != null:
				mesh_root.position.y = abs(sin(walk_cycle)) * 0.05
				mesh_root.rotation.z = sin(walk_cycle) * 0.04
		else:
			var reached_wp: Vector3 = waypoints[0]
			waypoints.remove_at(0)
			if (reached_wp - DOOR_POS).length() < 0.6:
				entered_restaurant.emit(self)
			if waypoints.size() == 0:
				velocity = Vector3.ZERO
				if mesh_root != null:
					mesh_root.position.y = 0.0
					mesh_root.rotation.z = 0.0
				_on_all_waypoints_reached()
	else:
		velocity = velocity.move_toward(Vector3.ZERO, 16.0 * delta)
		if mesh_root != null and current_state != State.SEATED_ORDERING and current_state != State.EATING:
			mesh_root.position.y = move_toward(mesh_root.position.y, 0.0, delta * 0.2)
			mesh_root.rotation.z = move_toward(mesh_root.rotation.z, 0.0, delta * 0.5)

	if current_state != State.SEATED_ORDERING and current_state != State.EATING and current_state != State.CHEERING and current_state != State.WAITING_IN_LOBBY:
		move_and_slide()
	
	if state_timer > 0.0:
		state_timer -= delta
		if current_state == State.AT_HOST:
			if radial_ring != null:
				radial_ring.visible = true
				var prog: float = clampf(1.0 - (state_timer / 0.8), 0.0, 1.0)
				var mat = radial_ring.material_override
				if mat is ShaderMaterial:
					mat.set_shader_parameter("progress", prog)
		elif current_state == State.EATING:
			if table_ref != null and table_ref.has_method("set_eating_progress"):
				var prog: float = 1.0 - (state_timer / 3.2)
				table_ref.set_eating_progress(prog)
			if state_timer <= 1.2:
				set_bubble_text("⏳ 💵")
		if state_timer <= 0.0:
			_on_timer_complete()

func _update_patience_bar() -> void:
	if patience_root == null or patience_fill == null:
		return
	
	if not patience_root.visible:
		patience_root.visible = true
		
	var cam = get_viewport().get_camera_3d()
	if cam != null:
		patience_root.global_transform.basis = cam.global_transform.basis
		
	var ratio = clamp(current_patience / max_patience, 0.0, 1.0)
	
	# Scale width and keep left edge firmly anchored:
	patience_fill.scale.x = ratio
	patience_fill.position.x = 0.25 * (ratio - 1.0)
	
	if fill_material != null:
		if ratio > 0.55:
			# Emerald green
			fill_material.albedo_color = Color(0.25, 0.92, 0.45, 1.0)
		elif ratio > 0.25:
			# Amber yellow
			fill_material.albedo_color = Color(1.0, 0.85, 0.15, 1.0)
		else:
			# Urgent crimson flash
			var flash = (sin(time_passed * 16.0) + 1.0) * 0.5
			fill_material.albedo_color = Color(1.0, 0.2 * flash, 0.2 * flash, 1.0)

func _handle_customer_walkout() -> void:
	is_waiting_for_food = false
	if patience_root != null:
		patience_root.visible = false
	if radial_ring != null:
		radial_ring.visible = false
		
	if current_state == State.WAITING_IN_LOBBY:
		lobby_wait_timeout.emit(self)
		
	current_state = State.WALKING_TO_EXIT
	set_bubble_text("😡 Too Slow!", true)
	
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("angry")
		
	if is_vip_critic:
		var gm = get_node_or_null("/root/GameManager")
		if gm != null:
			gm.award_critic_review(false)
		_spawn_floating_text("💥 CRITIC DOCKED 0.1 STARS (-0.1 ★)", Color(1.0, 0.2, 0.2, 1.0))
	else:
		_spawn_floating_text("💢 Walked Out! ($0)", Color(1.0, 0.25, 0.25, 1.0))
	
	if table_ref != null and table_ref.has_method("vacate"):
		table_ref.vacate()
		
	global_position.y = 0.0
	_play_anim("walk")
	set_waypoints(_get_waypoints_from_table(position))

func _spawn_floating_text(txt: String, col: Color) -> void:
	var label = Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.double_sided = false
	label.font_size = 22
	label.outline_size = 5
	label.text = txt
	label.modulate = col
	label.outline_modulate = Color(0.1, 0.1, 0.1, 0.9)
	label.position = Vector3(0, 1.6, 0)
	add_child(label)
	
	var tw = create_tween()
	tw.tween_property(label, "position:y", 2.5, 1.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(label, "modulate:a", 0.0, 0.9).set_delay(0.3)
	tw.tween_callback(label.queue_free)

func _on_all_waypoints_reached() -> void:
	match current_state:
		State.WALKING_TO_HOST:
			current_state = State.AT_HOST
			set_bubble_text("", false)
			if radial_ring != null:
				radial_ring.visible = true
				var mat = radial_ring.material_override
				if mat is ShaderMaterial:
					mat.set_shader_parameter("progress", 0.0)
			_play_anim("idle")
			var to_host: Vector3 = (HOST_POS + Vector3(0, 0, 0.4)) - position
			rotation.y = atan2(to_host.x, to_host.z)
			state_timer = 0.8
			
			var hostess = get_tree().root.find_child("Hostess", true, false)
			if hostess != null and hostess.has_method("greet_customer"):
				hostess.greet_customer()
			
		State.WALKING_TO_TABLE:
			current_state = State.SEATED_ORDERING
			
			var gm = get_node_or_null("/root/GameManager")
			if is_vip_critic and gm != null:
				var unlocked = gm.get_unlocked_dishes()
				unlocked.sort_custom(func(a, b): return a.get("price", 0) > b.get("price", 0))
				ordered_dish = unlocked[0]
			elif gm != null and gm.has_method("pick_random_dish"):
				ordered_dish = gm.pick_random_dish()
			else:
				ordered_dish = {"id": "burger", "name": "Classic Burger", "icon": "🍔", "price": 45.0}
				
			set_bubble_text("⏳ 🍽️")
			
			# Start Customer Patience countdown with marketing campaign buffs
			var pat_mult: float = 1.0
			if gm != null and gm.has_method("get_patience_multiplier"):
				pat_mult = gm.get_patience_multiplier()
			current_patience = max_patience * pat_mult
			is_waiting_for_food = true
			if patience_root != null:
				patience_root.visible = true
				_update_patience_bar()
				
			state_timer = 0.0 # Customer waits for waiter service!
			
			if table_ref != null:
				global_position = table_ref.get_seat_position()
				if table_ref.has_method("get_seat_rotation_y"):
					rotation.y = table_ref.get_seat_rotation_y()
				else:
					rotation.y = PI * 0.5
				velocity = Vector3.ZERO
			if mesh_root != null:
				mesh_root.position = Vector3.ZERO
				mesh_root.rotation = Vector3.ZERO
			_play_anim("sit")
			order_placed.emit(table_ref, self)

		State.WAITING_IN_LOBBY:
			velocity = Vector3.ZERO
			_play_anim("sit")
			set_bubble_text("⏳ 🍽️")
				
		State.WALKING_TO_EXIT:
			queue_free()

func set_as_waiting_in_lobby(spot: Vector3) -> void:
	current_state = State.WAITING_IN_LOBBY
	max_patience = 28.0
	current_patience = 28.0
	is_waiting_for_food = true
	set_bubble_text("⏳ 🍽️")
	set_waypoints([DOOR_POS, spot])

func _get_waypoints_to_table(seat_pos: Vector3) -> Array:
	var pts: Array = [ARCH_POS]
	if seat_pos.x <= 3.0:
		# Column 1 (Tables 1, 2, 3) via west aisle
		pts.append(Vector3(-0.1, 0.0, 4.5))
		pts.append(Vector3(-0.1, 0.0, seat_pos.z))
	elif seat_pos.x <= 6.8:
		# Column 2 (Tables 4, 5, 6) via central aisle
		pts.append(AISLE_POS)
		pts.append(Vector3(3.5, 0.0, seat_pos.z))
	elif seat_pos.x <= 10.8:
		# Column 3 (Tables 7, 8, 9) via east central aisle
		pts.append(AISLE_POS)
		pts.append(Vector3(7.3, 0.0, 4.5))
		pts.append(Vector3(7.3, 0.0, seat_pos.z))
	else:
		# Column 4 (Tables 10, 11, 12) via expansion aisle
		pts.append(AISLE_POS)
		pts.append(Vector3(11.5, 0.0, 4.5))
		pts.append(Vector3(11.5, 0.0, seat_pos.z))
	pts.append(seat_pos)
	return pts

func _get_waypoints_from_table(curr_pos: Vector3) -> Array:
	var pts: Array = []
	if curr_pos.x <= 3.0:
		pts.append(Vector3(-0.1, 0.0, curr_pos.z))
		pts.append(Vector3(-0.1, 0.0, 4.5))
	elif curr_pos.x <= 6.8:
		pts.append(Vector3(3.5, 0.0, curr_pos.z))
		pts.append(AISLE_POS)
	elif curr_pos.x <= 10.8:
		pts.append(Vector3(7.3, 0.0, curr_pos.z))
		pts.append(Vector3(7.3, 0.0, 4.5))
		pts.append(AISLE_POS)
	else:
		pts.append(Vector3(11.5, 0.0, curr_pos.z))
		pts.append(Vector3(11.5, 0.0, 4.5))
		pts.append(AISLE_POS)
	pts.append(ARCH_POS)
	pts.append(HOST_POS)
	pts.append(DOOR_POS)
	pts.append(EXIT_POS)
	return pts

func assign_table_from_lobby(target_table: Node3D) -> void:
	if current_state != State.WAITING_IN_LOBBY and current_state != State.AT_HOST:
		return
	is_waiting_for_food = false
	if patience_root != null:
		patience_root.visible = false
	if radial_ring != null:
		radial_ring.visible = false
	table_ref = target_table
	assigned_table_id = target_table.table_id
	if target_table.has_method("occupy"):
		target_table.occupy(self)
	else:
		target_table.is_occupied = true
	var seat_pos: Vector3 = target_table.get_seat_position()
	current_state = State.WALKING_TO_TABLE
	set_bubble_text("💭")
	set_waypoints(_get_waypoints_to_table(seat_pos))
	
	var hostess = get_tree().root.find_child("Hostess", true, false)
	if hostess != null and hostess.has_method("greet_customer"):
		hostess.greet_customer()

func _on_timer_complete() -> void:
	match current_state:
		State.AT_HOST:
			if radial_ring != null:
				radial_ring.visible = false
			if table_ref != null:
				var seat_pos: Vector3 = table_ref.get_seat_position()
				current_state = State.WALKING_TO_TABLE
				set_bubble_text("💭")
				set_waypoints(_get_waypoints_to_table(seat_pos))
			else:
				current_state = State.WALKING_TO_EXIT
				set_waypoints([DOOR_POS, EXIT_POS])
				
		State.EATING:
			if table_ref != null and table_ref.has_method("hide_timer_ring"):
				table_ref.hide_timer_ring()
			current_state = State.CHEERING
			_play_anim("emote-yes")
			var gm = get_node_or_null("/root/GameManager")
			var dish_price: float = ordered_dish.get("price", 45.0)
			var table_bonus: float = gm.get_station_income(assigned_table_id) if gm != null else 0.0
			var price_mult: float = 1.0
			if gm != null and gm.has_method("get_dish_price_multiplier"):
				price_mult = gm.get_dish_price_multiplier()
			var total_revenue: float = (dish_price * price_mult) + table_bonus
			set_bubble_text("💵 +$%d" % round(total_revenue))
			
			if gm != null:
				gm.add_cash(total_revenue, global_position + Vector3(0, 1.8, 0))
				if gm.has_method("record_customer_served"):
					gm.record_customer_served()
			
			var am = get_node_or_null("/root/AudioManager")
			if am != null and am.has_method("play_sfx"):
				am.play_sfx("coin", 0.06, 1.05)
			
			if table_ref != null and table_ref.has_method("vacate"):
				table_ref.vacate()
			
			await get_tree().create_timer(1.0).timeout
			current_state = State.WALKING_TO_EXIT
			set_bubble_text("")
			status_bubble.visible = false
			global_position.y = 0.0
			_play_anim("walk")
			set_waypoints(_get_waypoints_from_table(position))

# Called when waiter serves food to this customer's table
func on_food_delivered() -> void:
	if current_state != State.SEATED_ORDERING:
		return
		
	var ratio = current_patience / max_patience
	is_waiting_for_food = false
	if patience_root != null:
		patience_root.visible = false
		
	var gm = get_node_or_null("/root/GameManager")
	if is_vip_critic:
		var bounty: float = ordered_dish.get("price", 80.0) * 3.0
		if gm != null:
			gm.award_critic_review(true, bounty)
		_spawn_floating_text("⭐⭐⭐⭐⭐ 5-STAR CRITIC REVIEW! +$%d ⭐" % bounty, Color(1.0, 0.88, 0.2, 1.0))
		set_bubble_text("⭐⭐⭐⭐⭐")
		if celebration_particles != null:
			celebration_particles.restart()
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("upgrade", 0.0, 4.0)
	elif ratio >= 0.50:
		var tip: float = round(ordered_dish.get("price", 45.0) * 0.30)
		if gm != null:
			gm.add_cash(tip, global_position + Vector3(0, 2.2, 0))
		_spawn_floating_text("+$%d Speedy Tip! ⚡" % tip, Color(0.35, 1.0, 0.5, 1.0))
		set_bubble_badge("fork_knife")
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_sfx"):
			am.play_sfx("coin", 0.05, 1.1)
	else:
		set_bubble_badge("fork_knife")
		
	current_state = State.EATING
	state_timer = 3.2
	_play_anim("sit")
	if table_ref != null and table_ref.has_method("serve_food"):
		var d_id = ordered_dish.get("id", "burger")
		table_ref.serve_food(d_id)
