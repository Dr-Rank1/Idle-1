@tool
extends SceneTree

func _init():
	var tbl_scn = load("res://scenes/dining_table.tscn")
	var tbl = tbl_scn.instantiate()
	
	var cl = tbl.get_node("ChairLeft")
	var cr = tbl.get_node("ChairRight")
	var sm = tbl.get_node("SeatMarker")
	
	print("--- CHAIR LEFT ---")
	print("Pos: ", cl.position)
	print("Rot deg: ", cl.rotation_degrees)
	# In local space of chair_A.gltf:
	# Earlier we found:
	# Backrest top is at z = -0.25 (negative Z!)
	# Cushion is at z = 0.0
	# So back of chair is in -Z direction!
	# Front of chair (where knees go / face) is in +Z direction!
	# Let's see where the chair's +Z and -Z point in table space:
	var cl_front = cl.transform.basis * Vector3(0, 0, 1) # front (cushion / knees)
	var cl_back = cl.transform.basis * Vector3(0, 0, -1) # back (backrest)
	print("ChairLeft front points to: ", cl_front.normalized())
	print("ChairLeft back points to: ", cl_back.normalized())
	print("Vector from ChairLeft to Table (0,0,0): ", (Vector3.ZERO - cl.position).normalized())
	
	print("\n--- CHAIR RIGHT ---")
	print("Pos: ", cr.position)
	print("Rot deg: ", cr.rotation_degrees)
	var cr_front = cr.transform.basis * Vector3(0, 0, 1)
	var cr_back = cr.transform.basis * Vector3(0, 0, -1)
	print("ChairRight front points to: ", cr_front.normalized())
	print("ChairRight back points to: ", cr_back.normalized())
	print("Vector from ChairRight to Table (0,0,0): ", (Vector3.ZERO - cr.position).normalized())
	
	print("\n--- SEAT MARKER ---")
	print("Pos: ", sm.position)
	print("Rot deg: ", sm.rotation_degrees)
	var sm_front = sm.transform.basis * Vector3(0, 0, 1)
	print("SeatMarker front points to: ", sm_front.normalized())
	
	quit(0)
