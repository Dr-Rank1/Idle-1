extends SceneTree

func _init() -> void:
	print("Generating speech bubble textures...")
	_make_bubble_pill()
	_make_circle_bubble()
	_make_entrance_chair_bubble()
	_make_milkshake_neon_texture()
	_make_vinyl_record_texture()
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

func _make_milkshake_neon_texture() -> void:
	var w: int = 512
	var h: int = 256
	var img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	# Dark retro background backing board with rounded border
	img.fill(Color(0.06, 0.08, 0.11, 0.94))
	
	var pink = Color(1.0, 0.15, 0.55, 1.0)
	var cyan = Color(0.05, 0.92, 1.0, 1.0)
	var white_core = Color(1.0, 0.96, 0.98, 1.0)
	var yellow = Color(1.0, 0.88, 0.2, 1.0)
	
	# Draw glowing border
	for y in range(h):
		for x in range(w):
			if x < 8 or x >= w - 8 or y < 8 or y >= h - 8:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
			elif (x <= 14 or x >= w - 15 or y <= 14 or y >= h - 15):
				img.set_pixel(x, y, cyan)
				
	# Draw Milkshake Glass on the left (center x=120, y=130)
	for y in range(60, 210):
		var t = float(y - 60) / 150.0
		var half_w = lerp(48.0, 22.0, t)
		var center_gx = 110.0
		for x in range(int(center_gx - half_w - 6), int(center_gx + half_w + 7)):
			var dist_to_edge = abs(abs(x - center_gx) - half_w)
			if dist_to_edge <= 4.0 and y <= 180:
				# Glass rim/sides
				img.set_pixel(x, y, cyan.lerp(white_core, 0.6))
			elif y > 180 and y <= 200 and abs(x - center_gx) <= 6.0:
				# Stem
				img.set_pixel(x, y, cyan)
			elif y > 200 and y <= 210 and abs(x - center_gx) <= 32.0:
				# Base
				img.set_pixel(x, y, cyan.lerp(white_core, 0.5))
			elif y > 75 and y < 178 and abs(x - center_gx) < half_w - 3.0:
				# Milkshake fill: sweet pink
				var wave = sin(x * 0.15) * 4.0
				if y > 88 + wave:
					img.set_pixel(x, y, Color(1.0, 0.45, 0.68, 0.85))
				else:
					# Whipped cream top
					img.set_pixel(x, y, Color(1.0, 1.0, 0.95, 0.95))

	# Cherry on top at (110, 52)
	for y in range(44, 62):
		for x in range(100, 120):
			if Vector2(x - 110, y - 53).length() <= 8.0:
				img.set_pixel(x, y, pink.lerp(white_core, 0.4))
				
	# Straw sticking out from (120, 80) to (145, 30)
	for step in range(60):
		var st = step / 60.0
		var sx = int(lerp(118.0, 150.0, st))
		var sy = int(lerp(82.0, 28.0, st))
		for dy in range(-2, 3):
			for dx in range(-2, 3):
				if sx + dx >= 0 and sx + dx < w and sy + dy >= 0 and sy + dy < h:
					img.set_pixel(sx + dx, sy + dy, yellow)

	# Neon Text Area: "The Milk Shake" on the right (x=180 to 490)
	# Draw script neon lines
	var text_coords = [
		# "THE" header
		Rect2(200, 48, 70, 8), Rect2(230, 48, 8, 40), # T
		Rect2(285, 48, 8, 40), Rect2(315, 48, 8, 40), Rect2(285, 66, 38, 8), # H
		Rect2(335, 48, 8, 40), Rect2(335, 48, 35, 8), Rect2(335, 65, 28, 8), Rect2(335, 80, 35, 8), # E
		# "MILK"
		Rect2(200, 110, 8, 55), Rect2(200, 110, 25, 8), Rect2(225, 110, 8, 55), Rect2(225, 110, 25, 8), Rect2(250, 110, 8, 55), # M
		Rect2(268, 110, 8, 55), # I
		Rect2(286, 110, 8, 55), Rect2(286, 157, 35, 8), # L
		Rect2(330, 110, 8, 55), Rect2(330, 134, 30, 8), Rect2(352, 110, 8, 25), Rect2(352, 140, 8, 25), # K
		# "SHAKE"
		Rect2(195, 185, 45, 7), Rect2(195, 185, 8, 24), Rect2(195, 204, 45, 7), Rect2(232, 204, 8, 24), Rect2(195, 222, 45, 7), # S
		Rect2(252, 185, 8, 44), Rect2(285, 185, 8, 44), Rect2(252, 204, 38, 7), # H
		Rect2(300, 185, 8, 44), Rect2(332, 185, 8, 44), Rect2(300, 185, 38, 7), Rect2(300, 206, 38, 7), # A
		Rect2(348, 185, 8, 44), Rect2(348, 204, 28, 7), Rect2(370, 185, 8, 20), Rect2(370, 210, 8, 20), # K
		Rect2(388, 185, 8, 44), Rect2(388, 185, 32, 7), Rect2(388, 204, 24, 7), Rect2(388, 222, 32, 7) # E
	]
	for r in text_coords:
		for ty in range(int(r.position.y), int(r.position.y + r.size.y)):
			for tx in range(int(r.position.x), int(r.position.x + r.size.x)):
				if tx >= 0 and tx < w and ty >= 0 and ty < h:
					img.set_pixel(tx, ty, pink.lerp(white_core, 0.7))

	var save_path = "res://assets/textures/the_milk_shake_neon.png"
	var global_path = ProjectSettings.globalize_path(save_path)
	var err = img.save_png(global_path)
	print("The Milk Shake neon generated, result:", err)

func _make_vinyl_record_texture() -> void:
	var size: int = 256
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	var center = size * 0.5
	var outer_r = 120.0
	var label_r = 46.0
	var spindle_r = 9.0
	
	for y in range(size):
		for x in range(size):
			var dist = Vector2(x - center, y - center).length()
			if dist <= outer_r:
				if dist <= spindle_r:
					# Spindle center hole
					img.set_pixel(x, y, Color(0, 0, 0, 0))
				elif dist <= label_r:
					# Record center label: bright retro red / gold rim
					if dist >= label_r - 4.0:
						img.set_pixel(x, y, Color(0.9, 0.78, 0.25, 1.0))
					else:
						img.set_pixel(x, y, Color(0.88, 0.18, 0.24, 1.0))
				else:
					# Vinyl grooves
					var groove = sin(dist * 1.8) * 0.08
					var col_val = 0.08 + groove
					img.set_pixel(x, y, Color(col_val, col_val, col_val + 0.015, 1.0))

	var save_path = "res://assets/textures/vinyl_record.png"
	var global_path = ProjectSettings.globalize_path(save_path)
	var err = img.save_png(global_path)
	print("Vinyl record generated, result:", err)


