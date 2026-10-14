extends SceneTree

func _init() -> void:
	print("Generating speech bubble textures...")
	_make_bubble_pill()
	_make_circle_bubble()
	_make_entrance_chair_bubble()
	quit(0)

func _make_bubble_pill() -> void:
	var w: int = 256
	var h: int = 160
	var img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	var r: float = 46.0 # Corner radius
	var center_x: float = w * 0.5
	var center_y: float = 64.0
	var half_w: float = 90.0
	var half_h: float = 42.0

	for y in range(h):
		for x in range(w):
			# Distance to rounded rectangle
			var dx = max(0.0, abs(x - center_x) - (half_w - r))
			var dy = max(0.0, abs(y - center_y) - (half_h - r))
			var dist = sqrt(dx * dx + dy * dy)
			
			# Check tail pointing down at (center_x, center_y + half_h)
			var in_tail = false
			if y >= center_y + half_h - 6.0 and y <= center_y + half_h + 24.0:
				var tail_y = y - (center_y + half_h - 6.0)
				var tail_half_w = (1.0 - (tail_y / 30.0)) * 16.0
				if abs(x - center_x) <= tail_half_w:
					in_tail = true
			
			# Shadow calculation (offset y by +5)
			var sdx = max(0.0, abs(x - center_x) - (half_w - r))
			var sdy = max(0.0, abs((y - 5.0) - center_y) - (half_h - r))
			var sdist = sqrt(sdx * sdx + sdy * sdy)
			
			if dist <= r or in_tail:
				# Inside bubble
				if dist >= r - 2.5 and not in_tail:
					# Border outline
					var t = clamp((dist - (r - 2.5)) / 2.5, 0.0, 1.0)
					img.set_pixel(x, y, Color(0.2, 0.22, 0.28, 1.0).lerp(Color(1, 1, 1, 1), 1.0 - t))
				else:
					img.set_pixel(x, y, Color(1, 1, 1, 0.98))
			elif sdist <= r + 8.0:
				# Soft drop shadow
				var shadow_alpha = clamp((1.0 - ((sdist - r) / 8.0)) * 0.35, 0.0, 0.35)
				img.set_pixel(x, y, Color(0.05, 0.05, 0.1, shadow_alpha))

	var save_path = "res://assets/textures/speech_bubble_pill.png"
	var global_path = ProjectSettings.globalize_path(save_path)
	var err = img.save_png(global_path)
	print("Pill bubble generated, result:", err)

func _make_circle_bubble() -> void:
	var size: int = 192
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	var center = size * 0.5
	var radius = 72.0
	
	for y in range(size):
		for x in range(size):
			var dist = Vector2(x - center, y - center).length()
			var sdist = Vector2(x - center, (y - 4.0) - center).length()
			
			if dist <= radius:
				if dist >= radius - 3.0:
					var t = clamp((dist - (radius - 3.0)) / 3.0, 0.0, 1.0)
					img.set_pixel(x, y, Color(0.2, 0.22, 0.28, 1.0).lerp(Color(1, 1, 1, 1), 1.0 - t))
				else:
					img.set_pixel(x, y, Color(1, 1, 1, 0.98))
			elif sdist <= radius + 8.0:
				var s_alpha = clamp((1.0 - ((sdist - radius) / 8.0)) * 0.35, 0.0, 0.35)
				img.set_pixel(x, y, Color(0.05, 0.05, 0.1, s_alpha))
				
	var save_path = "res://assets/textures/bubble_circle.png"
	var global_path = ProjectSettings.globalize_path(save_path)
	var err = img.save_png(global_path)
	print("Circle bubble generated, result:", err)

func _make_entrance_chair_bubble() -> void:
	var size: int = 192
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	var center = size * 0.5
	var radius = 72.0
	
	for y in range(size):
		for x in range(size):
			var dist = Vector2(x - center, y - center).length()
			var sdist = Vector2(x - center, (y - 4.0) - center).length()
			
			if dist <= radius:
				if dist >= radius - 3.5:
					var t = clamp((dist - (radius - 3.5)) / 3.5, 0.0, 1.0)
					img.set_pixel(x, y, Color(0.18, 0.20, 0.26, 1.0).lerp(Color(1, 1, 1, 1), 1.0 - t))
				else:
					# Inside circle: check if inside chair icon
					var px = x - center
					var py = y - center
					
					var chair_color = Color(0.24, 0.16, 0.12, 1.0) # Dark rich brown
					var chair_cushion = Color(0.85, 0.22, 0.26, 1.0) # Red diner cushion
					var in_chair = false
					var col = Color(1, 1, 1, 0.98)
					
					# Backrest posts: px between -18 and -14, or 14 and 18, py between -34 and 6
					if (abs(px - 16.0) <= 2.5 or abs(px + 16.0) <= 2.5) and (py >= -34.0 and py <= 6.0):
						col = chair_color
						in_chair = true
					# Backrest top rail: px between -18 and 18, py between -36 and -26
					elif abs(px) <= 17.0 and (py >= -36.0 and py <= -26.0):
						col = chair_cushion
						in_chair = true
					# Backrest middle rail: px between -18 and 18, py between -18 and -12
					elif abs(px) <= 17.0 and (py >= -18.0 and py <= -12.0):
						col = chair_cushion
						in_chair = true
					# Seat cushion: px between -20 and 20, py between 6 and 14
					elif abs(px) <= 21.0 and (py >= 6.0 and py <= 14.0):
						col = chair_cushion
						in_chair = true
					# Chair legs: py between 14 and 36, px at -16 or 16
					elif (abs(px - 15.0) <= 2.5 or abs(px + 15.0) <= 2.5) and (py >= 14.0 and py <= 36.0):
						col = chair_color
						in_chair = true
					# Stretcher bar between legs: py between 24 and 27, px between -15 and 15
					elif abs(px) <= 15.0 and (py >= 24.0 and py <= 27.0):
						col = chair_color
						in_chair = true
						
					img.set_pixel(x, y, col)
			elif sdist <= radius + 8.0:
				var s_alpha = clamp((1.0 - ((sdist - radius) / 8.0)) * 0.35, 0.0, 0.35)
				img.set_pixel(x, y, Color(0.05, 0.05, 0.1, s_alpha))
				
	var save_path = "res://assets/textures/entrance_chair_bubble.png"
	var global_path = ProjectSettings.globalize_path(save_path)
	var err = img.save_png(global_path)
	print("Entrance chair bubble generated, result:", err)

