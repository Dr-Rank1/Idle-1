extends Label3D

func setup(amount: float, start_pos: Vector3) -> void:
	var gm = Engine.get_main_loop().root.get_node_or_null("GameManager") if Engine.get_main_loop() else null
	var formatted: String = gm.format_money(amount) if gm != null and gm.has_method("format_money") else ("$%d" % round(amount))
	text = "💵 +" + formatted
	position = start_pos
	modulate = Color(0.3, 1.0, 0.52, 1.0)
	font_size = 50
	outline_size = 14
	outline_modulate = Color(0.02, 0.22, 0.06, 0.95)
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	scale = Vector3(0.5, 0.5, 0.5)

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", start_pos.y + 1.85, 1.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector3(1.2, 1.2, 1.2), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(self, "modulate:a", 0.0, 0.45).set_delay(0.35)
	tween.chain().tween_callback(queue_free)
