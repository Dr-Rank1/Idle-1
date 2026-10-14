import cv2
import numpy as np

W, H = 1024, 512
img = np.zeros((H, W, 4), dtype=np.uint8)

# Dark charcoal rounded backing
bg_color = (20, 20, 24, 255)
cv2.rectangle(img, (20, 20), (W-20, H-20), bg_color, -1)
cv2.rectangle(img, (20, 20), (W-20, H-20), (55, 55, 65, 255), 6)

neon = np.zeros((H, W, 3), dtype=np.uint8)

# 1. Hot Pink / Magenta tilted oval loop
center = (W // 2, H // 2 + 10)
axes = (350, 155)
angle = -18

# Pink / Magenta neon ring
cv2.ellipse(neon, center, axes, angle, 0, 360, (220, 20, 240), 22)
cv2.ellipse(neon, center, axes, angle, 0, 360, (245, 80, 255), 10)
cv2.ellipse(neon, center, axes, angle, 0, 360, (255, 180, 255), 4)

# 2. Text "Idle" in glowing rich neon gold/yellow (BGR: blue=10, green=210, red=255)
font_idle = cv2.FONT_HERSHEY_SCRIPT_SIMPLEX
text_idle = "Idle"
scale_idle = 4.2
idle_org = (W // 2 - 280, H // 2 - 30)

cv2.putText(neon, text_idle, idle_org, font_idle, scale_idle, (0, 160, 255), 26, cv2.LINE_AA)
cv2.putText(neon, text_idle, idle_org, font_idle, scale_idle, (20, 220, 255), 14, cv2.LINE_AA)
cv2.putText(neon, text_idle, idle_org, font_idle, scale_idle, (160, 250, 255), 5, cv2.LINE_AA)

# 3. Text "Diner" in glowing rich neon cyan/turquoise (BGR: blue=255, green=220, red=20)
font_diner = cv2.FONT_HERSHEY_TRIPLEX
text_diner = "Diner"
scale_diner = 4.6
diner_org = (W // 2 - 120, H // 2 + 150)

cv2.putText(neon, text_diner, diner_org, font_diner, scale_diner, (255, 180, 0), 32, cv2.LINE_AA)
cv2.putText(neon, text_diner, diner_org, font_diner, scale_diner, (255, 230, 40), 16, cv2.LINE_AA)
cv2.putText(neon, text_diner, diner_org, font_diner, scale_diner, (255, 245, 100), 6, cv2.LINE_AA)

bloom = cv2.GaussianBlur(neon, (21, 21), 0)
combined_rgb = cv2.addWeighted(neon, 0.85, bloom, 0.55, 0)

for c in range(3):
    img[:, :, c] = np.clip(img[:, :, c].astype(np.int32) + combined_rgb[:, :, c].astype(np.int32), 0, 255).astype(np.uint8)

img[:, :, 3] = 255

cv2.imwrite("restaurant_tycoon_3d/assets/textures/idle_diner_neon.png", img)
print("Saved rich saturated idle_diner_neon.png")
