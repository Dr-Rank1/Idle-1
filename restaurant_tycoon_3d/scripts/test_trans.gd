@tool
extends SceneTree
func _init():
	var n = Node3D.new()
	n.rotation.y = PI * 0.5 # 90 deg: local +Z points to +X!
	n.scale = Vector3(0.58, 0.58, 0.58)
	n.position = Vector3(-0.58, 0, 0)
	print("Rotation 90 deg (+X) transform: ", n.transform)
	
	var n2 = Node3D.new()
	n2.rotation.y = -PI * 0.5 # -90 deg: local +Z points to -X!
	n2.scale = Vector3(0.58, 0.58, 0.58)
	n2.position = Vector3(0.58, 0, 0)
	print("Rotation -90 deg (-X) transform: ", n2.transform)
	quit(0)
