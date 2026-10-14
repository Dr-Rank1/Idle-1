import cv2
import numpy as np
import os

OUT_DIR = "restaurant_tycoon_3d/assets/textures"
os.makedirs(OUT_DIR, exist_ok=True)

# 1. Circular Bubble: Fork & Knife (Dining order ready / eating)
def create_bubble_fork_knife():
    size = 256
    img = np.zeros((size, size, 4), dtype=np.uint8)
    center = (size // 2, size // 2)
    radius = 108

    # Soft drop shadow
    cv2.circle(img, (center[0] + 4, center[1] + 8), radius, (0, 0, 0, 70), -1)
    # White bubble background
    cv2.circle(img, center, radius, (255, 255, 255, 255), -1)
    # Outer crisp rim
    cv2.circle(img, center, radius, (215, 225, 235, 255), 6)
    cv2.circle(img, center, radius, (90, 105, 120, 255), 2)

    # Fork on left (silver/blue)
    fork_color = (200, 120, 30, 255) # Rich turquoise/blue in BGRA: B=200, G=120, R=30
    # Handle
    cv2.line(img, (95, 185), (95, 115), fork_color, 8)
    cv2.circle(img, (95, 185), 6, fork_color, -1)
    # Tines base
    cv2.ellipse(img, (95, 115), (16, 12), 0, 0, 180, fork_color, -1)
    # 3 Tines
    for tx in [83, 95, 107]:
        cv2.line(img, (tx, 115), (tx, 75), fork_color, 4)

    # Knife on right
    knife_color = (200, 120, 30, 255)
    # Handle
    cv2.line(img, (160, 185), (160, 120), knife_color, 8)
    cv2.circle(img, (160, 185), 6, knife_color, -1)
    # Blade
    pts = np.array([[156, 120], [164, 120], [168, 75], [156, 75]], np.int32)
    cv2.fillConvexPoly(img, pts, knife_color)
    cv2.ellipse(img, (162, 75), (6, 10), 0, 180, 360, knife_color, -1)

    cv2.imwrite(os.path.join(OUT_DIR, "bubble_fork_knife.png"), img)
    print("Created bubble_fork_knife.png")

# 2. Circular Bubble: Hourglass (Waiting for food / service)
def create_bubble_hourglass():
    size = 256
    img = np.zeros((size, size, 4), dtype=np.uint8)
    center = (size // 2, size // 2)
    radius = 108

    # Soft drop shadow
    cv2.circle(img, (center[0] + 4, center[1] + 8), radius, (0, 0, 0, 70), -1)
    # White bubble background
    cv2.circle(img, center, radius, (255, 255, 255, 255), -1)
    # Outer crisp rim
    cv2.circle(img, center, radius, (215, 225, 235, 255), 6)
    cv2.circle(img, center, radius, (90, 105, 120, 255), 2)

    # Hourglass Frame (Warm mahogany/brass)
    frame_color = (40, 80, 160, 255) # Orange-brown brass
    # Top plate
    cv2.rectangle(img, (82, 68), (174, 80), frame_color, -1)
    # Bottom plate
    cv2.rectangle(img, (82, 176), (174, 188), frame_color, -1)
    
    # Glass Bulbs
    glass_color = (245, 235, 220, 220)
    top_glass = np.array([[92, 80], [164, 80], [134, 128], [122, 128]], np.int32)
    bot_glass = np.array([[122, 128], [134, 128], [164, 176], [92, 176]], np.int32)
    cv2.fillConvexPoly(img, top_glass, glass_color)
    cv2.fillConvexPoly(img, bot_glass, glass_color)

    # Golden Sand
    sand_color = (30, 180, 245, 255) # Gold
    # Top sand half-empty
    top_sand = np.array([[104, 102], [152, 102], [132, 128], [124, 128]], np.int32)
    cv2.fillConvexPoly(img, top_sand, sand_color)
    # Falling stream
    cv2.line(img, (128, 124), (128, 150), sand_color, 3)
    # Bottom sand pile
    bot_sand = np.array([[102, 176], [154, 176], [140, 148], [116, 148]], np.int32)
    cv2.fillConvexPoly(img, bot_sand, sand_color)

    # Glass outline
    cv2.polylines(img, [top_glass], True, (160, 170, 180, 255), 3)
    cv2.polylines(img, [bot_glass], True, (160, 170, 180, 255), 3)

    cv2.imwrite(os.path.join(OUT_DIR, "bubble_hourglass.png"), img)
    print("Created bubble_hourglass.png")

# 3. Floating Green Cash Stack Graphic
def create_floating_cash_badge():
    w, h = 320, 160
    img = np.zeros((h, w, 4), dtype=np.uint8)

    # Shadow
    cv2.rectangle(img, (18, 22), (302, 142), (0, 0, 0, 80), -1)
    
    # Bottom bill (offset)
    cv2.rectangle(img, (14, 26), (294, 134), (40, 140, 60, 255), -1)
    cv2.rectangle(img, (14, 26), (294, 134), (80, 200, 100, 255), 3)

    # Top bill
    cv2.rectangle(img, (26, 14), (306, 122), (50, 170, 75, 255), -1)
    cv2.rectangle(img, (26, 14), (306, 122), (180, 245, 190, 255), 4)

    # Center oval
    cv2.ellipse(img, (166, 68), (55, 38), 0, 0, 360, (65, 195, 95, 255), -1)
    cv2.ellipse(img, (166, 68), (55, 38), 0, 0, 360, (220, 255, 220, 255), 3)

    # Currency Dollar Symbol $
    cv2.putText(img, "$", (148, 86), cv2.FONT_HERSHEY_DUPLEX, 2.0, (255, 255, 255, 255), 4, cv2.LINE_AA)

    # Corner stars / ornaments
    for cx, cy in [(48, 36), (284, 36), (48, 100), (284, 100)]:
        cv2.circle(img, (cx, cy), 8, (200, 250, 210, 255), -1)

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

if __name__ == "__main__":
    create_bubble_fork_knife()
    create_bubble_hourglass()
    create_floating_cash_badge()
    create_jukebox_texture()
    create_lounge_shelf_texture()
    create_chalkboard_texture()
    create_lockers_texture()
    create_kitchen_pass_rug()
    print("ALL FIDELITY ASSETS GENERATED!")
