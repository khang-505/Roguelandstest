import os
from PIL import Image, ImageDraw
import random

def make_dirs(base_path):
    dirs = [
        "characters", "enemies", "bosses", "weapons", 
        "items", "resources", "vfx", "ui",
        "environment/emberwild", "environment/frostgrave",
        "environment/verdant", "environment/void"
    ]
    for d in dirs:
        os.makedirs(os.path.join(base_path, d), exist_ok=True)

def generate_mirrored_sprite(size, color, outline_color, path):
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    w, h = size
    
    # Generate random mirrored pixel art
    for y in range(2, h-2):
        for x in range(2, w//2):
            if random.random() > 0.4:
                draw.point((x, y), fill=color)
                draw.point((w - 1 - x, y), fill=color)
                
    # Basic outline logic
    pixels = img.load()
    for y in range(h):
        for x in range(w):
            if pixels[x, y][3] > 0 and pixels[x, y] != outline_color:
                # check neighbors
                neighbors = [(x-1,y), (x+1,y), (x,y-1), (x,y+1)]
                for nx, ny in neighbors:
                    if 0 <= nx < w and 0 <= ny < h:
                        if pixels[nx, ny][3] == 0:
                            draw.point((nx, ny), fill=outline_color)

    img.save(path)

def generate_simple_rect_sprite(size, inner_color, border_color, path):
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rectangle([1, 1, size[0]-2, size[1]-2], fill=inner_color, outline=border_color)
    img.save(path)

def generate_tile(size, base_color, noise_color, path):
    img = Image.new("RGBA", size, base_color)
    draw = ImageDraw.Draw(img)
    for _ in range(5):
        rx, ry = random.randint(0, size[0]-1), random.randint(0, size[1]-1)
        draw.point((rx, ry), fill=noise_color)
    img.save(path)

def main():
    base_path = "d:/DULIEU/lamgame/Roguelands/art"
    make_dirs(base_path)

    # 1. Characters
    generate_mirrored_sprite((24, 24), (200, 200, 200, 255), (40, 40, 40, 255), f"{base_path}/characters/player_idle.png")
    generate_mirrored_sprite((24, 24), (200, 200, 200, 255), (40, 40, 40, 255), f"{base_path}/characters/player_walk.png")

    # 2. Enemies
    generate_mirrored_sprite((24, 24), (200, 50, 50, 255), (50, 10, 10, 255), f"{base_path}/enemies/ash_beetle.png")
    generate_mirrored_sprite((24, 32), (50, 200, 255, 255), (10, 40, 50, 255), f"{base_path}/enemies/frost_stalker.png")
    generate_mirrored_sprite((16, 16), (150, 50, 200, 255), (40, 10, 50, 255), f"{base_path}/enemies/swarm_drone.png")
    generate_mirrored_sprite((48, 48), (100, 100, 110, 255), (30, 30, 35, 255), f"{base_path}/enemies/iron_golem.png")
    generate_mirrored_sprite((32, 32), (180, 0, 255, 255), (50, 0, 80, 255), f"{base_path}/enemies/void_lurker.png")

    # 3. Boss
    generate_mirrored_sprite((96, 96), (255, 100, 0, 255), (80, 20, 0, 255), f"{base_path}/bosses/molten_warden.png")

    # 4. Weapons & Items
    generate_mirrored_sprite((16, 16), (0, 255, 200, 255), (0, 50, 40, 255), f"{base_path}/weapons/plasma_blade.png")
    generate_mirrored_sprite((16, 16), (200, 200, 255, 255), (50, 50, 80, 255), f"{base_path}/items/health_potion.png")
    generate_mirrored_sprite((16, 16), (255, 255, 0, 255), (80, 80, 0, 255), f"{base_path}/items/coin.png")

    # 5. Resources
    generate_mirrored_sprite((24, 24), (255, 150, 0, 255), (100, 50, 0, 255), f"{base_path}/resources/ember_crystal.png")

    # 6. Environment Tiles
    # Emberwild
    generate_tile((16, 16), (60, 40, 40, 255), (80, 50, 50, 255), f"{base_path}/environment/emberwild/floor.png")
    generate_tile((16, 16), (40, 20, 20, 255), (30, 15, 15, 255), f"{base_path}/environment/emberwild/wall.png")
    # Frostgrave
    generate_tile((16, 16), (200, 240, 255, 255), (255, 255, 255, 255), f"{base_path}/environment/frostgrave/floor.png")
    generate_tile((16, 16), (100, 150, 200, 255), (80, 120, 180, 255), f"{base_path}/environment/frostgrave/wall.png")
    # Verdant
    generate_tile((16, 16), (40, 80, 40, 255), (50, 100, 50, 255), f"{base_path}/environment/verdant/floor.png")
    generate_tile((16, 16), (20, 50, 20, 255), (15, 40, 15, 255), f"{base_path}/environment/verdant/wall.png")
    # Void
    generate_tile((16, 16), (30, 10, 40, 255), (40, 15, 60, 255), f"{base_path}/environment/void/floor.png")
    generate_tile((16, 16), (20, 5, 30, 255), (15, 0, 20, 255), f"{base_path}/environment/void/wall.png")

    # 7. VFX
    generate_simple_rect_sprite((4, 4), (255, 255, 255, 255), (200, 200, 200, 255), f"{base_path}/vfx/spark.png")
    generate_mirrored_sprite((16, 16), (255, 255, 255, 255), (100, 100, 100, 255), f"{base_path}/vfx/slash.png")

    # 8. UI
    generate_simple_rect_sprite((32, 32), (30, 30, 40, 200), (100, 100, 120, 255), f"{base_path}/ui/panel.png")

    print("Procedural Pixel Art generated successfully in res://art/")

if __name__ == "__main__":
    main()
