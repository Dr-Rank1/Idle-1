@tool
extends SceneTree

func _init():
	var char_scn = load("res://assets/models/characters/character-male-a.glb")
	var char_inst = char_scn.instantiate()
	var anim_player: AnimationPlayer = char_inst.find_child("AnimationPlayer", true, false)
	var sit_anim = anim_player.get_animation("sit")
	print("--- SIT ANIMATION ROTATION TRACKS ---")
	for t in range(sit_anim.get_track_count()):
		var path = sit_anim.track_get_path(t)
		var type = sit_anim.track_get_type(t)
		if type == Animation.TYPE_ROTATION_3D:
			print("Track %d (rot): %s -> %s" % [t, str(path), sit_anim.track_get_key_value(t, 0)])

	var chair_scn = load("res://assets/kaykit_restaurant/gltf/chair_A.gltf")
	var chair = chair_scn.instantiate()
	var mesh_inst: MeshInstance3D = chair.get_child(0)
	var mesh = mesh_inst.mesh
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	var min_z_v = Vector3.ZERO
	var max_z_v = Vector3.ZERO
	var max_y = -999.0
	for i in range(mdt.get_vertex_count()):
		var v = mdt.get_vertex(i)
		if v.y > max_y:
			max_y = v.y
			max_z_v = v
	print("\nHighest vertex of chair (backrest top): ", max_z_v)
	quit(0)
