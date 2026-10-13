@tool
extends SceneTree

func _init():
	print("--- CHECKING CHARACTER FACING ---")
	var char_scn = load("res://assets/models/characters/character-male-a.glb")
	var char_inst = char_scn.instantiate()
	# Check where the nose / face vertices or head bones are:
	var head = char_inst.find_child("head", true, false)
	# Or let's check mesh vertices of head:
	for child in char_inst.get_children():
		print("Char child: ", child.name)
		if child is Skeleton3D:
			for b in range(child.get_bone_count()):
				var bname = child.get_bone_name(b)
				if "head" in bname.to_lower() or "eye" in bname.to_lower() or "nose" in bname.to_lower():
					print("  Bone %s rest pos: %s" % [bname, child.get_bone_rest(b).origin])
	
	# Check mesh vertices with highest Y (face/head)
	var mi: MeshInstance3D = null
	for child in char_inst.get_children():
		if child is Skeleton3D:
			for c2 in child.get_children():
				if c2 is MeshInstance3D:
					mi = c2
					break
		elif child is MeshInstance3D:
			mi = child
			break
	if mi and mi.mesh:
		var mdt = MeshDataTool.new()
		mdt.create_from_surface(mi.mesh, 0)
		var front_z_face = 0.0
		var back_z_face = 0.0
		for i in range(mdt.get_vertex_count()):
			var v = mdt.get_vertex(i)
			if v.y > 0.6: # head region
				if v.z > front_z_face: front_z_face = v.z
				if v.z < back_z_face: back_z_face = v.z
		print("Head vertices Z range: [min_z=%f, max_z=%f]" % [back_z_face, front_z_face])
	
	# Now check Chair A:
	# In Chair A, we saw backrest is at z = -0.25, cushion is at z = 0.
	# So back of chair is -Z, front of chair (where knees go) is +Z!
	# If character sits in chair:
	# Does character face +Z (same as chair front) or -Z?
	# Let's inspect character leg forward direction in "sit" animation!
	var anim_player: AnimationPlayer = char_inst.find_child("AnimationPlayer", true, false)
	var sit_anim = anim_player.get_animation("sit")
	# In sit anim, Track 5 (leg-right rot) was: (0.608761, 0, 0, -0.793353)
	# That's a rotation around X axis!
	# A positive rotation around X axis swings the leg forward into +Z or -Z?
	var q = Quaternion(0.608761, 0, 0, -0.793353)
	var leg_down = Vector3(0, -1, 0)
	var leg_swung = q * leg_down
	print("Leg direction after sit rot: ", leg_swung)
	quit(0)
