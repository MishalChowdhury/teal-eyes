# Background Art Dimensions Specification

> **Purpose**: Exact dimensions for background assets to match room templates  
> **For**: Designer/Artist reference  
> **Date**: 2026-01-03

---

## Summary Table

| Room Template | Canvas Size | Camera Zoom | Viewport Coverage | Asset Location |
|---------------|-------------|-------------|-------------------|----------------|
| **Far (Epic)** | 7680 × 3240 px | 0.3× (zoomed out) | ~4 screens wide | `assets/art/environment/backgrounds/` |
| **Mid (Platform)** | 3840 × 2160 px | 0.8× | ~2 screens wide | `assets/art/environment/backgrounds/` |
| **Close (Puzzle)** | 2560 × 2160 px | 1.2× (zoomed in) | ~1.3 screens wide | `assets/art/environment/backgrounds/` |
| **Intimate (Emotional)** | 1920 × 2160 px | 1.5× (very close) | Exactly 1 screen wide | `assets/art/environment/backgrounds/` |

**Base Viewport**: 1920 × 1080 px (16:9 aspect ratio)

---

## Detailed Specifications

### 1. RoomTemplate_Far (Epic Scale)

**Use Case**: Grand vistas, epic landscapes, wide open spaces

**Canvas Dimensions**:
- **Width**: 7680 pixels (4× base viewport width)
- **Height**: 3240 pixels (3× base viewport height)
- **Aspect Ratio**: 2.37:1 (Ultra-wide cinematic)

**Camera Settings**:
- Zoom: 0.3× (player appears small, world feels massive)
- Center Position: (1920, 540) from left edge

**Visual Coverage**:
- Player sees ~6400px wide at 0.3× zoom
- Background extends beyond visible area for camera movement

**Export Settings**:
```
Format: PNG (with transparency if needed)
Resolution: 7680 × 3240 px
Color Depth: 32-bit RGBA
File Name: bg_far_[description].png
Example: bg_far_mountain_vista.png
```

**Godot Import Path**:
```
res://assets/art/environment/backgrounds/bg_far_[description].png
```

---

### 2. RoomTemplate_Mid (Platform Scale)

**Use Case**: Standard platforming sections, mid-range exploration

**Canvas Dimensions**:
- **Width**: 3840 pixels (2× base viewport width, standard 4K width)
- **Height**: 2160 pixels (2× base viewport height, standard 4K height)
- **Aspect Ratio**: 16:9 (Standard widescreen)

**Camera Settings**:
- Zoom: 0.8× (slightly zoomed out)
- Center Position: (960, 540) from left edge

**Visual Coverage**:
- Player sees ~2400px wide at 0.8× zoom
- 4K resolution - excellent for high-detail backgrounds

**Export Settings**:
```
Format: PNG (with transparency if needed)
Resolution: 3840 × 2160 px (4K UHD)
Color Depth: 32-bit RGBA
File Name: bg_mid_[description].png
Example: bg_mid_forest_ruins.png
```

**Godot Import Path**:
```
res://assets/art/environment/backgrounds/bg_mid_[description].png
```

---

### 3. RoomTemplate_Close (Puzzle Scale)

**Use Case**: Puzzle rooms, confined spaces, detailed interactions

**Canvas Dimensions**:
- **Width**: 2560 pixels (1.33× base viewport width)
- **Height**: 2160 pixels (2× base viewport height)
- **Aspect Ratio**: 1.19:1 (Slightly wider than square)

**Camera Settings**:
- Zoom: 1.2× (zoomed in, player appears larger)
- Center Position: (640, 540) from left edge

**Visual Coverage**:
- Player sees ~1600px wide at 1.2× zoom
- Vertical emphasis for vertical platforming/puzzles

**Export Settings**:
```
Format: PNG (with transparency if needed)
Resolution: 2560 × 2160 px
Color Depth: 32-bit RGBA
File Name: bg_close_[description].png
Example: bg_close_puzzle_chamber.png
```

**Godot Import Path**:
```
res://assets/art/environment/backgrounds/bg_close_[description].png
```

---

### 4. RoomTemplate_Intimate (Emotional Scale)

**Use Case**: Emotional moments, character-focused scenes, tight spaces

**Canvas Dimensions**:
- **Width**: 1920 pixels (Exactly 1× base viewport width)
- **Height**: 2160 pixels (2× base viewport height)
- **Aspect Ratio**: 8:9 (Portrait-ish, vertical emphasis)

**Camera Settings**:
- Zoom: 1.5× (very close, player fills screen)
- Center Position: (480, 540) from left edge

**Visual Coverage**:
- Player sees ~1280px wide at 1.5× zoom
- Very intimate framing, player is the focus
- Tall canvas for vertical composition

**Export Settings**:
```
Format: PNG (with transparency if needed)
Resolution: 1920 × 2160 px
Color Depth: 32-bit RGBA
File Name: bg_intimate_[description].png
Example: bg_intimate_memory_shrine.png
```

**Godot Import Path**:
```
res://assets/art/environment/backgrounds/bg_intimate_[description].png
```

---

## Art Direction Guidelines

### Color Palette
Following the **GRIS aesthetic** (see [03_art_pipeline.md](file:///Users/mishal/Documents/teal-eyes/_context/03_art_pipeline.md)):
- Watercolor style with soft gradients
- Muted, desaturated tones
- Avoid banding (Enable debanding in Godot)

### Layer Separation
If backgrounds have multiple depth layers, export as separate files:

**Naming Convention**:
```
bg_[scale]_[description]_[layer].png

Examples:
bg_far_mountain_vista_sky.png       (z-index: -50, parallax 0.0)
bg_far_mountain_vista_distant.png   (z-index: -25, parallax 0.5)
bg_far_mountain_vista_midground.png (z-index: -10, parallax 0.8)
bg_far_mountain_vista_foreground.png (z-index: 5, parallax 1.1)
```

### Godot Import Settings

**Once backgrounds are created**:

1. **Import as Texture2D**:
   - Filter: Linear ✅ (smooth scaling)
   - Mipmaps: Enabled ✅ (for zoom support)
   - Compression: Lossless (Preserve quality)

2. **In Scene Setup**:
   - Replace `BackgroundPlaceholder` ColorRect node with Sprite2D
   - Set texture to imported background
   - Set `centered = false`
   - Set `offset` to match ColorRect offsets exactly

3. **Parallax Setup** (if multi-layer):
   - Use ParallaxBackground with ParallaxLayer nodes
   - Set `motion_scale` according to [02_tech_specs.md](file:///Users/mishal/Documents/teal-eyes/_context/02_tech_specs.md#L64-L75)

---

## Quick Reference: Current Placeholder Positions

### RoomTemplate_Far
```gdscript
[node name="BackgroundPlaceholder" type="ColorRect"]
offset_left = -1920.0
offset_top = -1080.0
offset_right = 5760.0
offset_bottom = 2160.0
```

### RoomTemplate_Mid
```gdscript
[node name="BackgroundPlaceholder" type="ColorRect"]
offset_left = -960.0
offset_top = -540.0
offset_right = 2880.0
offset_bottom = 1620.0
```

### RoomTemplate_Close
```gdscript
[node name="BackgroundPlaceholder" type="ColorRect"]
offset_left = -640.0
offset_top = -540.0
offset_right = 1920.0
offset_bottom = 1620.0
```

### RoomTemplate_Intimate
```gdscript
[node name="BackgroundPlaceholder" type="ColorRect"]
offset_left = -480.0
offset_top = -540.0
offset_right = 1440.0
offset_bottom = 1620.0
```

> [!IMPORTANT]
> **To replace backgrounds**: Create Sprite2D with `offset` set to `(offset_left, offset_top)` and texture region matching the width/height. The backgrounds will align perfectly with no scene modifications needed.

---

## Designer Workflow

### 1. Create Backgrounds
- Use dimensions from the table above
- Export as PNG with transparency (if needed)
- Use consistent naming convention

### 2. Deliver Files
Place files in:
```
/Users/mishal/Documents/teal-eyes/assets/art/environment/backgrounds/
```

### 3. Developer Integration Steps
1. Import PNGs into Godot (auto-imports)
2. Open room template scene
3. Replace ColorRect with Sprite2D
4. Set texture property to the new background
5. Match offsets to ColorRect positions
6. Done! No dimension changes needed.

---

## Example Assets (If Needed)

If you need placeholder textures for testing, you can generate them with:
```
Width × Height, centered text with room name
Example: "7680×3240 - Epic Vista Background"
```
