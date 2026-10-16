#!/usr/bin/env python3
"""
generate_brand_assets.py
Generates crisp studio and title screen branding assets in restaurant_tycoon_3d/assets/textures/:
1. dr_rank_logo.png (1024x512): "DR RANK" Studio Emblem with Golden Shield, Crown, 3D text, and Ribbon.
2. idle_diner_title_logo.png (1024x512): Stacked 3D "IDLE DINER" Logo with Chef Hat, Ribbon, and Sparkles.
3. splash_bg_pattern.png (1080x1920): High-res mobile splash background with sunburst and culinary silhouettes.
"""

import os
import math
import random
import cv2
import numpy as np

DEFAULT_OUT_DIR = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    "restaurant_tycoon_3d",
    "assets",
    "textures",
)


def create_dr_rank_logo(out_dir=DEFAULT_OUT_DIR):
    """
    Renders 'DR RANK' studio logo (1024x512) featuring a golden crest badge,
    stylized crown, metallic 3D typography with diagonal specular highlight sweep,
    and a 'GAMES STUDIO' subtitle ribbon.
    """
    os.makedirs(out_dir, exist_ok=True)
    w, h = 1024, 512
    img = np.zeros((h, w, 4), dtype=np.uint8)
    cx = 512
    layer = np.zeros((h, w, 4), dtype=np.uint8)

    # --- 1. Golden Shield & Crown ---
    crest_cy = 135
    shield_pts = np.array([
        [cx - 85, crest_cy - 65],
        [cx + 85, crest_cy - 65],
        [cx + 95, crest_cy + 5],
        [cx + 65, crest_cy + 75],
        [cx, crest_cy + 105],
        [cx - 65, crest_cy + 75],
        [cx - 95, crest_cy + 5]
    ], np.int32)

    # Outer dark border of shield
    cv2.fillPoly(layer, [shield_pts], (15, 12, 10, 255))
    cv2.polylines(layer, [shield_pts], True, (15, 12, 10, 255), 16, cv2.LINE_AA)

    # Gold outer rim
    cv2.fillPoly(layer, [shield_pts], (30, 185, 245, 255))
    cv2.polylines(layer, [shield_pts], True, (50, 220, 255, 255), 6, cv2.LINE_AA)

    # Inner shield face
    inner_shield_pts = np.array([
        [cx - 70, crest_cy - 52],
        [cx + 70, crest_cy - 52],
        [cx + 78, crest_cy + 4],
        [cx + 52, crest_cy + 62],
        [cx, crest_cy + 86],
        [cx - 52, crest_cy + 62],
        [cx - 78, crest_cy + 4]
    ], np.int32)
    # Deep royal crimson face with gold divider
    cv2.fillPoly(layer, [inner_shield_pts], (35, 20, 140, 255))
    cv2.line(layer, (cx, crest_cy - 52), (cx, crest_cy + 86), (50, 220, 255, 255), 3, cv2.LINE_AA)
    # Right half slightly darker for 3D depth
    cv2.fillPoly(
        layer,
        [np.array([[cx, crest_cy - 52], [cx + 70, crest_cy - 52], [cx + 78, crest_cy + 4], [cx + 52, crest_cy + 62], [cx, crest_cy + 86]], np.int32)],
        (25, 15, 105, 180)
    )

    # Star in center of shield
    star_pts = []
    for i in range(10):
        r_star = 26 if i % 2 == 0 else 12
        ang = -math.pi / 2.0 + i * math.pi / 5.0
        star_pts.append([int(cx + r_star * math.cos(ang)), int(crest_cy + 12 + r_star * math.sin(ang))])
    cv2.fillPoly(layer, [np.array(star_pts, np.int32)], (40, 220, 255, 255))
    cv2.polylines(layer, [np.array(star_pts, np.int32)], True, (255, 255, 255, 255), 2, cv2.LINE_AA)

    # Crown on top of shield
    crown_base_y = crest_cy - 65
    crown_pts = np.array([
        [cx - 75, crown_base_y],
        [cx - 82, crown_base_y - 42],  # left peak
        [cx - 45, crown_base_y - 20],  # valley
        [cx - 38, crown_base_y - 54],  # mid-left peak
        [cx, crown_base_y - 24],      # mid valley
        [cx, crown_base_y - 68],      # center high peak
        [cx, crown_base_y - 24],
        [cx + 38, crown_base_y - 54],  # mid-right peak
        [cx + 45, crown_base_y - 20],
        [cx + 82, crown_base_y - 42],  # right peak
        [cx + 75, crown_base_y]
    ], np.int32)
    cv2.polylines(layer, [crown_pts], True, (15, 12, 10, 255), 14, cv2.LINE_AA)
    cv2.fillPoly(layer, [crown_pts], (30, 195, 255, 255))
    cv2.polylines(layer, [crown_pts], True, (120, 240, 255, 255), 3, cv2.LINE_AA)

    # Crown pearls at peaks
    for px, py in [(cx - 82, crown_base_y - 42), (cx - 38, crown_base_y - 54), (cx, crown_base_y - 68), (cx + 38, crown_base_y - 54), (cx + 82, crown_base_y - 42)]:
        cv2.circle(layer, (px, py), 7, (15, 12, 10, 255), -1)
        cv2.circle(layer, (px, py), 5, (255, 255, 255, 255), -1)
        cv2.circle(layer, (px - 1, py - 1), 2, (180, 235, 255, 255), -1)

    # Crown jewels on band
    cv2.rectangle(layer, (cx - 65, crown_base_y - 12), (cx + 65, crown_base_y), (20, 140, 200, 255), -1)
    cv2.circle(layer, (cx, crown_base_y - 6), 5, (30, 30, 220, 255), -1)  # Ruby
    cv2.circle(layer, (cx - 35, crown_base_y - 6), 4, (200, 120, 20, 255), -1)  # Sapphire
    cv2.circle(layer, (cx + 35, crown_base_y - 6), 4, (200, 120, 20, 255), -1)  # Sapphire

    # --- 2. Typography: DR RANK ---
    text = "DR RANK"
    font = cv2.FONT_HERSHEY_TRIPLEX
    scale = 3.6
    thick = 10
    (tw, th), _ = cv2.getTextSize(text, font, scale, thick)
    tx = cx - tw // 2
    ty = 350

    # 3D Extrusion
    for d in range(16, 0, -1):
        c_factor = d / 16.0
        ext_col = (int(15 + 15 * (1 - c_factor)), int(18 + 70 * (1 - c_factor)), int(22 + 130 * (1 - c_factor)), 255)
        cv2.putText(layer, text, (tx, ty + d), font, scale, (15, 12, 10, 255), thick + 16, cv2.LINE_AA)
        cv2.putText(layer, text, (tx, ty + d), font, scale, ext_col, thick + 8, cv2.LINE_AA)

    # Top face outline and bevel
    cv2.putText(layer, text, (tx, ty), font, scale, (15, 12, 10, 255), thick + 12, cv2.LINE_AA)
    cv2.putText(layer, text, (tx, ty), font, scale, (35, 195, 255, 255), thick + 4, cv2.LINE_AA)
    cv2.putText(layer, text, (tx, ty), font, scale, (255, 255, 255, 255), thick - 4, cv2.LINE_AA)

    # Specular Highlight Diagonal Sweep across DR RANK
    text_mask = np.zeros((h, w), dtype=np.uint8)
    cv2.putText(text_mask, text, (tx, ty), font, scale, 255, thick + 2, cv2.LINE_AA)

    gleam_poly1 = np.array([
        [tx + 120, ty - th - 30],
        [tx + 175, ty - th - 30],
        [tx + 65, ty + 25],
        [tx + 10, ty + 25]
    ], np.int32)
    gleam_poly2 = np.array([
        [tx + 360, ty - th - 30],
        [tx + 420, ty - th - 30],
        [tx + 290, ty + 25],
        [tx + 230, ty + 25]
    ], np.int32)
    gleam_mask = np.zeros((h, w), dtype=np.uint8)
    cv2.fillPoly(gleam_mask, [gleam_poly1, gleam_poly2], 255)
    gleam_intersect = cv2.bitwise_and(text_mask, gleam_mask)
    layer[gleam_intersect > 0, 0:3] = np.clip(
        layer[gleam_intersect > 0, 0:3].astype(np.int32) + 95, 0, 255
    ).astype(np.uint8)

    # --- 3. Subtitle Ribbon: GAMES STUDIO ---
    rx, ry = cx, 435
    rw, rh = 460, 48

    ribbon_left_fold = np.array([
        [rx - rw // 2 - 35, ry - rh // 2 + 8],
        [rx - rw // 2 + 10, ry - rh // 2 + 4],
        [rx - rw // 2 + 10, ry + rh // 2 - 4],
        [rx - rw // 2 - 35, ry + rh // 2 - 8],
        [rx - rw // 2 - 20, ry]
    ], np.int32)
    ribbon_right_fold = np.array([
        [rx + rw // 2 + 35, ry - rh // 2 + 8],
        [rx + rw // 2 - 10, ry - rh // 2 + 4],
        [rx + rw // 2 - 10, ry + rh // 2 - 4],
        [rx + rw // 2 + 35, ry + rh // 2 - 8],
        [rx + rw // 2 + 20, ry]
    ], np.int32)

    cv2.polylines(layer, [ribbon_left_fold, ribbon_right_fold], True, (15, 12, 10, 255), 8, cv2.LINE_AA)
    cv2.fillPoly(layer, [ribbon_left_fold, ribbon_right_fold], (25, 15, 120, 255))

    ribbon_box = np.array([
        [rx - rw // 2, ry - rh // 2],
        [rx + rw // 2, ry - rh // 2],
        [rx + rw // 2, ry + rh // 2],
        [rx - rw // 2, ry + rh // 2]
    ], np.int32)
    cv2.polylines(layer, [ribbon_box], True, (15, 12, 10, 255), 10, cv2.LINE_AA)
    cv2.fillPoly(layer, [ribbon_box], (35, 25, 185, 255))
    cv2.line(layer, (rx - rw // 2 + 3, ry - rh // 2 + 3), (rx + rw // 2 - 3, ry - rh // 2 + 3), (50, 220, 255, 255), 3, cv2.LINE_AA)
    cv2.line(layer, (rx - rw // 2 + 3, ry + rh // 2 - 3), (rx + rw // 2 - 3, ry + rh // 2 - 3), (50, 220, 255, 255), 3, cv2.LINE_AA)

    sub_text = "G A M E S   S T U D I O"
    s_font = cv2.FONT_HERSHEY_DUPLEX
    s_scale = 0.95
    s_thick = 2
    (stw, sth), _ = cv2.getTextSize(sub_text, s_font, s_scale, s_thick)
    stx = rx - stw // 2
    sty = ry + sth // 2 - 1
    cv2.putText(layer, sub_text, (stx, sty + 2), s_font, s_scale, (15, 10, 50, 255), s_thick + 2, cv2.LINE_AA)
    cv2.putText(layer, sub_text, (stx, sty), s_font, s_scale, (255, 255, 255, 255), s_thick, cv2.LINE_AA)

    for sx in [stx - 28, stx + stw + 28]:
        cv2.circle(layer, (sx, ry), 5, (40, 220, 255, 255), -1, cv2.LINE_AA)
        cv2.circle(layer, (sx, ry), 2, (255, 255, 255, 255), -1, cv2.LINE_AA)

    # --- 4. Soft Drop Shadow ---
    alpha = layer[:, :, 3].astype(np.float32) / 255.0
    shadow_mask = np.zeros((h, w), dtype=np.float32)
    s_dx, s_dy = 6, 14
    shadow_mask[s_dy:, s_dx:] = alpha[:-s_dy, :-s_dx]
    shadow_blur = cv2.GaussianBlur(shadow_mask, (25, 25), 8.0)

    img[:, :, 0] = 10
    img[:, :, 1] = 10
    img[:, :, 2] = 15
    img[:, :, 3] = np.clip(shadow_blur * 170.0, 0, 255).astype(np.uint8)

    layer_a = layer[:, :, 3].astype(np.float32) / 255.0
    for c in range(3):
        img[:, :, c] = (layer[:, :, c] * layer_a + img[:, :, c] * (1.0 - layer_a)).astype(np.uint8)
    img[:, :, 3] = np.clip(layer[:, :, 3].astype(np.int32) + img[:, :, 3].astype(np.int32) * (255 - layer[:, :, 3]) // 255, 0, 255).astype(np.uint8)

    out_path = os.path.join(out_dir, "dr_rank_logo.png")
    cv2.imwrite(out_path, img)
    print(f"Generated {out_path}")
    return out_path


def create_idle_diner_title_logo(out_dir=DEFAULT_OUT_DIR):
    """
    Renders stacked 3D game title logo (1024x512) reading 'IDLE DINER' in golden-yellow
    and turquoise with a chef hat, 3D extruded drop, red 'RESTAURANT TYCOON' banner,
    and sparkle stars.
    """
    os.makedirs(out_dir, exist_ok=True)
    w, h = 1024, 512
    img = np.zeros((h, w, 4), dtype=np.uint8)
    layer = np.zeros((h, w, 4), dtype=np.uint8)
    cx = 512

    # --- 1. Chef Hat on top-left of 'IDLE' ---
    hat_cx, hat_cy = 345, 68
    hat_pts = np.array([
        [hat_cx - 36, hat_cy + 22],
        [hat_cx - 48, hat_cy - 10],
        [hat_cx - 32, hat_cy - 42],
        [hat_cx, hat_cy - 52],
        [hat_cx + 32, hat_cy - 42],
        [hat_cx + 48, hat_cy - 10],
        [hat_cx + 36, hat_cy + 22]
    ], np.int32)
    cv2.polylines(layer, [hat_pts], True, (15, 12, 10, 255), 14, cv2.LINE_AA)
    cv2.fillPoly(layer, [hat_pts], (250, 250, 255, 255))
    cv2.ellipse(layer, (hat_cx - 16, hat_cy - 18), (14, 26), -15, 170, 310, (210, 215, 225, 255), 3, cv2.LINE_AA)
    cv2.ellipse(layer, (hat_cx + 16, hat_cy - 18), (14, 26), 15, 230, 370, (210, 215, 225, 255), 3, cv2.LINE_AA)

    band_box = np.array([
        [hat_cx - 36, hat_cy + 12],
        [hat_cx + 36, hat_cy + 12],
        [hat_cx + 38, hat_cy + 26],
        [hat_cx - 38, hat_cy + 26]
    ], np.int32)
    cv2.polylines(layer, [band_box], True, (15, 12, 10, 255), 10, cv2.LINE_AA)
    cv2.fillPoly(layer, [band_box], (35, 30, 215, 255))
    cv2.circle(layer, (hat_cx, hat_cy + 19), 5, (40, 220, 255, 255), -1, cv2.LINE_AA)
    cv2.circle(layer, (hat_cx, hat_cy + 19), 2, (255, 255, 255, 255), -1, cv2.LINE_AA)

    # --- 2. 'IDLE' Text (Golden-Yellow with 3D extrusion) ---
    text_idle = "IDLE"
    font = cv2.FONT_HERSHEY_TRIPLEX
    scale_idle = 3.6
    thick_idle = 10
    (w_idle, h_idle), _ = cv2.getTextSize(text_idle, font, scale_idle, thick_idle)
    ix = cx - w_idle // 2
    iy = 160

    for d in range(18, 0, -1):
        c_f = d / 18.0
        ext_col = (int(18 + 12 * (1 - c_f)), int(22 + 40 * (1 - c_f)), int(75 + 70 * (1 - c_f)), 255)
        cv2.putText(layer, text_idle, (ix, iy + d), font, scale_idle, (15, 12, 10, 255), thick_idle + 16, cv2.LINE_AA)
        cv2.putText(layer, text_idle, (ix, iy + d), font, scale_idle, ext_col, thick_idle + 8, cv2.LINE_AA)

    cv2.putText(layer, text_idle, (ix, iy), font, scale_idle, (15, 12, 10, 255), thick_idle + 14, cv2.LINE_AA)
    cv2.putText(layer, text_idle, (ix, iy), font, scale_idle, (20, 140, 220, 255), thick_idle + 6, cv2.LINE_AA)
    cv2.putText(layer, text_idle, (ix, iy), font, scale_idle, (40, 225, 255, 255), thick_idle - 2, cv2.LINE_AA)
    cv2.putText(layer, text_idle, (ix, iy), font, scale_idle, (150, 245, 255, 255), thick_idle - 6, cv2.LINE_AA)

    # --- 3. 'DINER' Text (Turquoise / Retro Teal with 3D extrusion) ---
    text_diner = "DINER"
    scale_diner = 4.8
    thick_diner = 13
    (w_diner, h_diner), _ = cv2.getTextSize(text_diner, font, scale_diner, thick_diner)
    dx = cx - w_diner // 2
    dy = 310

    for d in range(22, 0, -1):
        c_f = d / 22.0
        ext_col = (int(20 + 15 * (1 - c_f)), int(18 + 35 * (1 - c_f)), int(70 + 60 * (1 - c_f)), 255)
        cv2.putText(layer, text_diner, (dx, dy + d), font, scale_diner, (15, 12, 10, 255), thick_diner + 18, cv2.LINE_AA)
        cv2.putText(layer, text_diner, (dx, dy + d), font, scale_diner, ext_col, thick_diner + 10, cv2.LINE_AA)

    cv2.putText(layer, text_diner, (dx, dy), font, scale_diner, (15, 12, 10, 255), thick_diner + 16, cv2.LINE_AA)
    cv2.putText(layer, text_diner, (dx, dy), font, scale_diner, (160, 130, 20, 255), thick_diner + 8, cv2.LINE_AA)
    cv2.putText(layer, text_diner, (dx, dy), font, scale_diner, (225, 205, 35, 255), thick_diner, cv2.LINE_AA)
    cv2.putText(layer, text_diner, (dx, dy), font, scale_diner, (255, 250, 160, 255), thick_diner - 6, cv2.LINE_AA)

    # --- 4. Bottom Banner: RESTAURANT TYCOON ---
    bx, by = cx, 432
    bw, bh = 600, 56

    b_left_dovetail = np.array([
        [bx - bw // 2 - 42, by - bh // 2 + 10],
        [bx - bw // 2 + 12, by - bh // 2 + 4],
        [bx - bw // 2 + 12, by + bh // 2 - 4],
        [bx - bw // 2 - 42, by + bh // 2 - 10],
        [bx - bw // 2 - 24, by]
    ], np.int32)
    b_right_dovetail = np.array([
        [bx + bw // 2 + 42, by - bh // 2 + 10],
        [bx + bw // 2 - 12, by - bh // 2 + 4],
        [bx + bw // 2 - 12, by + bh // 2 - 4],
        [bx + bw // 2 + 42, by + bh // 2 - 10],
        [bx + bw // 2 + 24, by]
    ], np.int32)
    cv2.polylines(layer, [b_left_dovetail, b_right_dovetail], True, (15, 12, 10, 255), 10, cv2.LINE_AA)
    cv2.fillPoly(layer, [b_left_dovetail, b_right_dovetail], (22, 16, 125, 255))

    banner_pts = np.array([
        [bx - bw // 2, by - bh // 2],
        [bx + bw // 2, by - bh // 2],
        [bx + bw // 2, by + bh // 2],
        [bx - bw // 2, by + bh // 2]
    ], np.int32)
    cv2.polylines(layer, [banner_pts], True, (15, 12, 10, 255), 12, cv2.LINE_AA)
    cv2.fillPoly(layer, [banner_pts], (35, 28, 205, 255))

    cv2.line(layer, (bx - bw // 2 + 4, by - bh // 2 + 4), (bx + bw // 2 - 4, by - bh // 2 + 4), (50, 220, 255, 255), 3, cv2.LINE_AA)
    cv2.line(layer, (bx - bw // 2 + 4, by + bh // 2 - 4), (bx + bw // 2 - 4, by + bh // 2 - 4), (50, 220, 255, 255), 3, cv2.LINE_AA)

    sheen_pts = np.array([
        [bx - bw // 2 + 4, by - bh // 2 + 4],
        [bx + bw // 2 - 4, by - bh // 2 + 4],
        [bx + bw // 2 - 4, by - 4],
        [bx, by + 2],
        [bx - bw // 2 + 4, by - 4]
    ], np.int32)
    sheen_overlay = layer.copy()
    cv2.fillPoly(sheen_overlay, [sheen_pts], (255, 255, 255, 255))
    layer = cv2.addWeighted(sheen_overlay, 0.28, layer, 0.72, 0)

    banner_text = "★   R E S T A U R A N T   T Y C O O N   ★"
    b_font = cv2.FONT_HERSHEY_DUPLEX
    b_scale = 1.05
    b_thick = 2
    (btw, bth), _ = cv2.getTextSize(banner_text, b_font, b_scale, b_thick)
    btx = bx - btw // 2
    bty = by + bth // 2 - 1

    cv2.putText(layer, banner_text, (btx, bty + 2), b_font, b_scale, (15, 10, 50, 255), b_thick + 2, cv2.LINE_AA)
    cv2.putText(layer, banner_text, (btx, bty), b_font, b_scale, (255, 255, 255, 255), b_thick, cv2.LINE_AA)

    # --- 5. Sparkle Stars ---
    def draw_sparkle(x, y, rad):
        s_pts = []
        for i in range(8):
            r = rad if i % 2 == 0 else rad * 0.35
            ang = i * math.pi / 4.0
            s_pts.append([int(x + r * math.cos(ang)), int(y + r * math.sin(ang))])
        cv2.polylines(layer, [np.array(s_pts, np.int32)], True, (15, 12, 10, 255), 4, cv2.LINE_AA)
        cv2.fillPoly(layer, [np.array(s_pts, np.int32)], (70, 235, 255, 255))
        cv2.circle(layer, (x, y), int(rad * 0.25), (255, 255, 255, 255), -1, cv2.LINE_AA)

    draw_sparkle(240, 130, 16)
    draw_sparkle(780, 190, 18)
    draw_sparkle(210, 310, 14)
    draw_sparkle(820, 340, 15)

    # --- 6. Soft Drop Shadow ---
    alpha = layer[:, :, 3].astype(np.float32) / 255.0
    shadow_mask = np.zeros((h, w), dtype=np.float32)
    s_dx, s_dy = 6, 14
    shadow_mask[s_dy:, s_dx:] = alpha[:-s_dy, :-s_dx]
    shadow_blur = cv2.GaussianBlur(shadow_mask, (25, 25), 8.0)

    img[:, :, 0] = 10
    img[:, :, 1] = 10
    img[:, :, 2] = 15
    img[:, :, 3] = np.clip(shadow_blur * 170.0, 0, 255).astype(np.uint8)

    layer_a = layer[:, :, 3].astype(np.float32) / 255.0
    for c in range(3):
        img[:, :, c] = (layer[:, :, c] * layer_a + img[:, :, c] * (1.0 - layer_a)).astype(np.uint8)
    img[:, :, 3] = np.clip(layer[:, :, 3].astype(np.int32) + img[:, :, 3].astype(np.int32) * (255 - layer[:, :, 3]) // 255, 0, 255).astype(np.uint8)

    out_path = os.path.join(out_dir, "idle_diner_title_logo.png")
    cv2.imwrite(out_path, img)
    print(f"Generated {out_path}")
    return out_path


def create_splash_bg_pattern(out_dir=DEFAULT_OUT_DIR):
    """
    Generates rich 1080x1920 mobile splash background with warm radial gradient,
    subtle 28-ray rotating sunburst rays, and floating culinary silhouettes.
    """
    os.makedirs(out_dir, exist_ok=True)
    h, w = 1920, 1080
    cx, cy = 540, 880

    # 1. Base Radial Gradient + Sunburst
    y_grid, x_grid = np.ogrid[:h, :w]
    dist = np.sqrt((x_grid - cx) ** 2 + (y_grid - cy) ** 2)
    max_dist = math.sqrt(max(cx, w - cx) ** 2 + max(cy, h - cy) ** 2)
    norm_dist = np.clip(dist / max_dist, 0.0, 1.0)

    theta = np.arctan2(y_grid - cy, x_grid - cx)
    ray = 0.5 + 0.5 * np.sin(theta * 28)
    ray_factor = ray * 0.12 * (1.0 - 0.25 * norm_dist)
    t = np.clip(norm_dist + ray_factor, 0.0, 1.0)

    # Multi-stop radial color ramp in BGR
    b = np.zeros((h, w), dtype=np.float32)
    g = np.zeros((h, w), dtype=np.float32)
    r = np.zeros((h, w), dtype=np.float32)

    # Stop 1: 0.0 to 0.40 -> Golden sunshine yellow-orange
    m1 = t <= 0.40
    s1 = t / 0.40
    b[m1] = 45 + (50 - 45) * s1[m1]
    g[m1] = 180 + (70 - 180) * s1[m1]
    r[m1] = 255 + (225 - 255) * s1[m1]

    # Stop 2: 0.40 to 0.80 -> Warm ruby coral / crimson
    m2 = (t > 0.40) & (t <= 0.80)
    s2 = (t - 0.40) / 0.40
    b[m2] = 50 + (65 - 50) * s2[m2]
    g[m2] = 70 + (22 - 70) * s2[m2]
    r[m2] = 225 + (120 - 225) * s2[m2]

    # Stop 3: 0.80 to 1.0 -> Royal midnight plum / dark wine
    m3 = t > 0.80
    s3 = np.clip((t - 0.80) / 0.20, 0.0, 1.0)
    b[m3] = 65 + (45 - 65) * s3[m3]
    g[m3] = 22 + (12 - 22) * s3[m3]
    r[m3] = 120 + (50 - 120) * s3[m3]

    # Vignette
    vignette = 1.0 - 0.25 * np.clip((norm_dist - 0.5) / 0.5, 0.0, 1.0)
    b *= vignette
    g *= vignette
    r *= vignette

    bg = np.dstack([b, g, r]).astype(np.uint8)

    # 2. Culinary Silhouettes Overlay
    overlay = np.zeros((h, w, 4), dtype=np.uint8)

    def draw_burger(img, px, py, s=1.0, col=(255, 235, 190, 255)):
        pts_top = []
        for a in range(180, 361, 15):
            rad = math.radians(a)
            pts_top.append([px + int(36 * s * math.cos(rad)), py - int(6 * s) + int(20 * s * math.sin(rad))])
        pts_top.append([px - int(36 * s), py - int(6 * s)])
        cv2.fillPoly(img, [np.array(pts_top, np.int32)], col, cv2.LINE_AA)
        cv2.rectangle(img, (px - int(34 * s), py - int(3 * s)), (px + int(34 * s), py + int(6 * s)), col, -1)
        cv2.rectangle(img, (px - int(32 * s), py + int(9 * s)), (px + int(32 * s), py + int(18 * s)), col, -1)

    def draw_shake(img, px, py, s=1.0, col=(255, 235, 190, 255)):
        glass_pts = np.array([
            [px - int(18 * s), py - int(10 * s)],
            [px + int(18 * s), py - int(10 * s)],
            [px + int(12 * s), py + int(30 * s)],
            [px - int(12 * s), py + int(30 * s)]
        ], np.int32)
        cv2.fillPoly(img, [glass_pts], col, cv2.LINE_AA)
        cv2.rectangle(img, (px - int(4 * s), py + int(30 * s)), (px + int(4 * s), py + int(38 * s)), col, -1)
        cv2.ellipse(img, (px, py + int(40 * s)), (int(16 * s), int(4 * s)), 0, 0, 360, col, -1, cv2.LINE_AA)
        cv2.circle(img, (px, py - int(14 * s)), int(14 * s), col, -1, cv2.LINE_AA)
        cv2.circle(img, (px - int(8 * s), py - int(10 * s)), int(10 * s), col, -1, cv2.LINE_AA)
        cv2.circle(img, (px + int(8 * s), py - int(10 * s)), int(10 * s), col, -1, cv2.LINE_AA)
        cv2.line(img, (px + int(4 * s), py - int(16 * s)), (px + int(16 * s), py - int(38 * s)), col, max(1, int(3 * s)), cv2.LINE_AA)
        cv2.circle(img, (px - int(4 * s), py - int(24 * s)), int(5 * s), col, -1, cv2.LINE_AA)

    def draw_star(img, px, py, s=1.0, col=(255, 235, 190, 255)):
        pts = []
        r_out = int(22 * s)
        r_in = int(8 * s)
        for i in range(8):
            r = r_out if i % 2 == 0 else r_in
            ang = -math.pi / 2.0 + i * math.pi / 4.0
            pts.append([int(px + r * math.cos(ang)), int(py + r * math.sin(ang))])
        cv2.fillPoly(img, [np.array(pts, np.int32)], col, cv2.LINE_AA)

    def draw_cutlery(img, px, py, s=1.0, col=(255, 235, 190, 255)):
        cv2.line(img, (px - int(15 * s), py + int(20 * s)), (px + int(15 * s), py - int(20 * s)), col, max(1, int(3 * s)), cv2.LINE_AA)
        cv2.line(img, (px + int(15 * s), py + int(20 * s)), (px - int(15 * s), py - int(20 * s)), col, max(1, int(3 * s)), cv2.LINE_AA)
        cv2.circle(img, (px - int(16 * s), py - int(22 * s)), int(6 * s), col, -1, cv2.LINE_AA)

    random.seed(12345)
    items = ["burger", "shake", "star", "cutlery"]
    cols = 6
    rows = 11
    step_x = w // cols
    step_y = h // rows

    for r_idx in range(rows):
        for c_idx in range(cols):
            px = int((c_idx + 0.5) * step_x + random.uniform(-25, 25))
            py = int((r_idx + 0.5) * step_y + random.uniform(-25, 25))
            scale = random.uniform(0.75, 1.15)
            item_type = items[(r_idx * cols + c_idx) % len(items)]
            if item_type == "burger":
                draw_burger(overlay, px, py, scale)
            elif item_type == "shake":
                draw_shake(overlay, px, py, scale)
            elif item_type == "star":
                draw_star(overlay, px, py, scale)
            elif item_type == "cutlery":
                draw_cutlery(overlay, px, py, scale)

    # Blend overlay with 0.14 weight into bg
    overlay_a = (overlay[:, :, 3].astype(np.float32) / 255.0) * 0.14
    final_img = bg.copy()
    for ch in range(3):
        final_img[:, :, ch] = np.clip(
            final_img[:, :, ch] * (1.0 - overlay_a) + overlay[:, :, ch] * overlay_a,
            0, 255
        ).astype(np.uint8)

    final_img = np.dstack([final_img, np.full((h, w), 255, dtype=np.uint8)])

    out_path = os.path.join(out_dir, "splash_bg_pattern.png")
    cv2.imwrite(out_path, final_img)
    print(f"Generated {out_path}")
    return out_path


def generate_all(out_dir=DEFAULT_OUT_DIR):
    """Generates all brand and splash assets."""
    print(f"=== Generating Brand Assets in {out_dir} ===")
    p1 = create_dr_rank_logo(out_dir)
    p2 = create_idle_diner_title_logo(out_dir)
    p3 = create_splash_bg_pattern(out_dir)
    print("All brand assets successfully generated!")
    return [p1, p2, p3]


if __name__ == "__main__":
    generate_all()
