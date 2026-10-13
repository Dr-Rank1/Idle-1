#!/usr/bin/env python3
import random
from PIL import Image, ImageDraw, ImageFilter

def create_wood_parquet(width=512, height=512, output_path="assets/textures/wood_parquet.png"):
    img = Image.new("RGB", (width, height), (195, 138, 92))
    draw = ImageDraw.Draw(img)
    
    num_rows = 8
    row_height = height // num_rows
    
    plank_colors = [
        (205, 148, 98),
        (192, 135, 88),
        (215, 158, 105),
        (185, 128, 82),
        (210, 152, 100),
        (198, 142, 92),
        (188, 132, 85),
        (208, 150, 96),
    ]
    
    plank_w = width // 3
    
    for r in range(num_rows):
        y0 = r * row_height
        y1 = y0 + row_height
        offset = (r * 113) % plank_w
        
        for p in range(-1, 5):
            x0 = p * plank_w + offset
            x1 = x0 + plank_w
            
            rx0 = max(0, min(width, x0))
            rx1 = max(0, min(width, x1))
            if rx1 <= rx0:
                continue
                
            c = plank_colors[(r * 3 + p) % len(plank_colors)]
            draw.rectangle([rx0, y0, rx1, y1], fill=c)
            
            # Subtle wood grain lines inside each plank
            for gx in range(rx0 + 10, rx1 - 5, 16):
                grain_c = (max(0, c[0] - 8), max(0, c[1] - 6), max(0, c[2] - 5))
                draw.line([(gx, y0 + 1), (gx, y1 - 1)], fill=grain_c, width=1)
                
            # Grooves
            groove_c = (115, 72, 40)
            highlight_c = (235, 180, 130)
            draw.line([(rx0, y0), (rx1, y0)], fill=highlight_c, width=1)
            draw.line([(rx0, y1 - 1), (rx1, y1 - 1)], fill=groove_c, width=2)
            if 0 < x1 < width:
                draw.line([(x1 - 1, y0), (x1 - 1, y1)], fill=groove_c, width=2)
                draw.line([(x1, y0), (x1, y1)], fill=highlight_c, width=1)
                
    img = img.filter(ImageFilter.GaussianBlur(radius=0.4))
    img.save(output_path)
    print(f"Saved {output_path}")

def create_kitchen_tiles(width=512, height=512, output_path="assets/textures/kitchen_tiles.png"):
    img = Image.new("RGB", (width, height), (210, 215, 220))
    draw = ImageDraw.Draw(img)
    
    tiles = 8
    tile_size = width // tiles
    
    tile_c1 = (248, 250, 252) # Clean off-white porcelain
    tile_c2 = (145, 160, 175) # Chic slate blue-gray
    grout_c = (90, 100, 110) # Grout line
    
    for r in range(tiles):
        for c in range(tiles):
            x0 = c * tile_size
            y0 = r * tile_size
            x1 = x0 + tile_size
            y1 = y0 + tile_size
            
            fill_c = tile_c1 if (r + c) % 2 == 0 else tile_c2
            draw.rectangle([x0, y0, x1, y1], fill=fill_c)
            
            hi = tuple(min(255, val + 15) for val in fill_c)
            draw.line([(x0 + 1, y0 + 1), (x1 - 2, y0 + 1)], fill=hi, width=1)
            draw.line([(x0 + 1, y0 + 1), (x0 + 1, y1 - 2)], fill=hi, width=1)
            
            draw.rectangle([x0, y0, x1, y1], outline=grout_c, width=2)
            
    img = img.filter(ImageFilter.GaussianBlur(radius=0.3))
    img.save(output_path)
    print(f"Saved {output_path}")

def create_sidewalk_paving(width=512, height=512, output_path="assets/textures/sidewalk_tiles.png"):
    img = Image.new("RGB", (width, height), (218, 215, 210))
    draw = ImageDraw.Draw(img)
    
    tiles_x = 4
    tiles_y = 4
    sx = width // tiles_x
    sy = height // tiles_y
    
    colors = [
        (225, 222, 218),
        (215, 212, 207),
        (220, 218, 213),
        (212, 209, 204),
    ]
    
    for r in range(tiles_y):
        for c in range(tiles_x):
            x0 = c * sx
            y0 = r * sy
            x1 = x0 + sx
            y1 = y0 + sy
            fill_c = colors[(r * 2 + c) % len(colors)]
            draw.rectangle([x0, y0, x1, y1], fill=fill_c)
            draw.rectangle([x0, y0, x1, y1], outline=(160, 155, 150), width=2)
            
    img = img.filter(ImageFilter.GaussianBlur(radius=0.3))
    img.save(output_path)
    print(f"Saved {output_path}")

if __name__ == "__main__":
    create_wood_parquet()
    create_kitchen_tiles()
    create_sidewalk_paving()
