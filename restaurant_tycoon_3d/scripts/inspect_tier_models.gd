@tool
extends SceneTree

func _init():
	print("--- INSPECTING UPGRADE MODELS ---")
	var t2_scn = load("res://assets/models/furniture/tableCrossCloth.glb")
	if t2_scn:
		var t2 = t2_scn.instantiate()
		print("TableCrossCloth loaded, children: ", t2.get_child_count())
		for c in t2.get_children():
			if c is MeshInstance3D:
				print("  mesh: ", c.name, " aabb: ", c.get_aabb())
				
	var c2_scn = load("res://assets/models/furniture/chairCushion.glb")
	if c2_scn:
		var c2 = c2_scn.instantiate()
		print("chairCushion loaded, children: ", c2.get_child_count())
		for c in c2.get_children():
			if c is MeshInstance3D:
				print("  mesh: ", c.name, " aabb: ", c.get_aabb())

	var c3_scn = load("res://assets/models/furniture/chairModernCushion.glb")
	if c3_scn:
		var c3 = c3_scn.instantiate()
		print("chairModernCushion loaded, children: ", c3.get_child_count())
		for c in c3.get_children():
			if c is MeshInstance3D:
				print("  mesh: ", c.name, " aabb: ", c.get_aabb())
	quit(0)
