@tool
extends SceneTree

func _init():
	print("--- INSPECTING CHAIR ---")
	var chair_scn = load("res://assets/kaykit_restaurant/gltf/chair_A.gltf")
	var chair = chair_scn.instantiate()
	for child in chair.get_children():
		print("Chair child: ", child.name, " type: ", child.get_class())
		if child is VisualInstance3D:
			print("  aabb: ", child.get_aabb())
	
	print("\n--- INSPECTING CHARACTER SIT ANIMATION ---")
	var char_scn = load("res://assets/models/characters/character-male-a.glb")
	var char_inst = char_scn.instantiate()
	var anim_player: AnimationPlayer = char_inst.find_child("AnimationPlayer", true, false)
	if anim_player:
		print("Animations: ", anim_player.get_animation_list())
		var sit_anim = anim_player.get_animation("sit")
		if sit_anim:
			print("Sit anim length: ", sit_anim.length)
			print("Track count: ", sit_anim.get_track_count())
			for t in range(sit_anim.get_track_count()):
				var path = sit_anim.track_get_path(t)
				var type = sit_anim.track_get_type(t)
				if "Root" in str(path) or "Hips" in str(path) or "Position" in str(path) or type == Animation.TYPE_POSITION_3D:
					print("Track %d: %s (type %d, key count %d)" % [t, str(path), type, sit_anim.track_get_key_count(t)])
					if sit_anim.track_get_key_count(t) > 0:
						print("  Key 0 value: ", sit_anim.track_get_key_value(t, 0))
	quit(0)
