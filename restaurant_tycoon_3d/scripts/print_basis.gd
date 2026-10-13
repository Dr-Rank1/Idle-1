@tool
extends SceneTree

func _init():
	var b_left = Basis(Vector3.UP, PI * 0.5).scaled(Vector3(0.58, 0.58, 0.58))
	print("ChairLeft (+90 deg, face +X): Transform3D(", b_left.x.x, ", ", b_left.x.y, ", ", b_left.x.z, ", ", b_left.y.x, ", ", b_left.y.y, ", ", b_left.y.z, ", ", b_left.z.x, ", ", b_left.z.y, ", ", b_left.z.z, ", -0.58, 0, 0)")
	
	var b_right = Basis(Vector3.UP, -PI * 0.5).scaled(Vector3(0.58, 0.58, 0.58))
	print("ChairRight (-90 deg, face -X): Transform3D(", b_right.x.x, ", ", b_right.x.y, ", ", b_right.x.z, ", ", b_right.y.x, ", ", b_right.y.y, ", ", b_right.y.z, ", ", b_right.z.x, ", ", b_right.z.y, ", ", b_right.z.z, ", 0.58, 0, 0)")
	
	var sm_b = Basis(Vector3.UP, PI * 0.5)
	print("SeatMarker (+90 deg): Transform3D(", sm_b.x.x, ", ", sm_b.x.y, ", ", sm_b.x.z, ", ", sm_b.y.x, ", ", sm_b.y.y, ", ", sm_b.y.z, ", ", sm_b.z.x, ", ", sm_b.z.y, ", ", sm_b.z.z, ", -0.55, 0.0, 0)")
	
	quit(0)
