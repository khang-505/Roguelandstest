# ROGUELANDS CLONE — ART STYLE GUIDE

## 1. Pixel Resolution & Scaling
- **Base Resolution:** Designed for a retro feel. The game camera should render at a low base resolution (e.g., 480x270 or 640x360) and scale up to the window size.
- **Texture Filtering:** Strictly `Nearest` filtering. No bilinear or trilinear blur.
- **Subpixel Rendering:** Disabled. Sprites should snap to pixels if possible, or maintain consistent pixel density.

## 2. Sprite Sizes
- **Player:** ~24x24 to 32x32 pixels.
- **Small Enemies (Swarm Drone, Ash Beetle):** ~16x16 to 24x24 pixels.
- **Large Enemies (Iron Golem, Void Lurker):** ~48x48 pixels.
- **Boss (Molten Warden):** ~96x96 pixels (massive screen presence).
- **Weapons/Items:** ~16x16 pixels.
- **Environment Props:** ~16x16 to 32x32 pixels.
- **Tiles:** 16x16 pixels per block.

## 3. Tile Size
- **Base Grid:** 16x16 pixels. Level generation and static platform collisions must align with this grid.

## 4. Palette
A limited, high-contrast palette inspired by 16-bit Sci-Fi/Fantasy.
- **Shadows:** Deep, cool colors (Dark Purple `#1a0f2e`, Dark Blue `#0d1b2a`). Avoid pure black `#000000`.
- **Highlights:** High saturation, glowing colors (Cyan `#00f0ff`, Neon Pink `#ff007f`, Magma Orange `#ff5e00`).

## 5. Outline Rules
- **Gameplay Entities (Player, Enemies, Boss, Items, Resources):** Must have a 1-pixel dark outline (not pure black, but a very dark shade of their base color) to pop out from the background.
- **Environment (Ground, Walls, BG):** No outline or very subtle internal borders to prevent visual clutter and keep focus on entities.

## 6. Shadow Rules
- **Drop Shadows:** All characters and dynamic objects should cast a simple semi-transparent oval shadow directly beneath them (`Color(0, 0, 0, 0.4)`).
- **Shading:** Sprites should use simple cell-shading (2-3 shades per color maximum). Light source is generally top-down or top-left.

## 7. Lighting Rules
- Use stylized `PointLight2D` (or Glow via `WorldEnvironment`) for energy weapons, lava, crystals, and boss cores.
- Lighting should not wash out the pixel art colors. Limit the use of gradient lights; favor sharp, distinct glows.

## 8. Biome Colors
- **Emberwild:** Dark charcoal/obsidian ground. Bright orange/red/yellow accents (lava, ember crystals).
- **Frostgrave:** Pale blue/white ground. Cyan and deep blue accents (ice formations).
- **Verdant Abyss:** Dark olive/brown ground. Toxic green and bright yellow-green accents (alien flora).
- **Alien Void:** Deep space purple/black ground. Magenta and cyan accents (cosmic energy).

## 9. Enemy Readability
- **Silhouettes:** Must instantly convey behavior. (e.g., bulky = slow tank, slender/spiky = fast attacker).
- **Color Coding:** Enemies should contrast with their native biome if possible, or feature brightly colored weak points/eyes that stand out.

## 10. Boss Readability
- **Scale:** At least 3x the size of the player.
- **Visual Phases:** 
  - Phase 1: Normal colors.
  - Phase 2/3: Core colors shift (e.g., orange to white-hot), glow intensity increases, emission of ambient particles.

## 11. VFX Rules
- **Style:** Short, snappy, pixelated bursts. Use `CPUParticles2D` with square/pixel textures, NOT soft blurred circles.
- **Hit Feedback:** White flash (1-2 frames) + directional pixel sparks.
- **Death:** Explosion of pixels matching the entity's primary color, quickly fading/shrinking.

## 12. UI Rules
- **Theme:** Dark translucent panels (`Color(0.1, 0.1, 0.15, 0.8)`) with 1-pixel bright borders (e.g., cyan or gold for rare items).
- **Font:** A crisp pixel font (or default Godot font forced to no-antialiasing).
- **Icons:** Flat, recognizable 16x16 pixel icons. Colors dictate rarity (White, Green, Blue, Purple, Gold).
