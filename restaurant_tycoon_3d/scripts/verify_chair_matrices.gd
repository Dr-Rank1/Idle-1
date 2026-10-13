@tool
extends SceneTree

func _init():
	var n_left = Node3D.new()
	n_left.rotation_degrees = Vector3(0, 90, 0) # +90 deg
	n_left.scale = Vector3(0.55, 0.55, 0.55)
	n_left.position = Vector3(-0.68, 0, 0)
	print("ChairLeft (rot_deg 90, front +X into table):")
	print("  transform: ", n_left.transform)
	var cl_front = n_left.transform.basis * Vector3(0, 0, 1)
	print("  front: ", cl_front.normalized())
	
	var n_right = Node3D.new()
	n_right.rotation_degrees = Vector3(0, -90, 0) # -90 deg
	n_right.scale = Vector3(0.55, 0.55, 0.55)
	n_right.position = Vector3(0.68, 0, 0)
	print("\nChairRight (rot_deg -90, front -X into table):")
	print("  transform: ", n_right.transform)
	var cr_front = n_right.transform.basis * Vector3(0, 0, 1)
	print("  front: ", cr_front.normalized())
	
	var sm = Marker3D.new()
	sm.rotation_degrees = Vector3(0, 90, 0)
	sm.position = Vector3(-0.68, 0.15, 0)
	print("\nSeatMarker (rot_deg 90, front +X into table):")
	print("  transform: ", sm.transform)
	var sm_front = sm.transform.basis * Vector3(0, 0, 1)
	print("  front: ", sm_front.normalized())
	
	quit(0)
