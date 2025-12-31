# Art Pipeline - "The Handshake"

> **Purpose**: Instructions for how assets are named and imported (Crucial for the "Artist" partner).

## Naming Convention

### File Naming Pattern
```
type_location_name_variant.png
```

### Examples
- `bg_room01_mountains_far.png` - Background for room 01 showing mountains (far layer)
- `bg_room01_mountains_mid.png` - Same room, different depth layer
- `char_player_idle_v01.png` - Character sprite for player idle animation (version 01)
- `prop_temple_pillar_broken.png` - Prop asset for broken temple pillar
- `fx_saree_shimmer_gold.png` - Visual effect for saree shimmer (gold variant)

### Type Prefixes
- `bg_` - Background layers
- `char_` - Character sprites
- `prop_` - Environmental props/objects
- `fx_` - Visual effects
- `ui_` - User interface elements
- `tile_` - Tileset elements

## Import Settings

### Texture Import Configuration
- **Filter**: Linear
- **Mipmaps**: On (for zooming support)
- **Debanding**: On (smooth gradients)
- **Compression**: Lossless (preserve high-res quality)

### Source Files
- **Format**: PNG with transparency
- **Resolution**: 4K source files
- **Color Space**: sRGB

## Asset Organization

### Directory Structure
```
res://assets/
  ├── backgrounds/
  ├── characters/
  ├── props/
  ├── effects/
  └── ui/
```

### Version Control
- Keep original 4K source files
- Use version suffixes for iterations (e.g., `_v01`, `_v02`)
- Document significant changes in asset notes


# 03 Art Pipeline & Standards

## 1. Source Specification (The "Truth")
To ensure compatibility with PS5 and High-DPI Steam displays:
- **Master Canvas Size:** 3840 x 2160 px (4K UHD).
- **Color Profile:** sRGB IEC61966-2.1 (Strict adherence to prevent color shifting).
- **Bit Depth:** 8-bit or 16-bit.
- **DPI:** 300 (standard for source files, though engine ignores metadata).

## 2. Export Standards
All assets must be exported from Procreate/Pixaki as:
- **Format:** PNG-24 (Transparent).
- **Alpha:** Pre-multiplied Alpha is handled by Godot, but source PNGs should have transparent backgrounds (no "Paper" layers active).
- **Trimming:** Assets should be cropped to their visual content (remove empty transparent space) to optimize VRAM, *unless* they are full-screen background layers.

## 3. The "Saree" Special Requirements
The Saree is a physics object, not a sprite animation.
- **Texture Mode:** Tileable.
- **Source Segment:** 512x512px or 1024x1024px.
- **Seamless Rule:** The LEFT edge of the texture must match the RIGHT edge pixel-perfectly.
- **Orientation:** Draw the fabric pattern flowing Horizontally (Left to Right).

## 4. Layering & Depth (Parallax Strategy)
Scene files must be composed of these standardized depth layers (z-index):
- **Layer 5 (Foreground):** Large, blurry vignette elements (Leaves, Pillars).
- **Layer 0 (Play Area):** "StaticBody2D" collision objects. The visual floor.
- **Layer -5 (Mid-Ground):** Decorative non-collidable elements immediately behind the player.
- **Layer -10 to -50 (Background):** Distant mountains/skies. Moving slowly via `ParallaxLayer`.

## 5. Naming Convention (Strict)
Agents and Scripts will rely on this pattern to auto-load resources. Use `snake_case`.

`category_location_description_variant.png`

**Examples:**
- `bg_room01_mountain_far.png`
- `prop_forest_statue_broken.png`
- `char_saree_pattern_gold.png`
- `ui_hud_health_bar.png`

## 6. Godot Import Settings
**Crucial for the "Watercolor" Aesthetic:**
- **Texture Filter:** `Linear` (Do NOT use Nearest/Pixel style).
- **Mipmaps:** `Generate` (Essential for the "Snap Camera" zooming to prevent shimmering artifacts).
- **Anisotropy:** `4x` (For clearer textures at oblique angles, if 3D elements are added later).
- **Debanding:** Enabled in Project Settings (Prevents "stripes" in soft gradients).

## 7. Scale Reference
- **1 Meter (Physics)** = **100 Pixels**.
- **Player Height:** ~360px (at Standard Zoom).