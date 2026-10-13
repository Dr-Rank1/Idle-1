@tool
extends SceneTree

func _init():
	var paths = [
		"res://assets/models/furniture/wallDoorwayWide.glb",
		"res://assets/models/furniture/doorwayOpen.glb",
		"res://assets/models/furniture/wallDoorway.glb",
		"res://assets/models/furniture/wallHalf.glb",
		"res://assets/models/furniture/wall.glb",
		"res://assets/kaykit_restaurant/gltf/wall_doorway.gltf",
		"res://assets/kaykit_restaurant/gltf/wall_orderwindow_decorated.gltf",
		"res://assets/kaykit_restaurant/gltf/wall_half.gltf"
	]
	for p in paths:
		if ResourceLoader.exists(p):
			var res = load(p)
			if res:
				var inst = res.instantiate()
				var aabb = calculate_aabb(inst)
				print(p.get_file(), " -> size: ", aabb.size, " center: ", aabb.position + aabb.size * 0.5)
				inst.free()
			else:
				print("Failed to load: ", p)
		else:
			print("Not exists: ", p)
	quit()

func calculate_aabb(node: Node) -> AABB:
	var total_aabb = AABB()
	var first = true
	var stack = [node]
	while stack.size() > 0:
		var curr = stack.pop_back()
		if curr is VisualInstance3D:
			var b = curr.get_aabb()
			if first:
				total_aabb = b
				first = false
			else:
				total_aabb = total_aabb.merge(b)
		for child in curr.get_children():
			stack.append(child)
	return total_aabb
