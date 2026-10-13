@tool
extends SceneTree

func _init():
	var chair_scn = load("res://assets/kaykit_restaurant/gltf/chair_A.gltf")
	var chair = chair_scn.instantiate()
	var mesh_inst: MeshInstance3D = chair.get_child(0)
	var mesh = mesh_inst.mesh
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	
	var high_verts = []
	for i in range(mdt.get_vertex_count()):
		var v = mdt.get_vertex(i)
		if v.y > 1.15:
			high_verts.append(v)
	print("High vertices count: ", high_verts.size())
	var avg = Vector3.ZERO
	for v in high_verts:
		avg += v
	avg /= float(high_verts.size())
	print("Average backrest top center: ", avg)
	
	# Seat cushion height (around y = 0.5)
	var seat_verts = []
	for i in range(mdt.get_vertex_count()):
		var v = mdt.get_vertex(i)
		if v.y > 0.45 and v.y < 0.6:
			seat_verts.append(v)
	var avg_seat = Vector3.ZERO
	for v in seat_verts:
		avg_seat += v
	avg_seat /= float(seat_verts.size())
	print("Average seat cushion center: ", avg_seat)
	quit(0)
