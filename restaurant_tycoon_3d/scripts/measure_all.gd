@tool
extends SceneTree

func _init():
	var assets_to_check = [
		"res://assets/kaykit_restaurant/gltf/extractorhood.gltf",
		"res://assets/kaykit_restaurant/gltf/table_round_A_small.gltf",
		"res://assets/kaykit_restaurant/gltf/chair_A.gltf",
		"res://assets/kaykit_restaurant/gltf/kitchentable_A_large_decorated.gltf",
		"res://assets/kaykit_restaurant/gltf/kitchencounter_straight_A.gltf",
		"res://assets/kaykit_restaurant/gltf/wall_orderwindow_decorated.gltf",
		"res://assets/models/furniture/doorwayFront.glb",
		"res://assets/models/furniture/desk.glb",
		"res://assets/models/furniture/televisionModern.glb",
		"res://assets/models/furniture/wallWindow.glb",
		"res://assets/models/furniture/paneling.glb",
		"res://assets/models/food/cutting-board.glb",
		"res://assets/models/food/knife-block.glb",
		"res://assets/models/food/pot.glb",
		"res://assets/models/food/shaker-salt.glb"
	]
	
	for path in assets_to_check:
		if not ResourceLoader.exists(path):
			print("NOT FOUND: ", path)
			continue
		var scn = load(path)
		var inst = scn.instantiate()
		var aabb = get_tree_aabb(inst)
		print(path.get_file(), " -> Size: ", aabb.size, " | Min: ", aabb.position, " | Max: ", aabb.end)
	quit(0)

func get_tree_aabb(node: Node3D) -> AABB:
	var total_aabb = AABB()
	var first = true
	var meshes = []
	_gather_meshes(node, meshes)
	for m in meshes:
		var m_aabb = m.get_aabb()
		var trans = m.global_transform
		var transformed_aabb = trans * m_aabb
		if first:
			total_aabb = transformed_aabb
			first = false
		else:
			total_aabb = total_aabb.merge(transformed_aabb)
	return total_aabb

func _gather_meshes(node: Node, out: Array) -> void:
	if node is MeshInstance3D:
		out.append(node)
	for c in node.get_children():
		_gather_meshes(c, out)
