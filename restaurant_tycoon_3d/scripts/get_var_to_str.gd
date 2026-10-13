@tool
extends SceneTree

func _init():
	var n = Node3D.new()
	n.position = Vector3(-0.68, 0, 0)
	n.scale = Vector3(0.55, 0.55, 0.55)
	n.rotation_degrees = Vector3(0, 90, 0)
	print("ChairLeft string representation: ", var_to_str(n.transform))
	
	var nr = Node3D.new()
	nr.position = Vector3(0.68, 0, 0)
	nr.scale = Vector3(0.55, 0.55, 0.55)
	nr.rotation_degrees = Vector3(0, -90, 0)
	print("ChairRight string representation: ", var_to_str(nr.transform))
	
	var sm = Marker3D.new()
	sm.position = Vector3(-0.68, 0.15, 0)
	sm.rotation_degrees = Vector3(0, 90, 0)
	print("SeatMarker string representation: ", var_to_str(sm.transform))
	
	quit(0)
