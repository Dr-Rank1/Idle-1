#!/usr/bin/env python3
import os
from PIL import Image, ImageDraw, ImageFilter, ImageFont

def make_bistro_canopy(width=512, height=512, out_path="assets/textures/bistro_canopy.png"):
    img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 8 vertical stripes: alternating burgundy red and warm cream
    c_red = (175, 32, 38, 255)
    c_cream = (252, 246, 235, 255)
    c_red_shade = (145, 24, 28, 255)
    c_cream_shade = (230, 222, 208, 255)
    c_gold = (218, 168, 62, 255)
    
    num_stripes = 10
    stripe_w = width / num_stripes
    
    for i in range(num_stripes):
        x0 = int(i * stripe_w)
        x1 = int((i + 1) * stripe_w)
        is_red = (i % 2 == 0)
        col = c_red if is_red else c_cream
        shade = c_red_shade if is_red else c_cream_shade
        
        # Base stripe
        draw.rectangle([x0, 0, x1, height], fill=col)
        # Subtle cylindrical fabric volume shading along edges of each stripe
        draw.line([(x0, 0), (x0, height)], fill=shade, width=2)
        draw.line([(x1 - 1, 0), (x1 - 1, height)], fill=shade, width=2)
        
    # Gold piping trim near front valance drop
    valance_y = int(height * 0.82)
    draw.line([(0, valance_y), (width, valance_y)], fill=c_gold, width=6)
    
    # Scalloped valance bottom edge
    num_scallops = num_stripes
    scallop_w = width / num_scallops
    for i in range(num_scallops):
        sx0 = i * scallop_w
        sx1 = (i + 1) * scallop_w
        sy = height - 14
        # gold fringe dot
        draw.ellipse([sx0 + scallop_w * 0.35, sy, sx1 - scallop_w * 0.35, height - 2], fill=c_gold)
        
    img.save(out_path)
    print(f"Saved {out_path}")

def make_bistro_canopy_slope(width=512, height=512, out_path="assets/textures/bistro_canopy_slope.png"):
    img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    c_red = (175, 32, 38, 255)
    c_cream = (252, 246, 235, 255)
    c_red_shade = (145, 24, 28, 255)
    c_cream_shade = (230, 222, 208, 255)
    c_gold = (218, 168, 62, 255)
    
    num_stripes = 10
    stripe_h = height / num_stripes
    
    for i in range(num_stripes):
        y0 = int(i * stripe_h)
        y1 = int((i + 1) * stripe_h)
        is_red = (i % 2 == 0)
        col = c_red if is_red else c_cream
        shade = c_red_shade if is_red else c_cream_shade
        
        draw.rectangle([0, y0, width, y1], fill=col)
        draw.line([(0, y0), (width, y0)], fill=shade, width=2)
        draw.line([(0, y1 - 1), (width, y1 - 1)], fill=shade, width=2)
        
    img.save(out_path)
    print(f"Saved {out_path}")

def make_neon_sign(width=512, height=256, out_path="assets/textures/neon_bistro_sign.png"):
    img = Image.new("RGBA", (width, height), (15, 18, 24, 240))
    draw = ImageDraw.Draw(img)
    
    # Outer dark acrylic backing with brass bezel
    draw.rounded_rectangle([6, 6, width - 7, height - 7], radius=18, outline=(220, 175, 75, 255), width=4)
    draw.rounded_rectangle([14, 14, width - 15, height - 15], radius=14, outline=(40, 50, 65, 255), width=2)
    
    # Glowing neon tube border (vibrant magenta/coral)
    glow_col = (255, 65, 120, 255)
    draw.rounded_rectangle([20, 20, width - 21, height - 21], radius=12, outline=glow_col, width=4)
    
    # Neon texts using default font with thick simulated neon glow
    try:
        font_large = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 46)
        font_small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 26)
    except:
        font_large = ImageFont.load_default()
        font_small = ImageFont.load_default()
        
    # Text 1: "CHEF'S BISTRO"
    t1 = "CHEF'S BISTRO"
    bbox1 = draw.textbbox((0, 0), t1, font=font_large)
    t1_w = bbox1[2] - bbox1[0]
    t1_x = (width - t1_w) // 2
    t1_y = 48
    
    # Neon glow layers (outer glow, inner tube core)
    for offset in [-3, -2, -1, 1, 2, 3]:
        draw.text((t1_x + offset, t1_y), t1, font=font_large, fill=(255, 60, 110, 160))
        draw.text((t1_x, t1_y + offset), t1, font=font_large, fill=(255, 60, 110, 160))
    # Hot white core
    draw.text((t1_x, t1_y), t1, font=font_large, fill=(255, 230, 240, 255))
    
    # Text 2: "★ OPEN ★" in electric cyan neon
    t2 = "★ OPEN ★"
    bbox2 = draw.textbbox((0, 0), t2, font=font_small)
    t2_w = bbox2[2] - bbox2[0]
    t2_x = (width - t2_w) // 2
    t2_y = 145
    
    for offset in [-2, -1, 1, 2]:
        draw.text((t2_x + offset, t2_y), t2, font=font_small, fill=(0, 230, 200, 180))
        draw.text((t2_x, t2_y + offset), t2, font=font_small, fill=(0, 230, 200, 180))
    draw.text((t2_x, t2_y), t2, font=font_small, fill=(225, 255, 250, 255))
    
    # Subtle stars / accents
    draw.text((36, 142), "★", font=font_small, fill=(255, 215, 60, 255))
    draw.text((width - 64, 142), "★", font=font_small, fill=(255, 215, 60, 255))
    
    img.save(out_path)
    print(f"Saved {out_path}")

if __name__ == "__main__":
    make_bistro_canopy()
    make_bistro_canopy_slope()
    make_neon_sign()
