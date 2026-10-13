@tool
extends SceneTree

func _init():
	var tbl_scn = load("res://scenes/dining_table.tscn")
	var tbl = tbl_scn.instantiate()
	var sm = tbl.get_node("SeatMarker")
	print("SeatMarker local pos: ", sm.position)
	print("SeatMarker local rot: ", sm.rotation)
	print("SeatMarker local rot.y deg: ", rad_to_deg(sm.rotation.y))
	print("ChairLeft local pos: ", tbl.get_node("ChairLeft").position)
	print("ChairLeft local rot: ", tbl.get_node("ChairLeft").rotation)
	print("ChairLeft local rot.y deg: ", rad_to_deg(tbl.get_node("ChairLeft").rotation.y))
	quit(0)
