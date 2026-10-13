@tool
extends SceneTree

func _init():
	print("--- INSPECTING KAYKIT ROUND TABLES ---")
	var t_dec = load("res://assets/kaykit_restaurant/gltf/table_round_A_decorated.gltf")
	if t_dec:
		var inst = t_dec.instantiate()
		print("table_round_A_decorated child count: ", inst.get_child_count())
		for c in inst.get_children():
			print("  child: ", c.name, " class: ", c.get_class())
			if c is VisualInstance3D:
				print("    aabb: ", c.get_aabb())

	var t_b = load("res://assets/kaykit_restaurant/gltf/table_round_B.gltf")
	if t_b:
		var inst_b = t_b.instantiate()
		print("table_round_B child count: ", inst_b.get_child_count())
		for c in inst_b.get_children():
			print("  child: ", c.name, " class: ", c.get_class())
			if c is VisualInstance3D:
				print("    aabb: ", c.get_aabb())
	quit(0)
