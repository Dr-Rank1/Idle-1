from PIL import Image, ImageDraw, ImageFont
import os

TEXTURES_DIR = "/home/ian/Documents/Apps/idle game 1/restaurant_tycoon_3d/assets/textures"
os.makedirs(TEXTURES_DIR, exist_ok=True)

# 1. TV Screen Broadcast Texture (512x288, 16:9)
def make_tv_texture():
    im = Image.new("RGBA", (512, 288), (20, 24, 34, 255))
    draw = ImageDraw.Draw(im)
    
    # Gradient stadium / cooking show background
    for y in range(288):
        ratio = y / 288.0
        r = int(30 + ratio * 40)
        g = int(60 + ratio * 80)
        b = int(120 + ratio * 60)
        draw.line([(0, y), (512, y)], fill=(r, g, b, 255))
    
    # TV Show graphic: Big golden burger / plate illustration
    draw.ellipse([200, 70, 312, 182], fill=(240, 180, 50, 255), outline=(255, 230, 120, 255), width=4)
    # Burger bun top
    draw.chord([216, 85, 296, 155], start=180, end=360, fill=(210, 130, 40, 255))
    # Lettuce
    draw.rectangle([212, 122, 300, 130], fill=(80, 200, 60, 255))
    # Patty
    draw.rectangle([214, 130, 298, 142], fill=(120, 50, 20, 255))
    # Cheese
    draw.polygon([(216, 136), (294, 136), (280, 148), (250, 146)], fill=(255, 210, 30, 255))
    # Bottom bun
    draw.rectangle([218, 142, 294, 154], fill=(210, 130, 40, 255))
    
    # Channel header & score ticker
    draw.rectangle([0, 0, 512, 40], fill=(15, 18, 25, 230))
    draw.rectangle([16, 8, 110, 32], fill=(230, 50, 50, 255)) # "LIVE" badge
    draw.rectangle([0, 252, 512, 288], fill=(10, 12, 18, 240)) # Lower third ticker
    draw.rectangle([0, 252, 140, 288], fill=(240, 160, 20, 255)) # Headline tag
    
    out_path = os.path.join(TEXTURES_DIR, "tv_screen.png")
    im.save(out_path)
    print("Saved TV texture to", out_path)

# 2. Wall Art: Framed Bistro Poster 1 (Food / Burger)
def make_wall_art_food():
    im = Image.new("RGBA", (256, 384), (250, 246, 238, 255))
    draw = ImageDraw.Draw(im)
    
    # Outer dark walnut wooden frame
    draw.rectangle([0, 0, 255, 383], fill=(45, 26, 14, 255))
    # Gold fillet
    draw.rectangle([12, 12, 243, 371], fill=(210, 175, 95, 255))
    # Off-white matte border
    draw.rectangle([18, 18, 237, 365], fill=(248, 245, 238, 255))
    
    # Inner artwork area (vintage bistro poster style)
    draw.rectangle([34, 34, 221, 349], fill=(225, 75, 60, 255))
    # Cream oval center
    draw.ellipse([46, 60, 209, 290], fill=(252, 248, 235, 255), outline=(210, 175, 95, 255), width=3)
    
    # French Chef Toque & Crossed Whisks graphic
    draw.ellipse([100, 100, 156, 150], fill=(255, 255, 255, 255), outline=(40, 40, 40, 255), width=2)
    draw.rectangle([108, 140, 148, 160], fill=(255, 255, 255, 255), outline=(40, 40, 40, 255), width=2)
    # Heart
    draw.polygon([(128, 215), (105, 185), (115, 170), (128, 180), (141, 170), (151, 185)], fill=(225, 75, 60, 255))
    
    # Banner strip
    draw.rectangle([50, 240, 206, 275], fill=(30, 45, 70, 255))
    
    out_path = os.path.join(TEXTURES_DIR, "wall_art_chef.png")
    im.save(out_path)
    print("Saved Chef art to", out_path)

# 3. Wall Art: Framed Wine & Coffee Poster 2
def make_wall_art_cafe():
    im = Image.new("RGBA", (256, 384), (250, 246, 238, 255))
    draw = ImageDraw.Draw(im)
    
    # Frame
    draw.rectangle([0, 0, 255, 383], fill=(45, 26, 14, 255))
    draw.rectangle([12, 12, 243, 371], fill=(210, 175, 95, 255))
    draw.rectangle([18, 18, 237, 365], fill=(248, 245, 238, 255))
    
    # Inner artwork area (sage green / olive bistro style)
    draw.rectangle([34, 34, 221, 349], fill=(55, 95, 80, 255))
    draw.ellipse([46, 60, 209, 290], fill=(252, 248, 235, 255), outline=(210, 175, 95, 255), width=3)
    
    # Coffee cup & steam
    draw.rectangle([105, 150, 151, 190], fill=(160, 80, 40, 255), outline=(60, 30, 10, 255), width=2)
    draw.ellipse([140, 158, 162, 182], outline=(60, 30, 10, 255), width=3) # handle
    draw.ellipse([92, 186, 164, 198], fill=(230, 230, 230, 255), outline=(60, 30, 10, 255), width=2) # saucer
    
    # Warm rays / coffee beans
    draw.ellipse([115, 110, 123, 125], fill=(110, 60, 30, 255))
    draw.ellipse([133, 108, 141, 123], fill=(110, 60, 30, 255))
    
    # Banner strip
    draw.rectangle([50, 240, 206, 275], fill=(185, 135, 60, 255))
    
    out_path = os.path.join(TEXTURES_DIR, "wall_art_cafe.png")
    im.save(out_path)
    print("Saved Cafe art to", out_path)

# 4. Rich Wall Material Texture with Wood Wainscoting
def make_wall_wainscot_texture():
    # 512x512 tileable horizontally
    im = Image.new("RGBA", (512, 512), (246, 242, 233, 255))
    draw = ImageDraw.Draw(im)
    
    # Upper wall: warm elegant cream plaster with subtle vertical texture
    for x in range(0, 512, 4):
        tint = 244 + (x % 7)
        draw.line([(x, 0), (x, 320)], fill=(tint, tint - 4, tint - 12, 255))
    
    # Chair rail / dado moulding at y = 320 to 335
    draw.rectangle([0, 318, 512, 322], fill=(60, 38, 22, 255))
    draw.rectangle([0, 322, 512, 332], fill=(95, 62, 38, 255))
    draw.rectangle([0, 332, 512, 336], fill=(50, 30, 16, 255))
    
    # Lower wainscoting paneling (y = 336 to 480)
    # Elegant warm bistro sage/navy or warm wood paneling
    draw.rectangle([0, 336, 512, 480], fill=(85, 55, 34, 255)) # rich wood
    # Recessed panels
    for i in range(4):
        px1 = i * 128 + 10
        px2 = (i + 1) * 128 - 10
        # Shadow
        draw.rectangle([px1, 348, px2, 470], fill=(70, 44, 26, 255))
        # Inner highlight
        draw.rectangle([px1 + 4, 352, px2 - 4, 466], fill=(98, 64, 40, 255))
    
    # Skirting board / baseboard (y = 480 to 512)
    draw.rectangle([0, 480, 512, 488], fill=(60, 36, 20, 255))
    draw.rectangle([0, 488, 512, 512], fill=(45, 26, 14, 255))
    
    out_path = os.path.join(TEXTURES_DIR, "wall_wainscot.png")
    im.save(out_path)
    print("Saved Wainscot wall texture to", out_path)

if __name__ == "__main__":
    make_tv_texture()
    make_wall_art_food()
    make_wall_art_cafe()
    make_wall_wainscot_texture()
