extends CharacterBody3D

enum State {
	IDLE,
	WALKING_TO_KITCHEN,
	WALKING_TO_TABLE,
	SERVING,
	RETURNING
}

@export var staff_id: String = "waiter_1"
@export var staff_name: String = "Marco"

var current_state: State = State.IDLE
var base_speed: float = 3.6
var move_speed: float = 3.6
var walk_cycle: float = 0.0

var waypoints: Array = []
var target_table: Node3D = null
var is_cleaning_job: bool = false

@onready var mesh_root: Node3D = $MeshRoot
@onready var serving_tray: Node3D = $ServingTray
@onready var status_bubble: Label3D = $StatusLabel

var anim_player: AnimationPlayer = null

const KITCHEN_PASS_POS: Vector3 = Vector3(-2.6, 0.0, -4.4)
const DINING_AISLE_POS: Vector3 = Vector3(0.0, 0.0, -4.4)
var home_pos: Vector3 = Vector3(0.0, 0.0, -1.0)

func _ready() -> void:
	home_pos = position
	serving_tray.visible = false
	if status_bubble != null:
		status_bubble.visible = false
	anim_player = find_child("AnimationPlayer", true, false)
	_play_anim("idle")
	
	_update_speed()
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.staff_updated.connect(_on_staff_updated)

func _update_speed() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm != null and gm.has_method("get_staff_speed_multiplier"):
		var mult = gm.get_staff_speed_multiplier(staff_id)
		move_speed = base_speed * mult
	else:
		move_speed = base_speed

func _on_staff_updated(id: String) -> void:
	if id == staff_id:
		_update_speed()

func _play_anim(anim_name: String) -> void:
	if anim_player != null and anim_player.has_animation(anim_name):
		anim_player.play(anim_name)

func serve_order(table: Node3D) -> void:
	if current_state != State.IDLE:
		return
	target_table = table
	is_cleaning_job = false
	current_state = State.WALKING_TO_KITCHEN
	waypoints = [KITCHEN_PASS_POS]
	serving_tray.visible = false
	_play_anim("walk")

func clean_dirty_table(table: Node3D) -> void:
	if current_state != State.IDLE:
		return
	target_table = table
	is_cleaning_job = true
	current_state = State.WALKING_TO_TABLE
	serving_tray.visible = false
	if is_instance_valid(target_table):
		var target_z = target_table.global_position.z
		var target_x = target_table.global_position.x
		var lane_z = target_z + 0.65
		var aisle_x = 4.6 if target_x > 4.0 else 0.0
		var table_approach = Vector3(aisle_x, 0.0, lane_z)
		var table_dest = Vector3(target_x, 0.0, lane_z)
		waypoints = [DINING_AISLE_POS, table_approach, table_dest]
	_play_anim("walk")

func _physics_process(delta: float) -> void:
	if waypoints.size() > 0:
		var target: Vector3 = waypoints[0]
		var to_target: Vector3 = target - position
		to_target.y = 0.0
		var dist: float = to_target.length()
		
		if dist > 0.22:
			var dir: Vector3 = to_target.normalized()
			var desired_vel: Vector3 = dir * move_speed
			velocity = velocity.move_toward(desired_vel, 14.0 * delta)
			
			var target_yaw: float = atan2(dir.x, dir.z)
			rotation.y = lerp_angle(rotation.y, target_yaw, 11.0 * delta)
			
			walk_cycle += delta * (13.0 * (move_speed / base_speed))
			if mesh_root != null:
				mesh_root.position.y = abs(sin(walk_cycle)) * 0.05
				mesh_root.rotation.z = sin(walk_cycle) * 0.04
		else:
			waypoints.remove_at(0)
			if waypoints.size() == 0:
				velocity = Vector3.ZERO
				if mesh_root != null:
					mesh_root.position.y = 0.0
					mesh_root.rotation.z = 0.0
				_on_all_waypoints_reached()
	else:
		velocity = velocity.move_toward(Vector3.ZERO, 16.0 * delta)
		if mesh_root != null:
			mesh_root.position.y = move_toward(mesh_root.position.y, 0.0, delta * 0.2)
			mesh_root.rotation.z = move_toward(mesh_root.rotation.z, 0.0, delta * 0.5)

	move_and_slide()

func _on_all_waypoints_reached() -> void:
	match current_state:
		State.WALKING_TO_KITCHEN:
			rotation.y = -PI * 0.5
			serving_tray.visible = true
			serving_tray.scale = Vector3(0.2, 0.2, 0.2)
			var tw = create_tween()
			tw.tween_property(serving_tray, "scale", Vector3.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			
			var am = get_node_or_null("/root/AudioManager")
			if am != null and am.has_method("play_sfx"):
				am.play_sfx("bell", 0.04, -2.0)
			
			await get_tree().create_timer(0.35).timeout
			
			current_state = State.WALKING_TO_TABLE
			if is_instance_valid(target_table):
				var target_z = target_table.global_position.z
				var target_x = target_table.global_position.x
				var lane_z = target_z + 0.65
				var aisle_x = 4.6 if target_x > 4.0 else 0.0
				var table_approach = Vector3(aisle_x, 0.0, lane_z)
				var table_dest = Vector3(target_x, 0.0, lane_z)
				waypoints = [DINING_AISLE_POS, table_approach, table_dest]
			_play_anim("walk")
			
		State.WALKING_TO_TABLE:
			current_state = State.SERVING
			_play_anim("idle")
			
			if is_instance_valid(target_table):
				var to_tbl = target_table.global_position - position
				rotation.y = atan2(to_tbl.x, to_tbl.z)
				if is_cleaning_job:
					_play_anim("emote-yes")
					await get_tree().create_timer(0.65).timeout
					if target_table.has_method("clean_table"):
						target_table.clean_table()
					is_cleaning_job = false
				else:
					if target_table.has_method("serve_food"):
						target_table.serve_food()
					await get_tree().create_timer(0.45).timeout
					serving_tray.visible = false
			else:
				is_cleaning_job = false
				serving_tray.visible = false
			
			current_state = State.RETURNING
			var curr_x = position.x
			var aisle_x = 4.6 if curr_x > 4.0 else 0.0
			var ret_approach = Vector3(aisle_x, 0.0, position.z)
			waypoints = [ret_approach, DINING_AISLE_POS, home_pos]
			_play_anim("walk")
			
		State.RETURNING:
			current_state = State.IDLE
			_play_anim("idle")
			rotation.y = 0.0
