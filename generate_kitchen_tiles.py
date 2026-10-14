import cv2
import numpy as np

SIZE = 512
img = np.zeros((SIZE, SIZE, 3), dtype=np.uint8)

# Commercial slate grey quarry tile for kitchen (rich contrast, no blowout)
COLOR_TILE = np.array([125, 134, 138], dtype=np.float32) # slate blue/gray
COLOR_GROUT = np.array([80, 86, 90], dtype=np.float32)

TILES = 8
tile_size = SIZE / TILES

for y in range(SIZE):
    for x in range(SIZE):
        fx = (x % tile_size) / tile_size
        fy = (y % tile_size) / tile_size
        
        dist_x = min(fx, 1.0 - fx) * tile_size
        dist_y = min(fy, 1.0 - fy) * tile_size
        min_dist = min(dist_x, dist_y)
        
        shade = 1.0 - 0.08 * max(abs(fx - 0.5), abs(fy - 0.5))
        color = COLOR_TILE * shade
        
        grout_w = 2.5
        if min_dist < grout_w:
            t = min_dist / grout_w
            color = COLOR_GROUT * (1.0 - t) + color * t
            
        img[y, x] = np.clip(color, 0, 255).astype(np.uint8)

cv2.imwrite("restaurant_tycoon_3d/assets/textures/kitchen_slate_tiles.png", img)
print("Saved richer kitchen_slate_tiles.png")
