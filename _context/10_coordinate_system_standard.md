# Coordinate System Standard - Ground-Level Origin

> **Purpose**: Define the standard coordinate system for all room templates and level design  
> **Status**: ✅ IMPLEMENTED (2026-01-03)  
> **Applies to**: All RoomTemplate scenes and level layouts

---

## Core Principle

**Floor = y=0 (Ground Level)**

All room templates use a ground-level origin system where:
- The floor/ground is positioned at **y=0**
- Positive Y values go **downward** (below ground)
- Negative Y values go **upward** (above ground, into the sky)
- The camera looks **down from above** (negative Y position)

This creates a predictable, decoupled system where camera framing and floor collision are independent.

---

## Standard Specifications

### RoomTemplate_Far (Epic Scale)

**Canvas**: 7680 × 3240 px  
**Zoom**: 0.3× (player appears small, world feels massive)

| Element | Position | Notes |
|---------|----------|-------|
| Floor | `(3840, 0)` | Centered horizontally, at ground level |
| PhantomCamera2D | `(3840, -900)` | 900px above ground, centered |
| Background | `-3840` to `3840` (X)<br>`-2160` to `1080` (Y) | Centered, extends up/down |

**Player spawn example**: `(3840, -200)` = 200px above ground, centered

---

### RoomTemplate_Mid (Platform Scale)

**Canvas**: 3840 × 2160 px  
**Zoom**: 0.8× (slightly zoomed out)

| Element | Position | Notes |
|---------|----------|-------|
| Floor | `(1920, 0)` | Centered horizontally, at ground level |
| PhantomCamera2D | `(1920, -675)` | 675px above ground |
| Background | `-1920` to `1920` (X)<br>`-1350` to `810` (Y) | Centered, extends up/down |

---

### RoomTemplate_Close (Puzzle Scale)

**Canvas**: 2560 × 2160 px  
**Zoom**: 1.2× (zoomed in, closer framing)

| Element | Position | Notes |
|---------|----------|-------|
| Floor | `(1280, 0)` | Centered horizontally, at ground level |
| PhantomCamera2D | `(1280, -450)` | 450px above ground |
| Background | `-1280` to `1280` (X)<br>`-900` to `900` (Y) | Centered symmetrically |

---

### RoomTemplate_Intimate (Emotional Scale)

**Canvas**: 1920 × 2160 px  
**Zoom**: 1.5× (very close, player fills screen)

| Element | Position | Notes |
|---------|----------|-------|
| Floor | `(960, 0)` | Centered horizontally, at ground level |
| PhantomCamera2D | `(960, -360)` | 360px above ground |
| Background | `-960` to `960` (X)<br>`-720` to `720` (Y) | Centered symmetrically |

---

## Room Positioning in Levels

When placing rooms side-by-side in a level (e.g., Level01.tscn), position them horizontally using their **canvas width**:

```gdscript
[node name="Room01_Epic" parent="Rooms"]
position = Vector2(0, 0)  # First room at origin

[node name="Room02_Platform" parent="Rooms"]
position = Vector2(7680, 0)  # 7680px = Room01's width

[node name="Room03_Puzzle" parent="Rooms"]
position = Vector2(11520, 0)  # 7680 + 3840 = cumulative width

[node name="Room04_Emotional" parent="Rooms"]
position = Vector2(13440, 0)  # 7680 + 3840 + 1920
```

**Key principle**: Rooms are **horizontally offset only** (Y=0 always). Their internal floors all align at ground level.

---

## Player Spawn Guidelines

Player should spawn **above ground** (negative Y):

```gdscript
# Good examples:
position = Vector2(3840, -200)  # 200px above ground (standard)
position = Vector2(1920, -150)  # 150px above ground (tight space)

# Bad examples:
position = Vector2(3840, 0)     # ❌ Spawns inside the floor
position = Vector2(3840, 500)   # ❌ Spawns underground
```

**Standard height**: `-200` (200px above ground) for normal spawns.

---

## Camera Positioning Formula

To maintain proper framing, the camera should be positioned based on:

```
camera_y = -(viewport_height_at_zoom / 3)
```

This puts the floor in the **lower third** of the screen (classic platformer composition).

**Examples**:
- At 0.3× zoom: viewport ≈ 3600px tall → camera at `y = -900`
- At 0.8× zoom: viewport ≈ 1350px tall → camera at `y = -675` (math: 1350/2 = 675)
- At 1.2× zoom: viewport ≈ 900px tall → camera at `y = -450`
- At 1.5× zoom: viewport ≈ 720px tall → camera at `y = -360`

---

## Benefits of This System

✅ **Decoupled**: Camera and floor positions are independent  
✅ **Intuitive**: Ground = 0, everything relative  
✅ **Consistent**: Same logic across all room templates  
✅ **Scalable**: Easy to adjust camera framing without touching collision  
✅ **Designer-Friendly**: Clear numbers, no arbitrary values  

---

## Migration Notes

**Previous system** (before 2026-01-03):
- Floor at `y=900` (arbitrary middle position)
- Camera at `y=540` (arbitrary)
- Tightly coupled - moving floor broke camera framing

**New system** (after 2026-01-03):
- Floor at `y=0` (ground level)
- Camera at negative Y (above ground)
- Decoupled - floor and camera are independent

All existing room templates have been migrated to this system.
