import os
from PIL import Image, ImageDraw

def make_dirs(base_path):
    dirs = [
        "characters", "enemies", "bosses", "weapons", 
        "items", "resources", "vfx", "ui",
        "environment/emberwild", "environment/frostgrave",
        "environment/verdant", "environment/void"
    ]
    for d in dirs:
        os.makedirs(os.path.join(base_path, d), exist_ok=True)

def generate_single_character_sprite(path, size, main_color, accent_color):
    # Generates EXACTLY 1 single-frame sprite (e.g. 24x24) so Sprite2D NEVER shows multiple frames
    w, h = size
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Body rectangle with outline
    draw.rectangle([4, 4, w - 5, h - 5], fill=main_color, outline=(20, 20, 30, 255))
    # Visor / Head accent
    draw.rectangle([7, 6, w - 8, 9], fill=accent_color)
    # Feet
    draw.rectangle([5, h - 4, 9, h - 1], fill=(30, 30, 40, 255))
    draw.rectangle([w - 10, h - 4, w - 6, h - 1], fill=(30, 30, 40, 255))

    img.save(path)

def generate_weapon_icon(path, blade_color, hilt_color):
    img = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.line([(3, 13), (12, 4)], fill=blade_color, width=2)
    draw.rectangle([2, 12, 5, 14], fill=hilt_color)
    img.save(path)

def generate_biome_tile(path, top_color, body_color):
    img = Image.new("RGBA", (16, 16), body_color)
    draw = ImageDraw.Draw(img)
    draw.rectangle([0, 0, 15, 3], fill=top_color)
    draw.line([(0, 0), (15, 0)], fill=(255, 255, 255, 100))
    img.save(path)

def main():
    base_path = "d:/DULIEU/lamgame/Roguelands/art"
    make_dirs(base_path)

    # 1. Player & Characters (Single 24x24 frame images)
    generate_single_character_sprite(f"{base_path}/characters/player_idle.png", (24, 24), (40, 140, 220, 255), (0, 240, 255, 255))
    generate_single_character_sprite(f"{base_path}/characters/player_walk.png", (24, 24), (40, 140, 220, 255), (0, 240, 255, 255))

    # 2. Enemies (Single frame images)
    generate_single_character_sprite(f"{base_path}/enemies/ash_beetle.png", (24, 24), (220, 60, 40, 255), (255, 180, 0, 255))
    generate_single_character_sprite(f"{base_path}/enemies/frost_stalker.png", (24, 32), (100, 200, 240, 255), (255, 255, 255, 255))
    generate_single_character_sprite(f"{base_path}/enemies/flying_drone.png", (24, 24), (160, 60, 220, 255), (220, 100, 255, 255))
    generate_single_character_sprite(f"{base_path}/enemies/exploder_bug.png", (24, 24), (240, 160, 0, 255), (255, 0, 0, 255))
    generate_single_character_sprite(f"{base_path}/enemies/iron_golem.png", (48, 48), (100, 100, 110, 255), (30, 30, 35, 255))
    generate_single_character_sprite(f"{base_path}/enemies/void_lurker.png", (32, 32), (180, 0, 255, 255), (50, 0, 80, 255))
    generate_single_character_sprite(f"{base_path}/bosses/molten_warden.png", (96, 96), (255, 100, 0, 255), (80, 20, 0, 255))

    # 3. Weapons
    generate_weapon_icon(f"{base_path}/weapons/plasma_blade.png", (0, 240, 255, 255), (40, 40, 60, 255))
    generate_weapon_icon(f"{base_path}/weapons/void_blade.png", (180, 0, 255, 255), (40, 0, 60, 255))
    generate_weapon_icon(f"{base_path}/weapons/frost_rifle.png", (120, 220, 255, 255), (50, 50, 80, 255))
    generate_weapon_icon(f"{base_path}/weapons/ember_staff.png", (255, 120, 0, 255), (80, 40, 0, 255))

    # 4. Biome Tilesets
    generate_biome_tile(f"{base_path}/environment/emberwild/floor.png", (255, 100, 20, 255), (60, 30, 30, 255))
    generate_biome_tile(f"{base_path}/environment/frostgrave/floor.png", (220, 245, 255, 255), (80, 130, 180, 255))
    generate_biome_tile(f"{base_path}/environment/verdant/floor.png", (80, 200, 80, 255), (40, 90, 40, 255))
    generate_biome_tile(f"{base_path}/environment/void/floor.png", (180, 40, 220, 255), (40, 15, 60, 255))

    print("Single-frame character sprites generated successfully!")

if __name__ == "__main__":
    main()
