import cv2
import numpy as np

SIZE = 512
img = np.zeros((SIZE, SIZE, 3), dtype=np.uint8)

# Cool blue-grey square tiles for restroom
# OpenCV uses BGR
COLOR_TILE_A = np.array([188, 168, 138], dtype=np.float32) # cool blue-grey (R:138, G:168, B:188)
COLOR_TILE_B = np.array([178, 158, 128], dtype=np.float32) # slightly deeper shade
COLOR_GROUT  = np.array([215, 210, 205], dtype=np.float32) # crisp light grout

TILES = 8
tile_size = SIZE / TILES

for y in range(SIZE):
    tile_y = int(y // tile_size)
    fy = (y % tile_size) / tile_size
    dist_y = min(fy, 1.0 - fy) * tile_size

    for x in range(SIZE):
        tile_x = int(x // tile_size)
        fx = (x % tile_size) / tile_size
        dist_x = min(fx, 1.0 - fx) * tile_size

        min_dist = min(dist_x, dist_y)

        base_color = COLOR_TILE_A if (tile_x + tile_y) % 2 == 0 else COLOR_TILE_B
        
        # Subtle pillowing / bevel highlight
        shade = 1.0 - 0.06 * max(abs(fx - 0.5), abs(fy - 0.5))
        color = base_color * shade

        # Grout lines
        grout_w = 2.5
        if min_dist < grout_w:
            t = min_dist / grout_w
            color = COLOR_GROUT * (1.0 - t) + color * t

        img[y, x] = np.clip(color, 0, 255).astype(np.uint8)

out_path = "restaurant_tycoon_3d/assets/textures/restroom_tiles.png"
cv2.imwrite(out_path, img)
print(f"Generated {out_path}")
