@tool
extends MultiMeshInstance3D

func _ready() -> void:
	if multimesh == null:
		return
	
	var positions: Array[Vector3] = []
	
	# Center Seam (X = 0)
	for i in range(12):
		var z = -2.75 + (i * 0.5)
		positions.append(Vector3(0.0, 0.15, z))
		
	# North rim
	for i in range(14):
		var x = -3.25 + (i * 0.5)
		positions.append(Vector3(x, 0.15, -3.0))
		
	# South rim
	for i in range(14):
		var x = -3.25 + (i * 0.5)
		positions.append(Vector3(x, 0.15, 3.0))
		
	# West rim
	for i in range(10):
		var z = -2.25 + (i * 0.5)
		positions.append(Vector3(-3.4, 0.15, z))
		
	# East rim
	for i in range(10):
		var z = -2.25 + (i * 0.5)
		positions.append(Vector3(3.4, 0.15, z))
		
	multimesh.instance_count = positions.size()
	for i in range(positions.size()):
		var t = Transform3D(Basis(), positions[i])
		multimesh.set_instance_transform(i, t)
