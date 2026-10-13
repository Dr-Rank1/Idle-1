extends Label3D

func setup(amount: float, start_pos: Vector3) -> void:
	text = "+$%d" % round(amount)
	position = start_pos
	modulate = Color(0.25, 1.0, 0.45, 1.0)
	font_size = 54
	outline_size = 16
	outline_modulate = Color(0.02, 0.22, 0.06, 0.95)
	billboard = BaseMaterial3D.BILLBOARD_ENABLED

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", start_pos.y + 1.8, 1.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector3(1.3, 1.3, 1.3), 0.3)
	tween.chain().tween_property(self, "modulate:a", 0.0, 0.5)
	tween.chain().tween_callback(queue_free)
