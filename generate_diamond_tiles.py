import cv2
import numpy as np

SIZE = 1024
img = np.zeros((SIZE, SIZE, 3), dtype=np.uint8)

# Distinct contrast matching Idle Diner reference:
COLOR_LIGHT = np.array([242, 248, 246], dtype=np.float32) # warm ivory
COLOR_DARK  = np.array([172, 182, 180], dtype=np.float32) # distinct medium warm taupe gray
COLOR_GROUT = np.array([135, 142, 140], dtype=np.float32) # grout line

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

cv2.imwrite("restaurant_tycoon_3d/assets/textures/diner_diamond_tiles.png", img)
print("Saved axis-aligned diner_diamond_tiles.png successfully!")
