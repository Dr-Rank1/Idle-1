@tool
extends SceneTree

func _init():
	var tbl_scn = load("res://scenes/dining_table.tscn")
	var tbl = tbl_scn.instantiate()
	var cl = tbl.get_node("ChairLeft")
	print("Loaded ChairLeft transform: ", cl.transform)
	print("Loaded ChairLeft rot deg: ", cl.rotation_degrees)
	quit(0)
