import cv2
import numpy as np
import os
import math

OUT_DIR = "restaurant_tycoon_3d/assets/textures"
os.makedirs(OUT_DIR, exist_ok=True)

# 1. Circular Bubble: Fork & Knife (Dining order ready / eating, 1:1 with mobile casual finish)
def create_bubble_fork_knife():
    size = 256
    img = np.zeros((size, size, 4), dtype=np.uint8)
    cx, cy = 128, 110
    r = 86
    ang1, ang2 = 128, 82

    rad1 = math.radians(ang1)
    rad2 = math.radians(ang2)

    p1 = (int(round(cx + r * math.cos(rad1))), int(round(cy + r * math.sin(rad1))))
    p2 = (int(round(cx + r * math.cos(rad2))), int(round(cy + r * math.sin(rad2))))
    p_tip = (54, 226)

    # 1. Base silhouette mask
    base_mask = np.zeros((size, size), dtype=np.uint8)
    cv2.circle(base_mask, (cx, cy), r, 255, -1)
    tail_pts = np.array([p1, p_tip, p2], np.int32)
    cv2.fillConvexPoly(base_mask, tail_pts, 255)

    # 2. Bold drop shadow with Gaussian blur (stands out sharply against checkerboard floor)
    s_off = (5, 11)
    shadow_raw = np.zeros((size, size), dtype=np.float32)
    cv2.circle(shadow_raw, (cx + s_off[0], cy + s_off[1]), r + 3, 1.0, -1)
    s_pts = np.array([(p1[0] + s_off[0], p1[1] + s_off[1]),
                     (p_tip[0] + s_off[0], p_tip[1] + s_off[1]),
                     (p2[0] + s_off[0], p2[1] + s_off[1])], np.int32)
    cv2.fillConvexPoly(shadow_raw, s_pts, 1.0)
    shadow_blurred = cv2.GaussianBlur(shadow_raw, (17, 17), 5.5)

    shadow_alpha = np.clip(shadow_blurred * 175.0, 0, 255).astype(np.uint8)
    img[:, :, 0] = 12
    img[:, :, 1] = 12
    img[:, :, 2] = 16
    img[:, :, 3] = shadow_alpha

    # 3. Thick 8px white outer ring / boundary
    kernel_8px = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (9, 9))
    outer_white_mask = cv2.dilate(base_mask, kernel_8px)
    img[outer_white_mask > 0] = (255, 255, 255, 255)

    # 4. Bubble interior & contrasting 2px slate border inside the 8px white outer ring
    border_col = (75, 88, 104, 255)
    inner_rim_col = (228, 235, 242, 255)

    cv2.ellipse(img, (cx, cy), (r - 4, r - 4), 0, ang1, 360 + ang2, inner_rim_col, 4, cv2.LINE_AA)
    cv2.ellipse(img, (cx, cy), (r - 4, r - 4), 0, ang1, 360 + ang2, border_col, 2, cv2.LINE_AA)
    cv2.line(img, (int(round(cx + (r - 4) * math.cos(rad1))), int(round(cy + (r - 4) * math.sin(rad1)))), (p_tip[0] + 4, p_tip[1] - 6), border_col, 2, cv2.LINE_AA)
    cv2.line(img, (p_tip[0] + 4, p_tip[1] - 6), (int(round(cx + (r - 4) * math.cos(rad2))), int(round(cy + (r - 4) * math.sin(rad2)))), border_col, 2, cv2.LINE_AA)

    # Thick 8px pure white outer ring around the perimeter
    cv2.ellipse(img, (cx, cy), (r, r), 0, ang1, 360 + ang2, (255, 255, 255, 255), 8, cv2.LINE_AA)
    cv2.line(img, p1, p_tip, (255, 255, 255, 255), 8, cv2.LINE_AA)
    cv2.line(img, p_tip, p2, (255, 255, 255, 255), 8, cv2.LINE_AA)

    # Fork on left (charcoal/dark slate grey matching reference)
    icon_color = (48, 54, 62, 255)
    # Handle
    cv2.line(img, (96, 166), (96, 108), icon_color, 7, cv2.LINE_AA)
    cv2.circle(img, (96, 166), 5, icon_color, -1, cv2.LINE_AA)
    # Tines base
    cv2.ellipse(img, (96, 108), (16, 11), 0, 0, 180, icon_color, -1, cv2.LINE_AA)
    # 3 Tines
    for tx in [84, 96, 108]:
        cv2.line(img, (tx, 108), (tx, 72), icon_color, 4, cv2.LINE_AA)

    # Knife on right (charcoal/dark slate grey)
    # Handle
    cv2.line(img, (158, 166), (158, 114), icon_color, 7, cv2.LINE_AA)
    cv2.circle(img, (158, 166), 5, icon_color, -1, cv2.LINE_AA)
    # Blade
    pts = np.array([[155, 114], [162, 114], [166, 72], [155, 72]], np.int32)
    cv2.fillConvexPoly(img, pts, icon_color)
    cv2.ellipse(img, (160, 72), (6, 9), 0, 180, 360, icon_color, -1, cv2.LINE_AA)

    cv2.imwrite(os.path.join(OUT_DIR, "bubble_fork_knife.png"), img)
    print("Created bubble_fork_knife.png")

# 2. Circular Bubble: Hourglass (Waiting for food / service, 1:1 with mobile casual finish)
def create_bubble_hourglass():
    size = 256
    img = np.zeros((size, size, 4), dtype=np.uint8)
    cx, cy = 128, 110
    r = 86
    ang1, ang2 = 128, 82

    rad1 = math.radians(ang1)
    rad2 = math.radians(ang2)

    p1 = (int(round(cx + r * math.cos(rad1))), int(round(cy + r * math.sin(rad1))))
    p2 = (int(round(cx + r * math.cos(rad2))), int(round(cy + r * math.sin(rad2))))
    p_tip = (54, 226)

    # 1. Base silhouette mask
    base_mask = np.zeros((size, size), dtype=np.uint8)
    cv2.circle(base_mask, (cx, cy), r, 255, -1)
    tail_pts = np.array([p1, p_tip, p2], np.int32)
    cv2.fillConvexPoly(base_mask, tail_pts, 255)

    # 2. Bold drop shadow with Gaussian blur
    s_off = (5, 11)
    shadow_raw = np.zeros((size, size), dtype=np.float32)
    cv2.circle(shadow_raw, (cx + s_off[0], cy + s_off[1]), r + 3, 1.0, -1)
    s_pts = np.array([(p1[0] + s_off[0], p1[1] + s_off[1]),
                     (p_tip[0] + s_off[0], p_tip[1] + s_off[1]),
                     (p2[0] + s_off[0], p2[1] + s_off[1])], np.int32)
    cv2.fillConvexPoly(shadow_raw, s_pts, 1.0)
    shadow_blurred = cv2.GaussianBlur(shadow_raw, (17, 17), 5.5)

    shadow_alpha = np.clip(shadow_blurred * 175.0, 0, 255).astype(np.uint8)
    img[:, :, 0] = 12
    img[:, :, 1] = 12
    img[:, :, 2] = 16
    img[:, :, 3] = shadow_alpha

    # 3. Thick 8px white outer ring / boundary
    kernel_8px = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (9, 9))
    outer_white_mask = cv2.dilate(base_mask, kernel_8px)
    img[outer_white_mask > 0] = (255, 255, 255, 255)

    # 4. Bubble interior & contrasting 2px slate border inside the 8px white outer ring
    border_col = (75, 88, 104, 255)
    inner_rim_col = (228, 235, 242, 255)

    cv2.ellipse(img, (cx, cy), (r - 4, r - 4), 0, ang1, 360 + ang2, inner_rim_col, 4, cv2.LINE_AA)
    cv2.ellipse(img, (cx, cy), (r - 4, r - 4), 0, ang1, 360 + ang2, border_col, 2, cv2.LINE_AA)
    cv2.line(img, (int(round(cx + (r - 4) * math.cos(rad1))), int(round(cy + (r - 4) * math.sin(rad1)))), (p_tip[0] + 4, p_tip[1] - 6), border_col, 2, cv2.LINE_AA)
    cv2.line(img, (p_tip[0] + 4, p_tip[1] - 6), (int(round(cx + (r - 4) * math.cos(rad2))), int(round(cy + (r - 4) * math.sin(rad2)))), border_col, 2, cv2.LINE_AA)

    # Thick 8px pure white outer ring around the perimeter
    cv2.ellipse(img, (cx, cy), (r, r), 0, ang1, 360 + ang2, (255, 255, 255, 255), 8, cv2.LINE_AA)
    cv2.line(img, p1, p_tip, (255, 255, 255, 255), 8, cv2.LINE_AA)
    cv2.line(img, p_tip, p2, (255, 255, 255, 255), 8, cv2.LINE_AA)

    # Hourglass Frame (Warm mahogany/brass wood)
    frame_color = (35, 75, 155, 255)
    cv2.rectangle(img, (84, 62), (172, 74), frame_color, -1)
    cv2.rectangle(img, (84, 156), (172, 168), frame_color, -1)
    
    # Glass Bulbs
    glass_color = (248, 242, 230, 220)
    top_glass = np.array([[94, 74], [162, 74], [134, 114], [122, 114]], np.int32)
    bot_glass = np.array([[122, 114], [134, 114], [162, 156], [94, 156]], np.int32)
    cv2.fillConvexPoly(img, top_glass, glass_color)
    cv2.fillConvexPoly(img, bot_glass, glass_color)

    # Golden-Yellow Sand
    sand_color = (25, 185, 245, 255)
    top_sand = np.array([[104, 92], [152, 92], [132, 114], [124, 114]], np.int32)
    cv2.fillConvexPoly(img, top_sand, sand_color)
    # Stream
    cv2.line(img, (128, 112), (128, 136), sand_color, 3)
    # Bottom sand pile
    bot_sand = np.array([[102, 156], [154, 156], [140, 132], [116, 132]], np.int32)
    cv2.fillConvexPoly(img, bot_sand, sand_color)

    # Glass outline
    cv2.polylines(img, [top_glass], True, (140, 150, 160, 255), 2)
    cv2.polylines(img, [bot_glass], True, (140, 150, 160, 255), 2)

    cv2.imwrite(os.path.join(OUT_DIR, "bubble_hourglass.png"), img)
    print("Created bubble_hourglass.png")

# 3. Floating Green Cash Stack Graphic (High-contrast mobile sticker finish)
def create_floating_cash_badge():
    w, h = 320, 200
    canvas = np.zeros((h, w, 4), dtype=np.uint8)

    center = (w // 2, h // 2)
    angle = -12.0

    bw, bh = 220, 96
    bx, by = (w - bw) // 2, (h - bh) // 2

    # Overall mask of bills stack
    stack_mask = np.zeros((h, w), dtype=np.uint8)
    cv2.rectangle(stack_mask, (bx - 8, by), (bx + bw, by + bh + 8), 255, -1)

    # Bold Drop Shadow with soft Gaussian blur
    s_off = (6, 12)
    shadow_raw = np.zeros((h, w), dtype=np.float32)
    cv2.rectangle(shadow_raw, (bx - 8 + s_off[0], by + s_off[1]), (bx + bw + s_off[0], by + bh + 8 + s_off[1]), 1.0, -1)
    shadow_blurred = cv2.GaussianBlur(shadow_raw, (19, 19), 6.0)
    shadow_alpha = np.clip(shadow_blurred * 185.0, 0, 255).astype(np.uint8)

    canvas[:, :, 0] = 10
    canvas[:, :, 1] = 12
    canvas[:, :, 2] = 14
    canvas[:, :, 3] = shadow_alpha

    # Thick 8px white outer ring / die-cut boundary around the stack
    kernel_8px = cv2.getStructuringElement(cv2.MORPH_RECT, (17, 17))
    outer_white_mask = cv2.dilate(stack_mask, kernel_8px)
    canvas[outer_white_mask > 0] = (255, 255, 255, 255)

    # Layer 1: Bottom bill (dark green base)
    cv2.rectangle(canvas, (bx - 8, by + 6), (bx + bw - 8, by + bh + 6), (32, 118, 46, 255), -1)
    cv2.rectangle(canvas, (bx - 8, by + 6), (bx + bw - 8, by + bh + 6), (55, 168, 75, 255), 2)

    # Layer 2: Middle bill
    cv2.rectangle(canvas, (bx - 4, by + 3), (bx + bw - 4, by + bh + 3), (42, 142, 60, 255), -1)
    cv2.rectangle(canvas, (bx - 4, by + 3), (bx + bw - 4, by + bh + 3), (80, 202, 104, 255), 2)

    # Layer 3: Top crisp emerald bill
    cv2.rectangle(canvas, (bx, by), (bx + bw, by + bh), (52, 180, 78, 255), -1)
    cv2.rectangle(canvas, (bx + 6, by + 6), (bx + bw - 6, by + bh - 6), (195, 250, 210, 255), 3)

    # Center white currency oval
    cv2.ellipse(canvas, (bx + bw // 2, by + bh // 2), (48, 34), 0, 0, 360, (255, 255, 255, 255), -1)
    cv2.ellipse(canvas, (bx + bw // 2, by + bh // 2), (48, 34), 0, 0, 360, (195, 250, 210, 255), 2)

    # Currency Dollar Symbol $
    cv2.putText(canvas, '$', (bx + bw // 2 - 14, by + bh // 2 + 16), cv2.FONT_HERSHEY_DUPLEX, 1.8, (42, 150, 62, 255), 4, cv2.LINE_AA)

    # Corner security dots
    for cx, cy in [(bx + 18, by + 18), (bx + bw - 18, by + 18), (bx + 18, by + bh - 18), (bx + bw - 18, by + bh - 18)]:
        cv2.circle(canvas, (cx, cy), 6, (215, 255, 225, 255), -1)
        cv2.circle(canvas, (cx, cy), 2, (52, 180, 78, 255), -1)

    # Rotate canvas
    M = cv2.getRotationMatrix2D(center, angle, 1.0)
    img = cv2.warpAffine(canvas, M, (w, h), flags=cv2.INTER_LINEAR, borderMode=cv2.BORDER_CONSTANT, borderValue=(0, 0, 0, 0))

    cv2.imwrite(os.path.join(OUT_DIR, "bubble_cash_stack.png"), img)
    print("Created bubble_cash_stack.png")

# 4. Iconic 1950s Retro Jukebox Front Texture (Wurlitzer 1015 style)
def create_jukebox_texture():
    w, h = 512, 768
    img = np.zeros((h, w, 4), dtype=np.uint8)

    # Outer mahogany arch cabinet
    cv2.rectangle(img, (30, 220), (482, 740), (25, 35, 110, 255), -1) # Dark red mahogany
    cv2.ellipse(img, (256, 230), (226, 210), 0, 180, 360, (25, 35, 110, 255), -1)

    # Outer chrome piping
    cv2.ellipse(img, (256, 230), (226, 210), 0, 180, 360, (220, 230, 240, 255), 14)
    cv2.line(img, (30, 230), (30, 740), (220, 230, 240, 255), 14)
    cv2.line(img, (482, 230), (482, 740), (220, 230, 240, 255), 14)

    # Glowing Neon Arch (Yellow to Magenta to Cyan gradient / vibrant glow)
    neon_colors = [
        (40, 220, 255, 255),  # Yellow
        (60, 140, 255, 255),  # Amber/Orange
        (180, 50, 255, 255),  # Magenta
        (255, 180, 40, 255),  # Cyan
    ]
    for i, col in enumerate(neon_colors):
        rad = 196 - i * 16
        cv2.ellipse(img, (256, 230), (rad, int(rad * 0.92)), 0, 180, 360, col, 12)
        cv2.line(img, (256 - rad, 230), (256 - rad, 520), col, 12)
        cv2.line(img, (256 + rad, 230), (256 + rad, 520), col, 12)

    # Center Glass Turntable Dome (Light cyan transparent)
    cv2.ellipse(img, (256, 230), (130, 115), 0, 180, 360, (240, 250, 255, 240), -1)
    cv2.ellipse(img, (256, 230), (130, 115), 0, 180, 360, (180, 190, 205, 255), 6)

    # Vinyl Record inside the dome
    cv2.circle(img, (256, 220), 75, (20, 20, 20, 255), -1)
    cv2.circle(img, (256, 220), 30, (30, 40, 180, 255), -1) # Red record label
    cv2.circle(img, (256, 220), 8, (230, 230, 230, 255), -1) # Spindle hole

    # Title Strip / Song Selector Display
    cv2.rectangle(img, (110, 290), (402, 410), (240, 245, 230, 255), -1)
    cv2.rectangle(img, (110, 290), (402, 410), (180, 170, 140, 255), 4)
    for y_line in range(310, 400, 16):
        cv2.line(img, (125, y_line), (387, y_line), (80, 120, 90, 255), 2)
        cv2.putText(img, "JUKEBOX HITS", (170, y_line - 2), cv2.FONT_HERSHEY_SIMPLEX, 0.35, (40, 60, 50, 255), 1)

    # Push-button selector strip
    for bx in range(125, 390, 28):
        cv2.rectangle(img, (bx, 420), (bx + 18, 442), (245, 80, 50, 255), -1) # Red button
        cv2.rectangle(img, (bx, 420), (bx + 18, 442), (230, 230, 240, 255), 2)

    # Lower Speaker Grille (Polished vertical chrome bars on dark gold fabric)
    cv2.rectangle(img, (90, 465), (422, 715), (20, 60, 120, 255), -1) # Gold amber mesh
    # Chrome vertical bars
    for gx in range(105, 415, 22):
        cv2.line(img, (gx, 465), (gx, 715), (225, 235, 245, 255), 6)
        cv2.line(img, (gx, 465), (gx, 715), (140, 150, 165, 255), 2)

    # Front emblem / logo crest
    cv2.ellipse(img, (256, 590), (55, 35), 0, 0, 360, (30, 180, 255, 255), -1)
    cv2.ellipse(img, (256, 590), (55, 35), 0, 0, 360, (240, 245, 255, 255), 4)
    cv2.putText(img, "WURLITZER", (215, 595), cv2.FONT_HERSHEY_SIMPLEX, 0.45, (255, 255, 255, 255), 1)

    # Chrome bottom kickplate
    cv2.rectangle(img, (30, 720), (482, 755), (200, 215, 225, 255), -1)

    cv2.imwrite(os.path.join(OUT_DIR, "jukebox_facade.png"), img)
    print("Created jukebox_facade.png")

# 5. Multi-Tier Back-Bar Liquor & Wine Shelf Texture
def create_lounge_shelf_texture():
    w, h = 512, 512
    img = np.zeros((h, w, 4), dtype=np.uint8)

    # Dark mahogany backing with warm amber ambient glow
    img[:, :] = (20, 25, 65, 255) # Dark cherry wood
    # Soft warm back-glow in center
    cv2.ellipse(img, (256, 256), (220, 200), 0, 0, 360, (40, 75, 140, 255), -1)

    # 3 Wood shelves
    for sy in [150, 300, 450]:
        cv2.rectangle(img, (20, sy), (492, sy + 22), (30, 45, 105, 255), -1)
        cv2.rectangle(img, (20, sy), (492, sy + 22), (70, 100, 180, 255), 2) # Highlight edge

    # Colorful bottles on shelves
    bottle_colors = [
        (30, 180, 245, 255),  # Whiskey / Amber
        (50, 140, 50, 255),   # Gin / Green
        (40, 40, 180, 255),   # Red wine / Burgundy
        (220, 140, 30, 255),  # Curacao / Blue
        (40, 200, 180, 255),  # Champagne / Gold
        (180, 50, 210, 255),  # Aperol / Violet
        (220, 220, 230, 255), # Vodka / Crystal
    ]

    import random
    random.seed(42)

    for sy in [150, 300, 450]:
        bx = 40
        while bx < 470:
            bw = random.choice([16, 20, 24])
            bh = random.choice([55, 70, 85])
            col = random.choice(bottle_colors)
            
            # Bottle body
            cv2.rectangle(img, (bx, sy - bh), (bx + bw, sy), col, -1)
            cv2.rectangle(img, (bx, sy - bh), (bx + bw, sy), (240, 240, 255, 120), 1)
            # Neck
            nw = max(6, bw // 3)
            nx = bx + (bw - nw) // 2
            nh = random.choice([20, 28])
            cv2.rectangle(img, (nx, sy - bh - nh), (nx + nw, sy - bh), col, -1)
            # Cap / Cork
            cv2.rectangle(img, (nx - 1, sy - bh - nh - 6), (nx + nw + 1, sy - bh - nh), (40, 70, 160, 255), -1)
            # Label
            cv2.rectangle(img, (bx + 2, sy - int(bh * 0.65)), (bx + bw - 2, sy - int(bh * 0.25)), (230, 235, 240, 240), -1)

            bx += bw + random.choice([8, 12, 16])

    cv2.imwrite(os.path.join(OUT_DIR, "lounge_shelf_bottles.png"), img)
    print("Created lounge_shelf_bottles.png")

# 6. Framed Chalkboard Menu Texture
def create_chalkboard_texture():
    w, h = 512, 384
    img = np.zeros((h, w, 4), dtype=np.uint8)

    # Oak frame
    cv2.rectangle(img, (0, 0), (w, h), (40, 70, 140, 255), -1)
    cv2.rectangle(img, (18, 18), (w - 18, h - 18), (25, 45, 90, 255), 4)

    # Dark slate chalkboard interior
    cv2.rectangle(img, (22, 22), (w - 22, h - 22), (45, 48, 46, 255), -1)

    # Chalk header
    cv2.putText(img, "~ SPECIALS ~", (140, 68), cv2.FONT_HERSHEY_DUPLEX, 1.1, (240, 245, 240, 255), 2, cv2.LINE_AA)
    cv2.line(img, (110, 82), (400, 82), (200, 210, 200, 255), 2)

    # Chalk items
    items = [
        ("Classic Burger", "$8.50"),
        ("Milkshake Shake", "$4.75"),
        ("Cherry Soda", "$3.00"),
        ("Crispy Fries", "$3.50"),
        ("House Cocktail", "$9.00"),
    ]
    y = 125
    for name, price in items:
        cv2.putText(img, name, (55, y), cv2.FONT_HERSHEY_SIMPLEX, 0.75, (230, 235, 230, 255), 2, cv2.LINE_AA)
        cv2.putText(img, ". . . . . . . . . . . .", (220, y), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (140, 150, 140, 255), 1, cv2.LINE_AA)
        cv2.putText(img, price, (415, y), cv2.FONT_HERSHEY_DUPLEX, 0.75, (100, 230, 140, 255), 2, cv2.LINE_AA)
        y += 44

    cv2.imwrite(os.path.join(OUT_DIR, "chalkboard_menu.png"), img)
    print("Created chalkboard_menu.png")

# 7. Dark Industrial Lockers Wall Texture
def create_lockers_texture():
    w, h = 512, 384
    img = np.zeros((h, w, 4), dtype=np.uint8)

    # Dark charcoal base
    img[:, :] = (35, 38, 42, 255)

    num_lockers = 6
    locker_w = w / num_lockers
    for i in range(num_lockers):
        lx = int(i * locker_w)
        rx = int((i + 1) * locker_w)
        # Door bevel
        cv2.rectangle(img, (lx + 4, 12), (rx - 4, h - 12), (45, 50, 56, 255), -1)
        cv2.rectangle(img, (lx + 4, 12), (rx - 4, h - 12), (20, 22, 25, 255), 2)

        # Ventilation louvers (slits) at top
        for vy in range(35, 90, 10):
            cv2.line(img, (lx + 16, vy), (rx - 16, vy), (20, 22, 25, 255), 3)
            cv2.line(img, (lx + 16, vy + 2), (rx - 16, vy + 2), (70, 75, 82, 255), 1)

        # Ventilation louvers at bottom
        for vy in range(h - 80, h - 35, 10):
            cv2.line(img, (lx + 16, vy), (rx - 16, vy), (20, 22, 25, 255), 3)
            cv2.line(img, (lx + 16, vy + 2), (rx - 16, vy + 2), (70, 75, 82, 255), 1)

        # Handle and padlock recess
        cx = rx - 18
        cy = h // 2
        cv2.rectangle(img, (cx - 4, cy - 20), (cx + 4, cy + 20), (180, 190, 200, 255), -1)
        cv2.circle(img, (cx, cy + 4), 5, (80, 90, 100, 255), -1)
        # Locker Number tag
        cv2.rectangle(img, (int((lx + rx) / 2) - 12, 115), (int((lx + rx) / 2) + 12, 130), (220, 225, 230, 255), -1)

    cv2.imwrite(os.path.join(OUT_DIR, "lockers_wall.png"), img)
    print("Created lockers_wall.png")

# 8. Large Rectangular Crimson Kitchen Pass Runner
def create_kitchen_pass_rug():
    w, h = 512, 256
    img = np.zeros((h, w, 4), dtype=np.uint8)

    # Gold outer fringe border
    cv2.rectangle(img, (8, 8), (w - 8, h - 8), (40, 160, 210, 255), -1) # Gold
    # Inner gold line
    cv2.rectangle(img, (24, 24), (w - 24, h - 24), (20, 120, 170, 255), 3)

    # Deep rich royal crimson / burgundy body
    cv2.rectangle(img, (32, 32), (w - 32, h - 32), (35, 20, 140, 255), -1)

    # Subtle inner embossed pattern
    cv2.rectangle(img, (48, 48), (w - 48, h - 48), (55, 30, 175, 255), 4)

    cv2.imwrite(os.path.join(OUT_DIR, "kitchen_pass_rug.png"), img)
    print("Created kitchen_pass_rug.png")

# 9. High-Fidelity Diamond Icon (256x256 faceted cyan/blue gem with specular highlights)
def create_icon_diamond():
    size = 256
    img = np.zeros((size, size, 4), dtype=np.uint8)

    shadow_mask = np.zeros((size, size), dtype=np.uint8)
    cv2.ellipse(shadow_mask, (128, 230), (55, 14), 0, 0, 360, 255, -1)
    shadow_blur = cv2.GaussianBlur(shadow_mask, (21, 21), 0)
    img[shadow_blur > 0] = (0, 0, 0, 60)

    p_tl = (84, 52)
    p_tr = (172, 52)
    p_gl = (32, 112)
    p_gr = (224, 112)
    p_tip = (128, 224)

    t_tl = (96, 76)
    t_tr = (160, 76)
    t_bl = (112, 112)
    t_br = (144, 112)
    t_top_m = (128, 52)

    table_pts = np.array([t_tl, t_tr, t_br, t_bl], np.int32)
    cv2.fillConvexPoly(img, table_pts, (255, 245, 215, 255))

    top_kite_pts = np.array([p_tl, t_top_m, t_tr, t_tl], np.int32)
    cv2.fillConvexPoly(img, top_kite_pts, (255, 235, 180, 255))
    top_kite_pts2 = np.array([t_tl, t_top_m, p_tr, t_tr], np.int32)
    cv2.fillConvexPoly(img, top_kite_pts2, (250, 220, 150, 255))

    cv2.fillConvexPoly(img, np.array([p_tl, t_tl, p_gl], np.int32), (245, 205, 120, 255))
    cv2.fillConvexPoly(img, np.array([p_tr, t_tr, p_gr], np.int32), (225, 175, 70, 255))

    cv2.fillConvexPoly(img, np.array([t_tl, t_bl, p_gl], np.int32), (255, 220, 140, 255))
    cv2.fillConvexPoly(img, np.array([t_tr, t_br, p_gr], np.int32), (230, 185, 80, 255))

    cv2.fillConvexPoly(img, np.array([p_gl, t_bl, (90, 112)], np.int32), (235, 190, 90, 255))
    cv2.fillConvexPoly(img, np.array([p_gr, t_br, (166, 112)], np.int32), (210, 160, 60, 255))

    cv2.fillConvexPoly(img, np.array([p_gl, (78, 112), p_tip], np.int32), (210, 155, 50, 255))
    cv2.fillConvexPoly(img, np.array([(78, 112), t_bl, p_tip], np.int32), (245, 200, 95, 255))
    cv2.fillConvexPoly(img, np.array([t_bl, (128, 112), p_tip], np.int32), (255, 225, 130, 255))
    cv2.fillConvexPoly(img, np.array([(128, 112), t_br, p_tip], np.int32), (235, 190, 85, 255))
    cv2.fillConvexPoly(img, np.array([t_br, (178, 112), p_tip], np.int32), (215, 165, 60, 255))
    cv2.fillConvexPoly(img, np.array([(178, 112), p_gr, p_tip], np.int32), (185, 130, 30, 255))

    facet_lines = [
        (p_gl, p_gr), (p_tl, p_tr), (p_tr, p_gr), (p_gr, p_tip), (p_tip, p_gl), (p_gl, p_tl),
        (t_tl, t_tr), (t_tr, t_br), (t_br, t_bl), (t_bl, t_tl),
        (p_tl, t_tl), (p_tr, t_tr), (t_top_m, t_tl), (t_top_m, t_tr),
        (p_gl, t_tl), (p_gl, t_bl), (p_gr, t_tr), (p_gr, t_br),
        (t_bl, p_tip), ((128, 112), p_tip), (t_br, p_tip),
        ((78, 112), p_tip), ((178, 112), p_tip)
    ]
    for p1, p2 in facet_lines:
        cv2.line(img, p1, p2, (255, 255, 255, 140), 1, cv2.LINE_AA)

    outer_poly = np.array([p_tl, p_tr, p_gr, p_tip, p_gl], np.int32)
    cv2.polylines(img, [outer_poly], True, (130, 60, 10, 255), 2, cv2.LINE_AA)

    cx, cy = 94, 72
    for r in range(1, 14):
        alpha = int(255 * (1.0 - r / 14.0))
        cv2.line(img, (cx - r, cy), (cx + r, cy), (255, 255, 255, alpha), 2, cv2.LINE_AA)
        cv2.line(img, (cx, cy - r), (cx, cy + r), (255, 255, 255, alpha), 2, cv2.LINE_AA)
    cv2.circle(img, (cx, cy), 3, (255, 255, 255, 255), -1)

    cv2.imwrite(os.path.join(OUT_DIR, "icon_diamond.png"), img)
    print("Created icon_diamond.png")

# 10. High-Fidelity Gold Coin Icon (256x256 embossed golden coin with star emblem)
def create_icon_gold_coin():
    size = 256
    img = np.zeros((size, size, 4), dtype=np.uint8)
    cx, cy = 128, 128

    shadow_mask = np.zeros((size, size), dtype=np.uint8)
    cv2.circle(shadow_mask, (cx + 3, cy + 6), 96, 255, -1)
    shadow_blur = cv2.GaussianBlur(shadow_mask, (19, 19), 0)
    img[shadow_blur > 0] = (0, 0, 0, 75)

    cv2.circle(img, (cx, cy), 96, (20, 130, 200, 255), -1)
    cv2.circle(img, (cx, cy), 91, (50, 210, 255, 255), -1)

    num_ticks = 48
    for i in range(num_ticks):
        angle = 2.0 * math.pi * i / num_ticks
        x1 = int(cx + 83 * math.cos(angle))
        y1 = int(cy + 83 * math.sin(angle))
        x2 = int(cx + 91 * math.cos(angle))
        y2 = int(cy + 91 * math.sin(angle))
        cv2.line(img, (x1, y1), (x2, y2), (25, 140, 210, 255), 2, cv2.LINE_AA)

    cv2.circle(img, (cx, cy), 82, (15, 120, 185, 255), -1)
    cv2.circle(img, (cx, cy), 78, (35, 185, 248, 255), -1)
    cv2.ellipse(img, (cx, cy), (78, 78), 0, 200, 340, (100, 235, 255, 255), 3, cv2.LINE_AA)
    cv2.ellipse(img, (cx, cy), (78, 78), 0, 20, 160, (15, 120, 180, 255), 3, cv2.LINE_AA)

    pts_outer, pts_inner = [], []
    r_outer, r_inner = 48, 21
    for i in range(5):
        ang_out = -math.pi / 2.0 + (i * 2.0 * math.pi / 5.0)
        pts_outer.append((int(round(cx + r_outer * math.cos(ang_out))), int(round(cy + r_outer * math.sin(ang_out)))))
        ang_in = ang_out + (math.pi / 5.0)
        pts_inner.append((int(round(cx + r_inner * math.cos(ang_in))), int(round(cy + r_inner * math.sin(ang_in)))))

    for i in range(5):
        p_tip = pts_outer[i]
        p_left_valley = pts_inner[(i - 1) % 5]
        p_right_valley = pts_inner[i]
        facet_bright = np.array([(cx, cy), p_left_valley, p_tip], np.int32)
        cv2.fillConvexPoly(img, facet_bright, (100, 235, 255, 255))
        facet_shadow = np.array([(cx, cy), p_tip, p_right_valley], np.int32)
        cv2.fillConvexPoly(img, facet_shadow, (15, 135, 195, 255))

    cv2.circle(img, (cx, cy), 6, (80, 220, 255, 255), -1)
    gx, gy = 180, 72
    for r in range(1, 16):
        alpha = int(255 * (1.0 - r / 16.0))
        cv2.line(img, (gx - r, gy), (gx + r, gy), (255, 255, 255, alpha), 2, cv2.LINE_AA)
        cv2.line(img, (gx, gy - r), (gx, gy + r), (255, 255, 255, alpha), 2, cv2.LINE_AA)
    cv2.circle(img, (gx, gy), 4, (255, 255, 255, 255), -1)

    cv2.imwrite(os.path.join(OUT_DIR, "icon_gold_coin.png"), img)
    print("Created icon_gold_coin.png")

# 11. High-Fidelity Energy Lightning Icon (256x256 vibrant yellow lightning bolt)
def create_icon_energy():
    size = 256
    img = np.zeros((size, size, 4), dtype=np.uint8)

    bolt_pts = np.array([[158, 22], [72, 134], [122, 134], [94, 234], [184, 112], [134, 112]], np.int32)
    shadow_mask = np.zeros((size, size), dtype=np.uint8)
    cv2.fillPoly(shadow_mask, [bolt_pts + np.array([4, 6])], 255)
    shadow_blur = cv2.GaussianBlur(shadow_mask, (15, 15), 0)
    img[shadow_blur > 0] = (0, 0, 0, 70)

    glow_mask = np.zeros((size, size), dtype=np.uint8)
    cv2.fillPoly(glow_mask, [bolt_pts], 255)
    glow_dilated = cv2.dilate(glow_mask, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (15, 15)))
    glow_blur = cv2.GaussianBlur(glow_dilated, (17, 17), 0)
    img[glow_blur > 20] = (10, 180, 255, 110)

    cv2.fillPoly(img, [bolt_pts], (0, 160, 245, 255))
    cv2.polylines(img, [bolt_pts], True, (0, 130, 210, 255), 4, cv2.LINE_AA)

    inner_bolt = np.array([[152, 34], [84, 130], [124, 130], [104, 218], [172, 116], [132, 116]], np.int32)
    cv2.fillPoly(img, [inner_bolt], (25, 225, 255, 255))

    core_pts = np.array([[146, 44], [98, 128], [124, 128], [110, 206]], np.int32)
    cv2.polylines(img, [core_pts], False, (220, 250, 255, 255), 4, cv2.LINE_AA)
    cv2.polylines(img, [core_pts], False, (255, 255, 255, 255), 2, cv2.LINE_AA)

    sparks = [(52, 95), (200, 75), (168, 185)]
    for sx, sy in sparks:
        s_pts = np.array([[sx, sy-7], [sx+6, sy], [sx, sy+7], [sx-6, sy]], np.int32)
        cv2.fillConvexPoly(img, s_pts, (150, 240, 255, 230))
        cv2.circle(img, (sx, sy), 2, (255, 255, 255, 255), -1)

    cv2.imwrite(os.path.join(OUT_DIR, "icon_energy.png"), img)
    print("Created icon_energy.png")

# 12. Stylized Treasure Chest Icons (Wood, Silver, Gold)
def create_icon_chest(tier: str):
    size = 256
    img = np.zeros((size, size, 4), dtype=np.uint8)

    if tier == "wood":
        c_body = (35, 65, 115, 255)
        c_body_dark = (20, 40, 75, 255)
        c_strap = (40, 115, 160, 255)
        c_strap_dark = (25, 75, 110, 255)
        c_rim = (30, 95, 140, 255)
        c_lock = (40, 195, 245, 255)
        c_gem = (10, 10, 10, 255)
        out_name = "icon_chest_wood.png"
    elif tier == "silver":
        c_body = (185, 190, 195, 255)
        c_body_dark = (130, 135, 145, 255)
        c_strap = (220, 225, 230, 255)
        c_strap_dark = (160, 165, 175, 255)
        c_rim = (195, 200, 210, 255)
        c_lock = (245, 248, 250, 255)
        c_gem = (245, 180, 40, 255)
        out_name = "icon_chest_silver.png"
    else: # "gold"
        c_body = (25, 170, 235, 255)
        c_body_dark = (15, 120, 180, 255)
        c_strap = (35, 45, 175, 255)
        c_strap_dark = (20, 25, 120, 255)
        c_rim = (45, 205, 255, 255)
        c_lock = (55, 225, 255, 255)
        c_gem = (40, 30, 235, 255)
        out_name = "icon_chest_gold.png"

    shadow_mask = np.zeros((size, size), dtype=np.uint8)
    cv2.ellipse(shadow_mask, (128, 218), (86, 20), 0, 0, 360, 255, -1)
    shadow_blur = cv2.GaussianBlur(shadow_mask, (19, 19), 0)
    img[shadow_blur > 0] = (0, 0, 0, 80)

    bx1, bx2, by1, by2 = 42, 214, 120, 210
    cv2.rectangle(img, (bx1, by1), (bx2, by2), c_body, -1)
    cv2.line(img, (bx1, 150), (bx2, 150), c_body_dark, 2)
    cv2.line(img, (bx1, 180), (bx2, 180), c_body_dark, 2)
    cv2.rectangle(img, (bx1, by1), (bx2, by2), c_body_dark, 3)

    lid_mask = np.zeros((size, size), dtype=np.uint8)
    cv2.ellipse(lid_mask, (128, 120), (88, 62), 0, 180, 360, 255, -1)
    img[lid_mask > 0] = c_body
    cv2.ellipse(img, (128, 120), (88, 42), 0, 180, 360, c_body_dark, 2, cv2.LINE_AA)
    cv2.ellipse(img, (128, 120), (88, 62), 0, 180, 360, c_body_dark, 3, cv2.LINE_AA)

    cv2.rectangle(img, (36, 114), (220, 126), c_rim, -1)
    cv2.rectangle(img, (36, 114), (220, 126), c_strap_dark, 2)

    for sx in [76, 162]:
        cv2.rectangle(img, (sx, by1), (sx + 18, by2), c_strap, -1)
        cv2.rectangle(img, (sx, by1), (sx + 18, by2), c_strap_dark, 2)
        cv2.rectangle(img, (sx, 64), (sx + 18, 114), c_strap, -1)
        cv2.rectangle(img, (sx, 64), (sx + 18, 114), c_strap_dark, 2)
        for ry in [76, 96, 136, 165, 195]:
            cv2.circle(img, (sx + 9, ry), 3, c_rim, -1)
            cv2.circle(img, (sx + 8, ry - 1), 1, (255, 255, 255, 220), -1)

    lx1, lx2, ly1, ly2 = 112, 144, 108, 148
    cv2.rectangle(img, (lx1, ly1), (lx2, ly2), c_lock, -1)
    cv2.rectangle(img, (lx1, ly1), (lx2, ly2), c_strap_dark, 2)

    lock_bracket = np.array([[lx1, ly2], [lx2, ly2], [128, 160]], np.int32)
    cv2.fillConvexPoly(img, lock_bracket, c_lock)
    cv2.polylines(img, [lock_bracket], True, c_strap_dark, 2, cv2.LINE_AA)

    if tier == "wood":
        cv2.circle(img, (128, 126), 4, c_gem, -1)
        cv2.fillConvexPoly(img, np.array([[126, 126], [130, 126], [132, 138], [124, 138]], np.int32), c_gem)
    else:
        cv2.circle(img, (128, 130), 8, c_gem, -1)
        cv2.circle(img, (128, 130), 8, c_strap_dark, 1, cv2.LINE_AA)
        cv2.circle(img, (126, 128), 3, (255, 255, 255, 230), -1)

    cv2.fillConvexPoly(img, np.array([[bx1, by2 - 20], [bx1, by2], [bx1 + 20, by2]], np.int32), c_strap)
    cv2.fillConvexPoly(img, np.array([[bx2, by2 - 20], [bx2, by2], [bx2 - 20, by2]], np.int32), c_strap)

    glint_x, glint_y = 70, 75
    cv2.circle(img, (glint_x, glint_y), 4, (255, 255, 255, 220), -1)
    cv2.line(img, (glint_x - 8, glint_y), (glint_x + 8, glint_y), (255, 255, 255, 200), 1, cv2.LINE_AA)
    cv2.line(img, (glint_x, glint_y - 8), (glint_x, glint_y + 8), (255, 255, 255, 200), 1, cv2.LINE_AA)

    cv2.imwrite(os.path.join(OUT_DIR, out_name), img)
    print("Created %s" % out_name)

# 13. Golden Stopwatch / Time Skip Icon (256x256 golden stopwatch with fast-forward arrows)
def create_icon_time_skip():
    size = 256
    img = np.zeros((size, size, 4), dtype=np.uint8)

    cx, cy = 128, 142
    r_body = 84

    shadow_mask = np.zeros((size, size), dtype=np.uint8)
    cv2.circle(shadow_mask, (cx + 3, cy + 6), r_body + 4, 255, -1)
    shadow_blur = cv2.GaussianBlur(shadow_mask, (19, 19), 0)
    img[shadow_blur > 0] = (0, 0, 0, 70)

    cv2.rectangle(img, (121, 46), (135, 60), (35, 175, 240, 255), -1)
    cv2.rectangle(img, (121, 46), (135, 60), (15, 115, 180, 255), 2)
    cv2.circle(img, (128, 36), 18, (45, 195, 250, 255), 6, cv2.LINE_AA)
    cv2.circle(img, (128, 36), 18, (15, 115, 180, 255), 1, cv2.LINE_AA)

    for px, py in [(68, 76), (188, 76)]:
        cv2.circle(img, (px, py), 9, (35, 175, 240, 255), -1)
        cv2.circle(img, (px, py), 9, (15, 115, 180, 255), 2)

    cv2.circle(img, (cx, cy), r_body, (20, 140, 215, 255), -1)
    cv2.circle(img, (cx, cy), r_body - 5, (50, 215, 255, 255), -1)
    cv2.circle(img, (cx, cy), r_body - 14, (15, 120, 185, 255), -1)

    r_dial = r_body - 18
    cv2.circle(img, (cx, cy), r_dial, (50, 25, 15, 255), -1)

    for i in range(12):
        ang = 2.0 * math.pi * i / 12.0
        t1 = (int(cx + (r_dial - 10) * math.cos(ang)), int(cy + (r_dial - 10) * math.sin(ang)))
        t2 = (int(cx + (r_dial - 3) * math.cos(ang)), int(cy + (r_dial - 3) * math.sin(ang)))
        thick = 3 if i % 3 == 0 else 1
        col = (70, 225, 255, 255) if i % 3 == 0 else (160, 130, 100, 200)
        cv2.line(img, t1, t2, col, thick, cv2.LINE_AA)

    tri1 = np.array([[82, 112], [128, 142], [82, 172]], np.int32)
    tri2 = np.array([[128, 112], [174, 142], [128, 172]], np.int32)
    cv2.fillConvexPoly(img, tri1 + np.array([2, 3]), (20, 10, 5, 200))
    cv2.fillConvexPoly(img, tri2 + np.array([2, 3]), (20, 10, 5, 200))
    cv2.fillConvexPoly(img, tri1, (40, 215, 255, 255))
    cv2.fillConvexPoly(img, tri2, (40, 215, 255, 255))
    cv2.polylines(img, [tri1], True, (255, 255, 255, 230), 2, cv2.LINE_AA)
    cv2.polylines(img, [tri2], True, (255, 255, 255, 230), 2, cv2.LINE_AA)

    cv2.ellipse(img, (cx, cy - 8), (r_dial - 8, r_dial - 22), -25, 190, 310, (255, 255, 255, 65), 5, cv2.LINE_AA)

    cv2.circle(img, (186, 88), 4, (255, 255, 255, 255), -1)
    cv2.line(img, (178, 88), (194, 88), (255, 255, 255, 220), 1, cv2.LINE_AA)
    cv2.line(img, (186, 80), (186, 96), (255, 255, 255, 220), 1, cv2.LINE_AA)

    cv2.imwrite(os.path.join(OUT_DIR, "icon_time_skip.png"), img)
    print("Created icon_time_skip.png")

if __name__ == "__main__":
    create_bubble_fork_knife()
    create_bubble_hourglass()
    create_floating_cash_badge()
    create_jukebox_texture()
    create_lounge_shelf_texture()
    create_chalkboard_texture()
    create_lockers_texture()
    create_kitchen_pass_rug()
    create_icon_diamond()
    create_icon_gold_coin()
    create_icon_energy()
    create_icon_chest("wood")
    create_icon_chest("silver")
    create_icon_chest("gold")
    create_icon_time_skip()
    print("ALL FIDELITY ASSETS GENERATED!")
