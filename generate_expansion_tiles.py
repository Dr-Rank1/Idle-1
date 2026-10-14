import cv2
import numpy as np

SIZE = 1024
img = np.zeros((SIZE, SIZE, 3), dtype=np.uint8)

# Warm cream-and-tan diamond checkerboard matching the South-East expansion in Idle Diner reference video
COLOR_LIGHT = np.array([248, 242, 232], dtype=np.float32) # warm ivory cream
COLOR_DARK  = np.array([216, 194, 172], dtype=np.float32) # warm soft tan / peach
COLOR_GROUT = np.array([170, 155, 138], dtype=np.float32) # subtle warm sand grout line

TILES = 8
tile_size = SIZE / TILES

for y in range(SIZE):
    for x in range(SIZE):
        u = x / tile_size
        v = y / tile_size
        
        iu = int(np.floor(u))
        iv = int(np.floor(v))
        
        fu = u - iu
        fv = v - iv
        dist_u = min(fu, 1.0 - fu) * tile_size
        dist_v = min(fv, 1.0 - fv) * tile_size
        min_dist = min(dist_u, dist_v)
        
        is_light = ((iu + iv) % 2) == 0
        base_color = COLOR_LIGHT if is_light else COLOR_DARK
        
        center_dist = max(abs(fu - 0.5), abs(fv - 0.5))
        shade = 1.0 - 0.04 * center_dist
        color = base_color * shade
        
        grout_width = 2.0
        if min_dist < grout_width:
            t = min_dist / grout_width
            color = COLOR_GROUT * (1.0 - t) + color * t
            
        img[y, x] = np.clip(color, 0, 255).astype(np.uint8)

out_path = "restaurant_tycoon_3d/assets/textures/expansion_diamond_tiles.png"
cv2.imwrite(out_path, img)
print("Saved expansion_diamond_tiles.png successfully!")
